// ignore_for_file: use_build_context_synchronously

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:zalo_app/blocs/bloc_user/user_cubit.dart';
import 'package:zalo_app/model/user.model.dart';
import 'package:zalo_app/services/api_service.dart';
import 'package:zalo_app/utils/valid.dart';

class EditSetting extends StatefulWidget {
  const EditSetting({Key? key}) : super(key: key);
  @override
  State<EditSetting> createState() => _EditSettingState();
}

class _EditSettingState extends State<EditSetting> {
  User? userExisting = User();
  final api = API();
  // late String _
  final valid = Valid();

  FilePickerResult? result;
  bool isNoti = false;
  bool blockGuest = false;

  void _toggleSwitch(bool value) {
    setState(() {
      isNoti = value;
      updateSetting({"notify": isNoti});
    });
  }

  void _toggleSwitchBlock(bool value) {
    setState(() {
      blockGuest = value;
      updateSetting({"blockGuest": blockGuest});
    });
  }

  @override
  void initState() {
    super.initState();
    getUser();
  }

  void getUser() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var token = prefs.getString("token") ?? "";
    var userOfToken = prefs.getString(token) ?? "";
    if (userOfToken != "") {
      userExisting = User.fromJson(userOfToken);
    } else {
      userExisting = null;
    }
    setState(() {
      userExisting = userExisting;
      blockGuest = userExisting!.setting!.blockGuest;
      isNoti = userExisting!.setting!.notify;
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  void updateSetting(dynamic data) async {
    var updateSettingResponse = await api.put("users/update-setting", data);
    if (updateSettingResponse["status"] == 200) {
      updateLocalSetting();
      SnackBar snackBar = const SnackBar(
        content: Text("Cập nhật cài đặt thành công"),
        duration: Duration(seconds: 2),
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    } else {
      SnackBar snackBar = const SnackBar(
        content: Text("Cập nhật cài đặt thất bại"),
        duration: Duration(seconds: 2),
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    }
  }

  void updateLocalSetting() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var token = prefs.getString("token") ?? "";
    var userOfToken = prefs.getString(token) ?? "";
    if (userOfToken != "") {
      User user = User.fromJson(userOfToken);
      user.setting!.notify = isNoti;
      user.setting!.blockGuest = blockGuest;
      prefs.setString(token, user.toJson());
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<UserCubit, UserState>(
      builder: (context, state) {
        return Scaffold(
            appBar: AppBar(
                title: const Text("Cập nhật cài đặt"),
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                )),
            body: Column(
              children: [
                Row(
                  children: [
                    const SizedBox(
                      width: 10,
                    ),
                    const Text("Không làm phiền"),
                    const Spacer(),
                    Switch(
                      value: isNoti,
                      onChanged: _toggleSwitch,
                      activeTrackColor: Colors.lightGreenAccent,
                      activeColor: Colors.green,

                      materialTapTargetSize: MaterialTapTargetSize
                          .shrinkWrap, // Reduces the tap target size
                    ),
                    const SizedBox(
                      width: 10,
                    ),
                  ],
                ),
                Row(
                  children: [
                    const SizedBox(
                      width: 10,
                    ),
                    const Text("Chặn người lạ"),
                    const Spacer(),
                    Switch(
                      value: blockGuest,
                      onChanged: _toggleSwitchBlock,
                      activeTrackColor: Colors.lightGreenAccent,
                      activeColor: Colors.green,
                      materialTapTargetSize: MaterialTapTargetSize
                          .shrinkWrap, // Reduces the tap target size
                    ),
                    const SizedBox(
                      width: 10,
                    ),
                  ],
                ),
              ],
            ));
      },
    );
  }
}
