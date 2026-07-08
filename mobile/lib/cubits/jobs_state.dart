part of 'jobs_cubit.dart';

/// Sealed state hierarchy for [JobsCubit].
///
/// [JobsInitial] and [JobsLoading] carry no data — the UI shows a spinner.
/// [JobsLoaded] carries the jobs list plus the region filter context (the
/// available regions and the currently selected one) so the filter control can
/// render and stay in sync across reloads. [JobsError] carries a message.
sealed class JobsState {
  const JobsState();
}

class JobsInitial extends JobsState {
  const JobsInitial();
}

class JobsLoading extends JobsState {
  const JobsLoading();
}

/// Jobs have been successfully loaded.
///
/// [regions] and [selectedRegion] describe the filter state so the list screen
/// can render the region dropdown without a separate state class.
class JobsLoaded extends JobsState {
  final List<JobSummary> jobs;
  final List<String> regions;
  final String? selectedRegion;

  const JobsLoaded({
    required this.jobs,
    this.regions = const [],
    this.selectedRegion,
  });
}

/// A request failed. [message] is a human-readable description for the UI.
class JobsError extends JobsState {
  final String message;

  const JobsError(this.message);
}
