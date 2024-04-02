// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:zalo_app/components/custom_button.dart';
import 'package:zalo_app/components/customer_text_field.dart';
import 'package:zalo_app/constants.dart';
import 'package:zalo_app/services/api_service.dart';
import 'package:zalo_app/utils/valid.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  late String email = "";
  final valid = Valid();
  final api = API();
  final _formKey = GlobalKey<FormState>();
  late bool checkMail = false;
  void forgot() async {
    var res = await api.post("users/forgot-password", {"email": email});

    if (res['status'] == 200) {
      setState(() {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
                "Một email xác minh đã được gửi đến email của bạn. Vui lòng kiểm tra email của bạn và nhấp vào liên kết để xác minh tài khoản của bạn."),
            backgroundColor: Colors.green,
          ),
        );
      });
    } else if (res['status'] == 400) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
              "Vui lòng kiểm tra email của bạn để đặt lại mật khẩu nếu không có email nào được gửi, vui lòng thử lại sau 15 phút."),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Container(
        margin: const EdgeInsets.symmetric(horizontal: 30, vertical: 70),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Icon(
                Icons.lock_outline,
                size: 100,
                color: Colors.blue[400],
              ),
            ),
            const SizedBox(
              height: 20,
              width: double.infinity,
            ),
            const Text(
              "Đặt lại mật khẩu",
              style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
            ),
            const Text(
                "Vui lòng nhập email đã xác minh của bạn để đặt lại mật khẩu."),
            const SizedBox(
              height: 20,
              width: double.infinity,
            ),
            Form(
              key: _formKey,
              child: TextFormField(
                onChanged: (value) {
                  setState(() {
                    email = value;
                  });
                },
                style: const TextStyle(
                  fontSize: 14,
                ),
                decoration: kTextInputDecoration.copyWith(
                    // contentPadding: const EdgeInsets.all(10),
                    hintText: 'Nhập email',
                    prefixIcon: const Icon(Icons.email_outlined)),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Vui lý nhập email';
                  }
                  if (!valid.validateEmail(email)) {
                    return 'Email không hợp lệ';
                  }
                  return null;
                },
              ),
            ),
            Container(
              margin: const EdgeInsets.only(top: 20, bottom: 10),
              width: double.infinity,
              child: TextButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    forgot();
                  }
                },
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  shape: RoundedRectangleBorder(
                    side: const BorderSide(color: Colors.blue),
                    borderRadius: BorderRadius.circular(5),
                  ),
                ),
                child: Text(
                  "Đặt lại mật khẩu ",
                  style: TextStyle(color: Colors.blue[400]),
                ),
              ),
            ),
            SizedBox(
              width: double.infinity,
              child: TextButton(
                onPressed: () {
                  GoRouter.of(context).go('/login');
                },
                child: Text(
                  "Quay lại",
                  style: TextStyle(color: Colors.blue[400]),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
