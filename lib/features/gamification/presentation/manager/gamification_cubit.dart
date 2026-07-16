import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/gamification_profile.dart';
import '../../domain/usecases/get_gamification_profile.dart';

class GamificationCubit extends Cubit<GamificationProfile?> {
  final GetGamificationProfileUseCase getGamificationProfileUseCase;
  StreamSubscription? _subscription;

  GamificationCubit({required this.getGamificationProfileUseCase})
    : super(null);

  void loadProfile(String uid) {
    _subscription?.cancel();
    _subscription = getGamificationProfileUseCase(
      uid,
    ).listen((profile) => emit(profile));
  }

  @override
  Future<void> close() {
    _subscription?.cancel();
    return super.close();
  }
}
