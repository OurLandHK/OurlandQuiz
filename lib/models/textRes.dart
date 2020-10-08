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

class GameModeEntry {
  final String label;
  final String desc;
  //final IconData iconData;
  const GameModeEntry(this.label, this.desc);
}

const int TIME_ATTACK_GAME_INDEX = 0;
const int FIX_TIME_GAME_INDEX = 1;
List<GameModeEntry> GameModes = [
  GameModeEntry("榮光十問", "每條問題限時鬥快答十條"),
  GameModeEntry("中中中又中", "限時${textRes.TOTAL_TIME}秒鬥多答中")
];

class TextRes {
  TextRes();

  int get TOTAL_TIME => 300;
  String get LABEL_ALL => "全部題目";

  // addQuestionScreen
  String get HINT_QUESTION => "問題Hint";
  String get LABEL_QUESTION => "問題";
  String get LABEL_NEW_QUESTION => "新題目";
  String get LABEL_MISSING_NEW_QUESTION => "未入問題";
  String get LABEL_OPTION => "選項";
  String get LABEL_ANSWER => "答案";
  String get LABEL_TOPIC => "關於";
  String get HINT_REFERENCE => "參考連結的URL";
  String get LABEL_REFERENCE => "答案來源";
  String get LABEL_QUESTION_IMAGE => "問題圖";
  String get LABEL_DETAIL => "詳情/解題";
  String get LABEL_ANSWER_IMAGE => "解題圖";
  String get HINT_DEATIL => "入D詳情或點解答案係咁 ";
  String get HELPER_DETAIL => "可用 Hash Tag";
  String get ERROR_DUPLICATE_OPTION => "有重覆選項";
  String get ERROR_EMPTY_OPTION => "未有選項";
  String get ERROR_NO_ANSWER_SELECTED => "未有答案";
  String get LABEL_SUGGEST_ADD_REFERECE => "不如入埋參考";
  String get LABEL_SUGGEST_ADD_DESC => "不如入埋詳情/解題";
  String get LABEL_SUBMIT_QUESTION => "可以提交";
  String get LABEL_SUBMIT => "提交";
  String get LABEL_PENDING_MESSAGE => "未審批正料: ";
  String get LABEL_APPROVE => "審批";
  String get LABEL_REJECT => "撤回";
  String get LABEL_NO_PENDING_MESSAGE => "沒有等待審批";
  String get LABEL_QUICK_GAME => "榮光十問";
  String get LABEL_RECENT_RECORD => "Recent Record: ";
  String get LABEL_WELCOME_BACK => "Welcome Back: ";
  String get LABEL_USER_INFO => " 用戶資料";
  String get LABEL_TITLE => "榮光教育委員會";
  String get LABEL_VERIFY => "核實";
  String get LABEL_USER_ID => "User ID";
  String get LABEL_PASSCODE => "PASSCODE";
  String get LABEL_ID_PASSCODE_WRONG => "ID 或 Passcode 錯";
  String get LABEL_UPDATE_USER_FAIL => "更新用戶失敗";
  String get LABEL_USER_NAME => "用戶名字";
  String get LABEL_UPDATE_USER => "更新用戶";
  String get LABEL_SHARE_TO_CLIPBOARD => '分享至剪貼簿';
  String get LABEL_TOTAL_QUESTION => '題目數量';
  String get LABEL_TOO_MUCH_NEW_QUESTION => '要少於100字';
  String get LABEL_YOU_ARE_CORRECT => '你答中了！';
  String get LABEL_CORRECT_ANSWER => '正確答案';
  String get LABEL_YOUR_ANSWER => '你答';
  String get LABEL_PLAYER_ANSWER => '玩家答案';
  String get LABEL_TIME => '時間';
  String get LABEL_CREATE_TIME => '創作時間';
  String get LABEL_RESULT => '成績';
  String get LABEL_NEWS => '新聞';
  String get LABEL_ADD_NEWS => '新增新聞';
  String get LABEL_UPDATE_NEWS_FAIL => '新增新聞失敗';
  String get LABEL_NEWS_TITLE => '新聞標題';
  String get LABEL_NEWS_DETAIL => '新聞詳情';
  String get LABEL_UPDATE_NEWS => '新增新聞';
  String get LABEL_WAIT => '未選答案';
  String get LABEL_DESC_DATE => '事件日期';
  String get LABEL_EDIT_QUESTION => '更新問題';
  String get LABEL_PASS_VALIDATE => '你過關了，返去要再按/start';
  String get LABEL_FAIL_VALIDATE => '努力D，再來';
  String get HINT_DESC_DATE => '如問題特定事件有關，可輸入事件有關日期';
  List<String> get QUESTION_STATUS_OPTIONS => ["等待審批", "撤回", "審批"];
  List<String> get USER_SETTING_MENU => ["創作清單", "設定", "登入其他戶口", "個人記錄"];
}
