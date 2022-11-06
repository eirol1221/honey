import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:honey/src/controller/appium.dart';
import 'package:honey/src/controller/debug.dart';
import 'package:honey/src/honey_function.dart';
import 'package:honey/src/overlay/honey_overlay.dart';

enum HoneyMode {
  debug,
  appium,
}

class HoneyWidgetsBinding extends BindingBase
    with
        GestureBinding,
        SchedulerBinding,
        ServicesBinding,
        PaintingBinding,
        SemanticsBinding,
        RendererBinding,
        WidgetsBinding,
        TestDefaultBinaryMessengerBinding {
  static HoneyWidgetsBinding get instance =>
      BindingBase.checkInstance(_instance);
  static HoneyWidgetsBinding? _instance;

  final _key = GlobalKey();
  final _semanticTagProperties = <String, Map<String, String>>{};

  var _testing = false;
  Widget? _rootWidget;
  late TestTextInput _testTextInput;

  TestTextInput get testTextInput => _testTextInput;

  Size get screenSize => window.physicalSize / window.devicePixelRatio;

  @override
  void initInstances() {
    super.initInstances();
    _instance = this;
    _testTextInput = TestTextInput();
  }

  static void ensureInitialized({
    HoneyMode mode = HoneyMode.debug,
    Map<String, HoneyFunction> customFunctions = const {},
  }) {
    if (_instance == null) {
      final instance = HoneyWidgetsBinding();
      instance.pipelineOwner.ensureSemantics();

      switch (mode) {
        case HoneyMode.debug:
          DebugController(customFunctions);
          break;
        case HoneyMode.appium:
          runFromClipboard(customFunctions);
          break;
      }
    }
  }

  @override
  void scheduleAttachRootWidget(Widget rootWidget) {
    _rootWidget = rootWidget;

    Widget widget = KeyedSubtree(key: _key, child: rootWidget);
    if (!_testing) {
      widget = HoneyOverlay(child: widget);
    }

    super.scheduleAttachRootWidget(widget);
  }

  Future<void> waitUntilSettled(Duration timeout) async {
    final s = Stopwatch()..start();
    do {
      scheduleFrame();
      await endOfFrame;
    } while (hasScheduledFrame && s.elapsed < timeout);
  }

  void updateSemanticsProperties(
    SemanticsTag tag,
    Map<String, String>? properties,
  ) {
    if (properties != null) {
      _semanticTagProperties[tag.name] = properties;
    } else {
      _semanticTagProperties.remove(tag.name);
    }
  }

  Map<String, String>? getSemanticsProperties(SemanticsTag tag) {
    return _semanticTagProperties[tag];
  }

  void reset({required bool testing}) {
    _testing = testing;
    resetGestureBinding();
    _testTextInput.reset();
    if (testing) {
      _testTextInput.register();
    } else {
      _testTextInput.unregister();
    }

    if (_rootWidget != null) {
      runApp(_rootWidget!);
    }
  }
}
