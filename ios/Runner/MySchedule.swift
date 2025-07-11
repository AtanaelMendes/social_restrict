import Foundation
import DeviceActivity

// The Device Activity name is how I can reference the activity from within my extension
@available(iOS 15.0, *)
extension DeviceActivityName {
    // Set the name of the activity to "daily"
    static let daily = Self("daily")
}

// I want to remove the application shield restriction when the child accumulates enough usage for a set of guardian-selected encouraged apps
@available(iOS 15.0, *)
extension DeviceActivityEvent.Name {
    // Set the name of the event to "encouraged"
    static let encouraged = Self("encouraged")
}

// The Device Activity schedule represents the time bounds in which my extension will monitor for activity
@available(iOS 15.0, *)
let schedule = DeviceActivitySchedule(
    intervalStart: DateComponents(hour: 8, minute: 0),
    intervalEnd: DateComponents(hour: 20, minute: 0),
    repeats: false,
    warningTime: nil
)

@available(iOS 15.0, *)
class MySchedule {
    static public func unsetSchedule() {
        let center = DeviceActivityCenter()
        print("SocialRestrict center.activities:\(center.activities)")
        if center.activities.isEmpty {
            return
        }
        center.stopMonitoring(center.activities)
        print("SocialRestrict center.activities:\(center.activities)")
    }
    
    static public func setSchedule() {
        let applications = MyModel.shared.selectionToEncourage
        if applications.applicationTokens.isEmpty {
            print("SocialRestrict empty applicationTokens")
        }
        if applications.categoryTokens.isEmpty {
            print("SocialRestrict empty categoryTokens")
        }
        
        let events: [DeviceActivityEvent.Name: DeviceActivityEvent] = [
            .encouraged: DeviceActivityEvent(
                applications: applications.applicationTokens,
                categories: applications.categoryTokens,
                threshold: DateComponents(minute: 1)
            )
        ]
        
        // Create a Device Activity center
        let center = DeviceActivityCenter()
        do {
            // Call startMonitoring with the activity name, schedule, and events
            print("SocialRestrict center.activities:\(center.activities)")
            print("SocialRestrict Try to start monitoring...")
            try center.startMonitoring(.daily, during: schedule, events: events)
            print("SocialRestrict monitoring...")
        } catch {
            print("SocialRestrict Error monitoring schedule: ", error)
        }

    }
}

// Another ingredient to shielding apps is figuring out what the guardian wants to discourage
// The Family Controls framework has a SwiftUI element for this: the family activity picker
