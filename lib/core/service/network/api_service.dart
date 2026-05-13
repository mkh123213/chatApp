import 'package:dio/dio.dart';
import 'package:retrofit/error_logger.dart';
import 'package:retrofit/http.dart';
import 'package:chat_material3/core/app/upload_image/model/upload_image_response.dart';

part 'api_service.g.dart';

const baseUrl = "https://api.escuelajs.co/api/v1";

@RestApi(baseUrl: baseUrl)
abstract class ApiService {
  factory ApiService(Dio dio, {String baseUrl, ParseErrorLogger? errorLogger}) =
      _ApiService;

  @POST("https://api.escuelajs.co/api/v1/files/upload")
  Future<UploadImageResourse> uploadImage(@Body() FormData file);
}
