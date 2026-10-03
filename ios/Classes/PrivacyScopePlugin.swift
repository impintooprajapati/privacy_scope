import Flutter
import UIKit

public class PrivacyScopePlugin: NSObject, FlutterPlugin, FlutterStreamHandler {
    private static let overlayTag = 982341

    private var appSwitcherPolicy: String = "allow"
    private var screenshotPolicy: String = "allow"
    private var eventSink: FlutterEventSink?

    public static func register(with registrar: FlutterPluginRegistrar) {
        let methodChannel = FlutterMethodChannel(name: "privacy_scope/methods", binaryMessenger: registrar.messenger())
        let eventChannel = FlutterEventChannel(name: "privacy_scope/events", binaryMessenger: registrar.messenger())

        let instance = PrivacyScopePlugin()
        registrar.addMethodCallDelegate(instance, channel: methodChannel)
        eventChannel.setStreamHandler(instance)
    }

    override init() {
        super.init()
        setupLifecycleObservers()
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case "applyPolicy":
            if let args = call.arguments as? [String: Any] {
                self.screenshotPolicy = args["screenshot"] as? String ?? "allow"
                self.appSwitcherPolicy = args["appSwitcher"] as? String ?? "allow"
            }
            result(nil)

        case "isScreenCaptured":
            let isCaptured = UIScreen.main.isCaptured
            result(isCaptured)

        default:
            result(FlutterMethodNotImplemented)
        }
    }

    // MARK: - FlutterStreamHandler
    public func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
        self.eventSink = events

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(screenCaptureChanged),
            name: UIScreen.capturedDidChangeNotification,
            object: nil
        )

        // Check initial state
        if UIScreen.main.isCaptured {
            events("capture_started")
        }

        return nil
    }

    public func onCancel(withArguments arguments: Any?) -> FlutterError? {
        NotificationCenter.default.removeObserver(self, name: UIScreen.capturedDidChangeNotification, object: nil)
        self.eventSink = nil
        return nil
    }

    @objc private func screenCaptureChanged() {
        guard let sink = self.eventSink else { return }
        if UIScreen.main.isCaptured {
            sink("capture_started")
        } else {
            sink("capture_stopped")
        }
    }

    // MARK: - App Switcher Privacy Overlay
    private func setupLifecycleObservers() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(appWillResignActive),
            name: UIApplication.willResignActiveNotification,
            object: nil
        )

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(appDidBecomeActive),
            name: UIApplication.didBecomeActiveNotification,
            object: nil
        )
    }

    @objc private func appWillResignActive() {
        guard appSwitcherPolicy == "blur" || appSwitcherPolicy == "hide" else { return }
        guard let window = getKeyWindow() else { return }

        // Remove any existing overlay first
        window.viewWithTag(PrivacyScopePlugin.overlayTag)?.removeFromSuperview()

        let overlay: UIView
        if appSwitcherPolicy == "blur" {
            let blurEffect = UIBlurEffect(style: .systemMaterial)
            let blurView = UIVisualEffectView(effect: blurEffect)
            blurView.frame = window.bounds
            blurView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            overlay = blurView
        } else {
            let opaqueView = UIView(frame: window.bounds)
            opaqueView.backgroundColor = UIColor.systemBackground
            opaqueView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            overlay = opaqueView
        }

        overlay.tag = PrivacyScopePlugin.overlayTag
        window.addSubview(overlay)
        window.bringSubviewToFront(overlay)
    }

    @objc private func appDidBecomeActive() {
        guard let window = getKeyWindow() else { return }
        if let overlay = window.viewWithTag(PrivacyScopePlugin.overlayTag) {
            UIView.animate(withDuration: 0.15, animations: {
                overlay.alpha = 0
            }) { _ in
                overlay.removeFromSuperview()
            }
        }
    }

    private func getKeyWindow() -> UIWindow? {
        if #available(iOS 13.0, *) {
            return UIApplication.shared.connectedScenes
                .filter { $0.activationState == .foregroundActive || $0.activationState == .foregroundInactive }
                .compactMap { $0 as? UIWindowScene }
                .flatMap { $0.windows }
                .first { $0.isKeyWindow }
                ?? UIApplication.shared.windows.first { $0.isKeyWindow }
        } else {
            return UIApplication.shared.keyWindow
        }
    }
}
