import 'dart:io';

import 'package:chat_material3/core/service/network/api_result.dart';
import 'package:chat_material3/core/service/supabase/supabase_storage_service.dart';
import 'package:image_picker/image_picker.dart';
import 'package:chat_material3/core/app/upload_image/data_source/upload_image_data_source.dart';
import 'package:chat_material3/core/app/upload_image/model/upload_image_response.dart';

class UploadImageRepo {
  const UploadImageRepo(this._dataSource);

  final UploadImageDataSource _dataSource;
  Future<ApiResult<UploadedFileData>> uploadImage({
    required File image,
  }) async {
    try {
      final result = await _dataSource.uploadImage(image: image);
      return ApiResult.success(result);
    } catch (e) {
      return ApiResult.failure("Can't upload image $e");
    }
  }
}
