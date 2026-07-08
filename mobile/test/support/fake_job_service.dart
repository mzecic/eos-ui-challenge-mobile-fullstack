import 'package:mobile/models/job_summary.dart';
import 'package:mobile/services/job_service.dart';

/// In-memory [JobService] stand-in for tests. Filters by region the same way
/// the backend does, and records calls so tests can assert on reload behavior.
class FakeJobService implements JobService {
  final List<JobSummary> jobs;
  final List<String> regions;
  final bool failJobs;
  final bool failRegions;

  int getJobsCalls = 0;
  String? lastRegion;

  FakeJobService({
    this.jobs = const [],
    this.regions = const [],
    this.failJobs = false,
    this.failRegions = false,
  });

  @override
  String get baseUrl => 'fake://test';

  @override
  Future<List<JobSummary>> getJobs({String? region, String? status}) async {
    getJobsCalls++;
    lastRegion = region;
    if (failJobs) throw JobServiceException('Failed to load jobs.');
    return jobs.where((j) {
      final regionOk =
          region == null || j.regionName.toLowerCase() == region.toLowerCase();
      final statusOk =
          status == null || j.statusName.toLowerCase() == status.toLowerCase();
      return regionOk && statusOk;
    }).toList();
  }

  @override
  Future<List<String>> getRegions() async {
    if (failRegions) throw JobServiceException('Failed to load regions.');
    return regions;
  }

  @override
  Future<JobSummary> getJob(String jobId) async {
    final match = jobs.where((j) => j.jobId == jobId);
    if (match.isEmpty) throw JobServiceException('Not found', 404);
    return match.first;
  }

  @override
  void dispose() {}
}

/// A couple of fixtures used across tests.
const jobPermian = JobSummary(
  jobId: 'job-001',
  padName: 'Permian Basin Alpha',
  statusName: 'Active',
  regionName: 'Permian',
  planStartDate: '2025-03-01',
  daysPlanned: 45,
  percentComplete: 62,
);

const jobEagleFord = JobSummary(
  jobId: 'job-002',
  padName: 'Eagle Ford Beta',
  statusName: 'Planned',
  regionName: 'Eagle Ford',
  planStartDate: '2025-04-15',
  daysPlanned: 30,
  percentComplete: 0,
);
