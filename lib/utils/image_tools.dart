import 'dart:typed_data';
import 'dart:ui' as ui;

/// เครื่องมือย่อรูปก่อนเก็บลงฐานข้อมูล
class ImageTools {
  const ImageTools._();

  /// ด้านที่ยาวที่สุดของรูปหลังย่อ
  ///
  /// รูปโปรไฟล์แสดงจริงแค่วงกลมเส้นผ่านศูนย์กลางไม่ถึง 60 พิกเซล
  /// เก็บ 256 ก็เกินพอสำหรับจอความละเอียดสูงแล้ว
  static const int maxSide = 256;

  /// ย่อรูปแล้วเข้ารหัสเป็น PNG โดยคงสัดส่วนเดิม
  ///
  /// รูปจากกล้องมือถือใบหนึ่งมักหนัก 3-5 MB ถ้าเก็บดิบ ๆ ลงฐานข้อมูล
  /// แค่ยี่สิบคนไฟล์ก็ร้อยเมกะไบต์แล้ว และช้าตอนอ่านทุกครั้งที่เปิดรายการ
  /// ย่อก่อนเก็บทำให้เหลือหลักสิบกิโลไบต์ต่อคน
  ///
  /// ต้องอ่านขนาดจริงของรูปมาคำนวณด้านสั้นเองก่อน เพราะถ้าสั่งย่อเป็น
  /// จัตุรัสตรง ๆ รูปคนที่ถ่ายแนวตั้งจะถูกบีบจนหน้าแบน
  static Future<Uint8List?> shrinkToPng(Uint8List source) async {
    final buffer = await ui.ImmutableBuffer.fromUint8List(source);
    final descriptor = await ui.ImageDescriptor.encoded(buffer);

    final width = descriptor.width;
    final height = descriptor.height;
    final longest = width > height ? width : height;

    // รูปที่เล็กกว่าขนาดเป้าหมายอยู่แล้ว ไม่ต้องขยายให้เสียความคมชัด
    final scale = longest <= maxSide ? 1.0 : maxSide / longest;
    final targetWidth = (width * scale).round().clamp(1, width);
    final targetHeight = (height * scale).round().clamp(1, height);

    final codec = await descriptor.instantiateCodec(
      targetWidth: targetWidth,
      targetHeight: targetHeight,
    );

    final frame = await codec.getNextFrame();
    final data = await frame.image.toByteData(format: ui.ImageByteFormat.png);

    // คืนภาพให้ระบบทันที ไม่งั้นหน่วยความจำของรูปจะค้างจนกว่าจะเก็บกวาดเอง
    frame.image.dispose();
    codec.dispose();
    descriptor.dispose();

    return data?.buffer.asUint8List();
  }
}
