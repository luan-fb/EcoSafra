/// Rotas do app em um único lugar.
///
/// Nada de string solta espalhada (`context.go('/dashboard')`). O enum dá
/// autocomplete e o compilador avisa se uma rota for renomeada.
enum AppRoute {
  splash(path: '/', name: 'splash'),
  signIn(path: '/entrar', name: 'sign-in'),
  dashboard(path: '/painel', name: 'dashboard'),

  /// Filha do painel: o caminho é relativo a [dashboard].
  location(path: '/localizacao', name: 'location'),
  schedule(path: '/agenda', name: 'schedule');

  const AppRoute({required this.path, required this.name});

  /// Caminho na URL (também usado no deep link).
  final String path;

  /// Nome usado em `context.goNamed(AppRoute.dashboard.name)`.
  final String name;
}
