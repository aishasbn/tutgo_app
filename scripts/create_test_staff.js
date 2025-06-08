// Script untuk membuat akun staff test
// Jalankan di Firebase Console atau menggunakan Firebase Admin SDK

console.log("🔄 Membuat akun staff untuk testing...")

// Data staff test yang akan dibuat
const testStaffAccounts = [
  {
    email: "staff001@staff.tutgo.com",
    password: "staff123",
    displayName: "Admin Utama",
    staffId: "STAFF001",
  },
  {
    email: "staff002@staff.tutgo.com",
    password: "staff123",
    displayName: "Operator 1",
    staffId: "STAFF002",
  },
]

// Instruksi manual untuk Firebase Console:
console.log("📋 Cara membuat akun staff di Firebase Console:")
console.log("1. Buka Firebase Console → Authentication → Users")
console.log("2. Klik 'Add user'")
console.log("3. Masukkan data berikut:")

testStaffAccounts.forEach((staff, index) => {
  console.log(`\n--- Staff ${index + 1} ---`)
  console.log(`Email: ${staff.email}`)
  console.log(`Password: ${staff.password}`)
  console.log(`Display Name: ${staff.displayName}`)
})

console.log("\n4. Setelah user dibuat, buka Firestore Database")
console.log("5. Buat collection 'users' jika belum ada")
console.log("6. Untuk setiap user, buat document dengan ID = UID user")
console.log("7. Isi document dengan struktur:")

const firestoreStructure = {
  uid: "firebase_user_uid",
  name: "Admin Utama",
  email: "staff001@staff.tutgo.com",
  staffId: "STAFF001",
  userType: "staff",
  createdAt: "timestamp",
  updatedAt: "timestamp",
}

console.log(JSON.stringify(firestoreStructure, null, 2))

console.log("\n✅ Setelah setup selesai, coba login dengan:")
testStaffAccounts.forEach((staff, index) => {
  console.log(`Staff ${index + 1}: ID = ${staff.staffId}, Password = ${staff.password}`)
})
