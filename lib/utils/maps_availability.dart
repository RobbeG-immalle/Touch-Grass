/// Check whether the Google Maps JavaScript API is loaded (web) or the
/// API key placeholder was replaced (mobile).
///
/// Uses conditional imports so the web-specific `dart:js_interop` code
/// is never compiled into mobile builds.
export 'maps_availability_stub.dart'
    if (dart.library.js_interop) 'maps_availability_web.dart';
