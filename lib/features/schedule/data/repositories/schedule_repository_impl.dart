import 'package:clock/clock.dart';
import 'package:ecosafra/core/database/app_database.dart';
import 'package:ecosafra/core/error/exception_mapper.dart';
import 'package:ecosafra/core/error/exceptions.dart';
import 'package:ecosafra/core/error/failure.dart';
import 'package:ecosafra/features/auth/domain/repositories/auth_repository.dart';
import 'package:ecosafra/features/schedule/data/datasources/schedule_local_data_source.dart';
import 'package:ecosafra/features/schedule/data/models/schedule_row_mapper.dart';
import 'package:ecosafra/features/schedule/domain/entities/fertilization_schedule.dart';
import 'package:ecosafra/features/schedule/domain/repositories/schedule_repository.dart';
import 'package:fpdart/fpdart.dart';
import 'package:uuid/uuid.dart';

/// O `uid` é lido a cada chamada, não guardado no construtor: o repositório
/// é singleton e a sessão pode trocar sem o app reiniciar.
class ScheduleRepositoryImpl implements ScheduleRepository {
  const ScheduleRepositoryImpl({
    required ScheduleLocalDataSource local,
    required AuthRepository authRepository,
    required Clock clock,
    required Uuid uuid,
  }) : _local = local,
       _authRepository = authRepository,
       _clock = clock,
       _uuid = uuid;

  final ScheduleLocalDataSource _local;
  final AuthRepository _authRepository;
  final Clock _clock;
  final Uuid _uuid;

  static const _signedOutMessage = 'É preciso estar logado para usar a agenda.';

  String? get _currentUserId => _authRepository.currentUser?.uid;

  @override
  Stream<List<FertilizationSchedule>> watchSchedules() {
    final userId = _currentUserId;
    if (userId == null) return Stream.value(const []);
    return _local
        .watchByUser(userId)
        .map((rows) => rows.map((row) => row.toEntity()).toList());
  }

  @override
  Future<Either<Failure, void>> createSchedule({
    required DateTime scheduledDate,
    String? note,
  }) => _write(
    (userId) => _local.insert(
      ScheduleRow(
        id: _uuid.v4(),
        userId: userId,
        scheduledDate: scheduledDate,
        note: note,
        createdAt: _clock.now(),
      ),
    ),
  );

  @override
  Future<Either<Failure, void>> updateSchedule({
    required String id,
    required DateTime scheduledDate,
    String? note,
  }) => _write(
    (userId) => _local.updateDateAndNote(
      id: id,
      userId: userId,
      scheduledDate: scheduledDate,
      note: note,
    ),
  );

  @override
  Future<Either<Failure, void>> setScheduleCompleted({
    required String id,
    required bool completed,
  }) => _write(
    (userId) => _local.setCompletedAt(
      id: id,
      userId: userId,
      completedAt: completed ? _clock.now() : null,
    ),
  );

  @override
  Future<Either<Failure, void>> deleteSchedule(String id) =>
      _write((userId) => _local.delete(id: id, userId: userId));

  @override
  Future<Either<Failure, void>> restoreSchedule(
    FertilizationSchedule schedule,
  ) => _write(
    (userId) => _local.insert(
      ScheduleRow(
        id: schedule.id,
        userId: userId,
        scheduledDate: schedule.scheduledDate,
        note: schedule.note,
        createdAt: schedule.createdAt,
        completedAt: schedule.completedAt,
      ),
    ),
  );

  Future<Either<Failure, void>> _write(
    Future<void> Function(String userId) action,
  ) async {
    final userId = _currentUserId;
    if (userId == null) return const Left(AuthFailure(_signedOutMessage));
    try {
      await action(userId);
      return const Right(null);
    } on AppException catch (e) {
      return Left(e.toFailure());
    }
  }
}
