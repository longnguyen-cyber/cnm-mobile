// import 'package:flutter/widgets.dart';
// import 'package:zego_uikit_prebuilt_call/zego_uikit_prebuilt_call.dart';
// import 'package:flutter_dotenv/flutter_dotenv.dart';

// class CallPage extends StatelessWidget {
//   const CallPage(
//       {super.key,
//       required this.callID,
//       required this.userID,
//       required this.userName});
//   final String callID;
//   final String userID;
//   final String userName;

//   @override
//   Widget build(BuildContext context) {
//     var appId = int.parse(dotenv.env["APP_ID"].toString());
//     var appSign = dotenv.env["APP_SIGN"];
//     return ZegoUIKitPrebuiltCall(
//       appID:
//           appId, // Fill in the appID that you get from ZEGOCLOUD Admin Console.
//       appSign: appSign
//           .toString(), // Fill in the appSign that you get from ZEGOCLOUD Admin Console.
//       userID: userID, // thay thành user_id
//       userName: userName, // thay thành user_name
//       callID: callID,
//       // You can also use groupVideo/groupVoice/oneOnOneVoice to make more types of calls.
//       config: ZegoUIKitPrebuiltCallConfig.oneOnOneVideoCall(),
//     );
//   }
// }
