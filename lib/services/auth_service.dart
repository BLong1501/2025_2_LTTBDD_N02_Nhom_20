import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/user_model.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  User? get currentUser => _auth.currentUser;

  // --- 1. ĐĂNG KÝ (Có kiểm tra trùng Username) ---
  Future<String?> register({
    required String email,
    required String password,
    required String name,
    required String username, // Thêm tham số này
  }) async {
    try {
      // B1: Kiểm tra xem Username đã tồn tại chưa
      final QuerySnapshot result = await _firestore
          .collection('users')
          .where('username', isEqualTo: username)
          .get();

      if (result.docs.isNotEmpty) {
        return "Tên đăng nhập đã tồn tại, vui lòng chọn tên khác.";
      }

      // B2: Tạo tài khoản Auth
      UserCredential cred = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // B3: Lưu info
      UserModel newUser = UserModel(
        id: cred.user!.uid,
        username: username, // Lưu username
        name: name,
        email: email,
        phoneNumber: '',
        address: '',
        role: UserRole.blogger,
        createdAt: DateTime.now(),
        isLocked: false,
        favorites: [],
        followers: [],
        bio: '',
      );

      await _firestore.collection('users').doc(newUser.id).set(newUser.toMap());
      return "Success"; // Trả về chuỗi Success nếu thành công
    } on FirebaseAuthException catch (e) {
      if (e.code == 'email-already-in-use') return "Email này đã được đăng ký.";
      return e.message;
    } catch (e) {
      return "Lỗi không xác định: $e";
    }
  }

  // --- 2. ĐĂNG NHẬP (Bằng Username HOẶC Email) ---
  Future<dynamic> login(String loginInput, String password) async {
    try {
      String emailToLogin = loginInput;

      // Nếu input KHÔNG phải là email (không chứa @), ta coi đó là Username
      if (!loginInput.contains('@')) {
        // Tìm Email dựa trên Username trong Firestore
        final QuerySnapshot result = await _firestore
            .collection('users')
            .where('username', isEqualTo: loginInput)
            .get();

        if (result.docs.isEmpty) {
          return "Tên đăng nhập không tồn tại.";
        }
        // Lấy email từ kết quả tìm được
        emailToLogin = result.docs.first.get('email');
      }

      // Đăng nhập bằng Email tìm được (hoặc email người dùng nhập)
      UserCredential cred = await _auth.signInWithEmailAndPassword(
        email: emailToLogin,
        password: password,
      );

      // Lấy thông tin chi tiết
      DocumentSnapshot doc = await _firestore.collection('users').doc(cred.user!.uid).get();
      return UserModel.fromMap(doc.data() as Map<String, dynamic>);

    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') return "Tài khoản không tồn tại.";
      if (e.code == 'wrong-password') return "Sai mật khẩu.";
      return "Lỗi đăng nhập: ${e.message}";
    }
  }

  // --- 3. QUÊN MẬT KHẨU ---
  // Firebase gửi Link reset pass về email (Cách chuẩn bảo mật nhất)
  Future<String> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
      return "Success";
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') return "Email này chưa đăng ký tài khoản nào.";
      return e.message ?? "Lỗi gửi mail";
    }
  }

  // ... (Hàm logout và stream giữ nguyên)
  Future<void> logout() async {
    await _auth.signOut();
  }
}