import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../../data/models/customer_model.dart';
import '../../providers/customer_provider.dart';
import '../../utils/validators.dart';

enum ImageSourceKey { cnicFront, cnicBack, product }

class EditCustomerScreen extends StatefulWidget {
  const EditCustomerScreen({super.key, required this.customer});

  final CustomerModel customer;

  @override
  State<EditCustomerScreen> createState() => _EditCustomerScreenState();
}

class _EditCustomerScreenState extends State<EditCustomerScreen> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController nameCtrl;
  late final TextEditingController fatherCtrl;
  late final TextEditingController phoneCtrl;
  late final TextEditingController cnicCtrl;
  late final TextEditingController addressCtrl;
  late final TextEditingController productCtrl;
  late final TextEditingController priceCtrl;
  late final TextEditingController downCtrl;
  late final TextEditingController monthsCtrl;
  late final TextEditingController referenceNameCtrl;
  late final TextEditingController referencePhoneCtrl;
  late final TextEditingController notesCtrl;
  late final TextEditingController securityCtrl;

  final ImagePicker _picker = ImagePicker();
  XFile? _cnicFront;
  XFile? _cnicBack;
  XFile? _productImage;

  @override
  void initState() {
    super.initState();
    nameCtrl = TextEditingController(text: widget.customer.name);
    fatherCtrl = TextEditingController(text: widget.customer.fatherName);
    phoneCtrl = TextEditingController(text: widget.customer.mobile);
    cnicCtrl = TextEditingController(text: widget.customer.cnic);
    addressCtrl = TextEditingController(text: widget.customer.address);
    productCtrl = TextEditingController(text: widget.customer.productName);
    priceCtrl = TextEditingController(text: widget.customer.price.toString());
    downCtrl = TextEditingController(
      text: widget.customer.downPayment.toString(),
    );
    monthsCtrl = TextEditingController(
      text: widget.customer.totalMonths.toString(),
    );
    referenceNameCtrl = TextEditingController(
      text: widget.customer.referenceName,
    );
    referencePhoneCtrl = TextEditingController(
      text: widget.customer.referencePhone,
    );
    notesCtrl = TextEditingController(text: widget.customer.notes);
    securityCtrl = TextEditingController(text: widget.customer.securityDetails);

    // images order: 0=cnicFront, 1=cnicBack, 2=productImage
    final imgs = widget.customer.images;
    _cnicFront = imgs.length > 0 ? _filePathToXFile(imgs[0]) : null;
    _cnicBack = imgs.length > 1 ? _filePathToXFile(imgs[1]) : null;
    _productImage = imgs.length > 2 ? _filePathToXFile(imgs[2]) : null;
  }

  XFile? _filePathToXFile(String path) {
    if (path.trim().isEmpty) return null;
    return XFile(path);
  }

  Future<XFile?> _pickAndReturn(ImageSourceKey key) async {
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

    if (source == null) return null;

    final image = await _picker.pickImage(source: source, imageQuality: 80);
    return image;
  }

  // top-level enum must be outside the state class

  @override
  void dispose() {
    nameCtrl.dispose();
    fatherCtrl.dispose();
    phoneCtrl.dispose();
    cnicCtrl.dispose();
    addressCtrl.dispose();
    productCtrl.dispose();
    priceCtrl.dispose();
    downCtrl.dispose();
    monthsCtrl.dispose();
    referenceNameCtrl.dispose();
    referencePhoneCtrl.dispose();
    notesCtrl.dispose();
    securityCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Customer'),
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
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            // Auto validate mode se error live show hote rehte hain.
            // Agar aap chaho to is line ko disable karke sirf SAVE par validate kiya ja sakta hai.
            autovalidateMode: AutovalidateMode.onUserInteraction,
            child: Column(
              children: [
                _field(
                  'Name',
                  nameCtrl,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty)
                      return 'Enter name';
                    return validateOnlyLettersAndSpaces(
                      value,
                      minLen: 2,
                      maxLen: 50,
                    );
                  },
                ),
                _field(
                  'Father Name',
                  fatherCtrl,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty)
                      return 'Enter father name';
                    return validateOnlyLettersAndSpaces(
                      value,
                      minLen: 2,
                      maxLen: 50,
                    );
                  },
                ),
                _field(
                  'Phone',
                  phoneCtrl,
                  keyboardType: TextInputType.phone,
                  validator: (value) {
                    // max 11 digits, digitsOnly check.
                    return validateMaxLengthDigits(value, 11);
                  },
                ),
                _field(
                  'CNIC',
                  cnicCtrl,
                  keyboardType: TextInputType.number,
                  validator: (value) => validateExactDigits(value, 13),
                ),
                _field(
                  'Address',
                  addressCtrl,
                  validator: (value) {
                    if ((value ?? '').trim().isEmpty) return null;
                    return (value!.trim().length < 5)
                        ? 'Address is too short'
                        : null;
                  },
                ),
                _field(
                  'Product',
                  productCtrl,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty)
                      return 'Enter product';
                    return null;
                  },
                ),
                _field(
                  'Price',
                  priceCtrl,
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if ((value ?? '').trim().isEmpty) return 'Enter price';
                    final p = double.tryParse(value!.trim());
                    if (p == null) return 'Enter valid price';
                    if (p <= 0) return 'Price must be greater than 0';
                    return null;
                  },
                ),
                _field(
                  'Down Payment',
                  downCtrl,
                  keyboardType: TextInputType.number,
                ),
                _field(
                  'Months',
                  monthsCtrl,
                  keyboardType: TextInputType.number,
                ),
                _field('Reference Name', referenceNameCtrl),
                _field(
                  'Reference Phone',
                  referencePhoneCtrl,
                  keyboardType: TextInputType.phone,
                ),
                _field('Notes', notesCtrl),
                _field('Security Details', securityCtrl),
                const SizedBox(height: 16),
                Card(
                  child: ListTile(
                    leading: const Icon(
                      Icons.credit_card,
                      color: Color(0xFF122A5E),
                    ),
                    title: const Text('CNIC Front'),
                    subtitle: Text(
                      _cnicFront == null
                          ? 'Take from camera or gallery'
                          : _cnicFront!.name,
                    ),
                    trailing: const Icon(Icons.camera_alt_outlined),
                    onTap: () async {
                      final image = await _pickAndReturn(
                        ImageSourceKey.cnicFront,
                      );
                      if (!mounted) return;
                      if (image != null) setState(() => _cnicFront = image);
                    },
                  ),
                ),
                const SizedBox(height: 12),
                Card(
                  child: ListTile(
                    leading: const Icon(
                      Icons.credit_card,
                      color: Color(0xFF122A5E),
                    ),
                    title: const Text('CNIC Back'),
                    subtitle: Text(
                      _cnicBack == null
                          ? 'Take from camera or gallery'
                          : _cnicBack!.name,
                    ),
                    trailing: const Icon(Icons.camera_alt_outlined),
                    onTap: () async {
                      final image = await _pickAndReturn(
                        ImageSourceKey.cnicBack,
                      );
                      if (!mounted) return;
                      setState(() => _cnicBack = image);
                    },
                  ),
                ),
                const SizedBox(height: 12),
                Card(
                  child: ListTile(
                    leading: const Icon(
                      Icons.shopping_bag_outlined,
                      color: Color(0xFF122A5E),
                    ),
                    title: const Text('Product Image'),
                    subtitle: Text(
                      _productImage == null
                          ? 'Take from camera or gallery'
                          : _productImage!.name,
                    ),
                    trailing: const Icon(Icons.camera_alt_outlined),
                    onTap: () async {
                      final image = await _pickAndReturn(
                        ImageSourceKey.product,
                      );
                      if (!mounted) return;
                      setState(() => _productImage = image);
                    },
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      final ok = _formKey.currentState?.validate() ?? false;
                      if (!ok) return;
                      _save();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF122A5E),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      minimumSize: const Size(double.infinity, 55),
                    ),
                    child: const Text('SAVE CUSTOMER RECORD'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _save() async {
    final provider = context.read<CustomerProvider>();

    final updatedImages = [
      if (_cnicFront != null) _cnicFront!.path,
      if (_cnicBack != null) _cnicBack!.path,
      if (_productImage != null) _productImage!.path,
    ];

    final updated = CustomerModel(
      id: widget.customer.id,
      name: nameCtrl.text.trim(),
      adminUid: widget.customer.adminUid,
      fatherName: fatherCtrl.text.trim(),
      mobile: phoneCtrl.text.trim(),
      cnic: cnicCtrl.text.trim(),
      address: addressCtrl.text.trim(),
      productName: productCtrl.text.trim(),
      price: double.tryParse(priceCtrl.text.trim()) ?? widget.customer.price,
      downPayment:
          double.tryParse(downCtrl.text.trim()) ?? widget.customer.downPayment,
      totalInstallments:
          int.tryParse(monthsCtrl.text.trim()) ?? widget.customer.totalMonths,
      installmentAmount: widget.customer.installmentAmount,
      completedInstallments: widget.customer.completedInstallments,
      paidAmount: widget.customer.paidAmount,
      lastPaidMonth: widget.customer.lastPaidMonth,
      startDate: widget.customer.startDate,
      referenceName: referenceNameCtrl.text.trim(),
      referencePhone: referencePhoneCtrl.text.trim(),
      shopName: widget.customer.shopName,
      notes: notesCtrl.text.trim(),
      images: [
        if (_cnicFront != null) _cnicFront!.path,
        if (_cnicBack != null) _cnicBack!.path,
        if (_productImage != null) _productImage!.path,
      ],
      totalMonths:
          int.tryParse(monthsCtrl.text.trim()) ?? widget.customer.totalMonths,
      isPaid: widget.customer.isPaid,
      securityDetails: securityCtrl.text.trim(),
    );

    await provider.updateCustomer(updated);

    if (!mounted) return;
    Navigator.pop(context);
  }

  Widget _field(
    String label,
    TextEditingController controller, {
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        validator: validator,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Colors.white),
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
