//
//  Deadline.swift
//  iostTest
//
//  Created by Hugo Andersson on 10/7/26.
//
import SwiftUI

#Preview {
    ContentView()
        .environment(DeadlineStore())
}

struct Deadline: Identifiable, Equatable, Hashable, Codable {
    
    var id = UUID()
    var name : String
    var category : Category
    var dueDate : Date
    var notes : String = ""
    var completed : Bool = false
    
    func getIconElement(big: Bool = false) -> some View {
        return category.getIconElement(big: big)
    }
    
    func getCategoryName() -> String {
        return category.name
    }
    
    func getCategoryElement(font: Font = .caption) -> some View {
        return Text(category.name.uppercased())
            .foregroundStyle(category.theme.color)
            .font(font)
            .bold()
    }
    
    func getProgressBarElement(text: String = "default") -> some View {
        var displayText = text
        if(text == "default"){
            displayText = getFormattedTimeLeft()
        }
        let progressBar = ProgressView(displayText, value: getPercentageDone(), total: 1)
            .font(.subheadline)
            .foregroundStyle(.black)
            .tint(category.theme.color)
        return progressBar
    }
    
    func isDueToday() -> Bool {
        return Calendar.current.isDateInToday(dueDate)
    }
    func isDueTomorrow() -> Bool {
        return Calendar.current.isDateInTomorrow(dueDate)
    }
    
    func getReadableDateTime() -> String {
        
        let month = dueDate.formatted(.dateTime.month())
        let date = dueDate.formatted(.dateTime.day())
        
        let hourMinute = dueDate.formatted(.dateTime.hour(.conversationalDefaultDigits(amPM: .wide)).minute())
        
        return "\(month) \(date) · \(hourMinute)"
    }
    
    func getFormattedTimeLeft() -> String {
        let calendar = Calendar.current
        
        let startOfToday = calendar.startOfDay(for: Date())
        let startOfDueDate = calendar.startOfDay(for: dueDate)
        let absoluteDaysLeft = calendar.dateComponents([.day], from: startOfToday, to: startOfDueDate).day ?? 0
        
        let month = dueDate.formatted(.dateTime.month())
        let date = dueDate.formatted(.dateTime.day())
        
        let hourMinute = dueDate.formatted(.dateTime.hour(.conversationalDefaultDigits(amPM: .wide)).minute())
        
        let isToday = Calendar.current.isDateInToday(dueDate)
        let isTomorrow = Calendar.current.isDateInTomorrow(dueDate)
        let wasYesterday = Calendar.current.isDateInYesterday(dueDate)
        
        var secondsLeft = dueDate.timeIntervalSinceNow
        let secondsPerHour = 60.0 * 60.0
        
        let hoursLeft = Int(secondsLeft / secondsPerHour)
        secondsLeft -= (Double(hoursLeft) * secondsPerHour)
        
        let minutesLeft = Int(secondsLeft / 60)
        let stringHoursLeft = "\(hoursLeft)h \(minutesLeft)m left"
        
        if dueDate < Date() {
            let od = "Overdue"
            if isToday{
                return "\(od) · Today \(hourMinute)"
            }else if wasYesterday{
                return "\(od) · Yesterday \(hourMinute)"
            }
            return "\(od) · \(month) \(date)"
        }else if isToday{
            return "Today · \(stringHoursLeft)"
        }else if isTomorrow{
            return "Tomorrow · \(stringHoursLeft)"
        }else{
            return "In \(absoluteDaysLeft) days · \(month) \(date)"
        }
    }
    
    func getPercentageDone() -> CGFloat {
        let days = 7.0
        let future = Date.now.addingTimeInterval(60*60*24*days)
        return min(max(1 - (dueDate.timeIntervalSinceNow / future.timeIntervalSinceNow),0.01),1)
    }
    
}
