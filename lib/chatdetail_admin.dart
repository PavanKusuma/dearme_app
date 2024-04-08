import 'dart:convert';
import 'dart:ui';

// import 'package:feather_icons_flutter/feather_icons_flutter.dart';
import 'package:just_audio/just_audio.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:psych_app/background_app.dart';
import 'package:psych_app/modal/chat.dart';
import 'package:psych_app/modal/chats.dart';

import 'package:psych_app/util/appheader1.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:psych_app/appointment_new.dart';
import 'package:psych_app/util/api_urls.dart';
import 'package:psych_app/util/constants.dart' as Constants;
import 'package:http/http.dart' show get;
import 'package:psych_app/util/divider.dart';
import 'package:psych_app/util/palette.dart';
import 'package:psych_app/util/progress.dart';
import 'package:psych_app/util/show_toast.dart';
// import 'package:psych_app/util/show_toast.dart';
import 'package:psych_app/util/sizedbox.dart';
import 'package:psych_app/util/utils.dart';
import 'package:psych_app/util/verticalline.dart';
import 'dart:typed_data';
import 'package:socket_io_client/socket_io_client.dart' as IO;


abstract class AnimationControllerState<T extends StatefulWidget>
    extends State<T> with SingleTickerProviderStateMixin {
  AnimationControllerState(this.animationDuration);
 
  final Duration animationDuration;
  late final animationController =
      AnimationController(vsync: this, duration: animationDuration);
 
  @override
  void dispose() {
    animationController.dispose();
    super.dispose();
  }
}

class ChatDetailAdmin extends StatefulWidget {
  final Chats chats;

  ChatDetailAdmin({required this.chats});


  @override
  ChatDetailAdminState createState() => ChatDetailAdminState();
}

class ChatDetailAdminState extends State<ChatDetailAdmin> with AutomaticKeepAliveClientMixin, TickerProviderStateMixin<ChatDetailAdmin> {

// late GlobalKey<FormState> _formKey;

  DateTime today = DateTime.now();
  ScrollController? scrollController;
  String? username, collegeId = '';
  bool isLoading = true;
  bool isDataAvailable = false;
  bool showWarning = false;
  bool isClosing = false;
  int offset = 0;
  int year = 0;
  // bool refreshQR = false;
  String universityId= '', role = '', type = '', branch = '', campusId = '', course = '', gcmRegId = '';
  TextEditingController messageController = new TextEditingController();
  List<Chat> list = [];
  String emptyStateMsg = '';
  bool showCreateCTA = true;

  Animation<double>? _animation;

  // audio element to play sound
  AudioPlayer player = AudioPlayer();
  late AnimationController _animationController;
 
  // connection status
  bool connectionStatus = true;
  bool first = true;
  late IO.Socket socket;

  @override
  void initState(){

super.initState();

print('started init');
initSocket();
  // _formKey = GlobalKey();

// print(Provider.of<SharedState>(context).isDataLoaded);
    getUserData();
    if(list.isEmpty ) {

      getChatDetailAdminData();
      // getOfficialDates();
    }
    
    scrollController = new ScrollController()..addListener(_scrollListener);
    // super.initState();
    
    _animationController = AnimationController(duration: const Duration(milliseconds: 500),vsync: this,);
    // _animationController.repeat();
    
  }


  initSocket(){
    socket = IO.io('https://piltovr.com/socket.io', <String, dynamic>{
      'autoConnect': false,
      'transports': ['websocket'],
    });
    socket.connect();
    socket.onConnect((_) {
      print('Connection established!');
      startSocketMessage();
    });
    // socket.on('message1',(message) {
    //     print('hello!');
    //     print("This is the message from server: \n"+message);
            
    //         // // set the messages
    //         // if(roomName1 == roomName){
    //         //     setMessages([...messages, {"message":message,"date":date}])
    //         // }
    //         // else {
    //         //     print('Not this id');
    //         // }
    //     });
    

    socket.onDisconnect((_) {
      print('Disconnected!');
    });
    // socket.onAny( (event, data) => {
    //   print('OKOKOKOK'),
    //   print(data[0])});
    // socket.on('message1', (data) {
    //   print('data data data data data');
    //   print(data);
    //   // setState(() {
    //   //   socketMsgs.add(data);
    //   // });
    // });

    socket.onConnectError((err1) {
      print(err1);
    });
    socket.onError((err) {
      print(err);
    });
  }

   @override
  void dispose() {
    socket.disconnect();
    socket.dispose();
    // _formKey.currentState?.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void getUserData() async {
    
    SharedPreferences preferences = await SharedPreferences.getInstance();
    // get the userObjectId from storage
    if(preferences.containsKey(Constants.username)){
      
      
      setState(() {
        emptyStateMsg = 'Fetching your data securely. Please wait...';
        universityId = preferences.getString(Constants.universityId)!;  
        username = preferences.getString(Constants.username)!;
        collegeId = preferences.getString(Constants.collegeId)!;
        role = preferences.getString(Constants.role)!;  
        type = preferences.getString(Constants.type)!;  
        branch = preferences.getString(Constants.branch)!;
        campusId = preferences.getString(Constants.campusId)!;
        course = preferences.getString(Constants.course)!;
        gcmRegId = preferences.getString(Constants.gcmRegId)!;
        year = preferences.getInt(Constants.year)!;


        // assign the default selected branch
        branch = branch.split(',')[0];
        
      });
      
    }

   
  }


  void startSocketMessage() {

    // Map<String, String> dataObj;
    Chat chatMessage;
      socket.on('help', (data) => {
        
        chatMessage = Chat.fromJson(jsonDecode(data)),
print(chatMessage.message),
        if(chatMessage.collegeId == widget.chats.collegeId){
          
          list.add(chatMessage),
          _animationController.forward(),
          scrollController!.jumpTo(scrollController!.position.maxScrollExtent),
      
          // play the sound
          player.setAsset('assets/incoming.mp3'),
          player.play()

        }
      });
  }

// 1 stage
// 2 collegeId
// 3 offset
  // get the chat data
  void getChatDetailAdminData() async {

    if(await checkInternetConnectivity()){
      
      // set connection status variable to true
      setState(() {
        connectionStatus = true;
        first = false;
      });
      

      // query parameters    
      Map<String, String> queryParams = {};

      // API call
      print("${APIUrls.chat}${APIUrls.pass}/S3/${widget.chats.collegeId}/$offset");
      var result = await get(Uri.parse(APIUrls.getUrl("${APIUrls.chat}${APIUrls.pass}/S3/${widget.chats.collegeId}/$offset", queryParams)), headers: {"Accept": "application/json"});
      print(result.body);
      
      // get the result body which is JSON
      var jsonString = jsonDecode(result.body); 
      
      // convert jsonString to Map
      var jsonObject = jsonString as Map; 

      List<Chat> list1;
      // check if the api returned success
      if(jsonObject['status'] == 200){
        // get the list data from jsonObject
        var requests = jsonObject['data'] as List;

        if(requests.isNotEmpty){
          // convert to list
          list1 = requests.map<Chat>((json) => Chat.fromJson(json)).toList();

          if(list1.isNotEmpty){
            // update the list items and toggle the loading
            setState(() {
              // list.clear();
              list.addAll(list1);

              // segregate between old and new items
              // for (var element in list1) {
              //   if(element.isOpen == 1){
              //     // list.add(element);
              //     showCreateCTA = false;
              //   }
              //   // else {
              //   //   oldList.add(element);
              //   // }
              // }
              
              isLoading = false;
              isDataAvailable = true;
            });
          }
          else {
            // no requests
            setState(() {
              emptyStateMsg = 'No pending requests';
              isLoading = false;
              isDataAvailable = false;
            });
          }

        }
        else {
          // no requests
          setState(() {
            emptyStateMsg = 'No pending requests';
            isLoading = false;
            isDataAvailable = false;
          });
        }

      
      }
      else {
          // no requests
          setState(() {
            emptyStateMsg = 'No pending requests';
            isLoading = false;
            isDataAvailable = false;
          });
        }
    }
    else {
        Future.delayed(const Duration(seconds: 2), () {

          // this is to check for retrying only once more. Else it will end the loop
          if(connectionStatus)
          {
            getChatDetailAdminData();
            // print('Again trying');
          
            // set the connection Status variable to false
            setState(() {
              connectionStatus = false;
              isLoading = false;
              isDataAvailable = false;
            });
          }
        });
      }
  }



  // 1 stage
  // 2 collegeId
  // 3 adminId
  // 4 message
  // 5 campusId
  void createChat() async {

    if(await checkInternetConnectivity()){
      
      if(messageController.text.isNotEmpty){

        // set connection status variable to true
        setState(() {
          connectionStatus = true;
          first = false;
        });
        
        
        var C = randomString("C");

        Chat chatMessage = new Chat();
        chatMessage.chatId = C;
        chatMessage.collegeId = widget.chats.collegeId;
        chatMessage.adminId = collegeId;
        chatMessage.message = messageController.text;
        chatMessage.sentAt = "just now";
        chatMessage.sentBy = collegeId;
        chatMessage.chatDate = today.toString();
        chatMessage.campusId = campusId;


        // query parameters    
        Map<String, String> queryParams = {};

        // API call
        print("${APIUrls.chat}${APIUrls.pass}/S1/$C/${widget.chats.collegeId}/$collegeId/${Uri.encodeComponent(messageController.text)}/$collegeId/$campusId");
        var result = await get(Uri.parse(APIUrls.getUrl("${APIUrls.chat}${APIUrls.pass}/S1/$C/${widget.chats.collegeId}/$collegeId/${Uri.encodeComponent(messageController.text)}/$collegeId/$campusId", queryParams)), headers: {"Accept": "application/json"});
        print(result.body);
        
        // get the result body which is JSON
        var jsonString = jsonDecode(result.body); 
        
        // convert jsonString to Map
        var jsonObject = jsonString as Map; 

        // check if the api returned success
        if(jsonObject['status'] == 200){

            // emit the data
            socket.emit('helpme', jsonEncode(chatMessage.toJson()));
          
              setState(() {
                // list.clear();
                messageController.text = '';
                list.add(chatMessage);
                _animationController.forward();
                scrollController!.jumpTo(scrollController!.position.maxScrollExtent);

                isLoading = false;
                isDataAvailable = true;
              });

            // play the sound
            player.setAsset('assets/outgoing.mp3');
            player.play();
        }
        else {
            // no requests
            setState(() {
              emptyStateMsg = 'No pending requests';
              isLoading = false;
              isDataAvailable = false;
            });
          }



        }
        else {
          showToast(context, "Type message to send", Constants.warning);
        }
      }
      else {
          Future.delayed(const Duration(seconds: 2), () {

            // this is to check for retrying only once more. Else it will end the loop
            if(connectionStatus)
            {
              getChatDetailAdminData();
              // print('Again trying');
            
              // set the connection Status variable to false
              setState(() {
                connectionStatus = false;
                isLoading = false;
                isDataAvailable = false;
              });
            }
          });
        }
  

  }
  
  // detect scroll to end and load more items
  void _scrollListener(){
    if(scrollController!.position.pixels == scrollController!.position.maxScrollExtent){
      setState(() {
        // increment offset by 5
        if(list.length-5 == offset){
          offset = offset+5;
          // show up the loader
          startLoader();
        }
        else {
          //print('do nothing');
          
        }
      });
    }
  }

  // show the loader while loading more items
  void startLoader(){
    setState((){
      isLoading = !isLoading;
      getChatDetailAdminData();
      // getOfficialDates();
    });
  }

@override
Widget build(BuildContext context) {
  return 
//   Scaffold(
// resizeToAvoidBottomInset: true,
//     body: 
//     SafeArea(
      
      Scaffold(
      resizeToAvoidBottomInset: true,
       backgroundColor: Colors.white,
        body: Stack(
          
          children: [
            // Container(
            //   child:  BackgroundGradient(),
            // ),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    // Colors.pink.withOpacity(0.3),
                    // Colors.black.withOpacity(0.3),

                    //  Colors.black45.withOpacity(0.3),
                    
                    Colors.grey.withOpacity(0.3),
                    Colors.grey.withOpacity(0.1),
                    // Colors.black45.withOpacity(0.3),
                  ],
                ),
              ),
            ),
            Positioned.fill(
              child: 
              Container(
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/nois.png'),
                  repeat: ImageRepeat.repeat, // Tile the image across the screen
                  opacity: 0.3
                ),
              ),
              
            ),
            ),


            Align(
              alignment: Alignment.topCenter,
              child:  SafeArea(
      child: 
          Builder(builder: (context) => Container(
                                
            child:
    Column(
      crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            // Container(
            //   padding: const EdgeInsets.fromLTRB(16, 4, 16, 4),
            //   child: AppHeader1(widget.chats.collegeId.toString(), 'Annonymous chat • Access privately', 0, connectionStatus),
            // ),

            
               Container(
                margin: const EdgeInsets.all(16),
                child: 
                  
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          InkWell(
                            onTap: () => 

                                // show dialog to confirm exit
                                Navigator.pop(context)
                              ,
                            child: Container(
                                    padding: const EdgeInsets.all(16),
                                    child: const Icon(PhosphorIconsBold.arrowBendUpLeft),
                          ),
                        ),
                        Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    
                    children: [ 
                        Text(widget.chats.collegeId.toString(), style: GoogleFonts.dmSerifText(textStyle: Theme.of(context).textTheme.displaySmall, fontWeight: FontWeight.bold)), 
                         sizedBox(8),
                        Text('Anonymous Chats • Access privately', style: GoogleFonts.dmSans(textStyle: Theme.of(context).textTheme.titleMedium, color: Colors.black54)), 
                        // sizedBox(8)
                      ],),
                        
                       
                      ],
                    ),
              ),

            Expanded(
              child: isLoading ? 
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          // loader while fetching data
                          isLoading? const AppProgress(height: 30, width: 30,) : new SizedBox(height: 0,),
                          Container(
                          alignment: Alignment.center,
                          child: Text(emptyStateMsg, style: GoogleFonts.dmSans(textStyle: Theme.of(context).textTheme.bodyMedium)), 
                        )
                      ],)
                      : 
                      (list.isNotEmpty) ?
              RefreshIndicator(
                onRefresh: () async {
                  // Implement your refresh logic, like fetching data from an API
                  print('Page refreshed!');
                  await Future.delayed(const Duration(seconds: 1)); // Simulating network call delay
                },
                child:  ListView.builder(
                        controller: scrollController,
                        scrollDirection: Axis.vertical,
                        itemCount: list.length,
                        itemBuilder: (context, index){
                          final animation = CurvedAnimation(
                            parent: _animationController!,
                            curve: Curves.easeIn,
                            reverseCurve: Curves.easeOut,
                          );
                          return AnimatedSize(
                                  duration: const Duration(seconds: 1),
                                  curve: Curves.easeIn,
                                  child: Transform.translate(
                                    offset: Tween<Offset>(
                                      begin: Offset(0, 1),
                                      end: Offset(0, 0),
                                    ).animate(animation).value,
                                    child: myRequestCard(index, context),
                                  ),
                                );
                          // return Container(
                            
                          //       child: myRequestCard(index, context),
                          //     );
                        }),
              )
              : 
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            mainAxisSize: MainAxisSize.max,
                            children: [
                              // loader while fetching data
                              // isLoading? AppProgress(height: 30, width: 30,) : new SizedBox(height: 0,),
                              Icon(PhosphorIconsRegular.checkCircle),
                              Container(
                                alignment: Alignment.center,
                                child: Text('No history available!', style: GoogleFonts.dmSans(textStyle: Theme.of(context).textTheme.bodyText2)), 
                            ),
                            sizedBox(8),
                            
                      ],),
            ),
            Container(
              padding: EdgeInsets.all(8),
              child: 
            Row(
              children: <Widget>[
                 Expanded(
                  // child: Padding(
                  //   padding: EdgeInsets.symmetric(horizontal: 8.0),
                    child: 
                    TextFormField(
                      style: GoogleFonts.dmSans(textStyle: Theme.of(context).textTheme.bodyLarge),
                      // autofocus: true,
                      controller: messageController,
                      minLines: 1,
                      maxLines: 4,
                      // maxLength: 120,
                      keyboardType: TextInputType.text,
                      decoration: InputDecoration(   
                        hintStyle: GoogleFonts.dmSans(textStyle: Theme.of(context).textTheme.bodyLarge),
                        counterText: '',         
                          hintText: 'Type here...',          
                          contentPadding: EdgeInsets.fromLTRB(12, 8, 12, 8),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: const BorderSide(
                            color: Colors.black26, // Uses shadowColor for focus
                            width: 1.0,
                          ),
                        ),
                      
                      ),
                    
                      validator: (value) { // validator function is called on calling form validate() method
                        if (value!.isEmpty) {
                          return 'Type to send';
                        }
                        return null;
                      },
                      //onSaved: (value) => description = value,
                    ),
                  
                ),
                InkWell(
                    // onTap: () => createSocketMessage(),
                    onTap: () => createChat(),
                  child: Container(
                    padding: EdgeInsets.fromLTRB(16, 8, 14, 8),
                    
                    decoration: BoxDecoration(
                        // color: Palette.blue,
                        border: Border.all(color: Color(0x336302E5)),
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                    
                      alignment: Alignment.center,
                      child: Icon(PhosphorIconsFill.paperPlaneRight, color: Color(0xFF6302E5), size: 24, ),
                  ),

                )
              ],
            )
            ),
          ],
        ),
      
//     SafeArea(child: 
//           Builder(builder: (context) => Container(
//                     padding: const EdgeInsets.fromLTRB(16, 4, 16, 4),
//             child: Column(
//               children: [

//                  Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
              
//               children: [ 
//                   AppHeader1('Anonymous Chats', 'Access privately', 0, connectionStatus),
                  
//                 ],
//               ),
                
//                 Expanded(
//                   // child: list.isEmpty ? 
//                   child: isLoading ? 
//                       Column(
//                         mainAxisAlignment: MainAxisAlignment.end,
//                         mainAxisSize: MainAxisSize.max,
//                         children: [
//                           // loader while fetching data
//                           isLoading? const AppProgress(height: 30, width: 30,) : new SizedBox(height: 0,),
//                           Container(
//                           alignment: Alignment.center,
//                           child: Text(emptyStateMsg, style: GoogleFonts.inter(textStyle: Theme.of(context).textTheme.bodyMedium)), 
//                         )
//                       ],)
//                       : 
//                       (list.isNotEmpty) ?
                      
//                           RefreshIndicator(
//                               onRefresh: _refreshList,
//                               child: 
//                                 ListView.builder(

//                                 // controller: scrollController,
//                                 scrollDirection: Axis.vertical,
//                                 itemCount: list.length,
//                                 itemBuilder: (context, index){
                                  
//                                   return Container(
                                    
//                                         child: myRequestCard(index, context),
//                                       );
//                                 })
                          
//                             )
                        
//                           : 
//                           Column(
//                             mainAxisAlignment: MainAxisAlignment.center,
//                             mainAxisSize: MainAxisSize.max,
//                             children: [
//                               // loader while fetching data
//                               // isLoading? AppProgress(height: 30, width: 30,) : new SizedBox(height: 0,),
//                               Icon(PhosphorIconsRegular.checkCircle),
//                               Container(
//                                 alignment: Alignment.center,
//                                 child: Text('No history available!', style: GoogleFonts.inter(textStyle: Theme.of(context).textTheme.bodyText2)), 
//                             ),
//                             sizedBox(8),
                            
//                       ],)
                     

                      
                
//             ),
//               ],
//             ),
//           ),
//         ),
          
//       ),
//     bottomNavigationBar: Container(
      
//       child: 
//      BottomAppBar(
//       height: 120,
//         child: 
        
//         Row(
//           mainAxisSize: MainAxisSize.max,
//                 children: [
//                   Expanded(child: 

//                     TextFormField(
//                       controller: messageController,
//                       minLines: 2,
//                       maxLines: 4,
//                       // maxLength: 120,
//                       keyboardType: TextInputType.text,
//                       decoration: InputDecoration(
                        
  
//     contentPadding: EdgeInsets.fromLTRB(12, 8, 12, 8),
//   focusedBorder: OutlineInputBorder(
//     borderRadius: BorderRadius.circular(10),
//     borderSide: BorderSide(
//       color: Theme.of(context).shadowColor, // Uses shadowColor for focus
//       width: 2.0,
//     ),
//   ),
 
// ),
                   
//                       validator: (value) { // validator function is called on calling form validate() method
//                         if (value!.isEmpty) {
//                           return 'Provide reason to proceed';
//                         }
//                         return null;
//                       },
//                       //onSaved: (value) => description = value,
//                     ),
//                   ),
//                   Container(
//                     decoration: BoxDecoration(
//                         color: Palette.red,
//                         shape: BoxShape.circle,
//                       ),
//                     width: 16,
//                     height: 16,
//                       alignment: Alignment.center,
//                       child: Icon(PhosphorIconsBold.paperPlane, color: Palette.white, size: 16, ),
//                   ),
//                   Container(

//                     child: Icon(PhosphorIconsBold.paperPlane, size: 16, ),
//                   )
//                 ],
//               )
        
       
  )))
  )]));
}

  // @override
//   Widget build(BuildContext context){
  
//   return Scaffold(
      
//       body: SafeArea(

//         child: 
        
      
//         Builder(builder: (context) => Container(
//         padding: const EdgeInsets.fromLTRB(16, 4, 16, 4),
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//           crossAxisAlignment: CrossAxisAlignment.center,
//           mainAxisSize: MainAxisSize.max,
//           children: <Widget>[

            
//             // Row(
//             //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
              
//             //   children: [ 
//                   AppHeader1('Anonymous Chats', 'Access privately', 0, connectionStatus),
                  
//                   // IconButton(
//                   //   onPressed: () => 
//                   //     Navigator.push(context, MaterialPageRoute(builder: (context) => ChatDetailAdminHistory())),
//                   //   iconSize: 36.0,
//                   //   icon: Icon(PhosphorIconsRegular.clockCounterClockwise,color: Palette.textShade1,size: 24.0,),
//                   //   color: Palette.primary,
//                   // )
//               //   ],
//               // ),
              
              
            
//                 Expanded(
//                   // child: list.isEmpty ? 
//                   child: isLoading ? 
//                       Column(
//                         mainAxisAlignment: MainAxisAlignment.end,
//                         mainAxisSize: MainAxisSize.max,
//                         children: [
//                           // loader while fetching data
//                           isLoading? const AppProgress(height: 30, width: 30,) : new SizedBox(height: 0,),
//                           Container(
//                           alignment: Alignment.center,
//                           child: Text(emptyStateMsg, style: GoogleFonts.inter(textStyle: Theme.of(context).textTheme.bodyMedium)), 
//                         )
//                       ],)
//                       : 
//                       (list.isNotEmpty) ?
                      
//                           RefreshIndicator(
//                               onRefresh: _refreshList,
//                               child: 
//                                 ListView.builder(

//                                 // controller: scrollController,
//                                 scrollDirection: Axis.vertical,
//                                 itemCount: list.length,
//                                 itemBuilder: (context, index){
                                  
//                                   return Container(
                                    
//                                         child: myRequestCard(index, context),
//                                       );
//                                 })
                          
//                             )
                        
//                           : 
//                           Column(
//                             mainAxisAlignment: MainAxisAlignment.center,
//                             mainAxisSize: MainAxisSize.max,
//                             children: [
//                               // loader while fetching data
//                               // isLoading? AppProgress(height: 30, width: 30,) : new SizedBox(height: 0,),
//                               Icon(PhosphorIconsRegular.checkCircle),
//                               Container(
//                                 alignment: Alignment.center,
//                                 child: Text('No history available!', style: GoogleFonts.inter(textStyle: Theme.of(context).textTheme.bodyText2)), 
//                             ),
//                             sizedBox(8),
                            
//                       ],)
                     

                      
                
//             ),
//             (list.isNotEmpty) ? Container(
//                 alignment: Alignment.center,
//                 child: Text('Pull down to refresh!', style: GoogleFonts.inter(textStyle: Theme.of(context).textTheme.bodySmall)), 
//               ) : sizedBox(0),


// Container(
//       padding: EdgeInsets.fromLTRB(0, 16, 8, 8),
//       child: 
//       Row(
//         mainAxisAlignment: MainAxisAlignment.start,
//         crossAxisAlignment: CrossAxisAlignment.center,
//         mainAxisSize: MainAxisSize.min,
//         children: <Widget>[
          
          
//           IconButton(icon: Icon(PhosphorIconsBold.arrowBendUpLeft, color: Theme.of(context).hintColor, size: 24,),
//           // IconButton(icon: Icon(Icons.keyboard_backspace, color: Theme.of(context).hintColor, size: 24,),
//           onPressed: () => 
//               Navigator.pop(context)
//             ,
//           ),
          
          
//           Container(
//             padding: EdgeInsets.all(0), 
//             child: Column(
            
//             mainAxisAlignment: MainAxisAlignment.start,
//             crossAxisAlignment: CrossAxisAlignment.start,
//             mainAxisSize: MainAxisSize.min,
            
//             children: <Widget>[

//               Text('header', style: GoogleFonts.inter(textStyle: Theme.of(context).textTheme.titleLarge, fontWeight: FontWeight.w800)),
//               'subHeader'.isNotEmpty ? const SizedBox(
//                 height: 4.0,
//               ) : sizedBox(0),

//               Text('subHeader', style: GoogleFonts.inter(textStyle: Theme.of(context).textTheme.bodySmall)),
//               connectionStatus ? sizedBox(0) : Text('No network detected. Try again later!', style: GoogleFonts.inter(textStyle: Theme.of(context).textTheme.bodySmall, color: Palette.red, fontWeight: FontWeight.bold))
              
//             ],
//           ),)
//         ],
//       ),
        
//     )
//               // Row(
//               //   children: [
//               //     Container(
//               //       decoration: BoxDecoration(
//               //       color: Theme.of(context).cardColor,
//               //       borderRadius: const BorderRadius.all(Radius.circular(10)),
//               //       boxShadow: [
//               //         BoxShadow(
//               //           color: Theme.of(context).shadowColor,
//               //           offset: const Offset(0.0, 0.0),
//               //           // blurRadius: 32.0,
//               //           spreadRadius: 0.3,
//               //         ),
//               //       ]
//               //     ),
                    
//               //       padding: const EdgeInsets.all(4),
//               //       margin: const EdgeInsets.fromLTRB(16, 0, 16, 0),
//               //       child: TextFormField(
//               //         controller: messageController,
//               //         minLines: 2,
//               //         maxLines: 6,
//               //         maxLength: 120,
//               //         keyboardType: TextInputType.text,
//               //         decoration: InputDecoration(
//               //           filled: true,
//               //           fillColor: Theme.of(context).cardColor,
//               //           border: InputBorder.none,
                        
//               //           hintText: 'Type here...',
//               //           // hintText: (_selectedValue == 1) ? 'Reason and going with' : (_selectedValue == 2) ? 'Reason and place of visit' : 'Reason and place of stay',
//               //             ),
//               //         validator: (value) { // validator function is called on calling form validate() method
//               //           if (value!.isEmpty) {
//               //             return 'Provide reason to proceed';
//               //           }
//               //           return null;
//               //         },
//               //         //onSaved: (value) => description = value,
//               //       ),
//               //     ),
//               //     Container(
//               //       decoration: BoxDecoration(
//               //           color: Palette.red,
//               //           shape: BoxShape.circle,
//               //         ),
//               //       width: 16,
//               //       height: 16,
//               //         alignment: Alignment.center,
//               //         child: Icon(PhosphorIconsBold.paperPlane, color: Palette.white, size: 16, ),
//               //     ),
//               //     Container(

//               //       child: Icon(PhosphorIconsBold.paperPlane, size: 16, ),
//               //     )
//               //   ],
//               // )
                
           
//           ],), 


//         ),
//         ),
        
//       )
//     );
//   }

  // create new request
//   createNewRequest(BuildContext context) async{
//     // print(allowedDates.length);
//     // print(blockedDates.length);
//     final result = await Navigator.push(context, MaterialPageRoute(builder: (context) => AppointmentNew()));
    
// // print(result);
//     if(result!=null){

//       // request item
//       Chats chatItem = new Chats();

//       Map<String, dynamic> r =  result;
      
//       chatItem.collegeId = r['collegeId'];
//       chatItem.sentAt = r['sentAt'];
      
//       // add object to list
//       List<Chats> list1 = [];
//       list1.add(chatItem);
//       list1.addAll(list);

//       setState(() {
//         list = list1;
//       });

//       // set the data available to true
//       // so that the user won't be able to create new request again.
//       setState(() {
//         isDataAvailable = true;
//       });
//       getChatDetailAdminData();
//       // show update message
//       // showToast(context, 'Your $requestType request is submitted');


//     }
//   }

 Future<void> _refreshList() async {
    // Add your refresh logic here, e.g. fetching new data from a server
    await Future.delayed(const Duration(seconds: 2));
    setState(() {
        isDataAvailable = true;
      });
    getChatDetailAdminData();
    // getOfficialDates();
  }


  String calculateTimeDifference(DateTime startTime, DateTime endTime) {
  final difference = endTime.difference(startTime);

  if (difference.inDays >= 1) {
    final days = difference.inDays;
    final hours = difference.inHours - days * 24;
    final minutes = difference.inMinutes - (days * 24 * 60) - (hours * 60);
    return '${days} day${days == 1 ? '' : 's'}, ${hours} hr${hours == 1 ? '' : 's'}, ${minutes} min${minutes == 1 ? '' : 's'}';
  } else if (difference.inHours >= 1) {
    final hours = difference.inHours;
    final minutes = difference.inMinutes - (hours * 60);
    return '${hours} hr${hours == 1 ? '' : 's'}, ${minutes} min${minutes == 1 ? '' : 's'}';
  } else {
    final minutes = difference.inMinutes;
    return '${minutes} min${minutes == 1 ? '' : 's'}';
  }
}


// single feed card
Widget myRequestCard(int position, BuildContext context){
  return Container(
    padding: const EdgeInsets.fromLTRB(16, 4, 16, 4),

    // add decoration
    child: 
    Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
       
       
        Row(
          
          mainAxisSize: MainAxisSize.max,
          children: <Widget>[
            Expanded(
              child: 
            Container(
              
              // padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
              child:  Column(
                crossAxisAlignment: (list[position].sentBy == collegeId) ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                          children: [
                            // Text(DateFormat('MMM d, y', 'en_US').format(getDate(list[position].sentAt!)).toUpperCase(), style: GoogleFonts.inter(textStyle: Theme.of(context).textTheme.bodyLarge, fontWeight: FontWeight.w600 )),
                            // sizedBox(4),
                            // Text(DateFormat().add_jm().format(getDate(list[position].sentAt!)).toUpperCase(), style: GoogleFonts.inter(textStyle: Theme.of(context).textTheme.bodyMedium, fontWeight: FontWeight.w600 )),
                            // sizedBox(4),
    
                            Container(
                              padding: EdgeInsets.fromLTRB(16, 8, 16, 8),
                              decoration: BoxDecoration(
                              color: (list[position].sentBy == collegeId) ? Color(0x336302E5) : const Color(0x66FFFFFF),
                              border: Border.all(color: (list[position].sentBy == collegeId) ? Color(0x336302E5) : const Color(0xFFDDDDDD)),
                              // border: Border.all(color: const Color(0xFFFFFFFF)),
                              // color: Color(0xFFFFFFFF),
                              borderRadius: BorderRadius.circular(24),
                              boxShadow: const [
                                BoxShadow(
                                  // color: Colors.black26,
                                  color: Color(0xCCFFFFFF),
                                  // color: Color(0xFF080B23),
                                  offset: Offset(0.0, 0.0),
                                  blurRadius: 24.0,
                                  spreadRadius: 0.3,
                                ),
                              ]
                            ),
                              child: Text(list[position].message!, style: GoogleFonts.dmSans(textStyle: Theme.of(context).textTheme.bodyLarge, color: (list[position].sentBy == collegeId) ? Colors.black : Colors.black87) ),
                            ),
                            sizedBox(4),
                            Text((list[position].sentAt != 'just now') ? DateFormat('MMM dd · hh:mm aa', 'en_US').format(getDate(list[position].sentAt!)) : 'just now', style: GoogleFonts.inter(textStyle: Theme.of(context).textTheme.bodySmall, color: Colors.black45)),      
                            // Text((list[position].sentAt != 'just now') ? DateFormat('MMM dd, yyyy · hh:mm aa', 'en_US').format(getDate(list[position].sentAt!)) : 'just now', style: GoogleFonts.inter(textStyle: Theme.of(context).textTheme.bodySmall)),      
                          ],
                        ),
            ),
            ),
          ],
        ),
        
        
      ]
    ),
  );

}

// single feed card
Widget myRequestCard1(int position, BuildContext context){
  return 
  Stack(
    children: [
      
  InkWell(
    
    child:
   Container(
    padding: const EdgeInsets.fromLTRB(16, 4, 16, 4),

    // add decoration
    child: 
    Container(
      decoration: BoxDecoration(
          color: const Color(0xFFFFFFFF),
          borderRadius: BorderRadius.circular(10),
          boxShadow: const [
            BoxShadow(
              color: Colors.black26,
              // color: Color(0xFF080B23),
              offset: Offset(0.0, 0.0),
              blurRadius: 24.0,
              spreadRadius: 0.3,
            ),
          ]
        ),
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
        child: 
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
             
             
              Row(
                
                mainAxisSize: MainAxisSize.max,
                children: <Widget>[
                  Expanded(
                    child: 
                  Container(
                    decoration: const BoxDecoration(
            
                      borderRadius: BorderRadius.all(Radius.circular(10))
                    ),
                    // padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                    child:  
                    (list[position].sentBy == list[position].collegeId) ?
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(list[position].message!, style: GoogleFonts.inter(textStyle: Theme.of(context).textTheme.bodyLarge, fontWeight: FontWeight.w600 )),
                                  sizedBox(4),
                                  Text(list[position].collegeId!.toUpperCase(), style: GoogleFonts.inter(textStyle: Theme.of(context).textTheme.bodySmall, fontWeight: FontWeight.w600 )),
                                  sizedBox(4),
                                  Text((list[position].sentAt != 'just now') ? DateFormat('MMM dd, yyyy · hh:mm aa', 'en_US').format(getDate(list[position].sentAt!)) : 'just now', style: GoogleFonts.inter(textStyle: Theme.of(context).textTheme.bodySmall)),      
                                ],
                              ):
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(list[position].message!, style: GoogleFonts.inter(textStyle: Theme.of(context).textTheme.bodyLarge, fontWeight: FontWeight.w600 )),
                                  sizedBox(4),
                                  Text(list[position].collegeId!.toUpperCase(), style: GoogleFonts.inter(textStyle: Theme.of(context).textTheme.bodySmall, fontWeight: FontWeight.w600 )),
                                  sizedBox(4),
                                  Text((list[position].sentAt != 'just now') ? DateFormat('MMM dd, yyyy · hh:mm aa', 'en_US').format(getDate(list[position].sentAt!)) : 'just now', style: GoogleFonts.inter(textStyle: Theme.of(context).textTheme.bodySmall)),      
                                ],
                              ),
                  ),
                  ),
                ],
              ),
              
              
            ]
          ),

          
      ),
    ),
  ),
      Positioned(
        bottom: 0, // Adjust as needed
        left: 0,
        child: CustomPaint(
            size: Size(30, 50), // Adjust size as needed
            painter: CirclePainter(
              color: Colors.grey, // Adjust color as needed
            ),
          child: SizedBox(
            width: 10, // Adjust bubble width
            height: 10, // Adjust bubble height
          ),
        ),
      ),
      // Positioned(
      //   bottom: 4, // Adjust as needed
      //   left: 4,
      //   child: CustomPaint(
      //       size: Size(30, 50), // Adjust size as needed
      //       painter: CirclePainter(
      //         color: Colors.grey, // Adjust color as needed
      //       ),
      //     child: SizedBox(
      //       width: 10, // Adjust bubble width
      //       height: 10, // Adjust bubble height
      //     ),
      //   ),
      // ),
    ],
  );

}



  // on subitting values
  void onSubmit(BuildContext context, String appointmentId, int position){
    
      // verify if collegeId exists and matches with the phoneNumber
      closeRequest(context, appointmentId, position);
    }


  // close request
  void closeRequest(BuildContext context, String appointmentId, int position) async {
    setState(() {
      isClosing = true;
    });
    // query parameters    
    Map<String, String> queryParams = {
      // "appointmentId":appointmentId,
      };

    // API call
    //var result = await get(Uri.encodeFull(APIUrls.getUrl(APIUrls.newRequest, queryParams)), headers: {"Accept": "application/json"});
    var result = await get(Uri.parse(APIUrls.getUrl("${APIUrls.updateAppointment}${APIUrls.pass}/S1.5/$appointmentId", queryParams)), headers: {"Accept": "application/json"});
    
    // get the result body which is JSON
    var jsonString = jsonDecode(result.body); 
    
    // convert jsonString to Map
    var jsonObject = jsonString as Map; 

    // check if the api returned success
    if(jsonObject['status'] == 200){
      
      // remove the item from list
      list.removeAt(position);
      
      setState(() {
        list = list;
        isDataAvailable = false;
        isClosing = false;
      });

      showToast(context, 'Request closed!',Constants.success);
        
    }
    else {
      // show the error msg
    //Scaffold.of(context).showSnackBar(SnackBar(content: Text('Error occured. Please try later!'), duration: Duration(seconds: 2),));
    showToast(context, jsonObject['message'],Constants.error);
    }
  }


  @override
  // TODO: implement wantKeepAlive
  bool get wantKeepAlive => true;
  
}
class
 
CirclePainter
 
extends
 
CustomPainter
 
{
  final Color color;

  CirclePainter({required
 
this.color});

  @override

  
void paint(Canvas canvas, Size size) {
    Paint paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    Offset center = Offset(size.width / 2, size.height / 2);
    double radius = size.width / 2;
    canvas.drawCircle(center, radius, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}