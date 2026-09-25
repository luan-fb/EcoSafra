import 'package:ecosafra/app/router/app_routes.dart';
import 'package:ecosafra/features/auth/presentation/guards/auth_guards.dart';
import 'package:ecosafra/features/dashboard/dashboard_module.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router_modular/go_router_modular.dart';

void main() {
  test('registra a escolha de localização como rota filha do painel', () {
    final route = DashboardModule().routes.whereType<ChildRoute>().singleWhere(
      (route) => route.name == AppRoute.location.name,
    );

    expect(route.path, '/localizacao');
    expect(route.guards.single, isA<RequireAuthGuard>());
  });
}
