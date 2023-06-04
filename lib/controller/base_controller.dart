import 'package:get/get.dart';
import 'package:tracking_app/enum/view_state.dart';

class BaseController extends GetxController implements GetxService {
  final _state = ViewState.idle.obs;


  ViewState get state => _state.value;

  setState(ViewState state) {
    _state.value = state;
  }
}
