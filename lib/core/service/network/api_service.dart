// REUSABLE SERVICE: Retrofit API client template.
// REQUIRES: dio, retrofit packages in pubspec.yaml. Run build_runner after changes.
// CHANGE: Update `baseUrl` to your project's API base URL.
// CHANGE: Replace all endpoint methods with your project's API endpoints.
// CHANGE: Update response model imports to your project's models.
import 'package:dio/dio.dart';
import 'package:retrofit/error_logger.dart';
import 'package:retrofit/http.dart';
import 'package:chat_material3/core/app/upload_image/model/upload_image_response.dart'; // CHANGE: your model

part 'api_service.g.dart';

const baseUrl = "https://api.escuelajs.co/api/v1";

@RestApi(baseUrl: baseUrl)
abstract class ApiService {
  factory ApiService(Dio dio, {String baseUrl, ParseErrorLogger? errorLogger}) =
      _ApiService;

  @POST("https://api.escuelajs.co/api/v1/files/upload")
  Future<UploadImageResourse> uploadImage(@Body() FormData file);
}
