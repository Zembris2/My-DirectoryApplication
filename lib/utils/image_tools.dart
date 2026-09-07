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

  /// ย่อรูปแล้วเข้ารหัสเป็น PNG
  ///
  /// รูปจากกล้องมือถือใบหนึ่งมักหนัก 3-5 MB ถ้าเก็บดิบ ๆ ลงฐานข้อมูล
  /// แค่ยี่สิบคนไฟล์ก็ร้อยเมกะไบต์แล้ว และช้าตอนอ่านทุกครั้งที่เปิดรายการ
  /// ย่อก่อนเก็บทำให้เหลือหลักสิบกิโลไบต์ต่อคน
  ///
  /// ใช้ตัวถอดรหัสรูปที่มากับ Flutter เอง จึงไม่ต้องพึ่งไลบรารีประมวลผลรูปเพิ่ม
  static Future<Uint8List?> shrinkToPng(Uint8List source) async {
    final codec = await ui.instantiateImageCodec(
      source,
      targetWidth: maxSide,
      targetHeight: maxSide,
      allowUpscaling: false,
    );

    final frame = await codec.getNextFrame();
    final data = await frame.image.toByteData(format: ui.ImageByteFormat.png);

    // คืนภาพให้ระบบทันที ไม่งั้นหน่วยความจำของรูปจะค้างจนกว่าจะเก็บกวาดเอง
    frame.image.dispose();
    codec.dispose();

    return data?.buffer.asUint8List();
  }
}
