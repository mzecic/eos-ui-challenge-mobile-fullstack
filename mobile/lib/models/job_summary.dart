// Do not modify this file.

class JobSummary {
  final String jobId;
  final String padName;
  final String statusName;
  final String regionName;
  final String planStartDate;
  final int daysPlanned;
  final int percentComplete;

  const JobSummary({
    required this.jobId,
    required this.padName,
    required this.statusName,
    required this.regionName,
    required this.planStartDate,
    required this.daysPlanned,
    required this.percentComplete,
  });

  factory JobSummary.fromJson(Map<String, dynamic> json) => JobSummary(
        jobId: json['job_id'] as String,
        padName: json['pad_name'] as String,
        statusName: json['status_name'] as String,
        regionName: json['region_name'] as String,
        planStartDate: json['plan_start_date'] as String,
        daysPlanned: json['days_planned'] as int,
        percentComplete: json['percent_complete'] as int,
      );
}
