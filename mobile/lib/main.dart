import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'cubits/jobs_cubit.dart';
import 'screens/job_list_screen.dart';
import 'services/job_service.dart';

void main() {
  runApp(const EosApp());
}

class EosApp extends StatelessWidget {
  const EosApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => JobsCubit(JobService()),
      child: MaterialApp(
        title: 'EOS Job Summary',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF1565C0)),
          useMaterial3: true,
        ),
        home: const JobListScreen(),
      ),
    );
  }
}
