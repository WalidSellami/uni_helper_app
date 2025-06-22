import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';
import 'package:overlay_support/overlay_support.dart';
import 'package:uni_helper/generated/l10n.dart';
import 'package:uni_helper/shared/cubits/checkCubit/CheckStates.dart';
import 'package:uni_helper/shared/styles/Colors.dart';

class CheckCubit extends Cubit<CheckStates> {

  CheckCubit() : super(InitialCheckState());

  static CheckCubit get(context) => BlocProvider.of(context);


  bool hasInternet = false;
  bool isSplashScreen = true;


  void checkConnection() {

    InternetConnection().onStatusChange.listen((status) {

      final bool isConnected = status == InternetStatus.connected;
      hasInternet = isConnected;

      (!isSplashScreen) ? showSimpleNotification(
        (hasInternet) ?
        Text(
          S.current.connection_status_2,
          textAlign: (kIsWeb) ? TextAlign.center : TextAlign.start,
          style: TextStyle(
            fontSize: 17.0,
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ) :
        Text(
          S.current.connection_status_3,
          textAlign: (kIsWeb) ? TextAlign.center : TextAlign.start,
          style: TextStyle(
            fontSize: 17.0,
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        background: (hasInternet) ? greenColor : Colors.red,
      ) : null;

      // if(kDebugMode) {
      //   print(hasInternet);
      // }

      emit(ConnectionCheckState());

    });
  }


  void changeStatus() {
    isSplashScreen = false;
    emit(ChangeStatusCheckState());
  }


}
