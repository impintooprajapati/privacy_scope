/// Context-aware privacy protection for Flutter apps.
///
/// Apply screenshot protection, app-switcher privacy, and sensitive-screen
/// policies only where your app needs them.
library privacy_scope;

export 'src/controller/privacy_controller.dart';
export 'src/controller/scope_registration.dart';
export 'src/core/privacy_event.dart';
export 'src/core/privacy_policy.dart';
export 'src/core/privacy_state.dart';
export 'src/platform/privacy_platform.dart';
export 'src/platform/privacy_platform_event.dart';
export 'src/widgets/privacy_scope_widget.dart';
