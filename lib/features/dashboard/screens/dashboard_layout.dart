import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/theme/colors.dart';
import '../../auth/cubit/auth_cubit.dart';

import 'dashboard_stats_view.dart';
import '../../restaurants/screens/restaurants_list_view.dart';
import '../../drivers/screens/drivers_list_view.dart';
import '../../orders/screens/orders_list_view.dart';
import '../../offers/screens/offers_list_view.dart';
import '../../settings/screens/settings_list_view.dart';
import '../../categories/screens/categories_list_view.dart';

class DashboardLayout extends StatefulWidget {
  const DashboardLayout({Key? key}) : super(key: key);

  @override
  State<DashboardLayout> createState() => _DashboardLayoutState();
}

class _DashboardLayoutState extends State<DashboardLayout> {
  int _selectedIndex = 0;

  final List<Widget> _views = [
    const DashboardStatsView(),
    const CategoriesListView(),
    const OffersListView(),
    const RestaurantsListView(),
    const DriversListView(),
    const OrdersListView(),
    const SettingsListView(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          // Sidebar
          Container(
            width: 250,
            color: AppColors.black,
            child: Column(
              children: [
                const SizedBox(height: 48),
                const Icon(Icons.dashboard_customize, size: 50, color: AppColors.primary),
                const SizedBox(height: 16),
                const Text(
                  'واصل',
                  style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 48),
                _buildNavItem(0, Icons.pie_chart, 'الإحصائيات'),
                _buildNavItem(1, Icons.category, 'الأصناف'),
                _buildNavItem(2, Icons.local_offer, 'العروض'),
                _buildNavItem(3, Icons.restaurant, 'المطاعم'),
                _buildNavItem(4, Icons.motorcycle, 'السائقين'),
                _buildNavItem(5, Icons.receipt_long, 'الطلبات'),
                _buildNavItem(6, Icons.settings, 'الإعدادات'),
                const Spacer(),
                const Divider(color: Colors.white24),
                ListTile(
                  leading: const Icon(Icons.logout, color: Colors.white70),
                  title: const Text('تسجيل خروج', style: TextStyle(color: Colors.white70)),
                  onTap: () => context.read<AuthCubit>().logout(),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
          
          // Main Content
          Expanded(
            child: Container(
              color: Colors.grey[100],
              child: _views[_selectedIndex],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, String title) {
    final isSelected = _selectedIndex == index;
    return Material(
      color: Colors.transparent,
      child: ListTile(
        selected: isSelected,
        selectedTileColor: AppColors.primary.withOpacity(0.2),
        leading: Icon(icon, color: isSelected ? AppColors.primary : Colors.white70),
        title: Text(
          title,
          style: TextStyle(
            color: isSelected ? AppColors.primary : Colors.white70,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        onTap: () {
          setState(() {
            _selectedIndex = index;
          });
        },
      ),
    );
  }
}
