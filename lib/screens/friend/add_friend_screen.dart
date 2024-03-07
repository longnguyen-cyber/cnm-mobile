import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:zalo_app/blocs/bloc_user/user_cubit.dart';
import 'package:zalo_app/components/customer_text_field.dart';
import 'package:zalo_app/components/index.dart';
import 'package:zalo_app/components/user_item.dart';
import 'package:zalo_app/constants.dart';
import 'package:zalo_app/model/user.model.dart';

class AddFriendScreen extends StatefulWidget {
  const AddFriendScreen({super.key});

  @override
  State<AddFriendScreen> createState() => _AddFriendScreenState();
}

class _AddFriendScreenState extends State<AddFriendScreen> {
  late String name = "";
  late List<User> users = [];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Thêm bạn bè'),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
            color: Colors.black,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: BlocBuilder<UserCubit, UserState>(
        builder: (context, state) {
          return Column(
            children: [
              CustomTextField(
                textField: TextFormField(
                  onChanged: (value) {
                    setState(() {
                      name = value;
                    });
                  },
                  style: const TextStyle(
                    fontSize: 20,
                  ),
                  decoration: kTextInputDecoration.copyWith(
                    hintText: 'Nhập tên tài khoản',
                  ),
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              CustomButton(
                buttonText: "Tìm kiếm",
                onPressed: () async {
                  List<User> users =
                      await context.read<UserCubit>().searchUser(name: name);
                  setState(() {
                    this.users = users;
                  });
                },
              ),
              ListView(
                shrinkWrap: true,
                children: [
                  for (int i = 0; i < users.length; i++)
                    UserItem(
                      obj: users[i],
                    )
                ],
              )
            ],
          );
        },
      ),
    );
  }
}
