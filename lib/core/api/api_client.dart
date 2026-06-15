import 'dart:convert';
import 'package:http/http.dart' as http;
import '../error/failures.dart';

/// A generic, robust HTTP Client for calling backend endpoints.
/// Supports GET, POST, PUT, and DELETE methods with integrated error handling.
class ApiClient {
  final String baseUrl;
  final http.Client _client;

  ApiClient({required this.baseUrl, http.Client? client})
    : _client = client ?? http.Client();

  /// Process standard response status and convert to Map/List or throw Server/Network Failures.
  dynamic _handleResponse(http.Response response) {
    final int statusCode = response.statusCode;
    if (statusCode >= 200 && statusCode < 300) {
      if (response.body.isEmpty) return null;
      return jsonDecode(response.body);
    } else {
      String errorMsg = 'Server responded with error status: $statusCode';
      try {
        final decoded = jsonDecode(response.body);
        if (decoded is Map) {
          if (decoded.containsKey('message')) {
            errorMsg = decoded['message'].toString();
          } else if (decoded.containsKey('error')) {
            errorMsg = decoded['error'].toString();
          }
        }
      } catch (_) {}
      throw ServerFailure(errorMsg);
    }
  }

  /// Prepare default headers with Content-Type and custom additions.
  Map<String, String> _getHeaders(Map<String, String>? extraHeaders) {
    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
    if (extraHeaders != null) {
      headers.addAll(extraHeaders);
    }
    return headers;
  }

  /// HTTP GET Method
  Future<dynamic> get(
    String endpoint, {
    Map<String, String>? queryParams,
    Map<String, String>? headers,
  }) async {
    try {
      var uri = Uri.parse('$baseUrl$endpoint');
      if (queryParams != null && queryParams.isNotEmpty) {
        uri = uri.replace(queryParameters: queryParams);
      }
      final response = await _client.get(uri, headers: _getHeaders(headers));
      return _handleResponse(response);
    } on http.ClientException catch (e) {
      throw NetworkFailure('Connection failed: ${e.message}');
    } catch (e) {
      if (e is Failure) rethrow;
      throw UnknownFailure(e.toString());
    }
  }

  /// Upload image using Multipart GET (specifically required by backend API)
  Future<dynamic> uploadImageMultipartGet(
    String endpoint, {
    required String filePath,
    required String fileKey,
    Map<String, String>? queryParams,
    Map<String, String>? headers,
  }) async {
    try {
      var uri = Uri.parse('$baseUrl$endpoint');
      if (queryParams != null && queryParams.isNotEmpty) {
        uri = uri.replace(queryParameters: queryParams);
      }
      final request = http.MultipartRequest('GET', uri);
      if (headers != null) {
        request.headers.addAll(headers);
      }
      if (!request.headers.containsKey('Accept')) {
        request.headers['Accept'] = 'application/json';
      }
      request.files.add(await http.MultipartFile.fromPath(fileKey, filePath));
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);
      print("response^^^^^^^^^^^^^^^^^^$response");
      return _handleResponse(response);
    } on http.ClientException catch (e) {
      throw NetworkFailure('Connection failed: ${e.message}');
    } catch (e) {
      print("^^^^^^^^^^^^^^^^^^$e");
      if (e is Failure) rethrow;
      throw UnknownFailure(e.toString());
    }
  }

  /// HTTP POST Method
  Future<dynamic> post(
    String endpoint, {
    dynamic body,
    Map<String, String>? headers,
  }) async {
    try {
      final uri = Uri.parse('$baseUrl$endpoint');
      final response = await _client.post(
        uri,
        headers: _getHeaders(headers),
        body: body != null ? jsonEncode(body) : null,
      );
      return _handleResponse(response);
    } on http.ClientException catch (e) {
      throw NetworkFailure('Connection failed: ${e.message}');
    } catch (e) {
      if (e is Failure) rethrow;
      throw UnknownFailure(e.toString());
    }
  }

  /// HTTP PUT Method
  Future<dynamic> put(
    String endpoint, {
    dynamic body,
    Map<String, String>? headers,
  }) async {
    try {
      final uri = Uri.parse('$baseUrl$endpoint');
      final response = await _client.put(
        uri,
        headers: _getHeaders(headers),
        body: body != null ? jsonEncode(body) : null,
      );
      return _handleResponse(response);
    } on http.ClientException catch (e) {
      throw NetworkFailure('Connection failed: ${e.message}');
    } catch (e) {
      if (e is Failure) rethrow;
      throw UnknownFailure(e.toString());
    }
  }

  /// HTTP DELETE Method
  Future<dynamic> delete(
    String endpoint, {
    Map<String, String>? headers,
  }) async {
    try {
      final uri = Uri.parse('$baseUrl$endpoint');
      final response = await _client.delete(uri, headers: _getHeaders(headers));
      return _handleResponse(response);
    } on http.ClientException catch (e) {
      throw NetworkFailure('Connection failed: ${e.message}');
    } catch (e) {
      if (e is Failure) rethrow;
      throw UnknownFailure(e.toString());
    }
  }
}
