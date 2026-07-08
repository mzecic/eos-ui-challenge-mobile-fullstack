import 'package:flutter/material.dart';

import '../models/job_summary.dart';
import '../services/job_service.dart';

/// Displays the full details for a single job.
class JobDetailScreen extends StatefulWidget {
  final String jobId;

  const JobDetailScreen({super.key, required this.jobId});

  @override
  State<JobDetailScreen> createState() => _JobDetailScreenState();
}

class _JobDetailScreenState extends State<JobDetailScreen> {
  final _service = JobService();
  late Future<JobSummary> _future;

  @override
  void initState() {
    super.initState();
    _future = _service.getJob(widget.jobId);
  }

  void _retry() {
    setState(() {
      _future = _service.getJob(widget.jobId);
    });
  }

  @override
  void dispose() {
    _service.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Job Detail')),
      body: FutureBuilder<JobSummary>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return _DetailError(
              message: snapshot.error.toString(),
              onRetry: _retry,
            );
          }
          return _JobDetailBody(job: snapshot.data!);
        },
      ),
    );
  }
}

class _JobDetailBody extends StatelessWidget {
  final JobSummary job;

  const _JobDetailBody({required this.job});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Text(job.padName, style: theme.textTheme.headlineSmall),
        const SizedBox(height: 24),
        _DetailRow(label: 'Job ID', value: job.jobId),
        _DetailRow(label: 'Status', value: job.statusName),
        _DetailRow(label: 'Region', value: job.regionName),
        _DetailRow(label: 'Plan start date', value: job.planStartDate),
        _DetailRow(label: 'Days planned', value: '${job.daysPlanned}'),
        _DetailRow(label: 'Percent complete', value: '${job.percentComplete}%'),
        const SizedBox(height: 16),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: job.percentComplete / 100,
            minHeight: 8,
          ),
        ),
      ],
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;

  const _DetailRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
            child: Text(
              label,
              style: theme.textTheme.bodyMedium
                  ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
            ),
          ),
          Expanded(
            child: Text(value, style: theme.textTheme.bodyLarge),
          ),
        ],
      ),
    );
  }
}

class _DetailError extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _DetailError({required this.message, required this.onRetry});

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
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                OutlinedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Back'),
                ),
                const SizedBox(width: 12),
                FilledButton.tonal(
                  onPressed: onRetry,
                  child: const Text('Retry'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
