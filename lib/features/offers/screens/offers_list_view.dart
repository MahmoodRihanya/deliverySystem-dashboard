import 'package:flutter/material.dart';
import '../../../core/api/api_client.dart';
import '../../../core/constants/endpoints.dart';
import '../../../core/theme/colors.dart';
import '../../../core/utils/image_helper.dart';
import 'add_edit_offer_screen.dart';

class OffersListView extends StatefulWidget {
  const OffersListView({Key? key}) : super(key: key);

  @override
  State<OffersListView> createState() => _OffersListViewState();
}

class _OffersListViewState extends State<OffersListView> {
  bool isLoading = true;
  List<dynamic> offers = [];

  @override
  void initState() {
    super.initState();
    _fetchOffers();
  }

  Future<void> _fetchOffers() async {
    setState(() => isLoading = true);
    try {
      final response = await ApiClient().get(Endpoints.adminOffers);
      if (response['success'] == true) {
        setState(() {
          offers = response['data'] ?? [];
        });
      }
    } catch (e) {
      debugPrint('Error fetching offers: $e');
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<void> _toggleOfferStatus(int id, bool currentStatus) async {
    try {
      final response = await ApiClient().patch(Endpoints.toggleOfferStatus(id));
      if (response['success'] == true) {
        setState(() {
          final index = offers.indexWhere((o) => o['offer_id'] == id);
          if (index != -1) {
            offers[index]['is_active'] = response['data']['is_active'] ?? !currentStatus;
          }
        });
        // ignore: use_build_context_synchronously
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(response['message']), backgroundColor: AppColors.success),
        );
      }
    } catch (e) {
      debugPrint('Error toggling offer status: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('حدث خطأ أثناء تعديل حالة العرض'), backgroundColor: AppColors.error),
      );
    }
  }

  Future<void> _approveOffer(int id) async {
    try {
      final response = await ApiClient().patch(Endpoints.approveOffer(id));
      if (response['success'] == true) {
        _fetchOffers();
        // ignore: use_build_context_synchronously
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(response['message']), backgroundColor: AppColors.success),
        );
      }
    } catch (e) {
      debugPrint('Error approving offer: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('حدث خطأ أثناء معاملة طلب الموافقة'), backgroundColor: AppColors.error),
      );
    }
  }

  Future<void> _deleteOffer(int id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('تأكيد الحذف'),
        content: const Text('هل أنت متأكد من حذف هذا العرض نهائياً؟'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('إلغاء')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('حذف', style: TextStyle(color: Colors.red))),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      final response = await ApiClient().delete(Endpoints.deleteOffer(id));
      if (response['success'] == true) {
        setState(() {
          offers.removeWhere((o) => o['offer_id'] == id);
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(response['message']), backgroundColor: AppColors.success),
        );
      }
    } catch (e) {
      debugPrint('Error deleting offer: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('حدث خطأ أثناء حذف العرض'), backgroundColor: AppColors.error),
      );
    }
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
                'العروض النشطة',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              Row(
                children: [
                   ElevatedButton.icon(
                    onPressed: () async {
                      final result = await showDialog(
                        context: context,
                        builder: (context) => const AddEditOfferScreen(),
                      );
                      if (result == true) {
                        _fetchOffers();
                      }
                    },
                    icon: const Icon(Icons.add, color: Colors.white),
                    label: const Text('إضافة عرض جديد', style: TextStyle(color: Colors.white)),
                    style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
                  ),
                  const SizedBox(width: 16),
                  IconButton(onPressed: _fetchOffers, icon: const Icon(Icons.refresh))
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
                  : offers.isEmpty
                      ? const Center(child: Text('لا توجد عروض مضافة'))
                      : ListView.separated(
                          itemCount: offers.length,
                          separatorBuilder: (_, __) => const Divider(height: 1),
                          itemBuilder: (context, index) {
                            final offer = offers[index];
                            final isActive = offer['is_active'] ?? false;
                            
                            return ListTile(
                              contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                              leading: Container(
                                width: 60,
                                height: 60,
                                decoration: BoxDecoration(
                                  color: AppColors.pink,
                                  borderRadius: BorderRadius.circular(8),
                                  image: offer['image_url'] != null
                                      ? DecorationImage(
                                          image: NetworkImage(ImageHelper.buildImageUrl(offer['image_url'])!),
                                          fit: BoxFit.cover,
                                        )
                                      : null,
                                ),
                                child: offer['image_url'] == null ? const Icon(Icons.local_offer, color: AppColors.primary) : null,
                              ),
                              title: Text(offer['title'] ?? 'بدون عنوان', style: const TextStyle(fontWeight: FontWeight.bold)),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(offer['description'] ?? 'لا يوجد وصف'),
                                  if (offer['restaurant_id'] != null)
                                    Padding(
                                      padding: const EdgeInsets.only(top: 4.0),
                                      child: Text(
                                        'بواسطة مطعم : ${offer['restaurants']?.isNotEmpty == true ? offer['restaurants'][0]['restaurant_name'] : 'مطعم محدد'}',
                                        style: const TextStyle(color: Colors.blue, fontWeight: FontWeight.bold, fontSize: 12),
                                      ),
                                    ),
                                ],
                              ),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  // Restaurants badge
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                    decoration: BoxDecoration(
                                      color: Colors.blue.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Text(
                                      '${offer['restaurants']?.length ?? 0} مطاعم',
                                      style: const TextStyle(color: Colors.blue, fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                    decoration: BoxDecoration(
                                      color: isActive ? Colors.green.withOpacity(0.1) : Colors.orange.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Text(
                                      isActive ? 'مفعل' : 'معطل',
                                      style: TextStyle(color: isActive ? Colors.green : Colors.orange, fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                  if (offer['is_approved'] == false) ...[
                                    const SizedBox(width: 16),
                                    ElevatedButton(
                                      onPressed: () => _approveOffer(offer['offer_id']),
                                      style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                                      child: const Text('موافقة', style: TextStyle(color: Colors.white)),
                                    ),
                                  ],
                                  const SizedBox(width: 16),
                                  Switch(
                                    value: isActive,
                                    activeColor: AppColors.primary,
                                    onChanged: (val) => _toggleOfferStatus(offer['offer_id'], isActive),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete, color: Colors.red),
                                    onPressed: () => _deleteOffer(offer['offer_id']),
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
}
