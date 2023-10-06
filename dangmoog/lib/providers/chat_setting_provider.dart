import 'package:flutter/material.dart';

class ChatSettingProvider with ChangeNotifier {
  bool _resizeScreenKeyboard = true;

  bool get resizeScreenKeyboard => _resizeScreenKeyboard;

  void setKeyboardResizable() {
    _resizeScreenKeyboard = true;
    notifyListeners();
  }

  void setKeyboardUnResizable() {
    _resizeScreenKeyboard = false;
    notifyListeners();
  }

  bool _blockInteraction = false;

  bool get blockInteraction => _blockInteraction;

  void setInteractionBlocked() {
    _blockInteraction = true;
    notifyListeners();
  }

  void setInteractionUnBlocked() {
    _blockInteraction = false;
    notifyListeners();
  }
}
