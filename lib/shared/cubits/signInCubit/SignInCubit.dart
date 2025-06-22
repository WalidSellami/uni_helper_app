import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uni_helper/generated/l10n.dart';
import 'package:uni_helper/shared/cubits/signInCubit/SignInStates.dart';
import 'package:uni_helper/shared/network/remote/DioHelper.dart';
import 'package:uni_helper/shared/utils/Constants.dart';

class SignInCubit extends Cubit<SignInStates> {

  SignInCubit() : super(InitialSignInState());

  static SignInCubit get(context) => BlocProvider.of(context);


  Future<void> userSignIn({
    required String regNbr,
    required String password,
    required BuildContext context
}) async {

    emit(LoadingSignInState());

    await DioHelper.postData(
        pathUrl: '/sign_in/${localeLanguage ?? deviceLocaleLang}',
        data: {
          'registration_number': regNbr,
          'password': password,
        }).then((value) {

        emit(SuccessSignInState(value?.data['status'], value?.data['message'], value?.data['user_id']));

    }).catchError((error) {

      if(kDebugMode) {
        print('${error.toString()} --> in user sign in');
      }

      String errorMessage = error.toString();

      if(context.mounted) {

        errorMessage = S.of(context).error_message;

        if (error is DioException) {
          if (kDebugMode) {
            print('DioException --> ${error.message}');
          }

          if (error.response != null) {
            final response = error.response!;
            final statusCode = response.statusCode;
            final data = response.data;

            if (data is Map && data.containsKey('message')) {
              errorMessage = data['message'];
            }

            if (kDebugMode) {
              print('StatusCode: $statusCode');
              print('Server Message: $errorMessage');
            }

          } else {
            if (kDebugMode) {
              print('No response from server.');
            }
          }

        } else {
          if (kDebugMode) {
            print('Unknown error: $error');
          }
        }

      }

      emit(ErrorSignInState(errorMessage));

    });


  }


}