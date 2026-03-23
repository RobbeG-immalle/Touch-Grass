import 'dart:js_interop';

@JS('google.maps.Map')
external JSFunction? get _googleMapsMapConstructor;

/// Returns `true` when the Google Maps JavaScript API has been loaded
/// (i.e. `window.google.maps.Map` exists).
bool isMapsApiAvailable() {
  try {
    return _googleMapsMapConstructor != null;
  } catch (_) {
    return false;
  }
}
