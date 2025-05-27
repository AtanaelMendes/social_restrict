import UIKit
import Flutter
import SwiftUI
import FirebaseCore
import FirebaseMessaging
import Foundation
import FamilyControls
import DeviceActivity
import ManagedSettings

// Variável global usada para rastrear o método Flutter
var globalMethodCall: String = ""

@available(iOS 15.0, *)
@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate, MessagingDelegate {
    var model = MyModel.shared
    var store = ManagedSettingsStore()

    override func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        print("[AppDelegate] didFinishLaunchingWithOptions chamado linha \(#line)")

        FirebaseApp.configure()
        print("[AppDelegate] Firebase configurado linha 27")

        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, _ in
            print("[AppDelegate] Permissão de notificação: \(granted) linha \(#line)")
            if granted {
                DispatchQueue.main.async {
                    application.registerForRemoteNotifications()
                    print("[AppDelegate] Notificações remotas registradas linha \(#line)")
                }
            }
        }

        Messaging.messaging().delegate = self
        print("[AppDelegate] Firebase Messaging delegate configurado linha 38")

        GeneratedPluginRegistrant.register(with: self)
        print("[AppDelegate] Plugins do Flutter registrados linha \(#line)")

        guard let controller = window?.rootViewController as? FlutterViewController else {
            print("[AppDelegate] Erro ao acessar FlutterViewController linha \(#line)")
            return super.application(application, didFinishLaunchingWithOptions: launchOptions)
        }

        let methodChannel = FlutterMethodChannel(
            name: "flutter.native/helper",
            binaryMessenger: controller.binaryMessenger
        )
        print("[AppDelegate] FlutterMethodChannel criado linha \(#line)")

        methodChannel.setMethodCallHandler { [weak self] call, result in
            guard let self = self else { return }

            print("[AppDelegate] Método chamado do Flutter: \(call.method) linha \(#line)")

            switch call.method {
            case "selectAppsToDiscourage", "selectAppsToEncourage":
                globalMethodCall = call.method
                print("[AppDelegate] Apresentando ContentView para \(call.method) linha \(#line)")
                let vc = UIHostingController(
                    rootView: ContentView(globalMethodCall: call.method)
                        .environmentObject(self.model)
                        .environmentObject(self.store)
                )
                controller.present(vc, animated: false)
                result(nil)

            case "blockApps":
                print("[AppDelegate] Chamado blockApps linha \(#line)")
                var applications = self.store.application.blockedApplications ?? Set<Application>()
                if let args = call.arguments as? [String: Any],
                   let apps = args["apps"] as? [String] {
                    print("[AppDelegate] Aplicativos para bloquear: \(apps) linha \(#line)")
                    apps.forEach { appId in
                        applications.insert(Application(bundleIdentifier: appId))
                    }
                    self.store.application.blockedApplications = applications
                }
                result(nil)

            case "unlockApps":
                print("[AppDelegate] Chamado unlockApps linha \(#line)")
                if let args = call.arguments as? [String: Any],
                   let apps = args["apps"] as? [String] {
                    print("[AppDelegate] Aplicativos para desbloquear: \(apps) linha \(#line)")
                    apps.forEach { appId in
                        self.store.application.blockedApplications?.remove(Application(bundleIdentifier: appId))
                    }
                }
                result(nil)

            case "report":
                print("[AppDelegate] Chamado report linha \(#line)")
                let monitor = DeviceActivityCenter()
                let deviceName = DeviceActivityName("teste")
                let schedule = DeviceActivitySchedule(
                    intervalStart: DateComponents(hour: 8, minute: 0),
                    intervalEnd: DateComponents(hour: 20, minute: 0),
                    repeats: false
                )
                do {
                    try monitor.startMonitoring(deviceName, during: schedule)
                    print("[AppDelegate] Monitoramento iniciado para: \(deviceName.rawValue) linha \(#line)")
                } catch {
                    print("[AppDelegate] Erro ao iniciar monitoramento: \(error) linha \(#line)")
                }
                result(nil)
            case "askUsageStatsPermission":
                print("[AppDelegate] Solicitando autorização FamilyControls... linha \(#line)")
                if #available(iOS 16.0, *) {
                    let status = AuthorizationCenter.shared.authorizationStatus
                    if status == .approved {
                        print("[AppDelegate] Autorização já concedida: \(status.rawValue) linha \(#line)")
                        result(true)
                    } else {
                        Task {
                            do {
                                try await AuthorizationCenter.shared.requestAuthorization(for: .individual)
                                let newStatus = AuthorizationCenter.shared.authorizationStatus
                                print("[AppDelegate] Autorização concluída: \(newStatus.rawValue) linha \(#line)")
                                result(newStatus == .approved)
                            } catch {
                                print("[AppDelegate] Erro ao solicitar autorização: \(error) linha \(#line)")
                                result(false)
                            }
                        }
                    }
                } else {
                    result(false)
                }
            case "startBackgroundTask":
                print("[AppDelegate] Iniciando BackgroundTask linha \(#line)")
                BackgroundTask.start()
                result(nil)
            default:
                print("[AppDelegate] Método não implementado: \(call.method) linha \(#line)")
                result(FlutterMethodNotImplemented)
            }
        }

        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }

    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        guard let fcmToken = fcmToken else { return }
        print("[AppDelegate] antes do setTokenFirebase linha \(#line)")
        if let controller = window?.rootViewController as? FlutterViewController {
            print("[AppDelegate] criando canal linha \(#line)")
             let methodChannel = FlutterMethodChannel(
                 name: "flutter.native/helper",
                 binaryMessenger: controller.binaryMessenger
            )
            print("[AppDelegate] canal criado linha \(#line)")
            methodChannel.invokeMethod("setTokenFirebase", arguments: fcmToken)
            print("[AppDelegate] Enviando token setTokenFirebase linha \(#line)")
        }
        print("[AppDelegate] Token FCM recebido: \(fcmToken ?? "vazio") linha \(#line)")
    }

    override func application(
        _ application: UIApplication,
        didReceiveRemoteNotification userInfo: [AnyHashable: Any],
        fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void
    ) {
        print("[AppDelegate] Notificação remota recebida: \(userInfo) linha \(#line)")

        if let unblockJSON = userInfo["unblock"] as? String {
            print("[AppDelegate] Dados para desbloquear apps: \(unblockJSON) linha \(#line)")
            processJSONAppList(unblockJSON) { appId in
                self.store.application.blockedApplications?.remove(Application(bundleIdentifier: appId))
                print("[AppDelegate] App desbloqueado: \(appId) linha \(#line)")
            }
        }

        if let blockJSON = userInfo["block"] as? String {
            print("[AppDelegate] Dados para bloquear apps: \(blockJSON) linha \(#line)")
            processJSONAppList(blockJSON) { appId in
                var apps = self.store.application.blockedApplications ?? Set<Application>()
                apps.insert(Application(bundleIdentifier: appId))
                self.store.application.blockedApplications = apps
                print("[AppDelegate] App bloqueado: \(appId) linha \(#line)")
            }
        }

        completionHandler(.newData)
    }

    private func processJSONAppList(_ jsonString: String, _ handler: (String) -> Void) {
        print("[AppDelegate] processJSONAppList chamado com: \(jsonString) linha \(#line)")
        guard let data = jsonString.data(using: .utf8) else {
            print("[AppDelegate] Erro ao converter string para Data linha \(#line)")
            return
        }

        do {
            if let jsonArray = try JSONSerialization.jsonObject(with: data, options: []) as? [Any] {
                let appIds = jsonArray.compactMap { $0 as? String }
                print("[AppDelegate] Apps extraídos do JSON: \(appIds) linha \(#line)")
                appIds.forEach(handler)
            }
        } catch {
            print("[AppDelegate] Erro ao decodificar JSON: \(error.localizedDescription) linha \(#line)")
        }
    }
}
