import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:zalo_app/blocs/bloc_user/user_cubit.dart';
import 'package:zalo_app/model/user.model.dart';

class Person extends StatefulWidget {
  const Person({Key? key}) : super(key: key);
  @override
  State<Person> createState() => _PersonState();
}

class _PersonState extends State<Person> {
  User? userExisting = User();
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

  @override
  Widget build(BuildContext context) {
    print("userExisting: $userExisting");
    return BlocBuilder<UserCubit, UserState>(
      builder: (context, state) {
        // if (state is LoginLoaded) {
        //   userExisting = state.user;
        // } else {
        //   userExisting = User(
        //     id: '',
        //     name: '',
        //     password: '',
        //     displayName: '',
        //     status: '',
        //     phone: '',
        //     email: '',
        //     avatar: '',
        //     isTwoFactorAuthenticationEnabled: false,
        //     twoFactorAuthenticationSecret: '',
        //   );
        // }
        return Scaffold(
          body: SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(
                  height: 10,
                ),
                // CircleAvatar(
                //   backgroundImage: AssetImage("${userExisting?.avatar}"),
                //   radius: 60,
                // ),
                const SizedBox(
                  height: 30,
                ),
                SizedBox(
                  width: 210,
                  child: Center(
                    child: Text(
                      userExisting?.name ?? "Unconfirmed",
                      style: const TextStyle(
                          fontWeight: FontWeight.w600, fontSize: 20),
                    ),
                  ),
                ),
                const SizedBox(
                  height: 30,
                ),
                Column(
                  children: [
                    Row(
                      children: const [
                        SizedBox(
                          width: 39,
                        ),
                        Text(
                          "First and last name",
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.w500),
                        )
                      ],
                    ),
                    const SizedBox(
                      height: 5,
                    ),
                    Row(
                      children: [
                        const SizedBox(
                          width: 90,
                        ),
                        SizedBox(
                          width: 230,
                          child: Text(
                            userExisting?.name ?? "Unconfirmed",
                            style: const TextStyle(
                                color: Color(0xFF717171),
                                fontWeight: FontWeight.w400,
                                fontSize: 16),
                          ),
                        ),
                        Container(
                          decoration: const BoxDecoration(
                            color: Color(0xFFB61B2D),
                            borderRadius:
                                BorderRadius.all(Radius.circular(10.0) //
                                    ),
                          ),
                          child: IconButton(
                            onPressed: () {},
                            icon: const Icon(Icons.edit_outlined),
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(
                      height: 15,
                    ),
                    SizedBox(
                      width: 370,
                      child: Center(
                        child: Container(
                          height: 1.0,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(
                  height: 15,
                ),
                SizedBox(
                  child: Column(
                    children: [
                      Row(
                        children: const [
                          SizedBox(
                            width: 39,
                          ),
                          Text(
                            "Phone",
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.w500),
                          )
                        ],
                      ),
                      const SizedBox(
                        height: 5,
                      ),
                      Row(
                        children: [
                          const SizedBox(
                            width: 90,
                          ),
                          SizedBox(
                            width: 230,
                            child: Text(
                              userExisting?.phone ?? "Unconfirmed",
                              style: const TextStyle(
                                  color: Color(0xFF717171),
                                  fontWeight: FontWeight.w400,
                                  fontSize: 16),
                            ),
                          ),
                          Container(
                            decoration: const BoxDecoration(
                              color: Color(0xFFB61B2D),
                              borderRadius:
                                  BorderRadius.all(Radius.circular(10.0) //
                                      ),
                            ),
                            child: IconButton(
                              onPressed: () {},
                              icon: const Icon(Icons.edit_outlined),
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(
                        height: 15,
                      ),
                      SizedBox(
                        width: 370,
                        child: Center(
                          child: Container(
                            height: 1.0,
                            color: Colors.grey,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(
                  height: 15,
                ),
                SizedBox(
                  child: Column(
                    children: [
                      Row(
                        children: const [
                          SizedBox(
                            width: 39,
                          ),
                          Text(
                            "ID/CCCD",
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.w500),
                          )
                        ],
                      ),
                      const SizedBox(
                        height: 5,
                      ),
                      Row(
                        children: [
                          const SizedBox(
                            width: 90,
                          ),
                          SizedBox(
                            width: 230,
                            child: Text(
                              userExisting?.email ?? "Unconfirmed",
                              style: const TextStyle(
                                  color: Color(0xFF717171),
                                  fontWeight: FontWeight.w400,
                                  fontSize: 16),
                            ),
                          ),
                          Container(
                            decoration: const BoxDecoration(
                              color: Color(0xFFB61B2D),
                              borderRadius:
                                  BorderRadius.all(Radius.circular(10.0) //
                                      ),
                            ),
                            child: IconButton(
                              onPressed: () {},
                              icon: const Icon(Icons.edit_outlined),
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(
                        height: 15,
                      ),
                      SizedBox(
                        width: 370,
                        child: Center(
                          child: Container(
                            height: 1.0,
                            color: Colors.grey,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(
                  height: 15,
                ),
                SizedBox(
                  child: Column(
                    children: [
                      Row(
                        children: const [
                          SizedBox(
                            width: 39,
                          ),
                          Text(
                            "Address",
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.w500),
                          )
                        ],
                      ),
                      const SizedBox(
                        height: 5,
                      ),
                      Row(
                        children: [
                          const SizedBox(
                            width: 90,
                          ),
                          SizedBox(
                            width: 230,
                            child: Text(
                              userExisting?.email ?? "Unconfirmed",
                              style: const TextStyle(
                                  color: Color(0xFF717171),
                                  fontWeight: FontWeight.w400,
                                  fontSize: 14),
                            ),
                          ),
                          Container(
                            decoration: const BoxDecoration(
                              color: Color(0xFFB61B2D),
                              borderRadius:
                                  BorderRadius.all(Radius.circular(10.0) //
                                      ),
                            ),
                            child: IconButton(
                              onPressed: () {},
                              icon: const Icon(Icons.edit_outlined),
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(
                        height: 15,
                      ),
                      SizedBox(
                        width: 370,
                        child: Center(
                          child: Container(
                            height: 1.0,
                            color: Colors.grey,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(
                  height: 15,
                ),
                SizedBox(
                  child: Column(
                    children: [
                      Row(
                        children: const [
                          SizedBox(
                            width: 39,
                          ),
                          Text(
                            "Face Authentication",
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.w500),
                          )
                        ],
                      ),
                      const SizedBox(
                        height: 5,
                      ),
                      Row(
                        children: [
                          const SizedBox(
                            width: 90,
                          ),
                          const SizedBox(
                            width: 230,
                            child: Text(
                              "Unconfirmed",
                              style: TextStyle(
                                  color: Color(0xFF717171),
                                  fontWeight: FontWeight.w400,
                                  fontSize: 14),
                            ),
                          ),
                          Container(
                            decoration: const BoxDecoration(
                              color: Color(0xFFB61B2D),
                              borderRadius:
                                  BorderRadius.all(Radius.circular(10.0) //
                                      ),
                            ),
                            child: IconButton(
                              onPressed: () {},
                              icon: const Icon(Icons.edit_outlined),
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
