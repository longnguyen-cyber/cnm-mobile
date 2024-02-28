import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:zalo_app/model/channel.model.dart';
import 'package:zalo_app/model/common.model.dart';
import 'package:zalo_app/repository/channel_repo.dart';

part 'channel_state.dart';

class ChannelCubit extends Cubit<ChannelState> {
  final ChannelRepository channelRepo;

  ChannelCubit({required this.channelRepo}) : super(ChannelInitial());

  Future<void> getAllChannels() async {
    try {
      var channels = await channelRepo.getAllChannels();
      emit(GetAllChannelsLoaded(channels: channels));
    } catch (e) {
      if (kDebugMode) {
        print(e.toString());
      }
    }
  }

  Future<void> getChannel(String id) async {
    try {
      var channel = await channelRepo.getChannel(id);
      emit(GetChannelLoaded(channel: channel!));
    } catch (e) {
      if (kDebugMode) {
        print(e.toString());
      }
    }
  }

  Future<void> deteteChannel(String id) async {
    try {
      await channelRepo.deteteChannel(id);
      emit(DeteteChannelLoaded());
    } catch (e) {
      if (kDebugMode) {
        print(e.toString());
      }
    }
  }

  Future<void> deleteUserOfChannel(String id, List<String> users) async {
    try {
      await channelRepo.deleteUserOfChannel(id, users);
      emit(DeleteUserOfChannelLoaded());
    } catch (e) {
      if (kDebugMode) {
        print(e.toString());
      }
    }
  }

  Future<void> updateRoleUserOfChannel(
      String id, String userId, String role) async {
    try {
      await channelRepo.updateRoleUserOfChannel(id, userId, role);
      emit(UpdateRoleUserOfChannelLoaded());
    } catch (e) {
      if (kDebugMode) {
        print(e.toString());
      }
    }
  }

  Future<void> leaveChannel(String id, String transferOwner) async {
    try {
      await channelRepo.leaveChannel(id, transferOwner);
      emit(LeaveChannelLoaded());
    } catch (e) {
      if (kDebugMode) {
        print(e.toString());
      }
    }
  }

  Future<void> addUserToChannel(String id, List<RoleUser> users) async {
    try {
      await channelRepo.addUserToChannel(id, users);
      emit(AddUserToChannelLoaded());
    } catch (e) {
      if (kDebugMode) {
        print(e.toString());
      }
    }
  }

  Future<void> createChannel(
      String name, bool isPublic, List<String> members) async {
    try {
      await channelRepo.createChannel(name, isPublic, members);
      emit(CreateChannelLoaded());
    } catch (e) {
      if (kDebugMode) {
        print(e.toString());
      }
    }
  }

  //Object contains name and isPublic
  Future<void> updateChannel(String id, Object obj) async {
    try {
      await channelRepo.updateChannel(id, obj);
      emit(UpdateChannelLoaded());
    } catch (e) {
      if (kDebugMode) {
        print(e.toString());
      }
    }
  }
}
