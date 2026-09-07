#!/usr/bin/env bash
# รันแอปบนเว็บแบบ release (วิธีที่เสถียรที่สุดบน Codespaces)
#
# โหมด dev (flutter run -d web-server) ใช้ DDC ซึ่งต้องโหลดสคริปต์กว่า 500 ไฟล์
# ผ่าน proxy ของ Codespaces และต้องต่อ websocket กลับมาที่ dev server
# ถ้าจังหวะไหนหลุด จะได้หน้าจอขาวเปล่าโดยไม่มี error ให้ดู
#
# วิธีนี้ build เป็น main.dart.js ไฟล์เดียว แล้วเสิร์ฟแบบ static จึงไม่มีปัญหานั้น
set -e

PORT="${1:-8081}"
cd "$(dirname "$0")"

echo "==> เตรียมไฟล์ SQLite ฝั่งเว็บ"
./setup_web.sh

echo "==> สร้าง build เว็บ (release)"
flutter build web --release

echo "==> เสิร์ฟที่พอร์ต $PORT"
echo "    เปิดแท็บ PORTS ใน Codespaces แล้วตั้งพอร์ต $PORT เป็น Public ก่อนเปิดลิงก์"
python3 - "$PORT" <<'PY'
import functools, http.server, socketserver, sys

PORT = int(sys.argv[1])

class Handler(http.server.SimpleHTTPRequestHandler):
    # python ปกติจะส่ง .wasm เป็น octet-stream ทำให้ CanvasKit/SQLite โหลดไม่ขึ้น
    extensions_map = {
        **http.server.SimpleHTTPRequestHandler.extensions_map,
        ".wasm": "application/wasm",
        ".js": "text/javascript",
        ".mjs": "text/javascript",
        ".json": "application/json",
    }

    def end_headers(self):
        self.send_header("Cache-Control", "no-store")
        super().end_headers()

socketserver.TCPServer.allow_reuse_address = True
with socketserver.TCPServer(("0.0.0.0", PORT), functools.partial(Handler, directory="build/web")) as httpd:
    print(f"กำลังเสิร์ฟ build/web ที่ 0.0.0.0:{PORT} (Ctrl+C เพื่อหยุด)", flush=True)
    httpd.serve_forever()
PY
