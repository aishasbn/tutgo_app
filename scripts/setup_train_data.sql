-- Script untuk setup data kereta di Firestore
-- Jalankan script ini untuk membuat data kereta Surabaya-Jakarta

-- Note: Script ini adalah contoh struktur data yang akan dibuat di Firestore
-- Anda perlu menjalankan ini melalui Firebase Console atau menggunakan script Dart

-- Collection: trains
-- Document ID: SBY-JKT-001
{
  "kode": "SBY-JKT-001",
  "nama": "Argo Bromo Anggrek",
  "fromStasiun": "Surabaya Gubeng",
  "toStasiun": "Jakarta Gambir",
  "jadwal": "08:00",
  "status": "onRoute",
  "arrivalCountdown": "2 jam 30 menit",
  "route": [
    {
      "nama": "Surabaya Gubeng",
      "waktu": "08:00",
      "isPassed": true,
      "isActive": false
    },
    {
      "nama": "Mojokerto",
      "waktu": "08:45",
      "isPassed": true,
      "isActive": false
    },
    {
      "nama": "Kertosono",
      "waktu": "09:30",
      "isPassed": true,
      "isActive": false
    },
    {
      "nama": "Madiun",
      "waktu": "10:15",
      "isPassed": false,
      "isActive": true
    },
    {
      "nama": "Solo Balapan",
      "waktu": "11:30",
      "isPassed": false,
      "isActive": false
    },
    {
      "nama": "Yogyakarta",
      "waktu": "12:15",
      "isPassed": false,
      "isActive": false
    },
    {
      "nama": "Purwokerto",
      "waktu": "14:00",
      "isPassed": false,
      "isActive": false
    },
    {
      "nama": "Cirebon",
      "waktu": "16:30",
      "isPassed": false,
      "isActive": false
    },
    {
      "nama": "Jakarta Gambir",
      "waktu": "19:00",
      "isPassed": false,
      "isActive": false
    }
  ],
  "gerbongs": [
    {
      "kode": "EKS-1",
      "tipe": "Eksekutif",
      "kapasitas": 50,
      "terisi": 35
    },
    {
      "kode": "EKS-2",
      "tipe": "Eksekutif",
      "kapasitas": 50,
      "terisi": 42
    },
    {
      "kode": "BIS-1",
      "tipe": "Bisnis",
      "kapasitas": 64,
      "terisi": 58
    },
    {
      "kode": "BIS-2",
      "tipe": "Bisnis",
      "kapasitas": 64,
      "terisi": 61
    }
  ],
  "createdAt": "2024-01-01T00:00:00Z",
  "updatedAt": "2024-01-01T08:00:00Z"
}
