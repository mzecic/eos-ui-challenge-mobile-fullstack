import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/job_summary.dart';

// Base URL for the FastAPI backend.
// iOS Simulator / host machine:  http://localhost:8000/api
// Android Emulator:              http://10.0.2.2:8000/api
//   (the emulator routes 10.0.2.2 to the host loopback)
//
// Override at build/run time without editing code, e.g.:
//   flutter run --dart-define=API_BASE_URL=http://10.0.2.2:8000/api
const String _defaultBaseUrl = String.fromEnvironment(
  'API_BASE_URL',
  defaultValue: 'http://localhost:8000/api',
);

/// Thrown when the backend returns a non-200 response or is unreachable.
class JobServiceException implements Exception {
  final String message;
  final int? statusCode;

  JobServiceException(this.message, [this.statusCode]);

  @override
  String toString() =>
      statusCode == null ? message : '$message (HTTP $statusCode)';
}

class JobService {
  final String baseUrl;
  final http.Client _client;

  JobService({String? baseUrl, http.Client? client})
      : baseUrl = baseUrl ?? _defaultBaseUrl,
        _client = client ?? http.Client();

  /// Return all jobs, optionally filtered by [region] and/or [status].
  Future<List<JobSummary>> getJobs({String? region, String? status}) async {
    final params = <String, String>{
      'region': ?region,
      'status': ?status,
    };
    final uri = Uri.parse('$baseUrl/jobs')
        .replace(queryParameters: params.isEmpty ? null : params);

    final body = await _getJson(uri, 'jobs') as List<dynamic>;
    return body
        .map((e) => JobSummary.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// Return a sorted list of unique region names.
  Future<List<String>> getRegions() async {
    final uri = Uri.parse('$baseUrl/jobs/regions');
    final body = await _getJson(uri, 'regions') as List<dynamic>;
    return body.cast<String>();
  }

  /// Return a single job by [jobId]. Throws for non-200 responses (incl. 404).
  Future<JobSummary> getJob(String jobId) async {
    final uri = Uri.parse('$baseUrl/jobs/${Uri.encodeComponent(jobId)}');
    final body = await _getJson(uri, 'job') as Map<String, dynamic>;
    return JobSummary.fromJson(body);
  }

  /// Perform a GET and decode JSON, mapping transport and non-200 failures to a
  /// [JobServiceException] with a meaningful message.
  Future<dynamic> _getJson(Uri uri, String resource) async {
    final http.Response response;
    try {
      response = await _client.get(uri);
    } catch (e) {
      throw JobServiceException('Could not reach the server. Check your connection.');
    }

    if (response.statusCode == 404) {
      throw JobServiceException('The requested $resource was not found.', 404);
    }
    if (response.statusCode != 200) {
      throw JobServiceException(
        'Failed to load $resource.',
        response.statusCode,
      );
    }
    return jsonDecode(response.body);
  }

  /// Releases the underlying HTTP client. Call when the service is disposed.
  void dispose() => _client.close();
}
