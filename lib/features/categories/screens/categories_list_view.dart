import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:dio/dio.dart' as dio;
import 'package:flutter/foundation.dart';
import '../../../core/api/api_client.dart';
import '../../../core/constants/endpoints.dart';
import '../../../core/theme/colors.dart';
import '../../../core/utils/image_helper.dart';

class CategoriesListView extends StatefulWidget {
  const CategoriesListView({Key? key}) : super(key: key);

  @override
  State<CategoriesListView> createState() => _CategoriesListViewState();
}

class _CategoriesListViewState extends State<CategoriesListView> {
  bool isLoading = true;
  List<dynamic> categories = [];
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _fetchCategories();
  }

  Future<void> _fetchCategories() async {
    setState(() => isLoading = true);
    try {
      final response = await ApiClient().get(Endpoints.categories);
      if (response['success'] == true) {
        setState(() {
          categories = response['data'];
        });
      }
    } catch (e) {
      debugPrint('Error fetching categories: $e');
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<void> _deleteCategory(int id) async {
    try {
      final response = await ApiClient().delete(Endpoints.category(id));
      if (response['success'] == true) {
        setState(() {
          categories.removeWhere((c) => c['id'] == id);
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(response['message']), backgroundColor: AppColors.success),
        );
      }
    } catch (e) {
      debugPrint('Error deleting category: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('حدث خطأ أثناء حذف الصنف'), backgroundColor: AppColors.error),
      );
    }
  }

  void _showAddCategoryDialog() {
    final nameController = TextEditingController();
    final descriptionController = TextEditingController();
    XFile? selectedImage;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('إضافة صنف جديد'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                GestureDetector(
                  onTap: () async {
                    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
                    if (image != null) {
                      setDialogState(() => selectedImage = image);
                    }
                  },
                  child: Container(
                    height: 120,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey[300]!),
                    ),
                    child: selectedImage != null
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: kIsWeb
                                ? Image.network(selectedImage!.path, fit: BoxFit.cover)
                                : Image.memory(Uint8List.fromList([]), fit: BoxFit.cover), // Simplified for non-web
                          )
                        : const Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.add_a_photo, size: 40, color: Colors.grey),
                              SizedBox(height: 8),
                              Text('اختر صورة الصنف', style: TextStyle(color: Colors.grey)),
                            ],
                          ),
                  ),
                ),
                if (selectedImage != null && !kIsWeb)
                   FutureBuilder<Uint8List>(
                     future: selectedImage!.readAsBytes(),
                     builder: (context, snapshot) {
                       if (snapshot.hasData) {
                         return Padding(
                           padding: const EdgeInsets.only(top: 8.0),
                           child: ClipRRect(
                             borderRadius: BorderRadius.circular(12),
                             child: Image.memory(snapshot.data!, height: 120, width: double.infinity, fit: BoxFit.cover),
                           ),
                         );
                       }
                       return const SizedBox();
                     },
                   ),
                const SizedBox(height: 16),
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: 'اسم الصنف', border: OutlineInputBorder()),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: descriptionController,
                  decoration: const InputDecoration(labelText: 'الوصف', border: OutlineInputBorder()),
                  maxLines: 2,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('إلغاء')),
            ElevatedButton(
              onPressed: () async {
                if (nameController.text.isNotEmpty) {
                  try {
                    dio.FormData formData = dio.FormData.fromMap({
                      'name': nameController.text,
                      'description': descriptionController.text,
                    });

                    if (selectedImage != null) {
                      if (kIsWeb) {
                        final bytes = await selectedImage!.readAsBytes();
                        formData.files.add(MapEntry(
                          'image',
                          dio.MultipartFile.fromBytes(bytes, filename: selectedImage!.name),
                        ));
                      } else {
                        formData.files.add(MapEntry(
                          'image',
                          await dio.MultipartFile.fromFile(selectedImage!.path, filename: selectedImage!.name),
                        ));
                      }
                    }

                    final response = await ApiClient().post(
                      Endpoints.categories,
                      data: formData,
                    );

                    if (response['success'] == true) {
                      _fetchCategories();
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(response['message']), backgroundColor: AppColors.success),
                      );
                    }
                  } catch (e) {
                    debugPrint('Error adding category: $e');
                  }
                }
              },
              child: const Text('إضافة'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'أصناف المأكولات',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              Row(
                children: [
                  IconButton(onPressed: _fetchCategories, icon: const Icon(Icons.refresh)),
                  const SizedBox(width: 16),
                  ElevatedButton.icon(
                    onPressed: _showAddCategoryDialog,
                    icon: const Icon(Icons.add),
                    label: const Text('إضافة صنف'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    ),
                  ),
                ],
              )
            ],
          ),
          const SizedBox(height: 24),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))
                ],
              ),
              child: isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : categories.isEmpty
                      ? const Center(child: Text('لا توجد أصناف حالياً'))
                      : ListView.separated(
                          itemCount: categories.length,
                          separatorBuilder: (_, __) => const Divider(height: 1),
                          itemBuilder: (context, index) {
                            final category = categories[index];
                            final fullImageUrl = ImageHelper.buildImageUrl(category['image_url']);

                            return ListTile(
                              contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                              leading: Container(
                                width: 50,
                                height: 50,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(8),
                                  color: AppColors.primary.withOpacity(0.1),
                                  image: fullImageUrl != null
                                      ? DecorationImage(image: NetworkImage(fullImageUrl), fit: BoxFit.cover)
                                      : null,
                                ),
                                child: fullImageUrl == null
                                    ? const Icon(Icons.category, color: AppColors.primary)
                                    : null,
                              ),
                              title: Text(category['name'] ?? 'بدون اسم',
                                  style: const TextStyle(fontWeight: FontWeight.bold)),
                              subtitle: Text(category['description'] ?? 'لا يوجد وصف'),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.edit_outlined, color: Colors.blue),
                                    onPressed: () => _showEditCategoryDialog(category),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete_outline, color: Colors.red),
                                    onPressed: () {
                                      showDialog(
                                        context: context,
                                        builder: (context) => AlertDialog(
                                          title: const Text('تأكيد الحذف'),
                                          content: const Text('هل أنت متأكد من حذف هذا الصنف؟'),
                                          actions: [
                                            TextButton(
                                                onPressed: () => Navigator.pop(context), child: const Text('إلغاء')),
                                            TextButton(
                                              onPressed: () {
                                                Navigator.pop(context);
                                                _deleteCategory(category['id']);
                                              },
                                              child: const Text('حذف', style: TextStyle(color: Colors.red)),
                                            ),
                                          ],
                                        ),
                                      );
                                    },
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
            ),
          )
        ],
      ),
    );
  }

  void _showEditCategoryDialog(dynamic category) {
    final nameController = TextEditingController(text: category['name']);
    final descriptionController = TextEditingController(text: category['description']);
    XFile? selectedImage;
    final String? currentImageUrl = category['image_url'];

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('تعديل الصنف'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                GestureDetector(
                  onTap: () async {
                    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
                    if (image != null) {
                      setDialogState(() => selectedImage = image);
                    }
                  },
                  child: Container(
                    height: 120,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey[300]!),
                    ),
                    child: selectedImage != null
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: kIsWeb
                                ? Image.network(selectedImage!.path, fit: BoxFit.cover)
                                : Image.memory(Uint8List.fromList([]), fit: BoxFit.cover), // Placeholder for native
                          )
                        : (currentImageUrl != null && currentImageUrl.isNotEmpty)
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: Image.network(
                                  ImageHelper.buildImageUrl(currentImageUrl) ?? '',
                                  fit: BoxFit.cover,
                                ),
                              )
                            : const Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.add_a_photo, size: 40, color: Colors.grey),
                                  SizedBox(height: 8),
                                  Text('تغيير الصورة', style: TextStyle(color: Colors.grey)),
                                ],
                              ),
                  ),
                ),
                if (selectedImage != null && !kIsWeb)
                   FutureBuilder<Uint8List>(
                     future: selectedImage!.readAsBytes(),
                     builder: (context, snapshot) {
                       if (snapshot.hasData) {
                         return Padding(
                           padding: const EdgeInsets.only(top: 8.0),
                           child: ClipRRect(
                             borderRadius: BorderRadius.circular(12),
                             child: Image.memory(snapshot.data!, height: 120, width: double.infinity, fit: BoxFit.cover),
                           ),
                         );
                       }
                       return const SizedBox();
                     },
                   ),
                const SizedBox(height: 16),
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: 'اسم الصنف', border: OutlineInputBorder()),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: descriptionController,
                  decoration: const InputDecoration(labelText: 'الوصف', border: OutlineInputBorder()),
                  maxLines: 2,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('إلغاء')),
            ElevatedButton(
              onPressed: () async {
                if (nameController.text.isNotEmpty) {
                  try {
                    dio.FormData formData = dio.FormData.fromMap({
                      'name': nameController.text,
                      'description': descriptionController.text,
                    });

                    if (selectedImage != null) {
                      if (kIsWeb) {
                        final bytes = await selectedImage!.readAsBytes();
                        formData.files.add(MapEntry(
                          'image',
                          dio.MultipartFile.fromBytes(bytes, filename: selectedImage!.name),
                        ));
                      } else {
                        formData.files.add(MapEntry(
                          'image',
                          await dio.MultipartFile.fromFile(selectedImage!.path, filename: selectedImage!.name),
                        ));
                      }
                    }

                    final response = await ApiClient().put(
                      Endpoints.category(category['id']),
                      data: formData,
                    );

                    if (response['success'] == true) {
                      _fetchCategories();
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(response['message']), backgroundColor: AppColors.success),
                      );
                    }
                  } catch (e) {
                    debugPrint('Error updating category: $e');
                  }
                }
              },
              child: const Text('حفظ التعديلات'),
            ),
          ],
        ),
      ),
    );
  }
}
