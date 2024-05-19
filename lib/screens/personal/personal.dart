import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:zalo_app/blocs/bloc_user/user_cubit.dart';
import 'package:zalo_app/config/routes/app_route_constants.dart';
import 'package:zalo_app/model/user.model.dart';
import 'package:zalo_app/services/api_service.dart';

class Person extends StatefulWidget {
  const Person({Key? key}) : super(key: key);
  @override
  State<Person> createState() => _PersonState();
}

class _PersonState extends State<Person> {
  User? userExisting = User();
  late bool isShow = false;
  late bool isEdit = false;
  final api = API();

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
    "email": userExisting?.email ?? "",
  };
  void updateUser(context, size) async {
    User? data = await context.read<UserCubit>().updateUser(dataUpdate);
    if (data != null) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          Future.delayed(
            const Duration(seconds: 3),
            () {
              Navigator.pop(context);
            },
          );
          return Dialog(
            child: SizedBox(
              width: size.width * 0.8,
              height: size.height * 0.8,
              child: Image.network(
                '${userExisting?.avatar}',
                fit: BoxFit.cover,
              ),
            ),
          );
        },
      );
      setState(() {
        isEdit = !isEdit;
      });
    }
  }

  void logout() async {
    final response = await api.post("users/logout", {});

    if (response != null) {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.remove("token");
      // ignore: use_build_context_synchronously
      GoRouter.of(context).pushNamed(MyAppRouteConstants.welcomeRouteName);
    }
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    return BlocBuilder<UserCubit, UserState>(
      builder: (context, state) {
        return Scaffold(
          body: SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(
                  height: 10,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: Row(
                    children: [
                      InkWell(
                        onTap: () {},
                        child: userExisting!.avatar != null
                            ? CircleAvatar(
                                backgroundImage:
                                    NetworkImage("${userExisting?.avatar}"),
                                radius: 20,
                              )
                            : CircleAvatar(
                                radius: 20,
                                child: Text(
                                  userExisting!.name?[0] ?? '',
                                  style: const TextStyle(fontSize: 40.0),
                                ),
                              ),
                      ),
                      const SizedBox(
                        width: 10,
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            userExisting!.name ?? "",
                            style: const TextStyle(
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(
                            height: 5,
                          ),
                          Text(
                            userExisting!.email ?? "",
                            style: const TextStyle(
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const Divider(
                  height: 30,
                  thickness: 4,
                ),
                InkWell(
                  onTap: () {
                    GoRouter.of(context)
                        .pushNamed(MyAppRouteConstants.editPersonRouteName);
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        const Icon(
                          Icons.person_outline,
                          size: 30,
                        ),
                        SizedBox(
                          width: size.width * 0.8,
                          child: const Text(
                            "Cập nhật thông tin cá nhân",
                            style: TextStyle(
                              fontSize: 14,
                            ),
                          ),
                        ),
                        const Expanded(child: Icon(Icons.arrow_forward_ios)),
                      ],
                    ),
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),
                InkWell(
                  onTap: () {
                    GoRouter.of(context)
                        .pushNamed(MyAppRouteConstants.editSettingRouteName);
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        const Icon(
                          Icons.lock_outline,
                          size: 30,
                        ),
                        const SizedBox(
                          width: 3,
                        ),
                        SizedBox(
                          width: size.width * 0.8,
                          child: const Text(
                            "Bảo mật và riêng tư",
                            style: TextStyle(
                              fontSize: 14,
                            ),
                          ),
                        ),
                        const Expanded(child: Icon(Icons.arrow_forward_ios)),
                      ],
                    ),
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),
                InkWell(
                  onTap: () {
                    logout();
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        const Icon(
                          Icons.lock_outline,
                          size: 30,
                        ),
                        const SizedBox(
                          width: 3,
                        ),
                        SizedBox(
                          width: size.width * 0.8,
                          child: const Text(
                            "Đăng xuất",
                            style: TextStyle(
                              fontSize: 14,
                            ),
                          ),
                        ),
                        const Expanded(child: Icon(Icons.logout)),
                      ],
                    ),
                  ),
                )
              ],
            ),
          ),
        );
      },
    );
  }
}
