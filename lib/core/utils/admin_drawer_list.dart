// // List<DrawerItemModel>

// import 'package:flutter/material.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:chat_material3/core/common/dialogs/custom_dialogs.dart';
// import 'package:chat_material3/core/common/widgets/text_app.dart';
// import 'package:chat_material3/core/extensions/context_extension.dart';
// import 'package:chat_material3/core/language/lang_keys.dart';
// import 'package:chat_material3/core/style/fonts/font_family_helper.dart';
// import 'package:chat_material3/core/style/fonts/font_weight_helper.dart';
// import 'package:chat_material3/core/utils/app_logout.dart';

// List<DrawerItemModel> adminDrawerList(BuildContext context) {
//   return <DrawerItemModel>[
//     //DashBoard
//     DrawerItemModel(
//       icon: Icon(Icons.dashboard, color: context.color.textColor),
//       title: TextApp(
//         text: context.translate(LangKeys.dashBoard),
//         theme: context.textStyle.copyWith(
//           // color: Colors.white,
//           fontSize: 14.sp,
//           fontFamily: FontFamilyHelper.poppinsEnglish,
//           fontWeight: FontWeightHelper.bold,
//         ),
//       ),
//       page: const DashBoardScreen(),
//     ),
//     //Categories
//     DrawerItemModel(
//       icon: Icon(Icons.category_outlined, color: context.color.textColor),
//       title: TextApp(
//         text: context.translate(LangKeys.categories),
//         theme: context.textStyle.copyWith(
//           // color: Colors.white,
//           fontSize: 14.sp,
//           fontFamily: FontFamilyHelper.poppinsEnglish,
//           fontWeight: FontWeightHelper.bold,
//         ),
//       ),
//       page: const AdminCategoriesScreen(),
//     ),
//     //Product
//     DrawerItemModel(
//       icon: Icon(
//         Icons.production_quantity_limits,
//         color: context.color.textColor,
//       ),
//       title: TextApp(
//         text: context.translate(LangKeys.products),
//         theme: context.textStyle.copyWith(
//           // color: Colors.white,
//           fontSize: 14.sp,
//           fontFamily: FontFamilyHelper.poppinsEnglish,
//           fontWeight: FontWeightHelper.bold,
//         ),
//       ),
//       page: const AdminProductsScreen(),
//     ),
//     //Users
//     DrawerItemModel(
//       icon: Icon(Icons.people_alt_rounded, color: context.color.textColor),
//       title: TextApp(
//         text: context.translate(LangKeys.users),
//         theme: context.textStyle.copyWith(
//           // color: Colors.white,
//           fontSize: 14.sp,
//           fontFamily: FontFamilyHelper.poppinsEnglish,
//           fontWeight: FontWeightHelper.bold,
//         ),
//       ),
//       page: const UsersScreen(),
//     ),
//     //Notifications
//     DrawerItemModel(
//       icon: Icon(Icons.notifications_active, color: context.color.textColor),
//       title: TextApp(
//         text: context.translate(LangKeys.notifications),
//         theme: context.textStyle.copyWith(
//           // color: Colors.white,
//           fontSize: 14.sp,
//           fontFamily: FontFamilyHelper.poppinsEnglish,
//           fontWeight: FontWeightHelper.bold,
//         ),
//       ),
//       page: const AddNotificationsScreen(),
//     ),
//     //LogOut
//     DrawerItemModel(
//       icon: Icon(Icons.exit_to_app, color: context.color.textColor),
//       title: GestureDetector(
//         onTap: () {
//           CustomDialog.twoButtonDialog(
//             context: context,
//             textBody: context.translate(LangKeys.wantToLogout),
//             textButton1: context.translate(LangKeys.yes),
//             textButton2: context.translate(LangKeys.no),
//             isLoading: false,
//             onPressed: () async {
//               await AppLogout().logout();
//             },
//           );
//         },
//         child: Text(
//           context.translate(LangKeys.logOut),
//           style: context.textStyle.copyWith(
//             // color: Colors.white,
//             fontFamily: 'Poppins',
//             fontWeight: FontWeightHelper.bold,
//             fontSize: 14.sp,
//           ),
//         ),
//       ),
//       page: const UsersScreen(),
//     ),
//   ];
// }

// class DrawerItemModel {
//   DrawerItemModel({
//     required this.icon,
//     required this.title,
//     required this.page,
//   });

//   final Icon icon;
//   final Widget title;
//   final Widget page;
// }
