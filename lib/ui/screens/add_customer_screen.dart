import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../providers/customer_provider.dart';
import '../../utils/validators.dart';

class AddCustomerScreen extends StatefulWidget {
  const AddCustomerScreen({super.key});

  @override
  State<AddCustomerScreen> createState() => _AddCustomerScreenState();
}

class _AddCustomerScreenState extends State<AddCustomerScreen> {
  final _formKey = GlobalKey<FormState>();
  final nameCtrl = TextEditingController();
  final fNameCtrl = TextEditingController();
  final phoneCtrl = TextEditingController();
  final productCtrl = TextEditingController();
  final priceCtrl = TextEditingController();
  final downPaymentCtrl = TextEditingController();
  final monthsCtrl = TextEditingController();
  final cnicCtrl = TextEditingController();
  final addressCtrl = TextEditingController();
  final referenceNameCtrl = TextEditingController();
  final referencePhoneCtrl = TextEditingController();
  final securityCtrl = TextEditingController();
  final notesCtrl = TextEditingController();

  DateTime selectedDate = DateTime.now();
  final ImagePicker _picker = ImagePicker();
  XFile? _pickedImage;

  @override
  void dispose() {
    nameCtrl.dispose();
    fNameCtrl.dispose();
    phoneCtrl.dispose();
    productCtrl.dispose();
    priceCtrl.dispose();
    downPaymentCtrl.dispose();
    monthsCtrl.dispose();
    cnicCtrl.dispose();
    addressCtrl.dispose();
    referenceNameCtrl.dispose();
    referencePhoneCtrl.dispose();
    securityCtrl.dispose();
    notesCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      builder: (context) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Camera'),
              onTap: () => Navigator.pop(context, ImageSource.camera),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Gallery'),
              onTap: () => Navigator.pop(context, ImageSource.gallery),
            ),
          ],
        ),
      ),
    );

    if (source != null) {
      final image = await _picker.pickImage(source: source, imageQuality: 80);
      if (image != null) {
        setState(() => _pickedImage = image);
      }
    }
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2035),
    );

    if (picked != null) {
      setState(() => selectedDate = picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('New Customer Entry'),
        elevation: 0,
        backgroundColor: const Color(0xFF122A5E),
        foregroundColor: Colors.white,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF1E3C72), Color(0xFF2A5298)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                _customField(
                  'Customer Name',
                  nameCtrl,
                  Icons.person,
                  validator: (value) =>
                      value!.trim().isEmpty ? 'Enter customer name' : null,
                ),
                _customField('Father Name', fNameCtrl, Icons.person_outline),
                _customField(
                  'Mobile Number',
                  phoneCtrl,
                  Icons.phone,
                  isNumber: true,
                  validator: (value) {
                    // allow exactly up to 11 digits
                    return validateMaxLengthDigits(value, 11);
                  },
                ),

                _customField(
                  'Product Name',
                  productCtrl,
                  Icons.shopping_bag,
                  validator: (value) =>
                      value!.trim().isEmpty ? 'Enter product name' : null,
                ),
                _customField(
                  'Total Price',
                  priceCtrl,
                  Icons.attach_money,
                  isNumber: true,
                  validator: (value) {
                    if (value!.trim().isEmpty) return 'Enter price';
                    final p = double.tryParse(value.trim());
                    if (p == null) return 'Enter valid price';
                    if (p <= 0) return 'Price must be greater than 0';
                    return null;
                  },
                ),

                _customField(
                  'Down Payment',
                  downPaymentCtrl,
                  Icons.payments,
                  isNumber: true,
                ),
                _customField(
                  'Total Months',
                  monthsCtrl,
                  Icons.calendar_month,
                  isNumber: true,
                  validator: (value) =>
                      value!.trim().isEmpty ? 'Enter months' : null,
                ),
                _customField(
                  'CNIC',
                  cnicCtrl,
                  Icons.badge_outlined,
                  isNumber: true,
                  validator: (value) => validateExactDigits(value, 13),
                ),
                _customField(
                  'Address',
                  addressCtrl,
                  Icons.home_outlined,
                  validator: (value) {
                    if ((value ?? '').trim().isEmpty) return null;
                    return (value!.trim().length < 5)
                        ? 'Address is too short'
                        : null;
                  },
                ),
                _customField(
                  'Reference Name',
                  referenceNameCtrl,
                  Icons.person_add_alt_1,
                  validator: (value) => validateOnlyLettersAndSpaces(
                    value,
                    minLen: 2,
                    maxLen: 50,
                  ),
                ),
                _customField(
                  'Reference Phone',
                  referencePhoneCtrl,
                  Icons.phone_forwarded,
                  isNumber: true,
                  validator: (value) => validateMaxLengthDigits(value, 11),
                ),
                _customField(
                  'Security Details',
                  securityCtrl,
                  Icons.security,
                  validator: (value) {
                    if ((value ?? '').trim().isEmpty) return null;
                    return value!.trim().length < 3
                        ? 'Security is too short'
                        : null;
                  },
                ),
                _customField(
                  'Notes',
                  notesCtrl,
                  Icons.note_alt_outlined,
                  validator: (value) {
                    if ((value ?? '').trim().isEmpty) return null;
                    return value!.trim().length < 3
                        ? 'Notes is too short'
                        : null;
                  },
                ),

                const SizedBox(height: 8),
                Card(
                  child: ListTile(
                    leading: const Icon(
                      Icons.image_outlined,
                      color: Color(0xFF122A5E),
                    ),
                    title: const Text('Customer Photo'),
                    subtitle: Text(
                      _pickedImage == null
                          ? 'Take from camera or gallery'
                          : _pickedImage!.name,
                    ),
                    trailing: const Icon(Icons.camera_alt_outlined),
                    onTap: _pickImage,
                  ),
                ),
                const SizedBox(height: 12),
                InkWell(
                  onTap: _pickDate,
                  child: InputDecorator(
                    decoration: InputDecoration(
                      labelText: 'Start Date',
                      labelStyle: const TextStyle(color: Colors.white70),
                      prefixIcon: const Icon(
                        Icons.date_range,
                        color: Colors.orangeAccent,
                      ),
                      filled: true,
                      fillColor: Colors.white.withValues(alpha: 0.1),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    child: Text(
                      '${selectedDate.day}/${selectedDate.month}/${selectedDate.year}',
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF122A5E),
                    minimumSize: const Size(double.infinity, 55),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                  onPressed: _saveCustomer,
                  icon: const Icon(Icons.save),
                  label: const Text('SAVE CUSTOMER RECORD'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _saveCustomer() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final provider = context.read<CustomerProvider>();
    final price = double.tryParse(priceCtrl.text.trim()) ?? 0.0;
    final downPayment = double.tryParse(downPaymentCtrl.text.trim()) ?? 0.0;
    final months = int.tryParse(monthsCtrl.text.trim()) ?? 0;

    try {
      await provider.addCustomer(
        name: nameCtrl.text.trim(),
        fName: fNameCtrl.text.trim(),
        phone: phoneCtrl.text.trim(),
        months: months,
        productName: productCtrl.text.trim(),
        price: price,
        downPayment: downPayment,
        startDate: selectedDate,
        cnic: cnicCtrl.text.trim(),
        address: addressCtrl.text.trim(),
        referenceName: referenceNameCtrl.text.trim(),
        referencePhone: referencePhoneCtrl.text.trim(),
        notes: notesCtrl.text.trim(),
        securityDetails: securityCtrl.text.trim(),
        images: _pickedImage == null ? const [] : [_pickedImage!.path],
      );

      if (!mounted) return;

      Navigator.pop(context);
    } catch (e, s) {
      debugPrint('Save customer failed: $e\n$s');
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Save failed: $e')));
    }
  }

  Widget _customField(
    String label,
    TextEditingController controller,
    IconData icon, {
    bool isNumber = false,
    String? Function(String?)? validator,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: TextFormField(
        controller: controller,
        keyboardType: isNumber ? TextInputType.number : TextInputType.text,
        style: const TextStyle(color: Colors.black87),
        validator: validator ?? (value) => null,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Colors.white70),
          prefixIcon: Icon(icon, color: Colors.orangeAccent),
          filled: true,
          fillColor: Colors.white.withValues(alpha: 0.1),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }
}
