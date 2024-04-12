import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:zalo_app/services/api_service.dart';
import 'package:zalo_app/utils/valid.dart';

class VerifyNotiScreen extends StatefulWidget {
  const VerifyNotiScreen({super.key});

  @override
  State<VerifyNotiScreen> createState() => _VerifyNotiScreenState();
}

class _VerifyNotiScreenState extends State<VerifyNotiScreen> {
  late String email = "";
  final valid = Valid();
  final api = API();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Container(
        margin: const EdgeInsets.symmetric(horizontal: 30, vertical: 70),
        child: Center(
          child: Column(
            children: [
              Icon(
                Icons.verified,
                size: 100,
                color: Colors.blue[400],
              ),
              const SizedBox(
                height: 50,
                width: double.infinity,
              ),
              const Text(
                "Xác nhận email của bạn",
                style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
              ),
              const SizedBox(
                height: 10,
                width: double.infinity,
              ),
              const Text(
                  "Một email xác minh đã được gửi đến email của bạn. Vui lòng kiểm tra email của bạn và nhấp vào liên kết để xác minh tài khoản của bạn."),
              const SizedBox(
                height: 20,
                width: double.infinity,
              ),
              CircularProgressIndicator(
                color: Colors.blue[400],
              ),
              const SizedBox(
                height: 20,
                width: double.infinity,
              ),
              SizedBox(
                width: double.infinity,
                child: TextButton(
                  onPressed: () {
                    GoRouter.of(context).go('/login');
                  },
                  child: Text(
                    "Quay lại đăng nhập",
                    style: TextStyle(color: Colors.blue[400]),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
