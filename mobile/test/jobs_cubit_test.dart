import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/cubits/jobs_cubit.dart';

import 'support/fake_job_service.dart';

void main() {
  group('JobsCubit', () {
    test('starts in JobsInitial', () {
      final cubit = JobsCubit(FakeJobService());
      expect(cubit.state, isA<JobsInitial>());
      cubit.close();
    });

    test('loadJobs emits [JobsLoading, JobsLoaded] on success', () async {
      final cubit = JobsCubit(
        FakeJobService(jobs: const [jobPermian, jobEagleFord]),
      );

      expectLater(
        cubit.stream,
        emitsInOrder([isA<JobsLoading>(), isA<JobsLoaded>()]),
      );

      await cubit.loadJobs();
      expect((cubit.state as JobsLoaded).jobs, hasLength(2));
      await cubit.close();
    });

    test('loadJobs emits [JobsLoading, JobsError] on failure', () async {
      final cubit = JobsCubit(FakeJobService(failJobs: true));

      expectLater(
        cubit.stream,
        emitsInOrder([isA<JobsLoading>(), isA<JobsError>()]),
      );

      await cubit.loadJobs();
      expect((cubit.state as JobsError).message, 'Failed to load jobs.');
      await cubit.close();
    });

    test('loadJobs forwards the region filter to the service', () async {
      final fake = FakeJobService(jobs: const [jobPermian, jobEagleFord]);
      final cubit = JobsCubit(fake);

      await cubit.loadJobs(region: 'Permian');

      expect(fake.lastRegion, 'Permian');
      final state = cubit.state as JobsLoaded;
      expect(state.jobs.single.jobId, 'job-001');
      expect(state.selectedRegion, 'Permian');
      await cubit.close();
    });

    test('regions load independently and appear in the loaded state', () async {
      final cubit = JobsCubit(
        FakeJobService(
          jobs: const [jobPermian, jobEagleFord],
          regions: const ['Eagle Ford', 'Permian'],
        ),
      );

      // Populate regions first, then jobs — the loaded state carries both.
      await cubit.loadRegions();
      await cubit.loadJobs();

      final state = cubit.state as JobsLoaded;
      expect(state.regions, const ['Eagle Ford', 'Permian']);
      await cubit.close();
    });
  });
}
