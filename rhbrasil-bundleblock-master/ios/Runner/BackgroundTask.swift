import Foundation
import UIKit

class BackgroundTask {
    static var timer: Timer?

    static func start() {
        // Inicializar o timer que roda a cada 10 segundos
        timer = Timer.scheduledTimer(withTimeInterval: 10, repeats: true) { _ in
            print("O aplicativo está rodando em segundo plano.")
        }

        // Garantir que o timer continua rodando mesmo quando o aplicativo está em segundo plano
        RunLoop.current.add(timer!, forMode: .common)

        // Registrar para receber notificações de entrada em segundo plano
        NotificationCenter.default.addObserver(self, selector: #selector(appDidEnterBackground), name: UIApplication.didEnterBackgroundNotification, object: nil)
    }

    @objc static func appDidEnterBackground() {
        // O aplicativo entrou em segundo plano, continuar rodando o timer
        print("O aplicativo entrou em segundo plano.")
    }
}