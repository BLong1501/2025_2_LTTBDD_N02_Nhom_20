import 'dart:io';

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:easy_localization/easy_localization.dart';

import '../profile/change_password_screen.dart';
import '../profile/edit_profile_screen.dart';

class AdminProfileScreen extends StatefulWidget {
  const AdminProfileScreen({super.key});

  @override
  State<AdminProfileScreen> createState() => _AdminProfileScreenState();
}

class _AdminProfileScreenState extends State<AdminProfileScreen> {

  final User? currentUser = FirebaseAuth.instance.currentUser;
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  final ImagePicker picker = ImagePicker();

  bool isUpdatingAvatar = false;

  /// CHANGE AVATAR
  Future<void> changeAvatar() async {

    final image = await picker.pickImage(source: ImageSource.gallery);

    if (image == null) return;

    setState(() => isUpdatingAvatar = true);

    File file = File(image.path);

    final ref = FirebaseStorage.instance
        .ref()
        .child("avatars/${currentUser!.uid}.jpg");

    await ref.putFile(file);

    final url = await ref.getDownloadURL();

    await firestore.collection("users").doc(currentUser!.uid).update({
      "avatarUrl": url
    });

    setState(() => isUpdatingAvatar = false);
  }

  /// LANGUAGE SELECTOR
  void showLanguageBottomSheet() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [

              Padding(
                padding: const EdgeInsets.all(20),
                child: Text(
                  "select_language".tr(),
                  style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold),
                ),
              ),

              const Divider(),

              /// Vietnamese
              ListTile(
                leading: const Text("🇻🇳", style: TextStyle(fontSize: 24)),
                title: Text("vietnamese".tr()),
                trailing: context.locale.languageCode == 'vi'
                    ? const Icon(Icons.check_circle, color: Colors.deepOrange)
                    : null,
                onTap: () {
                  context.setLocale(const Locale('vi'));
                  Navigator.pop(context);
                },
              ),

              /// English
              ListTile(
                leading: const Text("🇬🇧", style: TextStyle(fontSize: 24)),
                title: const Text("English"),
                trailing: context.locale.languageCode == 'en'
                    ? const Icon(Icons.check_circle, color: Colors.deepOrange)
                    : null,
                onTap: () {
                  context.setLocale(const Locale('en'));
                  Navigator.pop(context);
                },
              ),

              const SizedBox(height: 10),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {

    if (currentUser == null) {
      return const Center(child: Text("Not logged in"));
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),

      appBar: AppBar(
        title: Text("title_profile".tr()),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
      ),

      body: StreamBuilder<DocumentSnapshot>(
        stream: firestore
            .collection("users")
            .doc(currentUser!.uid)
            .snapshots(),
        builder: (context, snapshot) {

          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final data =
              snapshot.data!.data() as Map<String, dynamic>;

          final name =
              data["fullName"] ?? currentUser!.email!.split("@")[0];

          final email =
              data["email"] ?? currentUser!.email;

          final avatar =
              data["avatarUrl"] ?? "";

          return SingleChildScrollView(
            child: Column(
              children: [

                /// PROFILE HEADER
                Container(
                  width: double.infinity,
                  color: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 30),

                  child: Column(
                    children: [

                      /// AVATAR
                      GestureDetector(
                        onTap: changeAvatar,
                        child: Stack(
                          alignment: Alignment.bottomRight,
                          children: [

                            CircleAvatar(
                              radius: 50,
                              backgroundColor:
                                  Colors.orange.shade100,

                              backgroundImage:
                                  avatar.isNotEmpty
                                      ? NetworkImage(avatar)
                                      : null,

                              child: avatar.isEmpty
                                  ? const Icon(
                                      Icons.person,
                                      size: 50,
                                      color: Colors.deepOrange)
                                  : null,
                            ),

                            Container(
                              padding:
                                  const EdgeInsets.all(6),
                              decoration:
                                  const BoxDecoration(
                                color: Colors.deepOrange,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.camera_alt,
                                color: Colors.white,
                                size: 16,
                              ),
                            )
                          ],
                        ),
                      ),

                      const SizedBox(height: 15),

                      Text(
                        name,
                        style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold),
                      ),

                      const SizedBox(height: 5),

                      Text(
                        email ?? "",
                        style: TextStyle(
                            color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                /// ACCOUNT MANAGEMENT
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16),

                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,

                    children: [

                      Padding(
                        padding: const EdgeInsets.only(
                            left: 10, bottom: 10),
                        child: Text(
                          "account_management".tr(),
                          style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey),
                        ),
                      ),

                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius:
                              BorderRadius.circular(15),
                        ),

                        child: Column(
                          children: [

                            _menuTile(
                              icon: Icons.person_outline,
                              title:
                                  "change_info".tr(),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) =>
                                        const EditProfileScreen(),
                                  ),
                                );
                              },
                            ),

                            _divider(),

                            _menuTile(
                              icon: Icons.lock_outline,
                              title:
                                  "change_password".tr(),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) =>
                                        const ChangePasswordScreen(),
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 20),

                      /// SETTINGS
                      Padding(
                        padding: const EdgeInsets.only(
                            left: 10, bottom: 10),
                        child: Text(
                          "settings".tr(),
                          style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey),
                        ),
                      ),

                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius:
                              BorderRadius.circular(15),
                        ),

                        child: Column(
                          children: [

                           

                            // _divider(),

                            _menuTile(
                              icon: Icons.language,
                              title: "language".tr(),
                              onTap: showLanguageBottomSheet,
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  /// MENU TILE
  Widget _menuTile(
      {required IconData icon,
      required String title,
      required VoidCallback onTap}) {

    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      trailing:
          const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: onTap,
    );
  }

  Widget _divider() {
    return const Divider(
      height: 1,
      indent: 60,
    );
  }
}