import 'package:flutter/material.dart';
import '../../../core/api/api_client.dart';
import '../../../core/constants/endpoints.dart';

class DashboardStatsView extends StatefulWidget {
  const DashboardStatsView({Key? key}) : super(key: key);

  @override
  State<DashboardStatsView> createState() => _DashboardStatsViewState();
}

class _DashboardStatsViewState extends State<DashboardStatsView> {
  bool isLoading = true;
  Map<String, dynamic>? stats;

  @override
  void initState() {
    super.initState();
    _fetchStats();
  }

  Future<void> _fetchStats() async {
    setState(() => isLoading = true);
    try {
      final response = await ApiClient().get(Endpoints.dashboardStats);
      if (response['success'] == true) {
        setState(() {
          stats = response['data'];
        });
      }
    } catch (e) {
      debugPrint('Error fetch stats: $e');
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (stats == null) {
      return const Center(child: Text('فشل جلب الإحصائيات'));
    }

    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'نظرة عامة',
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              ),
              IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: _fetchStats,
              ),
            ],
          ),
          const SizedBox(height: 32),
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  'إجمالي الطلبات',
                  stats!['orders']?['total'].toString() ?? '0',
                  Icons.list_alt,
                  Colors.blue,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildStatCard(
                  'المطاعم',
                  stats!['restaurants']?['total'].toString() ?? '0',
                  Icons.restaurant,
                  Colors.orange,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildStatCard(
                  'السائقين المتاحين',
                  stats!['drivers']?['available'].toString() ?? '0',
                  Icons.motorcycle,
                  Colors.green,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildStatCard(
                  'إجمالي الإيرادات',
                  '${stats!['revenue']?['total'] ?? 0} ل.س',
                  Icons.attach_money,
                  Colors.purple,
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),
          Expanded(
            child: Row(
              children: [
                Expanded(
                  flex: 2,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.all(24),
                    child: const Text("خاصة بمدير النظام"),
                  ),
                ),
                const SizedBox(width: 24),
                Expanded(
                  flex: 1,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'حالة الطلبات اليوم',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Divider(),
                        _buildStatusRow(
                          'معلقة',
                          stats!['orders']?['pending'] ?? 0,
                          Colors.orange,
                        ),
                        _buildStatusRow(
                          'نشطة',
                          stats!['orders']?['active'] ?? 0,
                          Colors.blue,
                        ),
                        _buildStatusRow(
                          'مكتملة',
                          stats!['orders']?['delivered'] ?? 0,
                          Colors.green,
                        ),
                        _buildStatusRow(
                          'ملغية',
                          stats!['orders']?['cancelled'] ?? 0,
                          Colors.red,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            spreadRadius: 0,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: TextStyle(color: Colors.grey[600], fontSize: 16),
              ),
              Icon(icon, color: color, size: 28),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            value,
            style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusRow(String label, int value, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(color: color, shape: BoxShape.circle),
              ),
              const SizedBox(width: 8),
              Text(label),
            ],
          ),
          Text(
            value.toString(),
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
