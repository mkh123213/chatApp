import 'dart:io';

import 'package:chat_material3/core/helper_functions/get_current_user.dart';
import 'package:chat_material3/core/service/network/api_service.dart';
import 'package:chat_material3/core/service/supabase/supabase_storage_service.dart';
import 'package:dio/dio.dart';
import 'package:image_picker/image_picker.dart';
import 'package:chat_material3/core/app/upload_image/model/upload_image_response.dart';

class UploadImageDataSource {
  const UploadImageDataSource(this.supabaseClient);

  final SupabaseStorageService supabaseClient;

  Future<UploadedFileData> uploadImage({required File image}) async {
    final fromData = FormData();

    fromData.files.add(
      MapEntry('file', await MultipartFile.fromFile(image.path)),
    );

    final response = await supabaseClient.uploadImage(
      file: image,
      folderName: "chat_images",
      ownerId: getCurrentUser().uid,
      upsert: true,
    );

    return response;
  }
}
