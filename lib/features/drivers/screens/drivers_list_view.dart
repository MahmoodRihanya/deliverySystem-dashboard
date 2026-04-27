import 'package:flutter/material.dart';
import '../../../core/api/api_client.dart';
import '../../../core/constants/endpoints.dart';
import '../../../core/theme/colors.dart';
import '../../../core/utils/image_helper.dart';

class DriversListView extends StatefulWidget {
  const DriversListView({Key? key}) : super(key: key);

  @override
  State<DriversListView> createState() => _DriversListViewState();
}

class _DriversListViewState extends State<DriversListView> {
  bool isLoading = true;
  List<dynamic> drivers = [];

  @override
  void initState() {
    super.initState();
    _fetchDrivers();
  }

  Future<void> _fetchDrivers() async {
    setState(() => isLoading = true);
    try {
      final response = await ApiClient().get(Endpoints.drivers);
      if (response['success'] == true) {
        setState(() {
          drivers = response['data'];
        });
      }
    } catch (e) {
      debugPrint('Error fetching drivers: $e');
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<void> _toggleApproval(int id, bool currentStatus) async {
    try {
      final response = await ApiClient().put(Endpoints.approveDriver(id));
      if (response['success'] == true) {
         setState(() {
           final index = drivers.indexWhere((d) => d['driver_id'] == id);
           if (index != -1) {
             drivers[index]['is_approved'] = response['data']['is_approved'] ?? !currentStatus;
           }
         });
        // ignore: use_build_context_synchronously
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(response['message']), backgroundColor: AppColors.success),
        );
      }
    } catch (e) {
      debugPrint('Error toggling approval: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('حدث خطأ أثناء الاعتماد'), backgroundColor: AppColors.error),
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
                'السائقين المسجلين',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              IconButton(onPressed: _fetchDrivers, icon: const Icon(Icons.refresh))
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
                  : drivers.isEmpty
                      ? const Center(child: Text('لا يوجد سائقين مسجلين'))
                      : ListView.separated(
                          itemCount: drivers.length,
                          separatorBuilder: (_, __) => const Divider(height: 1),
                          itemBuilder: (context, index) {
                            final driver = drivers[index];
                            final isApproved = driver['is_approved'] ?? false;
                            
                            return ListTile(
                              contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                              leading: CircleAvatar(
                                backgroundColor: AppColors.pink,
                                backgroundImage: (driver['profile_image'] != null)
                                    ? NetworkImage(ImageHelper.buildImageUrl(driver['profile_image'])!)
                                    : null,
                                child: (driver['profile_image'] == null) ? const Icon(Icons.person, color: AppColors.primary) : null,
                              ),
                              title: Text(driver['full_name'] ?? 'السائق #${driver['driver_id']}', style: const TextStyle(fontWeight: FontWeight.bold)),
                              subtitle: Text('رقم الهاتف: ${driver['phone'] ?? '-'} | المركبة: ${driver['vehicle_type'] ?? '-'}'),
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
                                    onChanged: (val) => _toggleApproval(driver['driver_id'], isApproved),
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
