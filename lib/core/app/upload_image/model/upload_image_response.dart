import 'package:freezed_annotation/freezed_annotation.dart';

part 'upload_image_response.g.dart';

@JsonSerializable(createToJson: false)
class UploadImageResourse {
  final String location;
  UploadImageResourse({required this.location});
  factory UploadImageResourse.fromJson(Map<String, dynamic> json) =>
      _$UploadImageResourseFromJson(json);
}
