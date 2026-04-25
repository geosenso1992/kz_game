import 'package:flutter/material.dart';

/// Returns a responsive scale factor for desktop/web and tablet layouts.
/// Keeps the app at native mobile size on small screens, but enlarges
/// buttons, text and spacing on wider browser windows.
double responsiveScale(BuildContext context) {
  final width = MediaQuery.of(context).size.width;
  const baseWidth = 360.0;
  const maxScale = 1.5;
  return (width / baseWidth).clamp(1.0, maxScale);
}
