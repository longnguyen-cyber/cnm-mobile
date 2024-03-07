import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:zalo_app/blocs/bloc_friend/friend_cubit.dart';
import 'package:zalo_app/components/index.dart';
import 'package:zalo_app/config/routes/app_route_constants.dart';
import 'package:zalo_app/model/chat.model.dart';
import 'package:zalo_app/model/user.model.dart';

class Profile extends StatefulWidget {
  const Profile({super.key, this.user});
  final User? user;

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  @override
  Widget build(BuildContext context) {
    late bool isRequest = false;
    late String chatId = "";
    Size size = MediaQuery.of(context).size;
    //  User(id: 65dd4ae4cbeffa04dbbc5b16, name: nesw, password: null, displayName: null, status: null, phone: null, email: 01635080905l@gmail.com, avatar: null, isTwoFactorAuthenticationEnabled: null, twoFactorAuthenticationSecret: null)
    User userDefine = User(
      id: '65dd4ae4cbeffa04dbbc5b16',
      name: 'nesw',
      password: null,
      displayName: "kuga",
      status: null,
      phone: "01635080905",
      email: '01635080905l@gmail.com',
      avatar:
          "https://workchat.s3.ap-southeast-1.amazonaws.com/Screenshot-from-2024-02-25-13-48-02.png",
      isTwoFactorAuthenticationEnabled: null,
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
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
      body: Center(
          child: Column(
        children: [
          const SizedBox(
            height: 20,
          ),
          Stack(
            clipBehavior: Clip.none,
            children: [
              Image(
                image: NetworkImage(userDefine.avatar!),
                width: size.width * 0.9,
                height: 200,
                fit: BoxFit.cover,
              ),
              Positioned(
                top: 120,
                left: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.all(5),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: Align(
                    alignment: Alignment.center,
                    child: CircleAvatar(
                      radius: 50,
                      backgroundImage: NetworkImage(userDefine.avatar!),
                    ),
                  ),
                ),
              )
            ],
          ),
          const SizedBox(
            height: 40,
          ),
          Text(
            "${userDefine.name!}(${userDefine.displayName!})",
            style: const TextStyle(
              fontSize: 20,
            ),
          ),
          BlocBuilder<FriendCubit, FriendState>(
            builder: (context, state) {
              if (state is FriendInitial) {
                context
                    .read<FriendCubit>()
                    .getFriendChatWaittingAccept(userDefine.id!);
              } else if (state is FriendChatWaittingAccept) {
                Chat chat = state.chat;
                if (chat.requestAdd) {
                  isRequest = true;
                }
              }
              return _isRequest(isRequest);
            },
          ),
          const SizedBox(
            height: 20,
          ),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 20),
            child: BlocBuilder<FriendCubit, FriendState>(
              builder: (context, state) {
                if (state is FriendInitial) {
                  context
                      .read<FriendCubit>()
                      .getFriendChatWaittingAccept(userDefine.id!);
                } else if (state is FriendChatWaittingAccept) {
                  Chat chat = state.chat;
                  if (chat.requestAdd) {
                    isRequest = true;
                    chatId = chat.id!;
                  }
                }
                return Row(
                  children: [
                    Expanded(
                        child: CustomButton(
                            buttonText: "Nhắn tin",
                            onPressed: () {
                              GoRouter.of(context).pushNamed(
                                  MyAppRouteConstants.detailChatRouteName,
                                  extra: {"id": chatId, "type": "chat"});
                            })),
                    const SizedBox(
                      width: 20,
                    ),
                    ElevatedButton(
                      onPressed: () async {
                        if (isRequest) {
                          Future<bool> rs = context
                              .read<FriendCubit>()
                              .unReqAddFriend(chatId);
                          bool result = await rs;
                          if (result) {
                            isRequest = false;
                            // ignore: use_build_context_synchronously
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text("Đã hủy lời mời kết bạn"),
                              ),
                            );
                          }
                        } else {
                          Future<bool> rs = context
                              .read<FriendCubit>()
                              .reqAddFriend(userDefine.id!);

                          bool result = await rs;
                          if (result) {
                            isRequest = true;
                            // ignore: use_build_context_synchronously
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text("Đã gửi lời mời kết bạn"),
                              ),
                            );
                          }
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        padding: const EdgeInsets.all(0),
                      ),
                      child: SizedBox(
                        height: 60,
                        width: 80,
                        child: isRequest
                            ? const Icon(
                                Icons.person_remove_alt_1_sharp,
                                size: 30,
                              )
                            : const Icon(
                                Icons.person_add_alt_1_rounded,
                                size: 30,
                              ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      )),
    );
  }

  _isRequest(bool isRequest) {
    if (isRequest) {
      return const Text("Đã gửi lời mời kết bạn");
    } else {
      return const Text("");
    }
  }
}
