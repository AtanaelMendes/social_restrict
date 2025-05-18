import FamilyControls
import SwiftUI
import ManagedSettings

@available(iOS 15.0, *)
struct ContentView: View {
        
    @State private var isDiscouragedPresented = true
    @State private var isEncouragedPresented = false
    
    @EnvironmentObject var model: MyModel
    @Environment(\.presentationMode) var presentationMode
    
    @ViewBuilder
    func contentView() -> some View {
        switch globalMethodCall {
        case "selectAppsToDiscourage":
            FamilyActivityPicker(selection: $model.selectionToDiscourage)
                .onChange(of: model.selectionToDiscourage) { _ in
                    model.setShieldRestrictions()
                }
        case "selectAppsToEncourage":
            FamilyActivityPicker(selection: $model.selectionToEncourage)
                .onChange(of: model.selectionToEncourage) { _ in
                    MySchedule.setSchedule()
                }
            
        default:
            EmptyView()
            // if #available(iOS 15.0, *) {
            // }
        }
    }
        
        var body: some View {
            NavigationView {
                VStack {
                    contentView()
                }
                .navigationBarTitle("Select Apps", displayMode: .inline)
                .navigationBarItems(
                    leading: Button("Cancel") {
                        presentationMode.wrappedValue.dismiss()
                    },
                    trailing: Button("Done") {
                        switch globalMethodCall {
                        case "selectAppsToDiscourage":
                            model.setShieldRestrictions()
                        case "selectAppsToEncourage":
                            MySchedule.setSchedule()
                        default:
                            break
                        }
                        presentationMode.wrappedValue.dismiss()
                    }
                )
            }
        }
    
    
    struct ContentView_Previews: PreviewProvider {
        static var previews: some View {
            ContentView()
                .environmentObject(MyModel())
        }
    }
}
