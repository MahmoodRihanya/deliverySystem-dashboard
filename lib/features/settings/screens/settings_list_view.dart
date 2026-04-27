import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/theme/colors.dart';
import '../cubit/settings_cubit.dart';
import '../cubit/settings_state.dart';

class SettingsListView extends StatefulWidget {
  const SettingsListView({Key? key}) : super(key: key);

  @override
  State<SettingsListView> createState() => _SettingsListViewState();
}

class _SettingsListViewState extends State<SettingsListView> {
  final Map<String, TextEditingController> _controllers = {};
  bool _maintenanceMode = false;
  bool _enableDelivery = true;

  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    context.read<SettingsCubit>().fetchSettings();
  }

  @override
  void dispose() {
    for (var controller in _controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  TextEditingController _getController(String key, String initialValue) {
    if (!_controllers.containsKey(key)) {
      _controllers[key] = TextEditingController(text: initialValue);
    }
    return _controllers[key]!;
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<SettingsCubit, SettingsState>(
      listener: (context, state) {
        if (state is SettingsUpdateSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message), backgroundColor: Colors.green),
          );
        } else if (state is SettingsError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message), backgroundColor: Colors.red),
          );
        } else if (state is SettingsLoaded) {
          final settings = state.settings;
          // Initialize controllers for all text settings
          settings.forEach((key, data) {
            final value = data['value']?.toString() ?? '';
            if (data['value'] != 'true' && data['value'] != 'false' && 
                key != 'maintenance_mode' && key != 'enable_delivery') {
              if (!_controllers.containsKey(key)) {
                _controllers[key] = TextEditingController(text: value);
              } else {
                // Update text if it's different and not being edited? 
                // For simplicity, just update if it's the first load
                if (!_isInitialized) {
                  _controllers[key]!.text = value;
                }
              }
            }
          });

          if (!_isInitialized) {
            if (settings.containsKey('maintenance_mode')) {
              _maintenanceMode = settings['maintenance_mode']['value'] == 'true' || settings['maintenance_mode']['value'] == '1';
            }
            if (settings.containsKey('enable_delivery')) {
              _enableDelivery = settings['enable_delivery']['value'] == 'true' || settings['enable_delivery']['value'] == '1';
            }
            _isInitialized = true;
          }
        }
      },
      builder: (context, state) {
        if (state is SettingsLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state is SettingsLoaded || state is SettingsUpdating) {
          Map<String, dynamic> settings = {};
          if (state is SettingsLoaded) {
            settings = state.settings;
          }

          return Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'إعدادات النظام',
                      style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                    ElevatedButton.icon(
                      onPressed: state is SettingsUpdating ? null : _saveSettings,
                      icon: state is SettingsUpdating 
                          ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                          : const Icon(Icons.save),
                      label: const Text('حفظ الإعدادات'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Expanded(
                  child: Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    child: ListView(
                      padding: const EdgeInsets.all(24.0),
                      children: [
                        const Text('الإعدادات العامة', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.primary)),
                        const Divider(),
                        const SizedBox(height: 16),
                        _buildTextField(
                          label: 'الرسالة الترحيبية (أعلى شريط البحث)',
                          keyName: 'home_greeting',
                          value: settings['home_greeting']?['value'] ?? '',
                          description: 'تظهر للمستخدمين في الصفحة الرئيسية فوق شريط البحث',
                          maxLines: 1,
                        ),
                        const SizedBox(height: 16),
                        _buildTextField(
                          label: 'رسالة الترحيب العامة',
                          keyName: 'welcome_message',
                          value: settings['welcome_message']?['value'] ?? '',
                          description: 'تظهر للمستخدمين عند فتح التطبيق (Dialog/Splash)',
                          maxLines: 2,
                        ),
                        const SizedBox(height: 24),
                        const Text('إعدادات الطلبات', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.primary)),
                        const Divider(),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: _buildTextField(
                                label: 'سعر الكيلومتر (للتوصيل)',
                                keyName: 'delivery_fee_per_km',
                                value: settings['delivery_fee_per_km']?['value'] ?? '0',
                                description: 'السعر بالعملة المحلية لكل كيلومتر',
                                isNumber: true,
                              ),
                            ),
                            const SizedBox(width: 24),
                            Expanded(
                              child: _buildTextField(
                                label: 'وقت التوصيل المتوقع (دقيقة)',
                                keyName: 'estimated_delivery_time',
                                value: settings['estimated_delivery_time']?['value'] ?? '30',
                                description: 'الوقت الافتراضي للتوصيل',
                                isNumber: true,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        _buildTextField(
                          label: 'مهلة تعيين السائق (ثانية)',
                          keyName: 'driver_assign_timeout',
                          value: settings['driver_assign_timeout']?['value'] ?? '600',
                          description: 'الوقت الأقصى للبحث عن سائق قبل إلغاء التعيين التلقائي',
                          isNumber: true,
                        ),
                        const SizedBox(height: 24),
                        const Text('حالة النظام', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.primary)),
                        const Divider(),
                        const SizedBox(height: 16),
                        SwitchListTile(
                          title: const Text('وضع الصيانة (Maintenance Mode)'),
                          subtitle: const Text('إيقاف التطبيق مؤقتاً للصيانة'),
                          value: _maintenanceMode,
                          activeColor: AppColors.primary,
                          onChanged: (val) {
                            setState(() {
                              _maintenanceMode = val;
                            });
                          },
                        ),
                        SwitchListTile(
                          title: const Text('تفعيل خدمة التوصيل'),
                          subtitle: const Text('تفعيل أو إيقاف استلام طلبات التوصيل'),
                          value: _enableDelivery,
                          activeColor: AppColors.primary,
                          onChanged: (val) {
                            setState(() {
                              _enableDelivery = val;
                            });
                          },
                        ),
                        const SizedBox(height: 24),
                        _buildTextField(
                          label: 'رسالة وضع الصيانة',
                          keyName: 'maintenance_message',
                          value: settings['maintenance_message']?['value'] ?? 'التطبيق في حالة صيانة حالياً، يرجى المحاولة لاحقاً',
                          description: 'تظهر للمستخدمين عندما يكون التطبيق في وضع الصيانة',
                          maxLines: 2,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        }

        return const Center(child: Text('جاري تحميل الإعدادات...'));
      },
    );
  }

  Widget _buildTextField({
    required String label,
    required String keyName,
    required String value,
    String? description,
    bool isNumber = false,
    int maxLines = 1,
  }) {
    final controller = _getController(keyName, value);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
        if (description != null) ...[
          const SizedBox(height: 4),
          Text(description, style: TextStyle(color: Colors.grey[600], fontSize: 12)),
        ],
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          keyboardType: isNumber ? TextInputType.number : TextInputType.text,
          maxLines: maxLines,
          decoration: InputDecoration(
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
        ),
      ],
    );
  }

  void _saveSettings() {
    final updatedValues = <String, dynamic>{};
    
    // Collect text field values
    _controllers.forEach((key, controller) {
      updatedValues[key] = controller.text;
    });
    
    // Collect boolean values
    updatedValues['maintenance_mode'] = _maintenanceMode ? 'true' : 'false';
    updatedValues['enable_delivery'] = _enableDelivery ? 'true' : 'false';

    context.read<SettingsCubit>().updateSettings(updatedValues);
  }
}
