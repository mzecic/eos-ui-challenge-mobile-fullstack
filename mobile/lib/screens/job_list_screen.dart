import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../cubits/jobs_cubit.dart';
import '../models/job_summary.dart';
import 'job_detail_screen.dart';

/// Displays a filterable list of job summaries.
class JobListScreen extends StatefulWidget {
  const JobListScreen({super.key});

  @override
  State<JobListScreen> createState() => _JobListScreenState();
}

class _JobListScreenState extends State<JobListScreen> {
  @override
  void initState() {
    super.initState();
    // Populate the region filter and the jobs list independently.
    final cubit = context.read<JobsCubit>();
    cubit.loadRegions();
    cubit.loadJobs();
  }

  void _reload() {
    final cubit = context.read<JobsCubit>();
    cubit.loadRegions();
    cubit.loadJobs();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Job Summary')),
      body: BlocBuilder<JobsCubit, JobsState>(
        builder: (context, state) {
          return switch (state) {
            JobsInitial() ||
            JobsLoading() =>
              const Center(child: CircularProgressIndicator()),
            JobsError(:final message) =>
              _ErrorView(message: message, onRetry: _reload),
            JobsLoaded(
              :final jobs,
              :final regions,
              :final selectedRegion,
            ) =>
              _JobsView(
                jobs: jobs,
                regions: regions,
                selectedRegion: selectedRegion,
                onRegionChanged: (region) =>
                    context.read<JobsCubit>().loadJobs(region: region),
              ),
          };
        },
      ),
    );
  }
}

class _JobsView extends StatelessWidget {
  final List<JobSummary> jobs;
  final List<String> regions;
  final String? selectedRegion;
  final ValueChanged<String?> onRegionChanged;

  const _JobsView({
    required this.jobs,
    required this.regions,
    required this.selectedRegion,
    required this.onRegionChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _RegionFilter(
          regions: regions,
          selected: selectedRegion,
          onChanged: onRegionChanged,
        ),
        const Divider(height: 1),
        Expanded(
          child: jobs.isEmpty
              ? const Center(child: Text('No jobs match this filter.'))
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  itemCount: jobs.length,
                  itemBuilder: (context, index) => _JobCard(job: jobs[index]),
                ),
        ),
      ],
    );
  }
}

class _RegionFilter extends StatelessWidget {
  final List<String> regions;
  final String? selected;
  final ValueChanged<String?> onChanged;

  const _RegionFilter({
    required this.regions,
    required this.selected,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      child: Row(
        children: [
          const Icon(Icons.filter_list),
          const SizedBox(width: 12),
          Expanded(
            child: DropdownButton<String?>(
              value: selected,
              isExpanded: true,
              underline: const SizedBox.shrink(),
              hint: const Text('All regions'),
              items: [
                const DropdownMenuItem<String?>(
                  value: null,
                  child: Text('All regions'),
                ),
                for (final region in regions)
                  DropdownMenuItem<String?>(
                    value: region,
                    child: Text(region),
                  ),
              ],
              onChanged: onChanged,
            ),
          ),
        ],
      ),
    );
  }
}

class _JobCard extends StatelessWidget {
  final JobSummary job;

  const _JobCard({required this.job});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: InkWell(
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => JobDetailScreen(jobId: job.jobId),
          ),
        ),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      job.padName,
                      style: theme.textTheme.titleMedium,
                    ),
                  ),
                  _StatusChip(status: job.statusName),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                job.regionName,
                style: theme.textTheme.bodySmall
                    ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: job.percentComplete / 100,
                        minHeight: 6,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    '${job.percentComplete}%',
                    style: theme.textTheme.labelLarge,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  final String status;

  const _StatusChip({required this.status});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final (bg, fg) = switch (status.toLowerCase()) {
      'active' => (scheme.primaryContainer, scheme.onPrimaryContainer),
      'complete' => (scheme.tertiaryContainer, scheme.onTertiaryContainer),
      'on hold' => (scheme.errorContainer, scheme.onErrorContainer),
      _ => (scheme.surfaceContainerHighest, scheme.onSurfaceVariant),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status,
        style: Theme.of(context)
            .textTheme
            .labelSmall
            ?.copyWith(color: fg, fontWeight: FontWeight.w600),
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorView({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline,
                size: 48, color: Theme.of(context).colorScheme.error),
            const SizedBox(height: 16),
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            FilledButton.tonal(
              onPressed: onRetry,
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}
