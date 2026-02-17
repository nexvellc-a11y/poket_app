import 'dart:developer'; // Used for logging purposes, like in debugging

import 'package:dio/dio.dart';
import 'package:firebase_core/firebase_core.dart'; // Core Firebase services initialization
import 'package:flutter/material.dart'; // Flutter's Material Design widgets
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:poketstore/controllers/add_shop_controller/add_shop_controller.dart';
import 'package:poketstore/controllers/add_shop_controller/all_shop_controller.dart';
import 'package:poketstore/controllers/address_controller/address_controller.dart';
import 'package:poketstore/controllers/advertisment_controller/advertisment_controller.dart';
import 'package:poketstore/controllers/bottom_bar_controller/bottombar_controller.dart';
import 'package:poketstore/controllers/cart_controller/cart_controller.dart';
// import 'package:poketstore/controllers/cart_controller/checkout_controller.dart';
import 'package:poketstore/controllers/category_controller/category_controller.dart';
import 'package:poketstore/controllers/fcm_controller.dart';
import 'package:poketstore/controllers/fcm_controller/fcm_controller.dart';
import 'package:poketstore/controllers/forgot_password_controller/forgot_password_controller.dart';
import 'package:poketstore/controllers/forgot_password_controller/reset_password_controller.dart';
import 'package:poketstore/controllers/home_product_controller/home_product_controller.dart';
import 'package:poketstore/controllers/location_controller/location_controller.dart'; // Re-added Location controller
import 'package:poketstore/controllers/login_reg_controller/login_controller.dart';
import 'package:poketstore/controllers/my_shope_controller/add_product_controller.dart';
import 'package:poketstore/controllers/my_shope_controller/fetch_product.dart';
import 'package:poketstore/controllers/my_shope_controller/my_shop_list_user_controller.dart';
import 'package:poketstore/controllers/my_shope_controller/shope_details_controller.dart';
import 'package:poketstore/controllers/notification_controller.dart/notification_controller.dart';
import 'package:poketstore/controllers/login_reg_controller/registration_controller.dart';
import 'package:poketstore/controllers/order_controller/order_controller.dart';
import 'package:poketstore/controllers/order_controller/order_list_details_controller.dart';
import 'package:poketstore/controllers/otp_controller/send_otp_controller.dart';
import 'package:poketstore/controllers/otp_controller/verify_otp_controller.dart';
import 'package:poketstore/controllers/product_by_shop_controller/product_by_shop_controller.dart';
import 'package:poketstore/controllers/product_search_controller/district_search_controller.dart';
import 'package:poketstore/controllers/product_search_controller/product_search_controller.dart';
import 'package:poketstore/controllers/product_search_controller/shop_search_controller.dart';
import 'package:poketstore/controllers/product_search_controller/state_search_controller.dart';
import 'package:poketstore/controllers/reward_controller/reward_controller.dart';
import 'package:poketstore/controllers/search_producer_controller.dart';
import 'package:poketstore/controllers/set_location_controller.dart';
import 'package:poketstore/controllers/shop_nearby_controller/shop_nearby_controller.dart';
import 'package:poketstore/controllers/shop_nearby_controller/shop_product_nearby_controller.dart';
import 'package:poketstore/controllers/subscription_controller/start_plan_controller.dart';
import 'package:poketstore/controllers/subscription_controller/subscription_controller.dart';
import 'package:poketstore/controllers/subscription_controller/user_shop_list_controller.dart';
import 'package:poketstore/controllers/user_profile_controller/user_profile_controller.dart';
import 'package:poketstore/firebase_options.dart';
import 'package:poketstore/network/dio_network_service.dart';
import 'package:poketstore/service/notification(fcm)_service.dart/notification(fcm)_service.dart'; // FCM notification service
import 'package:poketstore/service/permission_service/permission_service.dart';
import 'package:poketstore/view/splash/splash_screen.dart'; // Splash screen, likely the app's entry point
import 'package:provider/provider.dart'; // State management library

import 'controllers/shop_of_user_controller/shop_of_user_controller.dart'; // Controller for user's shop
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

const AndroidNotificationChannel newOrderChannel = AndroidNotificationChannel(
  'new_order_channel', // MUST MATCH backend channel_id if sent
  'New Order Alerts',
  description: 'Special sound for new orders',
  importance: Importance.max,
  playSound: true,
  sound: RawResourceAndroidNotificationSound('new_order'),
);

/// The main entry point of the Flutter application.
/// Initializes Firebase and requests necessary permissions before running the app.
void main() async {
  // Ensure Flutter widgets binding is initialized before any Flutter-specific calls.
  WidgetsFlutterBinding.ensureInitialized();
  // Initialize Firebase services for the application.
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  // Ensure Flutter widgets binding is initialized again (redundant but harmless if already done).
  WidgetsFlutterBinding.ensureInitialized();

  // Request necessary permissions, e.g., location, notifications.
  await PermissionService.requestPermissions();
  // 🔔 CREATE NOTIFICATION CHANNEL
  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin
      >()
      ?.createNotificationChannel(newOrderChannel);
  DioNetworkService.initialize();

  runApp(
    MultiProvider(
      providers: [
        // List of all ChangeNotifierProviders used for state management across the app.
        // Each provider makes an instance of its controller available to its descendants.

        // Re-added: Location functionality
        ChangeNotifierProvider(create: (_) => LocationProvider()),
        ChangeNotifierProvider(create: (context) => LoginProvider()),
        ChangeNotifierProvider(create: (_) => RegistrationProvider()),
        ChangeNotifierProvider(create: (_) => BottomBarProvider()),
        ChangeNotifierProvider(create: (_) => SearchProducerProvider()),
        ChangeNotifierProvider(
          create:
              (context) =>
                  NotificationProvider()..loadNotificationsForCurrentUser(),
        ),
        ChangeNotifierProvider(create: (context) => ProductProvider()),
        ChangeNotifierProvider(create: (context) => AllShopController()),
        ChangeNotifierProvider(create: (context) => FetchProductProvider()),
        ChangeNotifierProvider(create: (context) => CategoryController()),
        // ChangeNotifierProvider(create: (context) => CartController()),
        ChangeNotifierProvider(create: (context) => OrderController()),
        ChangeNotifierProvider(create: (_) => ShopProvider()),
        ChangeNotifierProvider(create: (_) => ShopOfUserProvider()),
        ChangeNotifierProvider(create: (_) => MyShopListUserProvider()),
        ChangeNotifierProvider(create: (_) => ProductsByShopProvider()),
        ChangeNotifierProvider(create: (_) => ShopeDetailsProvider()),

        ChangeNotifierProvider(create: (_) => HomeProductController()),
        ChangeNotifierProvider(create: (_) => OrderListController()),
        ChangeNotifierProvider(create: (_) => LocationMapController()),
        ChangeNotifierProvider(create: (_) => UserProfileController()),
        ChangeNotifierProvider(create: (_) => RewardController()),

        ChangeNotifierProvider(create: (_) => DeliveryAddressController()),
        ChangeNotifierProvider(create: (_) => ProductSearchProvider()),
        ChangeNotifierProvider(create: (_) => SubscriptionProvider()),
        ChangeNotifierProvider(create: (_) => FCMProvider()),
        ChangeNotifierProvider(create: (_) => FCMNotificationController()),
        ChangeNotifierProvider(create: (_) => ForgotPasswordProvider()),
        ChangeNotifierProvider(create: (_) => ShopSearchController()),
        ChangeNotifierProvider(create: (_) => ShopNearbyController()),
        ChangeNotifierProvider(create: (_) => CartController()..fetchCart()),
        ChangeNotifierProvider(
          create: (_) => ShopProductNearbyProductController(),
        ),
        ChangeNotifierProvider(create: (_) => StartSubscriptionProvider()),
        ChangeNotifierProvider(create: (_) => ResetPasswordProvider()),
        ChangeNotifierProvider(create: (_) => SendOtpController()),
        ChangeNotifierProvider(create: (_) => VerifyOtpController()),
        ChangeNotifierProvider(create: (_) => AdvertisementController()),
        ChangeNotifierProvider(create: (_) => StateController()),
        ChangeNotifierProvider(create: (_) => DistrictController()),
        ChangeNotifierProvider(create: (_) => UserShopListController()),
      ],
      // The root widget of the application.
      child: const MyApp(),
    ),
  );
}

/// The root widget of the application, a StatefulWidget.
/// It manages the initial setup of the app's state, such as Firebase Push Notifications.
class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

/// The state class for MyApp, managing its lifecycle and initializations.
class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();

    // Re-added the Future.microtask block to fetch and log the current location.
    Future.microtask(() async {
      try {
        log('🚀 Starting Dio test from main');

        final dio = Dio();
        final res = await dio.get('https://api.poketstor.com');

        log('✅ Dio main test status: ${res.statusCode}');
      } catch (e, st) {
        log('❌ Dio main test failed', error: e, stackTrace: st);
      }
      // Access the LocationMapController instance using Provider.
      final locationController = Provider.of<LocationMapController>(
        // ignore: use_build_context_synchronously
        context,
        listen:
            false, // Set to false as we only need to call a method, not listen for changes here.
      );
      // Attempt to get and save the user's current location.
      await locationController.getCurrentAndSaveUserLocation();

      // Log the fetched location for debugging purposes.
      final position = locationController.locationMap;
      if (position != null) {
        log(
          "📍 Current location: Latitude ${position.latitude}, Longitude ${position.longitude},place${position.place},locality${position.locality},state${position.state},pincode${position.pincode}",
        );
      } else {
        log("❌ main screen Failed to get current location.");
      }
    });

    // Initialize Firebase Push Notification Service when the app starts.
    FirebasePushService().init(context);
  }

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      // 🔑 Base size = your Figma / design size
      designSize: const Size(375, 812), // iPhone X baseline (BEST PRACTICE)
      minTextAdapt: true,
      splitScreenMode: true, // ✅ Important for tablets & foldables
      builder: (context, child) {
        return MaterialApp(debugShowCheckedModeBanner: false, home: child);
      },
      child: const SplashScreen(),
    );
  }
}
