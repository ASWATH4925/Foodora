import 'package:flutter/material.dart';

class Address {
  final String id;
  final String label;
  final String fullAddress;
  bool isSelected;

  Address({
    required this.id,
    required this.label,
    required this.fullAddress,
    this.isSelected = false,
  });
}

class AddressProvider extends ChangeNotifier {
  final List<Address> _addresses = [
    Address(
      id: 'default_1',
      label: 'Other',
      fullAddress: 'Keelkattalai',
      isSelected: true,
    ),
  ];

  List<Address> get addresses => [..._addresses];

  Address? get selectedAddress {
    try {
      return _addresses.firstWhere((a) => a.isSelected);
    } catch (_) {
      return _addresses.isNotEmpty ? _addresses.first : null;
    }
  }

  void addAddress(String label, String fullAddress) {
    final address = Address(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      label: label,
      fullAddress: fullAddress,
    );
    _addresses.add(address);
    selectAddress(address.id);
  }

  void selectAddress(String id) {
    for (var addr in _addresses) {
      addr.isSelected = addr.id == id;
    }
    notifyListeners();
  }

  void deleteAddress(String id) {
    _addresses.removeWhere((a) => a.id == id);
    if (_addresses.isNotEmpty && !_addresses.any((a) => a.isSelected)) {
      _addresses.first.isSelected = true;
    }
    notifyListeners();
  }
}
