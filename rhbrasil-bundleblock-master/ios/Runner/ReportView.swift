import SwiftUI
import DeviceActivity

struct ReportView: View {

    @State private var context: DeviceActivityReport.Context = .init(rawValue: "Total Activity")
    @State private var filter = DeviceActivityFilter(
        segment: .daily(
            during: Calendar.current.dateInterval(
               of: .weekOfYear, for: .now
            )!
        ),
        users: .children,
        devices: .init([.iPhone, .iPad])
    )
    
    @ViewBuilder
    func reportView() -> some View {
        Text("Default")
    }

    public var body: some View {
        VStack {
            DeviceActivityReport(context, filter: filter)

            // A picker used to change the report's context.
            Picker(selection: $context, label: Text("Context: ")) {
                Text("Bar Graph")
                    .tag("barGraph")
                Text("Pie Chart")
                     .tag("pieChart")
            }


            // A picker used to change the filter's segment interval.
            Picker(
                selection: $filter.segmentInterval,
                 label: Text("Segment Interval: ")
            ) {
                Text("Hourly")
                    .tag(DeviceActivityFilter.SegmentInterval.hourly())
                Text("Daily")
                    .tag(DeviceActivityFilter.SegmentInterval.daily(
                        during: Calendar.current.dateInterval(
                             of: .weekOfYear, for: .now
                        )!
                    ))
                Text("Weekly")
                    .tag(DeviceActivityFilter.SegmentInterval.weekly(
                        during: Calendar.current.dateInterval(
                            of: .month, for: .now
                        )!
                    ))
            }
            // ...
        }
    }
}


struct ReportView_Previews: PreviewProvider {
    static var previews: some View {
        ReportView()
            .environmentObject(MyModel())
    }
}
