import 'dart:io';
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:whatsapp_ui/common/utils/utils.dart';
import 'package:whatsapp_ui/features/auth/screens/otp_screen.dart';
import 'package:whatsapp_ui/features/auth/screens/user_information_screen.dart';
import 'package:whatsapp_ui/models/user_model.dart';
import 'package:whatsapp_ui/mobile_layout_screen.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository(
    dio: Dio(BaseOptions(baseUrl: 'http://103.28.53.23:8080')),
    ref: ref,                    // Tambahkan ref
  );
});

class AuthRepository {
  final Dio dio;
  final Ref ref;                 // ← Tambahkan ini
  final String apiKey = "429683C4C977415CAAFCCEWADIDAW";

  AuthRepository({
    required this.dio,
    required this.ref,
  });

  Future<UserModel?> getCurrentUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final instanceName = prefs.getString('instance_name');

    if (instanceName == null) return null;

    return UserModel(
      name: instanceName,
      uid: instanceName,
      profilePic: prefs.getString('profile_pic_path') ?? '',
      isOnline: true,
      phoneNumber: instanceName,
      groupId: [],
    );
  }

  void signInWithPhone(BuildContext context, String phoneNumber) async {
    try {
      final response = await dio.post(
        '/send-otp',
        data: {
          "phone": phoneNumber,
          "apiKey": apiKey,
        },
      );

      if (response.statusCode == 200) {
        String verificationId = response.data['verification_id'] ?? phoneNumber;

        Navigator.pushNamed(
          context,
          OTPScreen.routeName,
          arguments: verificationId,
        );
      } else {
        throw Exception('Gagal mengirim OTP');
      }
    } catch (e) {
      showSnackBar(context: context, content: e.toString());
    }
  }

  void verifyOTP({
    required BuildContext context,
    required String verificationId,
    required String userOTP,
  }) async {
    try {
      final response = await dio.post(
        '/verify-otp',
        data: {
          "verification_id": verificationId,
          "otp": userOTP,
          "apiKey": apiKey,
        },
      );

      if (response.statusCode == 200) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('instance_name', verificationId);

        Navigator.pushNamedAndRemoveUntil(
          context,
          UserInformationScreen.routeName,
          (route) => false,
        );
      } else {
        throw Exception('OTP salah');
      }
    } catch (e) {
      showSnackBar(context: context, content: e.toString());
    }
  }

  void saveUserDataToEvolution({
    required String name,
    required File? profilePic,
    required BuildContext context,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      String uid = prefs.getString('instance_name') ?? 'unknown_user';
      String photoPath = '';

      if (profilePic != null) {
        photoPath = profilePic.path;
        await prefs.setString('profile_pic_path', photoPath);
      }

      var user = UserModel(
        name: name,
        uid: uid,
        profilePic: photoPath,
        isOnline: true,
        phoneNumber: uid,
        groupId: [],
      );

      await prefs.setString('user_data', json.encode(user.toMap()));

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (context) => const MobileLayoutScreen(),
        ),
        (route) => false,
      );
    } catch (e) {
      showSnackBar(context: context, content: e.toString());
    }
  }

  Stream<UserModel> userData(String userId) {
    // Karena pakai Evolution API (bukan Firebase Auth), kita return dummy stream
    return Stream.value(UserModel(
      name: 'User',
      uid: userId,
      profilePic: '',
      isOnline: true,
      phoneNumber: '',
      groupId: [],
    ));
  }

  void setUserState(bool isOnline) async {
    // Optional: bisa tambah request ke Evolution API nanti
    // await dio.post('/set-presence', data: {"isOnline": isOnline});
  }
}