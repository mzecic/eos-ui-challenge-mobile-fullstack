import 'package:flutter_bloc/flutter_bloc.dart';

import '../models/job_summary.dart';
import '../services/job_service.dart';

part 'jobs_state.dart';

class JobsCubit extends Cubit<JobsState> {
  final JobService _service;

  // Filter context kept on the cubit so it survives across job reloads and can
  // be populated by [loadRegions] independently of [loadJobs].
  List<String> _regions = const [];
  String? _selectedRegion;

  JobsCubit(this._service) : super(const JobsInitial());

  /// Load all jobs, optionally filtered by [region].
  ///
  /// Emits [JobsLoading], then [JobsLoaded] on success or [JobsError] on
  /// failure. The current region list is carried into [JobsLoaded] so the
  /// filter dropdown stays populated.
  Future<void> loadJobs({String? region}) async {
    _selectedRegion = region;
    emit(const JobsLoading());
    try {
      final jobs = await _service.getJobs(region: region);
      emit(JobsLoaded(
        jobs: jobs,
        regions: _regions,
        selectedRegion: _selectedRegion,
      ));
    } catch (e) {
      emit(JobsError(_messageFor(e)));
    }
  }

  /// Load the list of available region names.
  ///
  /// Callable independently of [loadJobs] so the filter can be populated before
  /// (or in parallel with) the first job fetch. If jobs are already displayed,
  /// re-emits [JobsLoaded] so the newly available regions appear in the filter.
  Future<void> loadRegions() async {
    try {
      _regions = await _service.getRegions();
      final current = state;
      if (current is JobsLoaded) {
        emit(JobsLoaded(
          jobs: current.jobs,
          regions: _regions,
          selectedRegion: _selectedRegion,
        ));
      }
    } catch (e) {
      emit(JobsError(_messageFor(e)));
    }
  }

  String _messageFor(Object error) {
    if (error is JobServiceException) return error.message;
    return 'Something went wrong. Please try again.';
  }
}
