import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/cubits/jobs_cubit.dart';
import 'package:mobile/screens/job_list_screen.dart';

import 'support/fake_job_service.dart';

void main() {
  Widget wrap(FakeJobService service) => MaterialApp(
        home: BlocProvider(
          create: (_) => JobsCubit(service),
          child: const JobListScreen(),
        ),
      );

  testWidgets('renders a card for each job', (tester) async {
    await tester.pumpWidget(wrap(
      FakeJobService(
        jobs: const [jobPermian, jobEagleFord],
        regions: const ['Eagle Ford', 'Permian'],
      ),
    ));
    await tester.pumpAndSettle();

    expect(find.text('Permian Basin Alpha'), findsOneWidget);
    expect(find.text('Eagle Ford Beta'), findsOneWidget);
  });

  testWidgets('selecting a region triggers a filtered reload', (tester) async {
    final service = FakeJobService(
      jobs: const [jobPermian, jobEagleFord],
      regions: const ['Eagle Ford', 'Permian'],
    );
    await tester.pumpWidget(wrap(service));
    await tester.pumpAndSettle();

    // Initial load fetched all jobs (no region filter).
    expect(service.getJobsCalls, 1);
    expect(find.text('Eagle Ford Beta'), findsOneWidget);

    // Open the region dropdown and choose "Permian".
    await tester.tap(find.byType(DropdownButton<String?>));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Permian').last);
    await tester.pumpAndSettle();

    // The cubit reloaded jobs filtered by the selected region.
    expect(service.getJobsCalls, 2);
    expect(service.lastRegion, 'Permian');
    expect(find.text('Permian Basin Alpha'), findsOneWidget);
    expect(find.text('Eagle Ford Beta'), findsNothing);
  });

  testWidgets('shows an error state with a retry button on failure',
      (tester) async {
    await tester.pumpWidget(wrap(FakeJobService(failJobs: true)));
    await tester.pumpAndSettle();

    expect(find.text('Failed to load jobs.'), findsOneWidget);
    expect(find.widgetWithText(FilledButton, 'Retry'), findsOneWidget);
  });
}
