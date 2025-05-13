class AppConfig {
  static const String baseUrl =
      'https://a8lc7dia7h.execute-api.us-east-1.amazonaws.com/production';

  static const String loginUrl = '$baseUrl/login';
  static const String signupUrl = '$baseUrl/signup';
  static const String confirmUrl = '$baseUrl/confirm-signup-otp';
  static const String objectDetectionUrl =
      'http://yololoadbalancer-1521513358.us-east-1.elb.amazonaws.com/detect/';
  static const String createBookingUrl = '$baseUrl/bookings';
  static String getBookingsUrl(String userId) =>
      '$baseUrl/user-bookings/$userId';
  static String getBookingUrl(String bookingId) =>
      '$baseUrl/bookings/$bookingId';
}
