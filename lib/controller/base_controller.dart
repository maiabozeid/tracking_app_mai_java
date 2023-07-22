import 'package:get/get.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:tracking_app/enum/view_state.dart';

class BaseController extends GetxController   {
  final _state = ViewState.idle.obs;

  ViewState get state => _state.value;

  setState(ViewState state) {
    _state.value = state;
  }

  final isConnected = false.obs;

  BaseController() {
    Future<bool> connected = InternetConnectionChecker().hasConnection;
    connected.then((value) {
      isConnected.value = value;

    });
  }
}
