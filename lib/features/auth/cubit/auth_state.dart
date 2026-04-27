import 'package:equatable/equatable.dart';

abstract class AuthState extends Equatable {
  const AuthState();
  
  @override
  List<Object?> get props => [];
}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class AuthSuccess extends AuthState {
  final Map<String, dynamic> adminData;
  const AuthSuccess(this.adminData);

  @override
  List<Object?> get props => [adminData];
}

class AuthFailure extends AuthState {
  final String error;
  const AuthFailure(this.error);
  
  @override
  List<Object?> get props => [error];
}
