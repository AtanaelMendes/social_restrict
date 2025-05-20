import DeviceActivity
import FamilyControls
import Flutter
import ManagedSettings
import SwiftUI
import UIKit
import FirebaseCore
import FirebaseMessaging
import Foundation

var globalMethodCall = ""
@available(iOS 15.0, *)
@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate, MessagingDelegate {
    var model = MyModel.shared
    var store = ManagedSettingsStore()
    
    override func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        FirebaseApp.configure()
        //BackgroundTask.start()
        
        // Solicita permissão para notificações
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { (granted, error) in
            if granted {
                DispatchQueue.main.async {
                    application.registerForRemoteNotifications()
                }
            } else {
                // Tratamento para quando a permissão é negada
            }
        }
        // Configuração do delegate do FCM
        Messaging.messaging().delegate = self

        let controller: FlutterViewController = window?.rootViewController as! FlutterViewController
        // メソッドチャンネル名
        let METHOD_CHANNEL_NAME = "flutter_screentime"
        // FlutterMethodChannel
        let methodChannel = FlutterMethodChannel(name: METHOD_CHANNEL_NAME, binaryMessenger: controller as! FlutterBinaryMessenger)

              // setMethodCallHandlerでコールバックを登録
        methodChannel.setMethodCallHandler { [self]
            (call: FlutterMethodCall, result: @escaping FlutterResult) in
            Task {
                print("Task")
                do {
                    if #available(iOS 16.0, *) {
                        print("try requestAuthorization")
                        try await AuthorizationCenter.shared.requestAuthorization(for: FamilyControlsMember.individual)
                        print("requestAuthorization success")
                        switch AuthorizationCenter.shared.authorizationStatus {
                        case .notDetermined:
                            print("not determined")
                        case .denied:
                            print("denied")
                        case .approved:
                            print("approved")
                        @unknown default:
                            break
                        }
                    } else {
                        // Fallback on earlier versions
                    }
                } catch {
                    print("Error requestAuthorization: ", error)
                }
            }
            switch call.method {
            case "selectAppsToDiscourage":
                globalMethodCall = "selectAppsToDiscourage"
                let vc = UIHostingController(rootView: ContentView()
                    .environmentObject(self.model)
                    .environmentObject(self.store))

                controller.present(vc, animated: false, completion: nil)

                print("selectAppsToDiscourage")
                result(nil)
            case "selectAppsToEncourage":
                globalMethodCall = "selectAppsToEncourage"
                let vc = UIHostingController(rootView: ContentView()
                    .environmentObject(self.model)
                    .environmentObject(self.store))
                controller.present(vc, animated: false, completion: nil)

                print("selectAppsToEncourage")
                result(nil)
            case "blockApps":
                var applications: Set<Application> = []
                
                if (self.store.application.blockedApplications != nil) {
                    applications = self.store.application.blockedApplications!
                }
                
                if let arguments = call.arguments as? [String: Any] {
                    if let apps = arguments["apps"] as? Array<String> {
                        apps.forEach { _app in
                            applications.insert(Application(bundleIdentifier: String(_app)))
                        }
                        if (applications.count > 0) {
                            self.store.application.blockedApplications = applications
                        }
                    }
                }
                // let apps = store.application.blockedApplications
                
                // let vc = UIHostingController(rootView: ReportView())
                // controller.present(vc, animated: false, completion: nil)

                // print("report")
                result(nil)
            case "unlockApps":
                if let arguments = call.arguments as? [String: Any] {
                    if let apps = arguments["apps"] as? Array<String> {
                        apps.forEach { _app in
                            self.store.application.blockedApplications?.remove(Application(bundleIdentifier: String(_app)))
                        }
                    }
                }
                result(nil)
            case "report":
                let monitor = DeviceActivityCenter()
                let deviceName = DeviceActivityName(rawValue: "teste")
                
                let activities = monitor.events(for: deviceName)
                
                let schedule = DeviceActivitySchedule(
                    intervalStart: DateComponents(hour: 8, minute: 0),
                    intervalEnd: DateComponents(hour: 20, minute: 0),
                    repeats: false,
                    warningTime: nil
                )
                
                do {
                    try monitor.startMonitoring(deviceName, during: schedule)
                    print("teste")
                } catch let error {
                    print(error.localizedDescription)
                }
                
               
               
                result(nil)
            default:
                print("no method")
                result(FlutterMethodNotImplemented)
            }
        }

        GeneratedPluginRegistrant.register(with: self)
        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }

    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        print("FCM Token: \(fcmToken)")
        // Aqui você pode enviar o token para o seu servidor, se necessário
    }

    override func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        // Trate a notificação recebida
        print("Notificação recebida: \(userInfo)")
        var blockArrayString = userInfo["block"] as? String ?? ""
        var unblockArrayString = userInfo["unblock"] as? String ?? ""
                
        
        if let unblockdata = unblockArrayString.data(using: .utf8) {
            do {
                // Usando o JSONSerialization para converter a string em um array de Any
                if let jsonArray = try JSONSerialization.jsonObject(with: unblockdata, options: []) as? [Any] {
                    
                    // Convertendo os elementos para strings, se possível
                    let stringArray = jsonArray.compactMap { $0 as? String }
                                                            
                    stringArray.forEach { _app in
                        self.store.application.blockedApplications?.remove(Application(bundleIdentifier: String(_app)))
                    }
                }
            } catch {
                print("Erro ao converter JSON: \(error.localizedDescription)")
            }
        } else {
            print("Erro ao converter a string para dados.")
        }
               
        if let data = blockArrayString.data(using: .utf8) {
            do {
                // Usando o JSONSerialization para converter a string em um array de Any
                if let jsonArray = try JSONSerialization.jsonObject(with: data, options: []) as? [Any] {
                    
                    // Convertendo os elementos para strings, se possível
                    let stringArray = jsonArray.compactMap { $0 as? String }
                    
                    var applications: Set<Application> = []
                    
                    if (store.application.blockedApplications != nil) {
                        applications = store.application.blockedApplications!
                    }
                    
                    stringArray.forEach { _app in
                        applications.insert(Application(bundleIdentifier: String(_app)))
                    }
                    if (applications.count > 0) {
                        store.application.blockedApplications = applications
                    }
                }
            } catch {
                print("Erro ao converter JSON: \(error.localizedDescription)")
            }
        } else {
            print("Erro ao converter a string para dados.")
        }
        
        completionHandler(.newData)
    }
}
