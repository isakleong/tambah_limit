
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:tambah_limit/models/resultModel.dart';
import 'package:tambah_limit/tools/function.dart';

class Messagehandler extends StatefulWidget {

  const Messagehandler({Key key}) : super(key: key);

  @override
  MessageHandlerState createState() => MessageHandlerState();

}

class MessageHandlerState extends State<Messagehandler> {

  Future<void> setupInteractedMessage() async {
    RemoteMessage initialMessage = await FirebaseMessaging.instance.getInitialMessage();

    if(initialMessage != null) {
      _handleMessage(initialMessage);
    }

    FirebaseMessaging.onMessageOpenedApp.listen(_handleMessage);
  }

  void _handleMessage(RemoteMessage message) {
    Result result = new Result(success: 1, message: "notification", data: message);
    if (message.data['type'] == 'chat') {
      Navigator.pushNamed(context, 
        '/chat', 
        arguments: result,
      );
    } else {
      printHelp("MASUK SINI OII");
      Navigator.pushNamed(context, 
        '/chat', 
        arguments: result,
      );
    }
  }

  @override
  void initState() {
    super.initState();

    setupInteractedMessage();
  }

  @override
  Widget build(BuildContext context) {
    return Container();
  }
  

}