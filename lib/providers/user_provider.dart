import 'package:flutter/foundation.dart';
import '../models/user_model.dart';

class UserProvider with ChangeNotifier {
  LocationData? _location;
  bool _isRegisteredResident = false;
  Map<String, String> _registrationData = {};

  LocationData? get location => _location;
  bool get isRegisteredResident => _isRegisteredResident;
  Map<String, String> get registrationData => _registrationData;

  void setLocation(String province, String city, String barangay) {
    _location = LocationData(
      province: province,
      city: city,
      barangay: barangay,
    );
    notifyListeners();
  }

  void setResidencyStatus(bool isResident) {
    _isRegisteredResident = isResident;
    notifyListeners();
  }

  void setUserDetails({
    required String fullName,
    required String email,
    required String phone,
    required String password,
  }) {
    _registrationData = {
      'fullName': fullName,
      'email': email,
      'phone': phone,
      'password': password,
    };
    notifyListeners();
  }

  void clearRegistrationData() {
    _location = null;
    _isRegisteredResident = false;
    _registrationData = {};
    notifyListeners();
  }
}