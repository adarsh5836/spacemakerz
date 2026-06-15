class AppRegex {
  // Mobile number regex: 10 digits
  static final RegExp mobileNumber = RegExp(r'^[0-9]{10}$');
  
  // Generic username regex (can be customized)
  static final RegExp username = RegExp(r'^[a-zA-Z0-9_]{3,20}$');
}
