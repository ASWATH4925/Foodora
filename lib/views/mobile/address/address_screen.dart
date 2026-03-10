import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:swiggy_ui/models/address_provider.dart';
import 'package:swiggy_ui/utils/app_colors.dart';
import 'package:swiggy_ui/utils/ui_helper.dart';

class AddressScreen extends StatefulWidget {
  const AddressScreen({Key? key}) : super(key: key);

  @override
  State<AddressScreen> createState() => _AddressScreenState();
}

class _AddressScreenState extends State<AddressScreen> {
  final _addressController = TextEditingController();
  String _selectedLabel = 'Home';
  final _labels = ['Home', 'Work', 'Other'];

  @override
  void dispose() {
    _addressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text('Manage Addresses'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Add new address section
            Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.15),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Add New Address',
                    style: Theme.of(context).textTheme.titleSmall!.copyWith(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  UIHelper.verticalSpaceMedium(),
                  // Label selector
                  Row(
                    children: _labels.map((label) {
                      final isSelected = _selectedLabel == label;
                      return Padding(
                        padding: const EdgeInsets.only(right: 10),
                        child: ChoiceChip(
                          label: Text(label),
                          selected: isSelected,
                          selectedColor: foodoraOrange,
                          labelStyle: TextStyle(
                            color: isSelected ? Colors.white : Colors.black,
                          ),
                          onSelected: (selected) {
                            if (selected) {
                              setState(() => _selectedLabel = label);
                            }
                          },
                        ),
                      );
                    }).toList(),
                  ),
                  UIHelper.verticalSpaceMedium(),
                  TextField(
                    controller: _addressController,
                    maxLines: 3,
                    decoration: InputDecoration(
                      hintText: 'Enter full address...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: darkOrange!, width: 2),
                      ),
                      prefixIcon: const Icon(Icons.location_on),
                    ),
                  ),
                  UIHelper.verticalSpaceMedium(),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        if (_addressController.text.trim().isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Please enter an address'),
                              backgroundColor: Colors.red,
                            ),
                          );
                          return;
                        }
                        Provider.of<AddressProvider>(context, listen: false)
                            .addAddress(
                          _selectedLabel,
                          _addressController.text.trim(),
                        );
                        _addressController.clear();
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: const Text('Address added successfully!'),
                            backgroundColor: Colors.green[700],
                          ),
                        );
                      },
                      icon: const Icon(Icons.add),
                      label: const Text('SAVE ADDRESS'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: darkOrange,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Saved addresses list
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'SAVED ADDRESSES',
                style: Theme.of(context).textTheme.titleSmall!.copyWith(
                      color: Colors.grey[600],
                      fontSize: 13,
                    ),
              ),
            ),
            UIHelper.verticalSpaceSmall(),
            Consumer<AddressProvider>(
              builder: (context, addressProvider, _) {
                final addresses = addressProvider.addresses;
                if (addresses.isEmpty) {
                  return Padding(
                    padding: const EdgeInsets.all(32),
                    child: Center(
                      child: Text(
                        'No saved addresses',
                        style: TextStyle(color: Colors.grey[500]),
                      ),
                    ),
                  );
                }
                return ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: addresses.length,
                  itemBuilder: (context, index) {
                    final addr = addresses[index];
                    return Container(
                      margin: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        border: addr.isSelected
                            ? Border.all(color: darkOrange!, width: 2)
                            : null,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.1),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: ListTile(
                        leading: Icon(
                          addr.label == 'Home'
                              ? Icons.home
                              : addr.label == 'Work'
                                  ? Icons.work
                                  : Icons.location_on,
                          color: addr.isSelected ? darkOrange : Colors.grey,
                        ),
                        title: Text(
                          addr.label,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: addr.isSelected ? darkOrange : Colors.black,
                          ),
                        ),
                        subtitle: Text(
                          addr.fullAddress,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (addr.isSelected)
                              Icon(Icons.check_circle,
                                  color: Colors.green[700], size: 22),
                            IconButton(
                              icon: Icon(Icons.delete_outline,
                                  color: Colors.red[400]),
                              onPressed: () {
                                addressProvider.deleteAddress(addr.id);
                              },
                            ),
                          ],
                        ),
                        onTap: () {
                          addressProvider.selectAddress(addr.id);
                        },
                      ),
                    );
                  },
                );
              },
            ),
            UIHelper.verticalSpaceLarge(),
          ],
        ),
      ),
    );
  }
}
