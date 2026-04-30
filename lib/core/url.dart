/// Resultado de [normalizeUrl]. `url` es null si la entrada está vacía o es
/// inválida; `error` solo se setea cuando la entrada no parsea como URL.
class NormalizedUrl {
  const NormalizedUrl({this.url, this.error});

  final String? url;
  final String? error;
}

/// Normaliza un texto a URL. Si el usuario escribe "epec.com.ar" lo convierte
/// a "https://epec.com.ar/". Schemes custom (ej: "mercadopago://...") se
/// preservan.
NormalizedUrl normalizeUrl(String raw) {
  final trimmed = raw.trim();
  if (trimmed.isEmpty) return const NormalizedUrl(url: null);

  final hasScheme = RegExp(
    r'^[a-z][a-z0-9+\-.]*:',
    caseSensitive: false,
  ).hasMatch(trimmed);
  final candidate = hasScheme ? trimmed : 'https://$trimmed';

  final uri = Uri.tryParse(candidate);
  if (uri == null || uri.scheme.isEmpty) {
    return const NormalizedUrl(url: null, error: 'El link no es válido.');
  }
  return NormalizedUrl(url: uri.toString());
}

/// `true` si la URL es http(s); `false` si es deep link u otra cosa.
bool isWebUrl(String url) {
  final uri = Uri.tryParse(url);
  if (uri == null) return false;
  return uri.scheme == 'http' || uri.scheme == 'https';
}
