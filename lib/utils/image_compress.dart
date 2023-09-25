import 'package:ffmpeg_kit_flutter/ffmpeg_kit.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';

String thumbnailCompress(String input, String output) {
  return '-i "file://$input" -qscale:v 5 -vf "scale=\'min(173,iw)\':-2" "$output"';
}

String imageCompress(String input, String output) {
  return '-i "file://$input" -qscale:v 5 -vf "scale=\'min(720,iw)\':-2" -y "$output"';
}

class CompressDto {
  final XFile _file;
  final String _image;
  final String _thumbnail;

  XFile get file => _file;
  String get image => _image;
  String get thumbnail => _thumbnail;

  const CompressDto(this._file, this._image, this._thumbnail);

  @override
  String toString() {
    return "{file : $_file, image: $_image, thumbnail: $_thumbnail}";
  }
}

Future<CompressDto?> compress(XFile? file) async {
  if (file != null) {
    print(file);
    // setState(() {
    //   image = file;
    // });

    final dir = await getApplicationDocumentsDirectory();
    final output = "${dir.path}/PROFILE_USERID_${DateTime.now().millisecondsSinceEpoch}.jpg";

    print(output);

    await FFmpegKit.execute(
      imageCompress(file.path, output),
      // (session) async {
      //   final state = await session.getState();

      //   final fail = await session.getFailStackTrace();
      //   // setState(() {
      //   //   compressOutput = output;
      //   // });
      // },
      // (log) {
      //   // print("============LOG============");
      //   // print(log.getMessage());
      // },
      // (statistics) {},
    );
    final thumbnail = "${dir.path}/PROFILE_THUMBAIL_USERID_${DateTime.now().millisecondsSinceEpoch}.jpg";

    await FFmpegKit.execute(
      thumbnailCompress(file.path, thumbnail),
      // (session) async {
      //   final state = await session.getState();

      //   // setState(() {
      //   //   thumbnailOutput = thumbnail;
      //   // });
      // },
      // (log) {
      //   // print("============LOG============");
      //   // print(log.getMessage());
      // },
      // (statistics) {},
    );

    print("=============================================");
    print(file);
    print(output);
    print(thumbnail);
    print("=============================================");

    return CompressDto(file, output, thumbnail);
  }

  return null;
}
