// import 'package:flutter/material.dart';
// import 'package:get/get.dart';

// class TimesheetSnackbar {
//   static void showSuccess(
//     String message,
//     String title,
//   ) {
//     Get.snackbar(
//       '',
//       '',
//       backgroundColor: const Color.fromARGB(255, 4, 173, 80),
//       duration: const Duration(seconds: 3),
//       snackPosition: SnackPosition.TOP,
//       snackStyle: SnackStyle.FLOATING,
//       maxWidth: 250,
//       colorText: AppColors.appWhite,
//       shouldIconPulse: true,
//       margin: const EdgeInsets.all(10),
//       titleText: Column(
//         crossAxisAlignment: CrossAxisAlignment.center,
//         children: [
//           Text(
//             title,
//             style: AppTextStyles.montserratSemiBold(
//               color: AppColors.appWhite,
//               size: 18,
//             ),
//           ),
//         ],
//       ),
//       messageText: Column(
//         crossAxisAlignment: CrossAxisAlignment.center,
//         children: [
//           Text(
//             message,
//             style: AppTextStyles.montserratBold(
//               color: AppColors.appWhite,
//               size: 16,
//             ),
//             textAlign: TextAlign.center,
//           ),
//         ],
//       ),
//     );
//   }

//   static void showError(
//     String message,
//     String title,
//   ) {
//     Get.snackbar(
//       '',
//       '',
//       backgroundColor: AppColors.redErro,
//       duration: const Duration(seconds: 4),
//       snackPosition: SnackPosition.TOP,
//       snackStyle: SnackStyle.FLOATING,
//       shouldIconPulse: true,
//       maxWidth: 250,
//       margin: const EdgeInsets.all(10),
//       colorText: AppColors.appWhite,
//       titleText: Column(
//         crossAxisAlignment: CrossAxisAlignment.center,
//         children: [
//           Text(
//             title,
//             style: AppTextStyles.montserratBold(
//               color: AppColors.appWhite,
//               size: 18,
//             ),
//           ),
//         ],
//       ),
//       messageText: Column(
//         crossAxisAlignment: CrossAxisAlignment.center,
//         children: [
//           const SizedBox(height: 8),
//           Text(
//             message,
//             style: AppTextStyles.montserratSemiBold(
//               color: AppColors.appWhite,
//               size: 16,
//             ),
//             textAlign: TextAlign.center,
//           ),
//         ],
//       ),
//     );
//   }

//   static void showAlert(
//     String message,
//     String title,
//   ) {
//     Get.snackbar(
//       '',
//       '',
//       backgroundColor: AppColors.hasAppointmentWithWarning,
//       duration: const Duration(seconds: 3),
//       snackPosition: SnackPosition.TOP,
//       snackStyle: SnackStyle.FLOATING,
//       maxWidth: 250,
//       colorText: AppColors.appWhite,
//       shouldIconPulse: true,
//       margin: const EdgeInsets.all(10),
//       titleText: Column(
//         crossAxisAlignment: CrossAxisAlignment.center,
//         children: [
//           Text(
//             title,
//             style: AppTextStyles.montserratSemiBold(
//               color: AppColors.appWhite,
//               size: 18,
//             ),
//           ),
//         ],
//       ),
//       messageText: Column(
//         crossAxisAlignment: CrossAxisAlignment.center,
//         children: [
//           Text(
//             message,
//             style: AppTextStyles.montserratBold(
//               color: AppColors.appWhite,
//               size: 16,
//             ),
//             textAlign: TextAlign.center,
//           ),
//         ],
//       ),
//     );
//   }

//   static void showFloatingFlushbar(String message, BuildContext context) =>
//       Flushbar(
//         margin: const EdgeInsets.all(10),
//         borderRadius: BorderRadius.circular(10),
//         backgroundGradient: const LinearGradient(
//           colors: [AppColors.brownishOrangeTwo, AppColors.brownishOrangeTwo],
//           stops: [0.6, 1],
//         ),
//         boxShadows: const [
//           BoxShadow(
//             color: Colors.black45,
//             offset: Offset(3, 3),
//             blurRadius: 3,
//           ),
//         ],
//         duration: const Duration(seconds: 3),
//         dismissDirection: FlushbarDismissDirection.HORIZONTAL,
//         forwardAnimationCurve: Curves.fastLinearToSlowEaseIn,
//         message: message,
//         messageText: Text(
//           message,
//           style: AppTextStyles.montserratSemiBold(
//             color: AppColors.appWhite,
//             size: 16,
//           ),
//           textAlign: TextAlign.center,
//         ),
//       )..show(context);
// }