/// As animações Lottie de clima que o app tem. Cada código WMO (e a
/// temperatura, no caso do frio) é agrupado numa delas por
/// `WeatherCondition.animationFor`.
///
/// Enhanced enum (o equivalente de um enum Kotlin com propriedade no
/// construtor): o caminho do asset mora junto do valor, então não existe
/// um `switch` separado que alguém esqueça de atualizar.
enum WeatherAnimation {
  sunny('assets/lottie/sunny.json'),
  partlyCloudy('assets/lottie/partly_cloudy.json'),
  cloudy('assets/lottie/cloudy.json'),
  rainy('assets/lottie/rainy.json'),
  cold('assets/lottie/cold.json');

  const WeatherAnimation(this.assetPath);

  final String assetPath;
}
