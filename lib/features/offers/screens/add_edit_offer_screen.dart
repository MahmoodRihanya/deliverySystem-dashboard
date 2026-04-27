import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:dio/dio.dart';
import '../../../core/api/api_client.dart';
import '../../../core/constants/endpoints.dart';
import '../../../core/theme/colors.dart';

class AddEditOfferScreen extends StatefulWidget {
  final Map<String, dynamic>? offer; // null for new
  const AddEditOfferScreen({Key? key, this.offer}) : super(key: key);

  @override
  State<AddEditOfferScreen> createState() => _AddEditOfferScreenState();
}

class _AddEditOfferScreenState extends State<AddEditOfferScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  
  Uint8List? _imageBytes;
  String? _imageName;
  bool _isLoading = false;
  
  List<dynamic> _allRestaurants = [];
  List<int> _selectedRestaurantIds = [];

  @override
  void initState() {
    super.initState();
    if (widget.offer != null) {
      _titleController.text = widget.offer!['title'] ?? '';
      _descriptionController.text = widget.offer!['description'] ?? '';
      
      // جلب المطاعم المختارة مسبقاً
      if (widget.offer!['restaurants'] != null && widget.offer!['restaurants'] is List) {
        _selectedRestaurantIds = (widget.offer!['restaurants'] as List)
            .map((r) => r['restaurant_id'] as int)
            .toList();
      }
    }
    _fetchRestaurants();
  }

  Future<void> _fetchRestaurants() async {
    try {
      final response = await ApiClient().get(Endpoints.restaurants);
      if (response['success'] == true) {
        setState(() {
          _allRestaurants = response['data'] ?? [];
        });
      }
    } catch (e) {
      debugPrint('Error fetching restaurants: $e');
    }
  }

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    
    if (image != null) {
      final bytes = await image.readAsBytes();
      setState(() {
        _imageBytes = bytes;
        _imageName = image.name;
      });
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_imageBytes == null && widget.offer == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('الرجاء اختيار صورة للعرض'), backgroundColor: AppColors.error),
      );
      return;
    }

    setState(() => _isLoading = true);
    
    try {
      FormData formData = FormData.fromMap({
        'title': _titleController.text,
        'description': _descriptionController.text,
        // send array to backend as JSON string or multi-part fields depending on parsing. 
        // We handle JSON.parse on backend so sending as a string is safe.
        'restaurant_ids': _selectedRestaurantIds.join(','), 
      });

      if (_imageBytes != null) {
        formData.files.add(
          MapEntry(
            'image',
            MultipartFile.fromBytes(_imageBytes!, filename: _imageName ?? 'offer_image.jpg'),
          ),
        );
      }

      final response = await ApiClient().post(
        Endpoints.createOffer,
        data: formData,
      );

      if (response['success'] == true) {
        // ignore: use_build_context_synchronously
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('تم حفظ العرض بنجاح'), backgroundColor: AppColors.success),
        );
        // ignore: use_build_context_synchronously
        Navigator.pop(context, true);
      }
    } catch (e) {
      debugPrint('Error saving offer: $e');
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('حدث خطأ أثناء الحفظ'), backgroundColor: AppColors.error),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: 600,
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.offer == null ? 'إضافة عرض جديد' : 'تعديل العرض',
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 24),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Image Picker
                      Center(
                        child: GestureDetector(
                          onTap: _pickImage,
                          child: Container(
                            width: 200,
                            height: 120,
                            decoration: BoxDecoration(
                              color: Colors.grey[200],
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.grey[400]!),
                              image: _imageBytes != null
                                  ? DecorationImage(
                                      image: MemoryImage(_imageBytes!),
                                      fit: BoxFit.cover,
                                    )
                                  : null,
                            ),
                            child: _imageBytes == null
                                ? const Center(
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(Icons.add_photo_alternate, size: 40, color: Colors.grey),
                                        SizedBox(height: 8),
                                        Text('اختر صورة العرض', style: TextStyle(color: Colors.grey)),
                                      ],
                                    ),
                                  )
                                : null,
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      
                      TextFormField(
                        controller: _titleController,
                        decoration: const InputDecoration(
                          labelText: 'عنوان العرض (مثال: توصيل مجاني)',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) => value == null || value.isEmpty ? 'هذا الحقل مطلوب' : null,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _descriptionController,
                        maxLines: 2,
                        decoration: const InputDecoration(
                          labelText: 'وصف إضافي (اختياري)',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 24),
                      const Text('اختر المطاعم المشمولة في هذا العرض:', style: TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey[300]!),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: _allRestaurants.length,
                          itemBuilder: (context, index) {
                            final rest = _allRestaurants[index];
                            final restId = rest['restaurant_id'];
                            return CheckboxListTile(
                              title: Text(rest['restaurant_name']),
                              subtitle: Text(rest['owner_name'] ?? ''),
                              value: _selectedRestaurantIds.contains(restId),
                              onChanged: (bool? value) {
                                setState(() {
                                  if (value == true) {
                                    _selectedRestaurantIds.add(restId);
                                  } else {
                                    _selectedRestaurantIds.remove(restId);
                                  }
                                });
                              },
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('إلغاء'),
                  ),
                  const SizedBox(width: 16),
                  ElevatedButton(
                    onPressed: _isLoading ? null : _submit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    ),
                    child: _isLoading
                        ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                        : const Text('حفظ العرض', style: TextStyle(color: Colors.white)),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
