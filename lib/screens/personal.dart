import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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
  late bool isShow = false;
  late bool isEdit = false;

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
    "displayName": userExisting?.displayName ?? "",
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
            child: Container(
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
                ElevatedButton(
                  onPressed: () => {
                    showModalBottomSheet<void>(
                      context: context,
                      builder: (BuildContext context) {
                        return Container(
                          height: 150,
                          color: Colors.black,
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              mainAxisSize: MainAxisSize.max,
                              children: <Widget>[
                                ElevatedButton(
                                  style: ButtonStyle(
                                    backgroundColor:
                                        MaterialStateProperty.all(Colors.white),
                                    foregroundColor:
                                        MaterialStateProperty.all(Colors.black),
                                    padding: MaterialStateProperty.all(
                                        const EdgeInsets.symmetric(
                                            horizontal: 100, vertical: 15)),
                                  ),
                                  onPressed: () async => {
                                    result = await FilePicker.platform
                                        .pickFiles(
                                            type: FileType.custom,
                                            allowedExtensions: [
                                          'jpg',
                                          'jpeg',
                                          'png'
                                        ]),
                                    if (result == null)
                                      {print("No file selected")}
                                    else
                                      {
                                        for (var element in result!.files)
                                          {print(element.name)}
                                      }
                                  },
                                  child: const Text('Edit image'),
                                ),
                                ElevatedButton(
                                  style: ButtonStyle(
                                    backgroundColor:
                                        MaterialStateProperty.all(Colors.white),
                                    foregroundColor:
                                        MaterialStateProperty.all(Colors.black),
                                    shadowColor: MaterialStateColor.resolveWith(
                                        (states) => Colors.black),
                                    padding: MaterialStateProperty.all(
                                        const EdgeInsets.symmetric(
                                            horizontal: 100, vertical: 15)),
                                  ),
                                  onPressed: () {
                                    showDialog(
                                      context: context,
                                      builder: (BuildContext context) {
                                        return Dialog(
                                          child: Container(
                                            width: size.width * 0.8,
                                            // height: size.height * 0.8,
                                            child: Image.network(
                                              '${userExisting?.avatar}',
                                              fit: BoxFit.cover,
                                            ),
                                          ),
                                        );
                                      },
                                    );
                                  },
                                  child: const Text('View image'),
                                ),
                                ElevatedButton(
                                  style: ButtonStyle(
                                    backgroundColor:
                                        MaterialStateProperty.all(Colors.white),
                                    foregroundColor:
                                        MaterialStateProperty.all(Colors.red),
                                    padding: MaterialStateProperty.all(
                                        const EdgeInsets.symmetric(
                                            horizontal: 100, vertical: 15)),
                                  ),
                                  onPressed: () => Navigator.pop(context),
                                  child: const Text('Close'),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    )
                  },
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all(Colors.white),
                    shape: MaterialStateProperty.all(
                      RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10000),
                      ),
                    ),
                    padding: MaterialStateProperty.all(const EdgeInsets.all(0)),
                  ),
                  child: CircleAvatar(
                    backgroundImage: NetworkImage("${userExisting?.avatar}"),
                    radius: 60,
                  ),
                ),
                const SizedBox(
                  height: 30,
                ),
                ElevatedButton(
                  onPressed: () => {
                    isEdit = !isEdit,
                    setState(() {
                      isEdit = isEdit;
                    })
                  },
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all(Colors.white),
                    shape: MaterialStateProperty.all(
                      RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10000),
                      ),
                    ),
                    maximumSize: MaterialStateProperty.all(const Size(200, 50)),
                    padding: MaterialStateProperty.all(const EdgeInsets.all(0)),
                  ),
                  child: const Center(
                    child: Text(
                      "Edit Profile",
                      style:
                          TextStyle(fontWeight: FontWeight.w600, fontSize: 20),
                    ),
                  ),
                ),
                const SizedBox(
                  height: 30,
                ),
                Column(
                  children: [
                    const Row(
                      children: [
                        SizedBox(
                          width: 50,
                        ),
                        Text(
                          "Name",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        )
                      ],
                    ),
                    Row(
                      children: [
                        const SizedBox(
                          width: 50,
                        ),
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
                          Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                userExisting?.name ?? "Unconfirmed",
                                style: const TextStyle(
                                    color: Color(0xFF717171),
                                    fontWeight: FontWeight.w400,
                                    fontSize: 16),
                              ),
                              const SizedBox(
                                height: 5,
                              ),
                              SizedBox(
                                width: size.width * 0.8,
                                child: Center(
                                  child: Container(
                                    height: 1.0,
                                    color: Colors.grey,
                                  ),
                                ),
                              ),
                            ],
                          )
                      ],
                    ),
                  ],
                ),
                const SizedBox(
                  height: 15,
                ),
                Column(
                  children: [
                    const Row(
                      children: [
                        SizedBox(
                          width: 50,
                        ),
                        Text(
                          "Display Name",
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.w500),
                        )
                      ],
                    ),
                    Row(
                      children: [
                        const SizedBox(
                          width: 50,
                        ),
                        if (isEdit)
                          SizedBox(
                            width: size.width * 0.8,
                            child: TextFormField(
                              initialValue: dataUpdate["displayName"],
                              style: const TextStyle(
                                color: Color(0xFF717171),
                                fontWeight: FontWeight.w400,
                                fontSize: 16,
                              ),
                              onChanged: (value) {
                                dataUpdate["displayName"] = value;
                              },
                            ),
                          )
                        else
                          Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                userExisting?.displayName ?? "Unconfirmed",
                                style: const TextStyle(
                                    color: Color(0xFF717171),
                                    fontWeight: FontWeight.w400,
                                    fontSize: 16),
                              ),
                              const SizedBox(
                                height: 5,
                              ),
                              SizedBox(
                                width: size.width * 0.8,
                                child: Center(
                                  child: Container(
                                    height: 1.0,
                                    color: Colors.grey,
                                  ),
                                ),
                              ),
                            ],
                          )
                      ],
                    ),
                  ],
                ),
                const SizedBox(
                  height: 15,
                ),
                Column(
                  children: [
                    const Row(
                      children: [
                        SizedBox(
                          width: 50,
                        ),
                        Text(
                          "Email",
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.w500),
                        )
                      ],
                    ),
                    Row(
                      children: [
                        const SizedBox(
                          width: 50,
                        ),
                        if (isEdit)
                          SizedBox(
                            width: size.width * 0.8,
                            child: TextFormField(
                              initialValue: dataUpdate["email"],
                              style: const TextStyle(
                                color: Color(0xFF717171),
                                fontWeight: FontWeight.w400,
                                fontSize: 16,
                              ),
                              onChanged: (value) {
                                dataUpdate["email"] = value;
                              },
                            ),
                          )
                        else
                          Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                userExisting?.email ?? "Unconfirmed",
                                style: const TextStyle(
                                    color: Color(0xFF717171),
                                    fontWeight: FontWeight.w400,
                                    fontSize: 16),
                              ),
                              const SizedBox(
                                height: 5,
                              ),
                              SizedBox(
                                width: size.width * 0.8,
                                child: Center(
                                  child: Container(
                                    height: 1.0,
                                    color: Colors.grey,
                                  ),
                                ),
                              ),
                            ],
                          )
                      ],
                    ),
                  ],
                ),
                const SizedBox(
<<<<<<< HEAD
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
                      const Row(
                        children: [
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
=======
                  height: 45,
>>>>>>> 0922a4f952e4a39b34db4394c7bf9d68ab8bc865
                ),
                if (isEdit)
                  ElevatedButton(
                    onPressed: () => {
                      //handle edit
                      updateUser(context, size),
                    },
                    child: const Text("Save"),
                  )
              ],
            ),
          ),
        );
      },
    );
  }
}
