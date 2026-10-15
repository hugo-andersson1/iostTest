import Foundation

// A read-only snapshot for the extension; the app's existing JSON remains the source of truth.
struct WidgetDeadline: Identifiable, Codable, Equatable {
    var id: UUID
    var name: String
    var dueDate: Date
    var icon: String
    var theme: String

    func progress(at date: Date) -> Double {
        min(max(1 - dueDate.timeIntervalSince(date) / (7 * 24 * 60 * 60), 0.01), 1)
    }

    func timeLeft(at date: Date) -> String {
        let seconds = dueDate.timeIntervalSince(date)
        guard seconds > 0 else { return "Overdue" }
        if seconds >= 86_400 {
            let days = Int(ceil(seconds / 86_400))
            return "\(days) days"
        }
        if seconds >= 3_600 {
            let hours = Int(ceil(seconds / 3_600))
            return "\(hours) \(hours == 1 ? "hour" : "hours")"
        }
        let minutes = max(1, Int(ceil(seconds / 60)))
        return "\(minutes) \(minutes == 1 ? "minute" : "minutes")"
    }
}

enum WidgetDeadlineStorage {
    static let appGroup = "group.testing.iosTest"
    static let widgetKind = "DeadlineWidget"
    static let addURL = URL(string: "deadlines://add")!
    static let listURL = URL(string: "deadlines://list")!

    static var fileURL: URL? {
        FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: appGroup)?
            .appendingPathComponent("widget-deadlines.json")
    }

    static func save(_ deadlines: [WidgetDeadline]) throws {
        guard let fileURL else { throw CocoaError(.fileNoSuchFile) }
        let data = try JSONEncoder().encode(deadlines)
        try data.write(to: fileURL, options: [.atomic, .completeFileProtectionUntilFirstUserAuthentication])
    }

    static func load() -> [WidgetDeadline]? {
        guard let fileURL,
              let data = try? Data(contentsOf: fileURL),
              let deadlines = try? JSONDecoder().decode([WidgetDeadline].self, from: data)
        else { return nil }
        return deadlines.sorted {
            if $0.dueDate == $1.dueDate { return $0.id.uuidString < $1.id.uuidString }
            return $0.dueDate < $1.dueDate
        }
    }
}
