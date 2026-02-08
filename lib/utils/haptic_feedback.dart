import 'package:flutter/services.dart';

class HapticService {
  static Future<void> light() async {
    try {
      await HapticFeedback.lightImpact();
    } catch (e) {
      // Device might not support haptics
    }
  }

  static Future<void> medium() async {
    try {
      await HapticFeedback.mediumImpact();
    } catch (e) {
      // Device might not support haptics
    }
  }

  static Future<void> heavy() async {
    try {
      await HapticFeedback.heavyImpact();
    } catch (e) {
      // Device might not support haptics
    }
  }

  static Future<void> selection() async {
    try {
      await HapticFeedback.selectionClick();
    } catch (e) {
      // Device might not support haptics
    }
  }

  static Future<void> success() async {
    try {
      await HapticFeedback.heavyImpact();
    } catch (e) {
      // Device might not support haptics
    }
  }

  static Future<void> error() async {
    try {
      await HapticFeedback.heavyImpact();
    } catch (e) {
      // Device might not support haptics
    }
  }
}
