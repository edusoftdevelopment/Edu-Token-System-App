part of '../network.dart';

class Failure {
  Failure({required this.code, required this.message});

  int code;
  String message;
}

class ServerFailure extends Failure {
  ServerFailure({required super.code, required super.message});
}

class CacheFailure extends Failure {
  CacheFailure({required super.code, required super.message});
}
