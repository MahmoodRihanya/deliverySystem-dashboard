import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/api/api_client.dart';
import '../../../core/constants/endpoints.dart';
import '../../../core/storage/local_storage.dart';
import 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  final ApiClient _apiClient;

  AuthCubit(this._apiClient) : super(AuthInitial());

  Future<void> login(String username, String password) async {
    emit(AuthLoading());
    try {
      final response = await _apiClient.post(Endpoints.loginAdmin, data: {
        'username': username,
        'password': password,
      });

      if (response['success'] == true) {
        final token = response['token'];
        final refreshToken = response['refreshToken'] ?? response['refresh_token'];
        
        await LocalStorage.saveToken(token);
        if (refreshToken != null) {
          await LocalStorage.saveRefreshToken(refreshToken);
        }

        emit(AuthSuccess(response['data']));
      } else {
        emit(AuthFailure(response['message'] ?? 'Login failed'));
      }
    } catch (e) {
      emit(AuthFailure(e.toString()));
    }
  }

  Future<void> logout() async {
    await LocalStorage.clearAll();
    emit(AuthInitial());
  }

  void checkAuth() {
    final token = LocalStorage.getToken();
    if (token != null) {
      // افتراضياً نعتبره مسجل دخول
      emit(const AuthSuccess({}));
    } else {
      emit(AuthInitial());
    }
  }
}
