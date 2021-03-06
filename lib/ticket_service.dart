import 'dart:typed_data';
import 'package:esc_pos_utils_plus/esc_pos_utils.dart';
import 'package:image/image.dart' as img;

class ESCPrinterService {
  final Uint8List ticket;
  late PaperSize _paperSize;
  late CapabilityProfile _profile;

  ESCPrinterService({required this.ticket});

  Future<List<int>> getBytes(
      {PaperSize paperSize: PaperSize.mm80, CapabilityProfile? profile}) async {
    List<int> bytes = [];
    _profile = profile ?? (await CapabilityProfile.load());
    _paperSize = paperSize;
    Generator generator = Generator(_paperSize, _profile);
    img.Image? decodeImage = img.decodeImage(ticket);
    if(decodeImage != null){
      final img.Image _resize =
      img.copyResize(decodeImage, width: _paperSize.width);
      bytes += generator.image(_resize);
    }
    bytes += generator.feed(1);
    bytes += generator.cut();
    return bytes;
  }
}