import 'package:flutter/material.dart';
import '../../../core/api/api_client.dart';
import '../../../core/constants/endpoints.dart';
import '../../../core/theme/colors.dart';
import '../../../core/utils/image_helper.dart';

class OrdersListView extends StatefulWidget {
  const OrdersListView({Key? key}) : super(key: key);

  @override
  State<OrdersListView> createState() => _OrdersListViewState();
}

class _OrdersListViewState extends State<OrdersListView> {
  bool isLoading = true;
  List<dynamic> orders = [];

  @override
  void initState() {
    super.initState();
    _fetchOrders();
  }

  Future<void> _fetchOrders() async {
    setState(() => isLoading = true);
    try {
      final response = await ApiClient().get(Endpoints.orders);
      if (response['success'] == true) {
        setState(() {
          orders = response['data'];
        });
      }
    } catch (e) {
      debugPrint('Error fetching orders: $e');
    } finally {
      setState(() => isLoading = false);
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
                'الطلبات',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              IconButton(onPressed: _fetchOrders, icon: const Icon(Icons.refresh))
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
                  : orders.isEmpty
                      ? const Center(child: Text('لا توجد طلبات'))
                      : ListView.separated(
                          itemCount: orders.length,
                          separatorBuilder: (_, __) => const Divider(height: 1),
                          itemBuilder: (context, index) {
                            final order = orders[index];
                            final status = order['order_status'] ?? '';
                            
                            Color statusColor = Colors.grey;
                            if (status == 'pending') statusColor = Colors.orange;
                            if (status == 'delivered') statusColor = Colors.green;
                            if (status == 'cancelled') statusColor = Colors.red;
                            if (status == 'active' || status == 'ready' || status == 'accepted') statusColor = Colors.blue;

                            return ListTile(
                                contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                                leading: CircleAvatar(
                                  backgroundColor: AppColors.pink,
                                  backgroundImage: (order['restaurant']?['logo_url'] != null)
                                      ? NetworkImage(ImageHelper.buildImageUrl(order['restaurant']['logo_url'])!)
                                      : null,
                                  child: (order['restaurant']?['logo_url'] == null) ? const Icon(Icons.restaurant, color: AppColors.primary) : null,
                                ),
                                title: Text('طلب #${order['order_id']} - ${order['restaurant']?['restaurant_name'] ?? ''}', style: const TextStyle(fontWeight: FontWeight.bold)),
                              subtitle: Text('العميل: ${order['user']?['full_name'] ?? '-'} | الإجمالي: ${order['total_amount']?.toString() ?? '0'} ل.س'),
                              trailing: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: statusColor.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  status,
                                  style: TextStyle(color: statusColor, fontWeight: FontWeight.bold),
                                ),
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
