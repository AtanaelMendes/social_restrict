//
//  BackgroundTaskOperation.swift
//  workmanager
//
//  Created by Sebastian Roth on 10/06/2021.
//

import Foundation

class BackgroundTaskOperation: Operation {

    private let identifier: String
    private let flutterPluginRegistrantCallback: FlutterPluginRegistrantCallback?

    init(_ identifier: String, flutterPluginRegistrantCallback: FlutterPluginRegistrantCallback?) {
        print("🔄 Init BackgroundTaskOperation com identifier: \(identifier) — linha \(#line)")
        self.identifier = identifier
        self.flutterPluginRegistrantCallback = flutterPluginRegistrantCallback
    }

    override func main() {
        print("🚀 main() chamado — linha \(#line)")

        let semaphore = DispatchSemaphore(value: 0)
        print("⏳ Semaphore criado — linha \(#line)")

        DispatchQueue.main.async {
            print("🧵 Executando em DispatchQueue.main — linha \(#line)")

            let worker = BackgroundWorker(
                mode: .backgroundTask(identifier: self.identifier),
                flutterPluginRegistrantCallback: self.flutterPluginRegistrantCallback
            )

            print("👷‍♂️ BackgroundWorker inicializado com ID: \(self.identifier) — linha \(#line)")

            worker.performBackgroundRequest { success in
                print("✅ Background request finalizada: \(success) — linha \(#line)")
                semaphore.signal()
            }
        }

        print("🔒 Esperando o semaphore — linha \(#line)")
        semaphore.wait()
        print("🔓 Semaphore liberado, main() finalizado — linha \(#line)")
    }
}
