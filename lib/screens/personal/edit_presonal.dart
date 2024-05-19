// ignore_for_file: use_build_context_synchronously

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get_connect/http/src/request/request.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:zalo_app/blocs/bloc_user/user_cubit.dart';
import 'package:zalo_app/components/index.dart';
import 'package:zalo_app/config/routes/app_route_constants.dart';
import 'package:zalo_app/constants.dart';
import 'package:zalo_app/model/user.model.dart';
import 'package:zalo_app/services/api_service.dart';
import 'package:zalo_app/utils/valid.dart';

class EditPerson extends StatefulWidget {
  const EditPerson({super.key});
  @override
  State<EditPerson> createState() => _EditPersonState();
}

class _EditPersonState extends State<EditPerson> {
  User? userExisting = User();
  late bool isShow = false;
  late bool isEdit = false;
  final api = API();
  late bool changePass = false;
  late String _password = "";
  // late String _
  final _formKey = GlobalKey<FormState>();
  final valid = Valid();
  late bool _obscureTextPass = true;
  late bool _obscureTextCf = true;
  late bool _obscureTextOld = true;
  FilePickerResult? result;

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
    });
  }

  late Map<String, String> dataUpdate = {
    "name": userExisting?.name ?? "",
    "oldPassword": "",
    "password": "",
  };

  @override
  void dispose() {
    super.dispose();
  }

  void uploadImage(PlatformFile file) async {
    List<int> bytes = await file.readStream!.toBytes();
    String extension = file.name.split(".").last;
    var data = {
      "filename": file.name,
      "extension": extension,
      "size": file.size,
      "bytes": bytes,
    };
    final response = await api.uploadFile(data);
    if (response != null) {
      updateUserServer({"avatar": response["path"]});
    }
  }

  void updateUserServer(dynamic data) async {
    var updateAvatarResponse = await api.put("users/update", data);
    if (updateAvatarResponse["status"] == 200) {
      if (data["avatar"] != null) {
        Navigator.pop(context);
      }
      updateUserLocal(data);
    } else if (updateAvatarResponse["status"] == 400) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text("Lỗi"),
            content: const Text("Mật khẩu không đúng"),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text("OK"),
              )
            ],
          );
        },
      );
    }
  }

  void updateUserLocal(dynamic data) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var token = prefs.getString("token") ?? "";
    var userOfToken = prefs.getString(token) ?? "";
    if (userOfToken != "") {
      User user = User.fromJson(userOfToken);
      User updateUser =
          user.copyWith(avatar: data["avatar"], name: data["name"]);
      prefs.setString(token, updateUser.toJson());
      setState(() {
        userExisting = updateUser;
      });
    }
    setState(() {
      isEdit = false;
      changePass = false;
    });
    SnackBar snackBar = const SnackBar(
      content: Text("Cập nhật thông tin thành công"),
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    return BlocBuilder<UserCubit, UserState>(
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(
              title: const Text("Chỉnh sửa thông tin"),
              leading: IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () {
                  Navigator.pop(context);
                },
              )),
          body: Column(
            children: [
              const SizedBox(
                height: 10,
              ),
              InkWell(
                onTap: () => {
                  showModalBottomSheet<void>(
                    context: context,
                    builder: (BuildContext context) {
                      return Container(
                        height: 170,
                        color: Colors.black,
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            mainAxisSize: MainAxisSize.max,
                            children: <Widget>[
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 100, vertical: 15),
                                child: ElevatedButton(
                                  onPressed: () async => {
                                    result = await FilePicker.platform
                                        .pickFiles(
                                            withReadStream: true,
                                            type: FileType.custom,
                                            allowedExtensions: [
                                          'jpg',
                                          'jpeg',
                                          'png'
                                        ]),
                                    // dynamic bytes = await image.readAsBytes(),
                                    uploadImage(result!.files.first),
                                    if (result == null)
                                      {}
                                    else
                                      // ignore: unused_local_variable
                                      {for (var element in result!.files) {}}
                                  },
                                  child: const Text('Cập nhật hình ảnh'),
                                ),
                              ),
                              const SizedBox(
                                height: 5,
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 100, vertical: 15),
                                child: ElevatedButton(
                                  onPressed: () {
                                    Navigator.pop(context);
                                    GoRouter.of(context).pushNamed(
                                        MyAppRouteConstants.fullRouteName,
                                        extra: userExisting!.avatar!);
                                  },
                                  child: const Text('Xem hình ảnh'),
                                ),
                              ),
                              const SizedBox(
                                height: 5,
                              ),
                              ElevatedButton(
                                onPressed: () => Navigator.pop(context),
                                child: const Text('Đóng'),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  )
                },
                child: userExisting!.avatar != null
                    ? CircleAvatar(
                        backgroundImage:
                            NetworkImage("${userExisting?.avatar}"),
                        radius: 30,
                      )
                    : CircleAvatar(
                        radius: 30,
                        child: Text(
                          userExisting!.name?[0] ?? '',
                          style: const TextStyle(fontSize: 40.0),
                        ),
                      ),
              ),
              const SizedBox(
                height: 30,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 50),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  verticalDirection: VerticalDirection.down,
                  children: [
                    if (isEdit)
                      SizedBox(
                        width: size.width * 0.8,
                        child: TextFormField(
                          initialValue: dataUpdate["name"],
                          style: const TextStyle(
                            color: Color(0xFF717171),
                            fontWeight: FontWeight.w400,
                            fontSize: 16,
                          ),
                          onChanged: (value) {
                            dataUpdate["name"] = value;
                          },
                        ),
                      )
                    else
                      Row(
                        children: [
                          SizedBox(
                            width: size.width * 0.7,
                            child: Text(
                              userExisting!.name ?? "",
                              style: const TextStyle(
                                  fontWeight: FontWeight.w400, fontSize: 20),
                            ),
                          ),
                          Expanded(
                              child: InkWell(
                            onTap: () {
                              setState(() {
                                isEdit = true;
                              });
                            },
                            child: const Icon(
                              Icons.edit_note,
                              color: Colors.black,
                            ),
                          )),
                        ],
                      ),
                  ],
                ),
              ),
              const SizedBox(
                height: 15,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 50),
                child: InkWell(
                  onTap: () {
                    changePass = !changePass;
                    setState(() {
                      changePass = changePass;
                    });
                  },
                  child: Row(
                    children: [
                      SizedBox(
                        width: size.width * 0.7,
                        child: const Text(
                          "Cập nhật mật khẩu",
                          style: TextStyle(
                              fontWeight: FontWeight.w400, fontSize: 20),
                        ),
                      ),
                      Expanded(
                          child: Icon(
                        changePass
                            ? Icons.keyboard_arrow_up
                            : Icons.keyboard_arrow_down,
                        color: Colors.black,
                      )),
                    ],
                  ),
                ),
              ),
              changePass == true ? _changePass() : Container(),
              const SizedBox(
                height: 45,
              ),
              ElevatedButton(
                onPressed: () => {
                  //handle edit
                  // updateUser(context, size),
                  if (changePass)
                    {
                      if (_formKey.currentState!.validate())
                        {
                          // updateUser(context, size)
                          updateUserServer({
                            "name": dataUpdate["name"],
                            "oldPassword": dataUpdate["oldPassword"],
                            "password": dataUpdate["password"]
                          })
                        }
                    }
                  else
                    {
                      updateUserServer({
                        "name": dataUpdate["name"],
                      })
                    },
                },
                child: const Text("Lưu"),
              )
            ],
          ),
        );
      },
    );
  }

  Padding _changePass() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 10),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          verticalDirection: VerticalDirection.down,
          children: [
            CustomTextField(
              textField: TextFormField(
                obscureText: _obscureTextOld,
                onChanged: (value) {
                  dataUpdate["oldPassword"] = value;
                },
                style: const TextStyle(
                  fontSize: 14,
                ),
                decoration: kTextInputDecoration.copyWith(
                  hintText: 'Mật khẩu hiện tại',
                  prefixIcon: const Icon(Icons.lock_outline),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscureTextOld ? Icons.visibility : Icons.visibility_off,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscureTextOld = !_obscureTextOld;
                      });
                    },
                  ),
                ),
              ),
            ),
            const SizedBox(
              height: 15,
            ),
            CustomTextField(
              textField: TextFormField(
                obscureText: _obscureTextPass,
                onChanged: (value) {
                  _password = value;
                },
                style: const TextStyle(
                  fontSize: 14,
                ),
                decoration: kTextInputDecoration.copyWith(
                  hintText: 'Mật khẩu mới',
                  prefixIcon: const Icon(Icons.lock_outline),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscureTextPass
                          ? Icons.visibility
                          : Icons.visibility_off,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscureTextPass = !_obscureTextPass;
                      });
                    },
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Vui lý nhập mật khẩu';
                  }
                  if (value.length < 6) {
                    return 'Mật khẩu ít nhất là 6 kí tự';
                  }
                  if (!valid.validatePassword(value)) {
                    return 'Mật khẩu phải chứa ít nhất 1 chữ hoa, 1 chữ số và 1 kí tự đặc biệt';
                  }

                  return null;
                },
              ),
            ),
            const SizedBox(
              height: 15,
            ),
            CustomTextField(
              textField: TextFormField(
                obscureText: _obscureTextCf,
                onChanged: (value) {
                  setState(() {
                    dataUpdate["password"] = _password;
                  });
                },
                style: const TextStyle(
                  fontSize: 14,
                ),
                decoration: kTextInputDecoration.copyWith(
                  hintText: 'Nhập lại mật khẩu',
                  prefixIcon: const Icon(Icons.lock_outline),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscureTextCf ? Icons.visibility : Icons.visibility_off,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscureTextCf = !_obscureTextCf;
                      });
                    },
                  ),
                ),
                validator: (value) {
                  if (_password.isEmpty) {
                    return 'Vui lòng nhập mật khẩu trước';
                  }
                  if (value != _password) {
                    return 'Mật khẩu nhập lại không khớp';
                  }
                  return null;
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
