class LocationService {
  // Mock data structure for barangay locations
  static final Map<String, Map<String, List<String>>> _locations = {
    'BATANGAS': {
      'BATANGAS CITY': ['Alangilan', 'Tinga Itaas'],
      'MUNICIPALITY OF AGONCILLO': ['Banyaga'],
    },
  };

  // Get all provinces
  static List<String> getProvinces() {
    return _locations.keys.toList();
  }

  // Get cities for a province
  static List<String> getCities(String province) {
    return _locations[province]?.keys.toList() ?? [];
  }

  // Get barangays for a province and city
  static List<String> getBarangays(String province, String city) {
    return _locations[province]?[city] ?? [];
  }

  // Validate if location exists
  static bool isValidLocation(String province, String city, String barangay) {
    final barangays = getBarangays(province, city);
    return barangays.contains(barangay);
  }
}