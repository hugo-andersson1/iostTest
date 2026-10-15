import Foundation

@main
struct ReminderChecks {
    static func main() throws {
        let now = Date(timeIntervalSince1970: 1_800_000_000)
        let id = UUID()
        let deadline = WidgetDeadline(id: id, name: "Renew Lease", dueDate: now.addingTimeInterval(30 * 3_600), icon: "person", theme: "green")
        let reminders = DeadlineReminder.plan(for: [deadline], now: now)
        precondition(reminders.count == 3)
        precondition(reminders.map { $0.fireDate.timeIntervalSince(now) } == [6, 25, 29].map { Double($0) * 3_600 })
        precondition(reminders.map(\.title) == ["Renew Lease due in 24 hours!", "Renew Lease due in 5 hours!", "Renew Lease due in 1 hour!"])

        var edited = deadline
        edited.name = "Updated Lease"
        edited.dueDate = now.addingTimeInterval(4 * 3_600)
        let updated = DeadlineReminder.plan(for: [edited], now: now)
        precondition(updated.count == 1) // Missed reminders aren't fired immediately.
        precondition(updated[0].identifier == reminders[2].identifier)
        precondition(updated[0].title == "Updated Lease due in 1 hour!")
        precondition(updated[0].fireDate == now.addingTimeInterval(3 * 3_600))
        precondition(DeadlineReminder.plan(for: [], now: now).isEmpty)

        edited.dueDate = now.addingTimeInterval(-1)
        precondition(DeadlineReminder.plan(for: [edited], now: now).isEmpty)
        precondition(edited.timeLeft(at: now) == "Overdue")
        precondition(edited.progress(at: now) == 1)
        edited.dueDate = now.addingTimeInterval(3_600)
        precondition(DeadlineReminder.plan(for: [edited], now: now).isEmpty) // Exactly-now trigger is skipped.
        precondition(edited.timeLeft(at: now) == "1 hour")
        edited.dueDate = now.addingTimeInterval(30)
        precondition(edited.timeLeft(at: now) == "1 minute")
        edited.dueDate = now.addingTimeInterval(31 * 86_400)
        precondition(edited.timeLeft(at: now) == "31 days")
        precondition(edited.progress(at: now) == 0.01)
        edited.dueDate = now.addingTimeInterval(3.5 * 86_400)
        precondition(edited.progress(at: now) == 0.5)

        let many = (0..<40).map { index in
            WidgetDeadline(id: UUID(), name: "Task \(index)", dueDate: now.addingTimeInterval(Double(30 + index) * 3_600), icon: "book", theme: "purple")
        }
        let all = DeadlineReminder.plan(for: many, now: now, limit: Int.max)
        precondition(all.count == 120)
        precondition(DeadlineReminder.plan(for: many.reversed(), now: now) == Array(all.prefix(64)))
        precondition(DeadlineReminder.plan(for: many, now: now, limit: 2).count == 2)
        precondition(DeadlineReminder.plan(for: many, now: now, limit: 0).isEmpty)
        let encoded = try JSONEncoder().encode([deadline])
        let decoded = try JSONDecoder().decode([WidgetDeadline].self, from: encoded)
        precondition(decoded == [deadline])
        print("Reminder timing, edits/removal, queue limits, widget countdown/progress and snapshot coding passed.")
    }
}
