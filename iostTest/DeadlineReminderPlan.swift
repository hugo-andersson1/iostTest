import Foundation

struct DeadlineReminder: Equatable {
    let identifier: String
    let title: String
    let fireDate: Date

    static let prefix = "deadline-reminder."

    static func plan(for deadlines: [WidgetDeadline], now: Date, limit: Int = 64) -> [DeadlineReminder] {
        deadlines.flatMap { deadline in
            [24, 5, 1].compactMap { hours -> DeadlineReminder? in
                let fireDate = deadline.dueDate.addingTimeInterval(-Double(hours) * 3_600)
                guard fireDate > now else { return nil }
                return DeadlineReminder(
                    identifier: "\(prefix)\(deadline.id.uuidString).\(hours)",
                    title: "\(deadline.name) due in \(hours) \(hours == 1 ? "hour" : "hours")!",
                    fireDate: fireDate
                )
            }
        }.sorted {
            if $0.fireDate == $1.fireDate { return $0.identifier < $1.identifier }
            return $0.fireDate < $1.fireDate
        }.prefix(max(0, limit)).map { $0 }
    }
}
