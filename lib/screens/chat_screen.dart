import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flash_chat/constants.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
final _firestore=FirebaseFirestore.instance;
User loggedinuser;

class ChatScreen extends StatefulWidget {
  static const String id='chatscreen';
  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
final messagetextcontroller=TextEditingController();
  final _auth=FirebaseAuth.instance;

  String messagetext;
  @override
  void initState() {
    super.initState();
   getcurrentuser();
  }

  void getcurrentuser() async{
    try {
      final user = await _auth.currentUser;
      if (user != null) {
        loggedinuser = user;
        print(loggedinuser.email);
      }
    }catch(e){
      print(e);
    }
  }




  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: null,
        actions: <Widget>[
          IconButton(
              icon: Icon(Icons.close),
              onPressed: () {
                _auth.signOut();
                Navigator.pop(context);
              }),
        ],
        title: Text('⚡️Chat'),
        backgroundColor: Colors.lightBlueAccent,
      ),
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
           messagestream(),
            Container(
              decoration: kMessageContainerDecoration,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Expanded(
                    child: TextField(
                      controller: messagetextcontroller,
                      onChanged: (value) {
                        messagetext=value;
                      },
                      decoration: kMessageTextFieldDecoration,
                    ),
                  ),
                  FlatButton(
                    onPressed: () {
                      messagetextcontroller.clear();
                      _firestore.collection('messages').add({

                        'text':messagetext,
                        'sender':loggedinuser.email,
                        'time': FieldValue.serverTimestamp()
                      });
                    },
                    child: Text(
                      'Send',
                      style: kSendButtonTextStyle,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
class messagestream extends StatelessWidget {


  @override
  Widget build(BuildContext context) {
    return  StreamBuilder<QuerySnapshot>(
      stream: _firestore.collection('messages').orderBy('time', descending: false).snapshots(),
      builder: (context,snapshot){
        if(!snapshot.hasData){
          return Center(
              child:CircularProgressIndicator(
                backgroundColor: Colors.lightBlueAccent,
              )
          );
        }
        final messages=snapshot.data.docs.reversed;
        List<messagebubble> messagesbubbles=[];
        for(var message in messages){
          Map messagetexts=message.data();
          final messagetext=messagetexts['text'];
          Map messagesenders=message.data();
          final messagesender=messagetexts['sender'];
          final currentuser=loggedinuser.email;
          Map messagesenderstime=message.data();
          final messageTime = messagesenderstime['time'] as Timestamp;
          final messagesbubble=messagebubble(sender: messagesender,text: messagetext,isme: currentuser==messagesender,time: messageTime,);
          messagesbubbles.add(messagesbubble);
        }
        return Expanded(
          child: ListView(
            reverse: true,
            padding: EdgeInsets.symmetric(horizontal: 10.0,vertical: 20.0),
            children: messagesbubbles,
          ),
        );


      },
    );
  }
}


class messagebubble extends StatelessWidget {
  messagebubble({this.text,this.sender,this.isme,this.time});
final String sender;
final String text;
 final bool isme;
  final Timestamp time;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding:  EdgeInsets.all(10.0),
      child: Column(
         crossAxisAlignment: isme? CrossAxisAlignment.end:CrossAxisAlignment.start,
        children: [
          Text(sender,
          style: TextStyle(
            fontSize: 12.0,
            color: Colors.black54,

          ),),
          Material(
            borderRadius: isme? BorderRadius.only(topLeft: Radius.circular(30.0),bottomLeft:Radius.circular(30.0),bottomRight:Radius.circular(30.0)):
            BorderRadius.only(topRight: Radius.circular(30.0),bottomLeft:Radius.circular(30.0),bottomRight:Radius.circular(30.0)),
            elevation: 5.0,
            color: isme? Colors.lightBlueAccent:Colors.white,
            child: Padding(
              padding:  EdgeInsets.symmetric(vertical: 10.0,horizontal: 20.0),
              child: Text('$text',
                style: TextStyle(
                  fontSize: 15.0,
                  color: isme? Colors.white: Colors.black54,
                ),),
            ),
          ),
        ],
      ),
    )   ;
  }
}

