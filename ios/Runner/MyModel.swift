import Foundation
import FamilyControls
import ManagedSettings
import DeviceActivity
@available(iOS 15.0, *)
private let _MyModel = MyModel()

@available(iOS 15.0, *)
class MyModel: ObservableObject {
    // Import ManagedSettings to get access to the application shield restriction
    let store = ManagedSettingsStore()
    //@EnvironmentObject var store: ManagedSettingsStore
    
    @Published var selectionToDiscourage: FamilyActivitySelection
    @Published var selectionToEncourage: FamilyActivitySelection
    
    init() {
        selectionToDiscourage = FamilyActivitySelection()
        selectionToEncourage = FamilyActivitySelection()
    }
    
    class var shared: MyModel {
        return _MyModel
    }
    
    func setShieldRestrictions() {
        print("setShieldRestrictions")
        // Pull the selection out of the app's model and configure the application shield restriction accordingly
        let applications = MyModel.shared.selectionToDiscourage
        if applications.applicationTokens.isEmpty {
            print("empty applicationTokens")
        } else {
            print(applications.applicationTokens)
        }

        if applications.categoryTokens.isEmpty {
            print("empty categoryTokens")
        } else {
            print(applications.categoryTokens)
        }
        let blocked = store.application.blockedApplications
        let teste = FamilyActivitySelection()
        
        //store.clearAllSettings()
        store.application.blockedApplications = [Application(bundleIdentifier: "ph.telegra.Telegraph")]
        
        
    }
}
