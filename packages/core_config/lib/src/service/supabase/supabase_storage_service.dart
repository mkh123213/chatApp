// REUSABLE SERVICE: Supabase Storage file upload/download wrapper.
// REQUIRES: supabase_flutter, path packages in pubspec.yaml
// CHANGE: Update `bucketName` to your Supabase storage bucket name.
// CHANGE: Add/remove upload methods to match your project's file types (e.g., remove chat/group/status methods if not needed).
import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseStorageService {
  SupabaseStorageService({
    SupabaseClient? client,
  }) : _client = client ?? Supabase.instance.client;

  final SupabaseClient _client;

  static const String bucketName = 'chatapp';

  String _cleanPathPart(String value) {
    return value
        .trim()
        .replaceAll(RegExp(r'[^\w.\-]'), '_')
        .replaceAll(RegExp(r'_+'), '_');
  }

  String _safeExtension(String filePath) {
    final extension = p.extension(filePath).toLowerCase();
    if (extension.isEmpty) return '.jpg';
    return extension;
  }

  Future<UploadedFileData> uploadGroupImage({
    required String groupId,
    required File file,
  }) async {
    final cleanGroupId = _cleanPathPart(groupId);

    if (cleanGroupId.isEmpty) {
      throw Exception('Group id is empty. Cannot upload group image.');
    }

    final extension = _safeExtension(file.path);
    final fileName = '${DateTime.now().millisecondsSinceEpoch}$extension';

    final storagePath = 'groups/$cleanGroupId/image/$fileName';

    await _client.storage.from(bucketName).upload(
          storagePath,
          file,
          fileOptions: const FileOptions(
            cacheControl: '3600',
            upsert: true,
          ),
        );

    final publicUrl =
        _client.storage.from(bucketName).getPublicUrl(storagePath);

    return UploadedFileData(
      url: publicUrl,
      storagePath: storagePath,
      fileName: fileName,
    );
  }

  Future<UploadedFileData> uploadMessageImage({
    required String groupId,
    required File file,
  }) async {
    final cleanGroupId = _cleanPathPart(groupId);

    if (cleanGroupId.isEmpty) {
      throw Exception('Group id is empty. Cannot upload message image.');
    }

    final extension = _safeExtension(file.path);
    final fileName = '${DateTime.now().millisecondsSinceEpoch}$extension';

    final storagePath = 'groups/$cleanGroupId/messages/images/$fileName';

    await _client.storage.from(bucketName).upload(
          storagePath,
          file,
          fileOptions: const FileOptions(
            cacheControl: '3600',
            upsert: false,
          ),
        );

    final publicUrl =
        _client.storage.from(bucketName).getPublicUrl(storagePath);

    return UploadedFileData(
      url: publicUrl,
      storagePath: storagePath,
      fileName: fileName,
    );
  }

  Future<UploadedFileData> uploadMessageFile({
    required String groupId,
    required File file,
    required String originalFileName,
  }) async {
    final cleanGroupId = _cleanPathPart(groupId);

    if (cleanGroupId.isEmpty) {
      throw Exception('Group id is empty. Cannot upload message file.');
    }

    final safeName = _cleanPathPart(originalFileName);
    final fileName = '${DateTime.now().millisecondsSinceEpoch}_$safeName';

    final storagePath = 'groups/$cleanGroupId/messages/files/$fileName';

    await _client.storage.from(bucketName).upload(
          storagePath,
          file,
          fileOptions: const FileOptions(
            cacheControl: '3600',
            upsert: false,
          ),
        );

    final publicUrl =
        _client.storage.from(bucketName).getPublicUrl(storagePath);

    return UploadedFileData(
      url: publicUrl,
      storagePath: storagePath,
      fileName: originalFileName,
    );
  }

  Future<UploadedFileData> uploadImage({
    required File file,
    String folderName = 'images',
    String? ownerId,
    bool upsert = false,
  }) async {
    final cleanFolderName = _cleanPathPart(folderName);
    final cleanOwnerId = ownerId == null ? null : _cleanPathPart(ownerId);

    if (cleanFolderName.isEmpty) {
      throw Exception('Folder name is empty. Cannot upload image.');
    }

    final extension = _safeExtension(file.path);
    final fileName = '${DateTime.now().millisecondsSinceEpoch}$extension';

    final storagePath = cleanOwnerId == null || cleanOwnerId.isEmpty
        ? '$cleanFolderName/$fileName'
        : '$cleanFolderName/$cleanOwnerId/$fileName';

    await _client.storage.from(bucketName).upload(
          storagePath,
          file,
          fileOptions: FileOptions(
            cacheControl: '3600',
            upsert: upsert,
          ),
        );

    final publicUrl =
        _client.storage.from(bucketName).getPublicUrl(storagePath);

    return UploadedFileData(
      url: publicUrl,
      storagePath: storagePath,
      fileName: fileName,
    );
  }

  Future<UploadedFileData> uploadChatImage({
    required String chatId,
    required File file,
  }) async {
    final cleanChatId = _cleanPathPart(chatId);
    if (cleanChatId.isEmpty) {
      throw Exception('Chat id is empty. Cannot upload chat image.');
    }
    final extension = _safeExtension(file.path);
    final fileName = '${DateTime.now().millisecondsSinceEpoch}$extension';
    final storagePath = 'chats/$cleanChatId/messages/images/$fileName';
    await _client.storage.from(bucketName).upload(
          storagePath,
          file,
          fileOptions: const FileOptions(cacheControl: '3600', upsert: false),
        );
    final publicUrl =
        _client.storage.from(bucketName).getPublicUrl(storagePath);
    return UploadedFileData(
        url: publicUrl, storagePath: storagePath, fileName: fileName);
  }

  Future<UploadedFileData> uploadChatAudio({
    required String chatId,
    required File file,
  }) async {
    final cleanChatId = _cleanPathPart(chatId);
    if (cleanChatId.isEmpty) {
      throw Exception('Chat id is empty. Cannot upload chat audio.');
    }
    final fileName = '${DateTime.now().millisecondsSinceEpoch}.m4a';
    final storagePath = 'chats/$cleanChatId/messages/audio/$fileName';
    await _client.storage.from(bucketName).upload(
          storagePath,
          file,
          fileOptions: const FileOptions(cacheControl: '3600', upsert: false),
        );
    final publicUrl =
        _client.storage.from(bucketName).getPublicUrl(storagePath);
    return UploadedFileData(
        url: publicUrl, storagePath: storagePath, fileName: fileName);
  }

  Future<UploadedFileData> uploadChatFile({
    required String chatId,
    required File file,
    required String originalFileName,
  }) async {
    final cleanChatId = _cleanPathPart(chatId);
    if (cleanChatId.isEmpty) {
      throw Exception('Chat id is empty. Cannot upload chat file.');
    }
    final safeName = _cleanPathPart(originalFileName);
    final fileName = '${DateTime.now().millisecondsSinceEpoch}_$safeName';
    final storagePath = 'chats/$cleanChatId/messages/files/$fileName';
    await _client.storage.from(bucketName).upload(
          storagePath,
          file,
          fileOptions: const FileOptions(cacheControl: '3600', upsert: false),
        );
    final publicUrl =
        _client.storage.from(bucketName).getPublicUrl(storagePath);
    return UploadedFileData(
        url: publicUrl, storagePath: storagePath, fileName: originalFileName);
  }

  Future<UploadedFileData> uploadStatusImage({
    required String userId,
    required File file,
  }) async {
    final cleanUserId = _cleanPathPart(userId);

    if (cleanUserId.isEmpty) {
      throw Exception('User id is empty. Cannot upload status image.');
    }

    final extension = _safeExtension(file.path);
    final fileName = '${DateTime.now().millisecondsSinceEpoch}$extension';

    final storagePath = 'statuses/$cleanUserId/$fileName';

    await _client.storage.from(bucketName).upload(
          storagePath,
          file,
          fileOptions: const FileOptions(
            cacheControl: '3600',
            upsert: false,
          ),
        );

    final publicUrl =
        _client.storage.from(bucketName).getPublicUrl(storagePath);

    return UploadedFileData(
      url: publicUrl,
      storagePath: storagePath,
      fileName: fileName,
    );
  }

  Future<void> removeFile({
    required String storagePath,
  }) async {
    final cleaned = storagePath.trim();

    if (cleaned.isEmpty) return;

    await _client.storage.from(bucketName).remove([cleaned]);
  }

  String getPublicUrl({
    required String folderName,
    required String fileName,
    String? ownerId,
  }) {
    final cleanFolderName = folderName.trim();
    final cleanFileName = fileName.trim();

    if (cleanFolderName.isEmpty) {
      throw Exception('Folder name is empty. Cannot get public URL.');
    }

    if (cleanFileName.isEmpty) {
      throw Exception('File name is empty. Cannot get public URL.');
    }

    final storagePath = ownerId == null || ownerId.trim().isEmpty
        ? '$cleanFolderName/$cleanFileName'
        : '$cleanFolderName/${_cleanPathPart(ownerId)}/$cleanFileName';

    return _client.storage.from(bucketName).getPublicUrl(storagePath);
  }
}

class UploadedFileData {
  const UploadedFileData({
    required this.url,
    required this.storagePath,
    required this.fileName,
  });

  final String url;
  final String storagePath;
  final String fileName;
}
