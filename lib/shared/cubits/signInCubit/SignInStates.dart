abstract class SignInStates {}

class InitialSignInState extends SignInStates {}

class LoadingSignInState extends SignInStates {}

class SuccessSignInState extends SignInStates {
  final String status;
  final String message;
  final int userId;

  SuccessSignInState(this.status, this.message, this.userId);
}

class ErrorSignInState extends SignInStates {
  dynamic error;

  ErrorSignInState(this.error);
}