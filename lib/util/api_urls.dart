import 'dart:convert';
import 'package:http/http.dart' as http;

class APIUrls {

    // authority 
    //static String authority = 'campus-1233.appspot.com';
    // static String authority = 'mysmartcampus.app';
    // static String authority = 'smartcampusweb.vercel.app'; // production
    static String authority = 'dearme.vercel.app'; // pre production
    static String pass = 'KfUwvS0oE6zV9jyHqXxL2Pi4D1mG8aRtNcZn7Ml3bArpT5gJQsCWeYBf';


    // verify user
    static String verifyUser = 'api/verify/';
    static String user = 'api/user/';
    
    // campus
    static String campuses = 'api/campuses/';

    // requests
    static String appVersion = 'api/appversion/'; // to check app version

    static String newRequest = 'api/newrequest/'; // new
    static String myRequests = 'api/requests/'; // my new requests
    static String otherRequests = 'api/otherrequests/'; // my new requests
    static String blockedDates = 'api/blockouting/'; // blocked dates
    static String updateRequests = 'api/updaterequests/'; // blocked dates
    static String requestStats = 'api/requeststats/'; // for admin to view stats
    static String visitorStats = 'api/visitorstats/'; // for admin to view stats
    static String visitorpasses = 'api/visitorpasses/'; // for visitorpass
    static String newVisitorpass = 'api/newvisitorpass/'; // for new visitorpass
    static String updateVisitorpass = 'api/updatevisitorpass/'; // for admin/student to update visitorpass
    static String passrequest = 'api/passrequest/'; // for admin/student to number days of temporary day pass
    
    static String hostels = 'api/hostels/'; // for foodadmin to get hostel students available for food details
    static String food = 'api/food/'; // for foodadmin to store the food availed details

    ///// PSYCH //////
    ///// PSYCH //////
    static String newAppointment = 'api/psych/newappointment/'; // new appointment
    static String appointments = 'api/psych/appointments/'; // appointments
    static String updateAppointment = 'api/psych/updateappointment/'; // update appointment
    static String chat = 'api/psych/chat/'; // update appointment
    static String assessments= 'api/psych/assessments/'; // assessments
    static String questions= 'api/psych/questions/'; // questions
    static String answers= 'api/psych/answers/'; // answers
    static String mood= 'api/psych/mood/'; // mood
    static String getmood= 'api/psych/getmood/'; // getmood
    static String feelings= 'api/psych/feelings/'; // feelings
    static String library= 'api/psych/library/'; // library


    // make API call
    // returns both JSON object as well as JSON array
    static Future<dynamic> makeApiCall(String endpoint, {bool isList = false}) async {
      try {
        // call the API
        final response = await http.get(Uri.parse('$authority/$endpoint/$pass'), headers: {"Accept": "application/json"});
        
        if (response.statusCode == 200) {
          final jsonData = jsonDecode(response.body);
          if (isList) {
            return jsonData as List<dynamic>;
          } else {
            return jsonData;
          }
        } else {
          throw Exception('Failed to load data');
        }
      } catch (e) {
        throw Exception('Failed to connect to server');
      }
    }


    // encrypted data
    static String encryptStringXOR(String plainText) {
      // Convert plain text and key to UTF-8 bytes
      List<int> plainBytes = utf8.encode(plainText);
      List<int> keyBytes = utf8.encode('SVECW');

      // XOR each byte of plain text with corresponding byte of key
      List<int> encryptedBytes = [];
      for (int i = 0; i < plainBytes.length; i++) {
        encryptedBytes.add(plainBytes[i] ^ keyBytes[i % keyBytes.length]);
      }

      // Convert encrypted bytes to base64 string
      String encryptedString = base64.encode(encryptedBytes);

      return encryptedString;
    }

    // decrypt data
    static String decryptStringXOR(String encryptedString) {
      // Convert encrypted string and key to UTF-8 bytes
      List<int> encryptedBytes = base64.decode(encryptedString);
      List<int> keyBytes = utf8.encode('SVECW');

      // XOR each byte of encrypted text with corresponding byte of key
      List<int> decryptedBytes = [];
      for (int i = 0; i < encryptedBytes.length; i++) {
        decryptedBytes.add(encryptedBytes[i] ^ keyBytes[i % keyBytes.length]);
      }

      // Convert decrypted bytes to UTF-8 string
      String decryptedString = utf8.decode(decryptedBytes);

      return decryptedString;
    }

    // unencoded url paths

    // campus
    // static String campuses = 'api/campus/campuses';
    // static String updatePlayerId = 'api/user/update_player_id';

    // // user creds
    // static String findUser = 'api/user/find_user';
    // static String sendotp = 'api/user/sendotp';
    // static String getHostels = 'api/user/gethostels';

    // static String verifyUser = 'api/user/verify_user';
    // static String searchUserDetails = 'api/user/user_details';

    //   // these are used for updating the users. currently, we are using onboard_user 
    //   static String updateUser = 'api/user/update_user';
    //   static String onboardUser = 'api/user/onboard_user';

    // static String usersById = 'api/user/users_by_id';

    // // fetch circulars
    // static String newCircular = 'api/circular/new_circular';
    // static String circulars = 'api/circular/circulars';
    
    // // fetch schedule
    // static String newSchedule = 'api/schedule/new_schedule';
    // static String todaySchedule = 'api/schedule/today_schedule';
    // static String branchSubjects = 'api/schedule/branch_subjects';

    // // requests
    // static String newRequest = 'api/approval/new_request'; // new
    // static String approverequests = 'api/approval/requests'; // requests for approval #ADMIN
    // static String updateRequest = 'api/approval/update_request'; // update request status #ADMIN
    // static String myNewRequests = 'api/approval/my_new_requests'; // my new requests
    // static String requestsHistory = 'api/approval/requests_history'; // my requests history
    // static String requestsHistoryAdmin = 'api/approval/requests_history_admin'; // my requests history
    // static String closeRequest = 'api/approval/close_request'; // close request
    // static String approvedOutings = 'api/approval/approved_outings'; // close request
    // static String usersRequestHistory = 'api/approval/requests_history_by_user'; // get requests of specific user
    // static String issueOuting = 'api/approval/issue_outing'; // issue outing #ISSUER
    // static String issuedRequestOfUser = 'api/approval/issued_request_of_user'; // issue outing #ISSUER
    // static String outingReturn = 'api/approval/outing_return'; // Mark as Returned #ISSUER
    // static String reportsData = 'api/approval/reports_data'; // Mark as Returned #SUPERADMIN

    // // grievances
    // static String grievances = 'api/feedback/my_feedbacks'; // my grievances
    // static String newGrievance = 'api/feedback/new_feedback'; // new grievance
    // static String grievancesForApproval = 'api/feedback/feedbacks'; // grievances for approval
    // static String closeGrievance = 'api/feedback/close_feedback'; // close grievance
    // static String updateGrievance = 'api/feedback/update_feedback'; // update grievance
    
    // // feed
    // static String feed = 'api/feed/feed';
    // static String newFeed = 'api/feed/new_feeditem';
    // static String hideFeedItem = 'api/feed/hide_feeditem';
    // static String addFeedReaction = 'api/feed/add_feed_reaction';
    // static String feedComments = 'api/feed/feed_comments';
    // static String addFeedComment = 'api/feed/feed_new_comment';

    // // directory
    // static String searchUsers = 'api/user/search_users';
    
    // // groups
    // static String getGroups = 'api/group/groups';
    
    // // placements
    // static String getPlacementYears = 'api/placement/placement_years';
    // static String getPlacementDetails = 'api/placement/placement_details';
  
    // // get years
    // static String newTopic = '/api/topic/new_topic'; // for faculty
    // static String getMyTopics = '/api/topic/get_my_topics'; // for faculty
    // static String getTopics = '/api/topic/get_topics'; // for students



    // form url with query parameters
    static String getUrl(String url, Map<String, String> queryParams){

      // for the url
      Uri uri = Uri.https(
        authority,
        url, 
        queryParams
      );

      // return the url string
      return uri.toString();
    }

}