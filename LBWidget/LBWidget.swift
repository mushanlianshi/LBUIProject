//
//  LBWidget.swift
//  LBWidget
//
//  Created by liu bin on 2023/6/8.
//

import WidgetKit
import SwiftUI
import Intents

struct Provider: IntentTimelineProvider {
    func placeholder(in context: Context) -> SimpleEntry {
        print("LBLog dic placeholder")
        return SimpleEntry(date: Date(), configuration: ConfigurationIntent())
    }

    func getSnapshot(for configuration: ConfigurationIntent, in context: Context, completion: @escaping (SimpleEntry) -> ()) {
        print("LBLog dic getSnapshot")
        let entry = SimpleEntry(date: Date(), configuration: configuration)
        completion(entry)
    }

    func getTimeline(for configuration: ConfigurationIntent, in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        print("LBLog dic getTimeline")
        var entries: [SimpleEntry] = []

        // Generate a timeline consisting of five entries an hour apart, starting from the current date.
        let currentDate = Date()
        for hourOffset in 0 ..< 5 {
            let entryDate = Calendar.current.date(byAdding: .hour, value: hourOffset, to: currentDate)!
            let entry = SimpleEntry(date: entryDate, configuration: configuration)
            entries.append(entry)
        }

        let timeline = Timeline(entries: entries, policy: .atEnd)
        completion(timeline)
    }
}

struct SimpleEntry: TimelineEntry {
    let date: Date
    let configuration: ConfigurationIntent
}

struct LBWidgetEntryView : View {
    var entry: Provider.Entry

    var body: some View {
        Text(entry.date, style: .time)
//        Text(getShareTime(), style: .time)
        Text(verbatim: getShareTime())
    }
    
    func getShareTime() -> String{
        guard var url = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: "group.lb.uiproject") else {
            return "0"
        }
        url.appendPathComponent("widgetShareData.json")
        guard let data = try? Data.init(contentsOf: url) else{
            return "0"
        }
        
        let dic = try? JSONSerialization.jsonObject(with: data) as? [String : Int]
        
        let time = dic?["currentTime"] as? Int
        print("LBLog dic \(String(describing: dic))")
        return String(describing: time)
    }
}

struct LBWidget: Widget {
    let kind: String = "LBWidget"

    var body: some WidgetConfiguration {
        IntentConfiguration(kind: kind, intent: ConfigurationIntent.self, provider: Provider()) { entry in
            LBWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("My Widget")
        .description("This is an example widget.")
    }
}

struct LBWidget_Previews: PreviewProvider {
    static var previews: some View {
        LBWidgetEntryView(entry: SimpleEntry(date: Date(), configuration: ConfigurationIntent()))
            .previewContext(WidgetPreviewContext(family: .systemSmall))
    }
}
