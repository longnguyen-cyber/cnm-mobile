import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:zalo_app/blocs/bloc_user/user_cubit.dart';
import 'package:zalo_app/components/user_item.dart';
import 'package:zalo_app/model/user.model.dart';
import 'package:zalo_app/services/api_service.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  late List<dynamic> users = [];
  final api = API();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        backgroundColor: Colors.blue,
        title: TextField(
          // controller: _searchController,
          style: const TextStyle(color: Colors.white),
          cursorColor: Colors.white,
          decoration: const InputDecoration(
            hintText: 'Tìm kiếm',
            hintStyle: TextStyle(color: Colors.white54),
            border: InputBorder.none,
          ),

          onChanged: (value) async {
            // Perform search functionality here
            if (value.isEmpty) {
              setState(() {
                users = [];
              });
              return;
            }
            final response = await api.get("users/search/$value", {});
            if (response != null) {
              var data = response['data'];
              if (data != null) {
                setState(() {
                  users = data;
                });
              }
            }
          },
        ),
        actions: <Widget>[
          IconButton(
            icon: const Icon(
              Icons.qr_code,
              color: Colors.white,
            ),
            onPressed: () {},
          ),
          IconButton(
              icon: const Icon(
                Icons.add,
                color: Colors.white,
              ),
              onPressed: () {}),
        ],
      ),
      body: ListView(
        children: [
          for (int i = 0; i < users.length; i++)
            UserItem(
              obj: User.fromMap(users[i]["user"]),
              chatId: users[i]["chatId"],
            )
        ],
      ),
    );
  }
}
