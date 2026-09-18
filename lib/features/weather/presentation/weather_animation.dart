/// As animações Lottie de clima que o app tem. São só três: cada código WMO
/// é agrupado numa delas por `WeatherCondition.animationFor`.
///
/// Enhanced enum (o equivalente de um enum Kotlin com propriedade no
/// construtor): o caminho do asset mora junto do valor, então não existe
/// um `switch` separado que alguém esqueça de atualizar.
enum WeatherAnimation {
  sunny('assets/lottie/sunny.json'),
  cloudy('assets/lottie/cloudy.json'),
  rainy('assets/lottie/rainy.json');

  const WeatherAnimation(this.assetPath);

  final String assetPath;
}
