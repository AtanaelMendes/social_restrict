import SwiftUI
import FamilyControls
import ManagedSettings

@available(iOS 15.0, *)
struct ContentView: View {
    let globalMethodCall: String

    @EnvironmentObject var model: MyModel
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>

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
        }
    }

    var body: some View {
        NavigationView {
            VStack {
                contentView()
            }
            .navigationBarTitle("Select Apps", displayMode: .inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }

                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
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
                }
            }
        }
    }
}

@available(iOS 15.0, *)
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(globalMethodCall: "selectAppsToDiscourage")
            .environmentObject(MyModel())
    }
}
