// import 'dart:convert';
// import 'dart:developer';
// import 'package:dio/dio.dart';
// import 'package:poketstore/model/login_reg_model/reg_model.dart';

// class RegistrationService {
//   final Dio _dio = Dio();
//   final String _registerUrl =
//       "https://api.poketstor.com/auth/user/register";
//   final String _verifyOtpUrl =
//       "https://api.poketstor.com/auth/user/verify-registration-otp";

//   // Changed return type to Future<void> as it just sends OTP and expects a message
//   Future<void> registerUser(Map<String, dynamic> data) async {
//     try {
//       Response response = await _dio.post(
//         _registerUrl,
//         data: jsonEncode(data),
//         options: Options(headers: {'Content-Type': 'application/json'}),
//       );

//       log("Registration Response: ${response.data}");

//       // Check if the response indicates success (e.g., status 200/201 and a message)
//       if (response.statusCode == 200 || response.statusCode == 201) {
//         if (response.data is Map<String, dynamic> &&
//             response.data.containsKey('message')) {
//           log("Server message: ${response.data['message']}");
//           return; // Success, OTP sent
//         } else {
//           throw Exception(
//             "Unexpected success response format for OTP sending.",
//           );
//         }
//       } else {
//         // Handle non-200/201 status codes
//         String errorMessage = "Failed to send OTP.";
//         if (response.data is Map<String, dynamic> &&
//             response.data.containsKey('message')) {
//           errorMessage = response.data['message'];
//         }
//         throw Exception(errorMessage);
//       }
//     } catch (e) {
//       log("Registration/Send OTP Error (Service): $e");
//       if (e is DioException && e.response != null) {
//         String errorMessage =
//             "Send OTP failed: ${e.response!.data['message'] ?? e.message}";
//         throw Exception(errorMessage);
//       }
//       throw Exception("Failed to send OTP. Please check your network.");
//     }
//   }

//   // This method's return type remains Future<Map<String, dynamic>>
//   // because it's expected to return user details and token upon successful verification.
//   Future<Map<String, dynamic>> verifyOtp(String email, String otp) async {
//     try {
//       Response response = await _dio.post(
//         _verifyOtpUrl,
//         data: jsonEncode({"email": email, "otp": otp}),
//         options: Options(headers: {'Content-Type': 'application/json'}),
//       );

//       log("Verify OTP Response: ${response.data}");

//       if (response.data is Map<String, dynamic>) {
//         return response.data;
//       } else {
//         log(
//           "Error: verifyOtp response.data is not a Map. It is of type ${response.data.runtimeType.toString()} and value ${response.data.toString()}",
//         );
//         throw Exception(
//           "Unexpected OTP verification response format: ${response.data.toString()}",
//         );
//       }
//     } catch (e) {
//       log("Verify OTP Error: $e");
//       if (e is DioException && e.response != null) {
//         throw Exception(
//           e.response!.data['message'] ?? "OTP verification failed",
//         );
//       }
//       throw Exception("OTP verification failed");
//     }
//   }
// }

import 'dart:convert';
import 'dart:developer';
import 'package:dio/dio.dart';

class RegistrationService {
  final Dio _dio = Dio();
  final String _registerUrl = "https://api.poketstor.com/auth/user/register";

  // Now directly registers the user and returns the response
  Future<Map<String, dynamic>> registerUser(Map<String, dynamic> data) async {
    try {
      Response response = await _dio.post(
        _registerUrl,
        data: jsonEncode(data),
        options: Options(headers: {'Content-Type': 'application/json'}),
      );

      log("Registration Response: ${response.data}");

      if (response.statusCode == 200 || response.statusCode == 201) {
        if (response.data is Map<String, dynamic>) {
          return response.data; // Return user data & token
        } else {
          throw Exception("Unexpected response format.");
        }
      } else {
        String errorMessage = "Registration failed.";
        if (response.data is Map<String, dynamic> &&
            response.data.containsKey('message')) {
          errorMessage = response.data['message'];
        }
        throw Exception(errorMessage);
      }
    } catch (e) {
      log("Registration Error (Service): $e");
      if (e is DioException && e.response != null) {
        String errorMessage =
            e.response!.data['message'] ?? e.message ?? "Registration failed";
        throw Exception(errorMessage);
      }
      throw Exception("Registration failed. Please check your network.");
    }
  }
}
