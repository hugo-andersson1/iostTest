# Widgets and reminders

## Run on your iPhone

1. Open `iostTest.xcodeproj` in Xcode and select the `iostTest` scheme.
2. In Signing & Capabilities, use the same development team for `iostTest` and `DeadlineWidgets`. Both targets use the App Group `group.testing.iosTest`. Let Xcode register/provision this group if prompted. If that identifier is unavailable for your team, choose a unique group and update both files in `Configuration/*.entitlements` plus `WidgetDeadlineStorage.appGroup` in `Shared/WidgetDeadline.swift` to match.
3. Build and run the app once. Allow notifications when prompted (the prompt appears once there is at least one unfinished deadline). If permission was previously denied, use Profile → Notification Settings.
4. On the Home Screen, edit the screen and add the **Deadlines** widget in small or medium size, or the separate **Add Deadline** widget.

App Groups must be supported by your Apple developer signing team. An unsigned Simulator build does not verify device provisioning.

## Behavior

- Small: the earliest unfinished deadline. Medium: the earliest two, across all categories. Overdue deadlines stay visible until removed/completed.
- Category icon, deadline name, remaining time and category-colored progress bar on a black background. Progress follows the app's existing seven-day formula, including its minimum 1% fill for distant deadlines.
- Add Deadline opens the app's existing add sheet. Tapping a deadline widget opens the Deadlines tab.
- Widgets read a lightweight shared snapshot exported from `DeadlineStore.deadlines`. Existing `deadlines.json` and `categories.json` stay in their original location; there is no data migration.
- The snapshot and notification schedule update when the array changes and when the app becomes active. The extension provides countdown timeline entries to iOS; the system controls when widgets refresh. Home Screen tinting can override category colors.
- Local reminders use `Title due in 24 hours!`, `Title due in 5 hours!`, and `Title due in 1 hour!`. Reminder times already in the past are skipped, not sent immediately. Notifications can appear while the app is open too.
- The nearest 64 pending notifications are prioritized (less any unrelated pending requests). For larger collections, reopening the app replenishes the queue. Profile shows when the queue is limited or permission is off. Delivery also depends on device notification/Focus settings.
- The existing Edit flow is unchanged. Because that flow removes a deadline while editing, its widget entry and pending reminders are removed too; saving or using the existing Exit action adds them back. Widgets and reminders follow the actual array contents.

## Validation

Build app and embedded extension:

```sh
xcodebuild -project iostTest.xcodeproj -scheme iostTest -configuration Debug -sdk iphonesimulator -destination 'generic/platform=iOS Simulator' -derivedDataPath /tmp/deadlines-widget-build CODE_SIGNING_ALLOWED=NO build
```

Run focused Foundation-only checks on macOS:

```sh
xcrun swiftc -module-cache-path /tmp/deadlines-test-module-cache Shared/WidgetDeadline.swift iostTest/DeadlineReminderPlan.swift Tests/ReminderChecks.swift -o /tmp/deadlines-reminder-checks
/tmp/deadlines-reminder-checks
```

The checks cover reminder offsets and wording, skipped past triggers, changed titles/dates, empty inputs, queue ordering/limits, countdown/progress boundaries, and snapshot encoding.

Before merging, verify on a signed device: add both widget sizes, confirm their category icons/colors, tap Add Deadline from a closed app and from another tab, complete/remove deadlines, and check permission denial/re-enabling. For a quick reminder check, create a deadline due in 1 hour and 2 minutes, then wait 2 minutes for its 1-hour reminder. Delete or complete another such deadline before the reminder to confirm cancellation. Real notification delivery and Home Screen rendering have not been exercised by the command-line checks.
