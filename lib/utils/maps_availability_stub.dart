/// Non-web stub — on Android/iOS the Maps SDK is always bundled,
/// so we assume it is available. A missing API key will still show a
/// watermark, but the SDK itself is present.
bool isMapsApiAvailable() => true;
