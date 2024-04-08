import 'dart:convert';

// import 'package:feather_icons_flutter/feather_icons_flutter.dart';
import 'package:just_audio/just_audio.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:psych_app/background_app.dart';
import 'package:psych_app/chatdetail_admin.dart';
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

class ChatAdmin extends StatefulWidget {
  const ChatAdmin({Key? key}) : super(key: key);

  @override
  ChatAdminState createState() => ChatAdminState();
}

class ChatAdminState extends State<ChatAdmin> with AutomaticKeepAliveClientMixin, TickerProviderStateMixin<ChatAdmin> {

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
  
  List<Chats> list = [];
  String emptyStateMsg = '';
  bool showCreateCTA = true;

  Animation<double>? _animation;

  // audio element to play sound
  AudioPlayer player = AudioPlayer();
  late AnimationController _animationController;

  // connection status
  bool connectionStatus = true;
  bool first = true;

  @override
  void initState(){

super.initState();
  // _formKey = GlobalKey();

// print(Provider.of<SharedState>(context).isDataLoaded);
    getUserData();
    if(list.isEmpty ) {

      getChatAdminData();
      // getOfficialDates();
    }
    
    scrollController = new ScrollController()..addListener(_scrollListener);
    // super.initState();
    
    _animationController = AnimationController(duration: const Duration(seconds: 1),vsync: this,);
    _animationController.repeat();
    
  }

   @override
  void dispose() {
    
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

// 1 stage
// 2 collegeId
// 3 offset
  // get the chat data
  void getChatAdminData() async {

    if(await checkInternetConnectivity()){
      
      // set connection status variable to true
      setState(() {
        connectionStatus = true;
        first = false;
      });
      

      // query parameters    
      Map<String, String> queryParams = {};

      // API call
      print("${APIUrls.chat}${APIUrls.pass}/S4/$collegeId/$offset");
      var result = await get(Uri.parse(APIUrls.getUrl("${APIUrls.chat}${APIUrls.pass}/S4/$collegeId/$offset", queryParams)), headers: {"Accept": "application/json"});
      print(result.body);
      
      // get the result body which is JSON
      var jsonString = jsonDecode(result.body); 
      
      // convert jsonString to Map
      var jsonObject = jsonString as Map; 

      List<Chats> list1;
      // check if the api returned success
      if(jsonObject['status'] == 200){
        // get the list data from jsonObject
        var requests = jsonObject['data'] as List;

        if(requests.isNotEmpty){
          // convert to list
          list1 = requests.map<Chats>((json) => Chats.fromJson(json)).toList();

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
            getChatAdminData();
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
      getChatAdminData();
      // getOfficialDates();
    });
  }



  @override
  Widget build(BuildContext context){
  
  return Scaffold(
      
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
        // padding: const EdgeInsets.fromLTRB(16, 4, 16, 4),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.max,
          children: <Widget>[

            
          

            Container(
                margin: const EdgeInsets.all(16),
                child: 
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    
                    children: [ 
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                        Text('Anonymous Chat', style: GoogleFonts.dmSerifText(textStyle: Theme.of(context).textTheme.displaySmall, fontWeight: FontWeight.bold)), 
                      ],),
                        
                        sizedBox(8),
                        Text('Access privately', style: GoogleFonts.dmSans(textStyle: Theme.of(context).textTheme.titleMedium, color: Colors.black54)), 
                        // sizedBox(8)
                      ],
                    ),
              ),
                Expanded(
                  // child: list.isEmpty ? 
                  child: isLoading ? 
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          // loader while fetching data
                          isLoading? const AppProgress(height: 30, width: 30,) : new SizedBox(height: 0,),
                          Container(
                          alignment: Alignment.center,
                          child: Text(emptyStateMsg, style: GoogleFonts.inter(textStyle: Theme.of(context).textTheme.bodyMedium)), 
                        )
                      ],)
                      : 
                      (list.isNotEmpty) ?
                      RefreshIndicator(
                        onRefresh: _refreshList,
                        child: 
                          ListView.builder(

                          // controller: scrollController,
                          scrollDirection: Axis.vertical,
                          itemCount: list.length,
                          itemBuilder: (context, index){
                            
                            return Container(
                              
                                  child: myRequestCard(index, context),
                                );
                          })
                    
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
                                child: Text('No history available!', style: GoogleFonts.inter(textStyle: Theme.of(context).textTheme.bodyText2)), 
                            ),
                            sizedBox(8),
                            
                      ],)
                     


                      //  RefreshIndicator(
                      //   onRefresh: _refreshList,
                      //   child: SingleChildScrollView(
                      // child: 
                      //   Wrap(
                      //       children: [
                             
                      //                 // REQUEST ITEM from the list
                      //                 (list.isNotEmpty) ?  myRequestCard(0, context) 
                      //                   :
                      //                   Column(
                      //                       mainAxisAlignment: MainAxisAlignment.center,
                      //                       mainAxisSize: MainAxisSize.max,
                      //                       children: [
                                            
                      //                         Container(
                      //                           alignment: Alignment.center,
                      //                           child: Text('No active requests!', style: GoogleFonts.inter(textStyle: Theme.of(context).textTheme.bodyMedium, color: Palette.textShade1)), 
                      //                         ),
                      //                       sizedBox(8),
                                            
                      //                 ],),

                      //         sizedBox(16),

                      //         // OLD REQUESTS
                      //                 (list.isNotEmpty) ?  myRequestCard(0, context) 
                      //                   :
                      //                   Column(
                      //                       mainAxisAlignment: MainAxisAlignment.center,
                      //                       mainAxisSize: MainAxisSize.max,
                      //                       children: [
                                            
                      //                         Container(
                      //                           alignment: Alignment.center,
                      //                           child: Text('No active requests!', style: GoogleFonts.inter(textStyle: Theme.of(context).textTheme.bodyMedium, color: Palette.textShade1)), 
                      //                         ),
                      //                       sizedBox(8),
                                            
                      //                 ],),
                                    
                      //       ])
                      // )
                      // ),


                      
                
            ),
            (list.isNotEmpty) ? Container(
                alignment: Alignment.center,
                child: Text('Pull down to refresh!', style: GoogleFonts.inter(textStyle: Theme.of(context).textTheme.bodySmall)), 
              ) : sizedBox(0),

                   
          ],), 


        ),
        ),
        
      )
    )]));
  }

  // create new request
  createNewRequest(BuildContext context) async{
    // print(allowedDates.length);
    // print(blockedDates.length);
    final result = await Navigator.push(context, MaterialPageRoute(builder: (context) => AppointmentNew()));
    
// print(result);
    if(result!=null){

      // request item
      Chats chatItem = new Chats();

      Map<String, dynamic> r =  result;
      
      chatItem.collegeId = r['collegeId'];
      chatItem.sentAt = r['sentAt'];
      
      // add object to list
      List<Chats> list1 = [];
      list1.add(chatItem);
      list1.addAll(list);

      setState(() {
        list = list1;
      });

      // set the data available to true
      // so that the user won't be able to create new request again.
      setState(() {
        isDataAvailable = true;
      });
      getChatAdminData();
      // show update message
      // showToast(context, 'Your $requestType request is submitted');


    }
  }

 Future<void> _refreshList() async {
    // Add your refresh logic here, e.g. fetching new data from a server
    await Future.delayed(const Duration(seconds: 2));
    setState(() {
        isDataAvailable = true;
      });
    getChatAdminData();
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
  return
  InkWell(
    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => ChatDetailAdmin(chats: list[position]))).whenComplete(() => { }),
    child:
   Container(
    padding: const EdgeInsets.fromLTRB(16, 4, 16, 4),

    // add decoration
    child: 
    Container(
      decoration: BoxDecoration(
              color: const Color(0xFFFFFFFF),
              border: Border.all(color: const Color(0xFFEEEEEE)),
              // color: Color(0xFFFFFFFF),
              borderRadius: BorderRadius.circular(12),
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
                  Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Text(DateFormat('MMM d, y', 'en_US').format(getDate(list[position].sentAt!)).toUpperCase(), style: GoogleFonts.inter(textStyle: Theme.of(context).textTheme.bodyLarge, fontWeight: FontWeight.w600 )),
                          // sizedBox(4),
                          // Text(DateFormat().add_jm().format(getDate(list[position].sentAt!)).toUpperCase(), style: GoogleFonts.inter(textStyle: Theme.of(context).textTheme.bodyMedium, fontWeight: FontWeight.w600 )),
                          // sizedBox(4),
                      
                          Text(list[position].collegeId!.toUpperCase(), style: GoogleFonts.dmSans(fontSize: 20, fontWeight: FontWeight.w600, color: Colors.black87) ),
                          sizedBox(4),
                          Text((list[position].sentAt != 'just now') ? DateFormat('MMM dd · hh:mm aa', 'en_US').format(getDate(list[position].sentAt!)) : 'just now', style: GoogleFonts.inter(textStyle: Theme.of(context).textTheme.bodySmall, color: Colors.black45)),      
                          // Text((list[position].sentAt != 'just now') ? DateFormat('MMM dd, yyyy · hh:mm aa', 'en_US').format(getDate(list[position].sentAt!)) : 'just now', style: GoogleFonts.inter(textStyle: Theme.of(context).textTheme.bodySmall)),      
                        ],
                      ),
                  ),
                ],
              ),
              
              
            ]
          ),

          
      ),
    ),
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
