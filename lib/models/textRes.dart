import 'dart:ui';
TextRes textRes = TextRes();

final themeColor = Color(0xfff5a623);
final primaryColor = Color(0xff203152);
final greyColor = Color(0xffaeaeae);
final greyColor2 = Color(0xffE8E8E8);

const List<Color> MEMO_COLORS = [
  Color(0xffF28B83),
  Color(0xFFFCBC05),
  Color(0xFFFFF476),
  Color(0xFFCBFF90),
  Color(0xFFA7FEEA),
  Color(0xFFE6C9A9),
  Color(0xFFE8EAEE),
  Color(0xFFA7A7EA),
  Color(0xFFCAF0F8),
  Color(0xFFD0D0D0),
];

class TextRes {
  TextRes();

  String get LABEL_ALL => "全部";

  // addQuestionScreen
  String get HINT_QUESTION => "問題Hint";
  String get LABEL_QUESTION => "問題";
  String get LABEL_NEW_QUESTION => "新題目";
  String get LABEL_MISSING_NEW_QUESTION => "未入問題";
  String get LABEL_OPTION => "選項";
  String get LABEL_ANSWER => "答案";
  String get LABEL_TOPIC => "關於";
  String get HINT_REFERENCE => "Reference Link with URL";
  String get LABEL_REFERENCE => "答案來源";
  String get LABEL_DETAIL => "詳情/解題";
  String get HINT_DEATIL => "入D 詳情 或 點解答案係咁";
  String get HELPER_DETAIL => "可用 Hash Tag";
  String get ERROR_DUPLICATE_OPTION => "Duplicate Option";
  String get ERROR_EMPTY_OPTION => "Duplicate Option";
  String get ERROR_NO_ANSWER_SELECTED => "No Answer Selected";
  String get LABEL_SUGGEST_ADD_REFERECE => "Suggest Add Reference";
  String get LABEL_SUGGEST_ADD_DESC => "Suggest Add Desc";
  String get LABEL_SUBMIT_QUESTION => "Good to Go";
  String get LABEL_PENDING_MESSAGE => "未審批正料: ";
  String get LABEL_APPROVE => "審批";
  String get LABEL_REJECT => "撤回";
  String get LABEL_NO_PENDING_MESSAGE => "沒有等待審批";
  String get LABEL_QUICK_GAME => "榮光十問";
  String get LABEL_RECENT_RECORD => "Recent Record: ";
  String get LABEL_WELCOME_BACK => "Welcome Back: ";
  String get LABEL_USER_INFO => " User Info";
  String get LABBEL_TITLE => "榮光教育委員會";
  String get LABEL_VERIFY => "Verify";
  String get LABEL_USER_ID => "User ID";
  String get LABEL_PASSCODE=> "PASSCODE";
  String get LABEL_ID_PASSCODE_WRONG => "ID or Passcode wrong";
  List<String> get QUESTION_STATUS_OPTIONS => ["等待審批", "撤回", "審批"];
  List<String> get USER_SETTING_MENU=>["創作清單","設定","登入其他戶口"];

}




