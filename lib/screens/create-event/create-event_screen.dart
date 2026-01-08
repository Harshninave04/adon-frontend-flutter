import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';

import '../../constants.dart';
import '../../helper/keyboard.dart';
import '../../core/constants/api_constants.dart';

class AddEventScreen extends StatefulWidget {
  const AddEventScreen({super.key});

  @override
  State<AddEventScreen> createState() => _AddEventScreenState();
}

class _AddEventScreenState extends State<AddEventScreen> {
  final _formKey = GlobalKey<FormState>();

  // Controllers
  final titleController = TextEditingController();
  final descriptionController = TextEditingController();
  final locationController = TextEditingController();
  final ticketPriceController = TextEditingController();
  final totalSeatsController = TextEditingController();

  DateTime? startDate;
  DateTime? endDate;

  bool isLoading = false;

  File? selectedImage;
  Uint8List? webImageBytes;
  final ImagePicker _picker = ImagePicker();

  Razorpay? _razorpay;
  String? razorpayOrderId;
  String? razorpayPaymentId;
  String? razorpaySignature;

  @override
  void initState() {
    super.initState();
    _razorpay = Razorpay();
    _razorpay!.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay!.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
  }

  @override
  void dispose() {
    _razorpay?.clear();
    titleController.dispose();
    descriptionController.dispose();
    locationController.dispose();
    ticketPriceController.dispose();
    totalSeatsController.dispose();
    super.dispose();
  }

  // IMAGE
  Future<void> pickImage() async {
    final XFile? image =
        await _picker.pickImage(source: ImageSource.gallery, imageQuality: 80);
    if (image == null) return;

    if (kIsWeb) {
      webImageBytes = await image.readAsBytes();
      selectedImage = null;
    } else {
      selectedImage = File(image.path);
      webImageBytes = null;
    }
    setState(() {});
  }

  // DATE PICKERS
  Future<void> pickStartDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        startDate = picked;
        if (endDate != null && endDate!.isBefore(picked)) {
          endDate = null;
        }
      });
    }
  }

  Future<void> pickEndDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: startDate ?? DateTime.now(),
      firstDate: startDate ?? DateTime.now(),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() => endDate = picked);
    }
  }

  // STEP 1: CREATE PLATFORM FEE ORDER
  Future<void> createPlatformFeeOrder() async {
    if (!_formKey.currentState!.validate()) return;

    if (startDate == null || endDate == null) {
      _error('Please select start and end dates');
      return;
    }

    KeyboardUtil.hideKeyboard(context);
    setState(() => isLoading = true);

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('accessToken');

      final response = await http.post(
        Uri.parse(ApiConstants.baseUrl + ApiConstants.createEventFee),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      final data = jsonDecode(response.body);
      razorpayOrderId = data['id'];

      _openRazorpayCheckout(
        orderId: razorpayOrderId!,
        amount: data['amount'],
      );
    } catch (e) {
      _error(e.toString());
      setState(() => isLoading = false);
    }
  }

  // RAZORPAY
  void _openRazorpayCheckout({
    required String orderId,
    required int amount,
  }) {
    const options = {
      'key': 'rzp_test_LetnicYdIN9c1h',
      'currency': 'INR',
      'name': 'AdOn',
      'description': 'Platform Fee',
      'image': 'https://www.adonservice.in/logo1.jpg',
    };

    final checkoutOptions = {
      ...options,
      'amount': amount,
      'order_id': orderId,
    };

    _razorpay!.open(checkoutOptions);
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) {
    razorpayPaymentId = response.paymentId;
    razorpaySignature = response.signature;
    createEvent();
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    _error('Payment failed or cancelled');
    setState(() => isLoading = false);
  }

  // STEP 3: CREATE EVENT
  Future<void> createEvent() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('accessToken');

      final request = http.MultipartRequest(
        'POST',
        Uri.parse(ApiConstants.baseUrl + ApiConstants.createEvent),
      );

      request.headers['Authorization'] = 'Bearer $token';

      request.fields.addAll({
        'title': titleController.text.trim(),
        'description': descriptionController.text.trim(),
        'location': locationController.text.trim(),
        'startDate': startDate!.toIso8601String(),
        'endDate': endDate!.toIso8601String(),
        'ticketPrice': ticketPriceController.text,
        'totalSeats': totalSeatsController.text,
        'razorpayOrderId': razorpayOrderId!,
        'razorpayPaymentId': razorpayPaymentId!,
        'razorpaySignature': razorpaySignature!,
      });

      if (kIsWeb && webImageBytes != null) {
        request.files.add(
          http.MultipartFile.fromBytes('image', webImageBytes!,
              filename: 'event.jpg'),
        );
      } else if (selectedImage != null) {
        request.files.add(
          await http.MultipartFile.fromPath('image', selectedImage!.path),
        );
      }

      final response = await request.send();

      if (response.statusCode == 200 || response.statusCode == 201) {
        _showSuccessModal();
        _resetForm();
      } else {
        throw Exception(await response.stream.bytesToString());
      }
    } catch (e) {
      _error(e.toString());
    } finally {
      setState(() => isLoading = false);
    }
  }

  // RESET
  void _resetForm() {
    titleController.clear();
    descriptionController.clear();
    locationController.clear();
    ticketPriceController.clear();
    totalSeatsController.clear();
    startDate = null;
    endDate = null;
    selectedImage = null;
    webImageBytes = null;
    razorpayOrderId = null;
    razorpayPaymentId = null;
    razorpaySignature = null;
    _formKey.currentState!.reset();
    setState(() {});
  }

  // MODAL
  void _showSuccessModal() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text("🎉 Event Created"),
        content: const Text(
          "Your event has been created successfully.",
          style: TextStyle(fontSize: 15),
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: kPrimaryColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text("OK"),
          ),
        ],
      ),
    );
  }

  void _error(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: Colors.red),
    );
  }

  // UI - UPDATED WITH BETTER DESIGN
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 60),
              const Text(
                "Create\nEvent",
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  height: 1.2,
                ),
              ),
              const SizedBox(height: 40),
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    _textField(titleController, "Event Title", Icons.event),
                    _textField(
                      descriptionController,
                      "Description (optional)",
                      Icons.notes,
                      required: false,
                    ),
                    _textField(
                      locationController,
                      "Location",
                      Icons.location_on,
                    ),
                    _numberField(
                      ticketPriceController,
                      "Ticket Price",
                      Icons.currency_rupee,
                    ),
                    _numberField(
                      totalSeatsController,
                      "Total Seats",
                      Icons.people,
                    ),

                    const SizedBox(height: 12),

                    _dateTile(
                      label: "Start Date",
                      date: startDate,
                      onTap: pickStartDate,
                    ),
                    const SizedBox(height: 12),
                    _dateTile(
                      label: "End Date",
                      date: endDate,
                      onTap: pickEndDate,
                    ),

                    const SizedBox(height: 20),

                    // IMAGE PICKER
                    GestureDetector(
                      onTap: pickImage,
                      child: Container(
                        height: 140,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade300),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: selectedImage == null && webImageBytes == null
                            ? const Center(
                                child: Text(
                                  "Tap to upload event image",
                                  style: TextStyle(color: Colors.grey),
                                ),
                              )
                            : ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: kIsWeb
                                    ? Image.memory(
                                        webImageBytes!,
                                        fit: BoxFit.cover,
                                      )
                                    : Image.file(
                                        selectedImage!,
                                        fit: BoxFit.cover,
                                      ),
                              ),
                      ),
                    ),

                    const SizedBox(height: 30),

                    // SUBMIT BUTTON
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: kPrimaryColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: isLoading ? null : createPlatformFeeOrder,
                        child: isLoading
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.white),
                                ),
                              )
                            : const Text(
                                "Pay ₹10 & Create Event",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                      ),
                    ),
                    const SizedBox(height: 30),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // UI HELPERS
  Widget _textField(
    TextEditingController controller,
    String hint,
    IconData icon, {
    bool required = true,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: TextFormField(
        controller: controller,
        validator: required
            ? (v) => v == null || v.isEmpty ? '$hint is required' : null
            : null,
        decoration: InputDecoration(
          hintText: hint,
          prefixIcon: Icon(icon),
          filled: true,
          fillColor: Colors.white,
          border: _outlineInputBorder(),
          enabledBorder: _outlineInputBorder(),
          focusedBorder: _outlineInputBorder(),
        ),
      ),
    );
  }

  Widget _numberField(
    TextEditingController controller,
    String hint,
    IconData icon,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: TextFormField(
        controller: controller,
        keyboardType: TextInputType.number,
        validator: (v) =>
            v == null || num.tryParse(v) == null ? 'Invalid $hint' : null,
        decoration: InputDecoration(
          hintText: hint,
          prefixIcon: Icon(icon),
          filled: true,
          fillColor: Colors.white,
          border: _outlineInputBorder(),
          enabledBorder: _outlineInputBorder(),
          focusedBorder: _outlineInputBorder(),
        ),
      ),
    );
  }

  Widget _dateTile({
    required String label,
    required DateTime? date,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(12),
          color: Colors.white,
        ),
        child: Row(
          children: [
            const Icon(Icons.calendar_today_outlined),
            const SizedBox(width: 12),
            Text(
              date == null ? label : date.toLocal().toString().split(' ')[0],
              style: TextStyle(
                color: date == null ? Colors.grey : Colors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }

  OutlineInputBorder _outlineInputBorder() {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: Colors.grey.shade300),
    );
  }
}
