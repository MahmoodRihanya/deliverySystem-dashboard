import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/api/api_client.dart';
import '../../../core/constants/endpoints.dart';
import 'settings_state.dart';

class SettingsCubit extends Cubit<SettingsState> {
  final ApiClient _apiClient;

  SettingsCubit(this._apiClient) : super(SettingsInitial());

  Future<void> fetchSettings() async {
    emit(SettingsLoading());
    try {
      final response = await _apiClient.get(Endpoints.settings);
      if (response['success'] == true) {
        final List data = response['data'];
        final Map<String, dynamic> settingsMap = {};
        for (var item in data) {
          settingsMap[item['setting_name']] = item;
        }
        emit(SettingsLoaded(settingsMap));
      } else {
        emit(SettingsError(response['message'] ?? 'فشل في جلب الإعدادات'));
      }
    } catch (e) {
      emit(SettingsError(e.toString()));
    }
  }

  Future<void> updateSettings(Map<String, dynamic> updatedValues) async {
    // Preserve current settings to restore in case of failure
    Map<String, dynamic>? currentSettings;
    if (state is SettingsLoaded) {
      currentSettings = (state as SettingsLoaded).settings;
    }
    
    emit(SettingsUpdating());
    try {
      final response = await _apiClient.put(
        Endpoints.settings,
        data: {'settings': updatedValues},
      );

      if (response['success'] == true) {
        emit(SettingsUpdateSuccess(response['message'] ?? 'تم تحديث الإعدادات بنجاح'));
        await fetchSettings(); // Refresh settings
      } else {
        emit(SettingsError(response['message'] ?? 'فشل في تحديث الإعدادات'));
        if (currentSettings != null) {
          emit(SettingsLoaded(currentSettings));
        }
      }
    } catch (e) {
      emit(SettingsError(e.toString()));
      if (currentSettings != null) {
        emit(SettingsLoaded(currentSettings));
      }
    }
  }
}
