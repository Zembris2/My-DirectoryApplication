#!/usr/bin/env bash
# เตรียมไฟล์ที่ SQLite ฝั่งเว็บต้องใช้ (web/sqflite_sw.js และ web/sqlite3.wasm)
#
# ทำไมต้องมีสคริปต์นี้แทนที่จะเรียก setup ตรง ๆ:
# `dart run sqflite_common_ffi_web:setup` จะดาวน์โหลด sqlite3.wasm ตามเวอร์ชัน
# ขั้นต่ำที่แพ็กเกจระบุไว้ (2.4.6) แต่ pub อาจ resolve แพ็กเกจ sqlite3 ให้เป็น
# เวอร์ชันใหม่กว่า (เช่น 3.5.2) พอ wasm กับโค้ด Dart คนละเวอร์ชัน จะพังตอนรันด้วย
#   TypeError: WebAssembly.instantiate(): Import #25 "env": module is not an object
# สคริปต์นี้จึงดาวน์โหลด wasm ให้ตรงกับเวอร์ชันใน pubspec.lock ทับลงไปอีกที
set -e
cd "$(dirname "$0")"

echo "==> สร้าง worker และดาวน์โหลด wasm ตัวตั้งต้น"
dart run sqflite_common_ffi_web:setup --force

VERSION=$(grep -A8 '^  sqlite3:' pubspec.lock | grep -m1 'version:' | tr -d ' "' | cut -d: -f2)
echo "==> pubspec.lock ใช้ sqlite3 $VERSION จึงดึง wasm ให้ตรงเวอร์ชัน"
curl -fsSL -o web/sqlite3.wasm \
  "https://github.com/simolus3/sqlite3.dart/releases/download/sqlite3-$VERSION/sqlite3.wasm"

echo "==> เสร็จแล้ว"
ls -l web/sqflite_sw.js web/sqlite3.wasm
