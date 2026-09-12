import 'package:flutter/material.dart';

/// O círculo de foto de perfil, usado em todo lugar que mostra "quem é o
/// usuário" (cabeçalho do painel, menu lateral, e o que mais vier).
///
/// Existir aqui em vez de repetido em cada tela é o que garante que, se um
/// dia a foto do Google vier quebrada (URL expirada, sem internet no
/// momento do load), o fallback pro ícone acontece em todo lugar de uma vez
/// só — `onBackgroundImageError` é o que limpa a imagem quebrada da tela;
/// sem ele, o `CircleAvatar` deixaria um círculo vazio pra sempre.
class UserAvatar extends StatelessWidget {
  const UserAvatar({
    required this.photoUrl,
    this.radius = 20,
    this.backgroundColor,
    this.iconColor,
    super.key,
  });

  final String? photoUrl;
  final double radius;
  final Color? backgroundColor;
  final Color? iconColor;

  @override
  Widget build(BuildContext context) {
    return _ErrorAwareAvatar(
      key: ValueKey(photoUrl),
      photoUrl: photoUrl,
      radius: radius,
      backgroundColor: backgroundColor,
      iconColor: iconColor,
    );
  }
}

/// Widget interno com estado só pra guardar "esta URL específica já falhou
/// ao carregar" — é o que permite trocar pro ícone e não tentar de novo o
/// mesmo `NetworkImage` quebrado a cada rebuild.
class _ErrorAwareAvatar extends StatefulWidget {
  const _ErrorAwareAvatar({
    required this.photoUrl,
    required this.radius,
    required this.backgroundColor,
    required this.iconColor,
    super.key,
  });

  final String? photoUrl;
  final double radius;
  final Color? backgroundColor;
  final Color? iconColor;

  @override
  State<_ErrorAwareAvatar> createState() => _ErrorAwareAvatarState();
}

class _ErrorAwareAvatarState extends State<_ErrorAwareAvatar> {
  bool _loadFailed = false;

  @override
  Widget build(BuildContext context) {
    final showPhoto = widget.photoUrl != null && !_loadFailed;

    return CircleAvatar(
      radius: widget.radius,
      backgroundColor: widget.backgroundColor,
      backgroundImage: showPhoto ? NetworkImage(widget.photoUrl!) : null,
      onBackgroundImageError: showPhoto
          ? (_, _) {
              // `setState` fora do build atual — o erro chega de forma
              // assíncrona, depois que o frame já foi desenhado.
              if (mounted) setState(() => _loadFailed = true);
            }
          : null,
      child: showPhoto
          ? null
          : Icon(Icons.person_rounded, color: widget.iconColor),
    );
  }
}
