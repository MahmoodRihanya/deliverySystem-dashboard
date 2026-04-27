import 'package:flutter/material.dart';
import '../../../core/api/api_client.dart';
import '../../../core/constants/endpoints.dart';
import '../../../core/theme/colors.dart';
import '../../../core/utils/image_helper.dart';

class RestaurantsListView extends StatefulWidget {
  const RestaurantsListView({Key? key}) : super(key: key);

  @override
  State<RestaurantsListView> createState() => _RestaurantsListViewState();
}

class _RestaurantsListViewState extends State<RestaurantsListView> {
  bool isLoading = true;
  List<dynamic> restaurants = [];

  @override
  void initState() {
    super.initState();
    _fetchRestaurants();
  }

  Future<void> _fetchRestaurants() async {
    setState(() => isLoading = true);
    try {
      final response = await ApiClient().get(Endpoints.restaurants);
      if (response['success'] == true) {
        setState(() {
          restaurants = response['data'];
        });
      }
    } catch (e) {
      debugPrint('Error fetching restaurants: $e');
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<void> _toggleApproval(int id, bool currentStatus) async {
    try {
      final response = await ApiClient().patch(Endpoints.approveRestaurant(id));
      if (response['success'] == true) {
        // تحديث القائمة بعد الاستجابة الناجحة لتجنب عمل refresh كامل لكل الداتا 
         setState(() {
           final index = restaurants.indexWhere((r) => r['restaurant_id'] == id);
           if (index != -1) {
             restaurants[index]['is_approved'] = response['data']['is_approved'] ?? !currentStatus;
           }
         });
        // تجاهل تحذير السياق
        // ignore: use_build_context_synchronously
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(response['message']), backgroundColor: AppColors.success),
        );
      }
    } catch (e) {
      debugPrint('Error toggling approval: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('حدث خطأ أثناء تعديل حالة المطعم'), backgroundColor: AppColors.error),
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
                'المطاعم المسجلة',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              IconButton(onPressed: _fetchRestaurants, icon: const Icon(Icons.refresh))
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
                  : restaurants.isEmpty
                      ? const Center(child: Text('لا توجد مطاعم مسجلة'))
                      : ListView.separated(
                          itemCount: restaurants.length,
                          separatorBuilder: (_, __) => const Divider(height: 1),
                          itemBuilder: (context, index) {
                            final restaurant = restaurants[index];
                            final isApproved = restaurant['is_approved'] ?? false;
                            
                            return ListTile(
                                contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                                leading: CircleAvatar(
                                  backgroundColor: AppColors.pink,
                                  backgroundImage: (restaurant['logo_url'] != null && restaurant['logo_url'].toString().isNotEmpty)
                                      ? NetworkImage(ImageHelper.buildImageUrl(restaurant['logo_url'])!)
                                      : null,
                                  child: (restaurant['logo_url'] == null || restaurant['logo_url'].toString().isEmpty) ? const Icon(Icons.restaurant, color: AppColors.primary) : null,
                                ),
                              title: Text(restaurant['restaurant_name'] ?? 'بدون اسم', style: const TextStyle(fontWeight: FontWeight.bold)),
                              subtitle: Text('المالك: ${restaurant['owner_name'] ?? '-'} | الهاتف: ${restaurant['phone'] ?? '-'}'),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                    decoration: BoxDecoration(
                                      color: isApproved ? Colors.green.withOpacity(0.1) : Colors.orange.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Text(
                                      isApproved ? 'معتمد' : 'غير معتمد',
                                      style: TextStyle(color: isApproved ? Colors.green : Colors.orange, fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Switch(
                                    value: isApproved,
                                    activeColor: AppColors.primary,
                                    onChanged: (val) => _toggleApproval(restaurant['restaurant_id'], isApproved),
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
