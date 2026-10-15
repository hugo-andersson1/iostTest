import SwiftUI
import WidgetKit

struct DeadlineEntry: TimelineEntry {
    let date: Date
    let deadlines: [WidgetDeadline]
    var needsApp = false

    static var preview: DeadlineEntry {
        let now = Date()
        return DeadlineEntry(date: now, deadlines: [
            WidgetDeadline(id: UUID(), name: "Java Design Draft", dueDate: now.addingTimeInterval(3 * 86_400), icon: "laptopcomputer", theme: "green"),
            WidgetDeadline(id: UUID(), name: "Performance Review", dueDate: now.addingTimeInterval(5 * 86_400), icon: "book", theme: "purple")
        ])
    }
}

struct DeadlineProvider: TimelineProvider {
    func placeholder(in context: Context) -> DeadlineEntry { .preview }

    func getSnapshot(in context: Context, completion: @escaping (DeadlineEntry) -> Void) {
        if context.isPreview { completion(.preview); return }
        let deadlines = WidgetDeadlineStorage.load()
        completion(DeadlineEntry(date: Date(), deadlines: Array((deadlines ?? []).prefix(2)), needsApp: deadlines == nil))
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<DeadlineEntry>) -> Void) {
        let now = Date()
        let loaded = WidgetDeadlineStorage.load()
        let deadlines = Array((loaded ?? []).prefix(2))
        // Pre-render countdown updates, including the exact moment a deadline becomes overdue.
        var dates = (0...60).map { now.addingTimeInterval(Double($0) * 60) }
        dates += deadlines.map(\.dueDate).filter { $0 > now && $0 <= now.addingTimeInterval(3_600) }
        let entries = Set(dates).sorted().map {
            DeadlineEntry(date: $0, deadlines: deadlines, needsApp: loaded == nil)
        }
        completion(Timeline(entries: entries, policy: .after(now.addingTimeInterval(3_600))))
    }
}

private extension WidgetDeadline {
    var color: Color {
        switch theme {
        case "red": return .red
        case "yellow": return .yellow
        case "purple": return .purple
        case "orange": return .orange
        case "green": return .green
        case "brown": return .brown
        case "pink": return .pink
        case "cyan": return .cyan
        case "gray": return .gray
        default: return .blue
        }
    }
}

struct DeadlineWidgetRow: View {
    let deadline: WidgetDeadline
    let date: Date
    var large = false

    var body: some View {
        VStack(alignment: .leading, spacing: large ? 10 : 5) {
            Label(deadline.name, systemImage: deadline.icon)
                .font(.system(size: large ? 16 : 15, weight: .semibold))
                .lineLimit(1)
                .minimumScaleFactor(0.75)
            Text(deadline.timeLeft(at: date))
                .font(.system(size: large ? 32 : 16, weight: .regular))
                .lineLimit(1)
                .minimumScaleFactor(0.7)
                .monospacedDigit()
            GeometryReader { geometry in
                Capsule().fill(deadline.color.opacity(0.25))
                    .overlay(alignment: .leading) {
                        Capsule().fill(deadline.color)
                            .frame(width: geometry.size.width * deadline.progress(at: date))
                    }
            }
            .frame(height: 9)
            .accessibilityLabel("Deadline approaching")
            .accessibilityValue("\(Int(deadline.progress(at: date) * 100)) percent")
        }
        .foregroundStyle(.white)
        .accessibilityElement(children: .combine)
    }
}

struct DeadlineWidgetView: View {
    @Environment(\.widgetFamily) private var family
    let entry: DeadlineEntry

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            if entry.deadlines.isEmpty {
                Image(systemName: entry.needsApp ? "arrow.up.forward.app" : "checkmark.circle")
                    .font(.title)
                Text(entry.needsApp ? "Open Deadlines" : "All done")
                    .font(.headline)
                Text(entry.needsApp ? "Open the app to load your deadlines." : "Add a deadline to get started.")
                    .font(.caption)
                    .foregroundStyle(.white.opacity(0.7))
            } else {
                ForEach(Array(entry.deadlines.prefix(family == .systemSmall ? 1 : 2))) { deadline in
                    DeadlineWidgetRow(deadline: deadline, date: entry.date, large: family == .systemSmall)
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
        .foregroundStyle(.white)
        .containerBackground(.black, for: .widget)
        .widgetURL(entry.deadlines.isEmpty && !entry.needsApp ? WidgetDeadlineStorage.addURL : WidgetDeadlineStorage.listURL)
    }
}

struct DeadlineWidget: Widget {
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: WidgetDeadlineStorage.widgetKind, provider: DeadlineProvider()) { entry in
            DeadlineWidgetView(entry: entry)
        }
        .configurationDisplayName("Deadlines")
        .description("Your nearest unfinished deadlines, with category colors.")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}

struct AddDeadlineWidgetView: View {
    var body: some View {
        VStack(spacing: 14) {
            Text("Add Deadline")
                .font(.system(size: 14, weight: .medium))
            Image(systemName: "plus")
                .font(.system(size: 36, weight: .medium))
                .foregroundStyle(.black)
                .frame(width: 62, height: 62)
                .background(.white, in: Circle())
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .foregroundStyle(.white)
        .containerBackground(.black, for: .widget)
        .widgetURL(WidgetDeadlineStorage.addURL)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Add Deadline")
    }
}

struct AddDeadlineProvider: TimelineProvider {
    func placeholder(in context: Context) -> DeadlineEntry { DeadlineEntry(date: Date(), deadlines: []) }
    func getSnapshot(in context: Context, completion: @escaping (DeadlineEntry) -> Void) { completion(placeholder(in: context)) }
    func getTimeline(in context: Context, completion: @escaping (Timeline<DeadlineEntry>) -> Void) {
        completion(Timeline(entries: [placeholder(in: context)], policy: .never))
    }
}

struct AddDeadlineWidget: Widget {
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: "AddDeadlineWidget", provider: AddDeadlineProvider()) { _ in
            AddDeadlineWidgetView()
        }
        .configurationDisplayName("Add Deadline")
        .description("Quickly add a deadline from your Home Screen.")
        .supportedFamilies([.systemSmall])
    }
}

@main
struct DeadlineWidgets: WidgetBundle {
    var body: some Widget {
        DeadlineWidget()
        AddDeadlineWidget()
    }
}

#Preview(as: .systemSmall) { DeadlineWidget() } timeline: { DeadlineEntry.preview }
#Preview(as: .systemMedium) { DeadlineWidget() } timeline: { DeadlineEntry.preview }
#Preview(as: .systemSmall) { AddDeadlineWidget() } timeline: { DeadlineEntry.preview }
