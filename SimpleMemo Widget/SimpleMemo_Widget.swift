//
//  SimpleMemo_Widget.swift
//  SimpleMemo Widget
//
//  Created by 민선기 on 2022/02/04.
//

import WidgetKit
import SwiftUI
import Intents

struct Provider: TimelineProvider {

    var memos = Array(RealmManager.shared.getMemos().prefix(3))
    
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(date: Date(), memos: memos)
    }

    func getSnapshot(in context: Context, completion: @escaping (SimpleEntry) -> ()) {
        let entry: SimpleEntry
        
        if context.isPreview {
            entry = SimpleEntry(
                date: Date(),
                memos: [
                    Memo(content: "", backgroundColor: "orange"),
                    Memo(content: "", backgroundColor: "red"),
                    Memo(content: "", backgroundColor: "dark_purple")
                ]
            )
        } else {
            entry = SimpleEntry(date: Date(), memos: memos)
        }
        
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        let memos = RealmManager.shared.getMemos()
        let lastThreeMemos = Array(memos.prefix(3))
        
        let entry = SimpleEntry(date: .now, memos: lastThreeMemos)
        
        let timeline = Timeline(entries: [entry], policy: .never)
        
        completion(timeline)

    }
}

struct SimpleEntry: TimelineEntry {
    let date: Date
    let memos: [Memo]
}

struct SimpleMemo_WidgetEntryView : View {
    var entry: Provider.Entry

    var body: some View {
        
        GeometryReader { geometry in
            VStack {
                
                ForEach(entry.memos) { memo in
                    
                    Text(memo.content)
                        .padding(EdgeInsets(top: 10, leading: 10, bottom: 10, trailing: 10))
                        .frame(width: geometry.size.width, height: geometry.size.height / 3, alignment: .leading)
                        .background(Color(UIColor(named: memo.backgroundColor)!))
                        .cornerRadius(12)
                        .font(Font.custom("GowunDodum-Regular", size: 11))
                        .foregroundColor(.black)
                }
            }
            .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)
            
        }
        .padding(EdgeInsets(top: 14, leading: 10, bottom: 14, trailing: 10))
        .background(Color(Constants.Colors.bg!))
        
    }
}

@main
struct SimpleMemo_Widget: Widget {
    let kind: String = "SimpleMemo_Widget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            SimpleMemo_WidgetEntryView(entry: entry)
        }
        .configurationDisplayName(NSLocalizedString("WidgetConfigurationDisplayName", comment: ""))
        .description(NSLocalizedString("WidgetDescription", comment: ""))
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}

struct SimpleMemo_Widget_Previews: PreviewProvider {
    static var previews: some View {
        SimpleMemo_WidgetEntryView(entry: SimpleEntry(date: Date(), memos: [Memo(content: "Hello", backgroundColor: "orange"), Memo(content: "Guten Tag", backgroundColor: "red"), Memo(content: "Hello Wolrd", backgroundColor: "dark_purple")]))
            .previewContext(WidgetPreviewContext(family: .systemMedium))
    }
}
