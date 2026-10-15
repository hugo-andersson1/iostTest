//
//  DeadlineStore.swift
//  iostTest
//
//  Created by Hugo Andersson on 10/7/26.
//
import SwiftUI
import Observation
import Foundation

#Preview {
    ContentView()
        .environment(DeadlineStore())
}

@Observable
class DeadlineStore {
    
    var personal = Category.personal
    
    var categories : [Category] = [] {
        didSet{
            saveCategories()
        }
    }
    var deadlines : [Deadline] = [] {
        didSet{
            saveDeadlines()
        }
    }
    
    var recentlyAdded : Deadline = Deadline(name:"Something went seriously wrong",category: Category.personal,dueDate: Date(),notes:"")
    
    
    var completedDeadlines : [Deadline] = []
    var currentCategory : Category = Category.all
    
    
    func loadSampleData(){
        
        let all = Category(name: "All", theme: theme.yellow, icon: "star")
        
        let personal = Category.personal
        
        let work = Category(name: "Work", theme: theme.red, icon: "briefcase.fill")
        let school = Category(name: "School", theme: theme.green, icon: "graduationcap.fill")
        
        self.categories = [
            all,personal,work,school
        ]
        
        self.currentCategory = all
        
        let date1 = Calendar.current.date(byAdding: .hour, value: 8, to: Date()) ?? Date()
        let date2 = Calendar.current.date(byAdding: .day, value: 1, to: Date()) ?? Date()
        let date3 = Calendar.current.date(byAdding: .day, value: 4, to: Date()) ?? Date()
        let date4 = Calendar.current.date(byAdding: .month, value: 1, to: Date()) ?? Date()
        
        
        self.deadlines = [
            Deadline(name: "Presentation", category: school, dueDate: Date().addingTimeInterval((60*60*4))),
            Deadline(name: "Q3 report", category: work, dueDate: date1),
            Deadline(name: "Java Project", category: school, dueDate: date2.addingTimeInterval(60*60*4)),
            Deadline(name: "UX Design", category: personal, dueDate: date3),
            Deadline(name: "Renew Lease", category: personal, dueDate: date4)
        ]
        
    }
    func deleteCategory(category: Category){
        if categories.count <= 2{
            return
        }
        let idx = categories.firstIndex(of: category)
        categories.remove(at: idx!)
        if deadlines.count > 0{
            for i in 0...deadlines.count-1{
                if i > deadlines.count-1{
                    break
                }
                if deadlines[i].category == category{
                    remove(deadline: deadlines[i], completed: false)
                }
            }
        }
        if completedDeadlines.count > 0{
            for i in 0...completedDeadlines.count-1{
                if i > completedDeadlines.count-1{
                    break
                }
                if completedDeadlines[i].category == category{
                    remove(deadline: completedDeadlines[i], completed: true)
                }
            }
        }
    }
    func replaceCategory(original: Category, to: Category){
        let idx = categories.firstIndex(of: original)
        
        if deadlines.count > 0{
            for i in 0...deadlines.count-1{
                if deadlines[i].category == original{
                    var copy = copyDeadline(deadline: deadlines[i])
                    copy.category = to
                    remove(deadline: deadlines[i], completed: false)
                    addDeadline(deadline: copy)
                }
            }
        }
        if completedDeadlines.count > 0{
            for i in 0...completedDeadlines.count-1{
                if completedDeadlines[i].category == original{
                    var copy = copyDeadline(deadline: completedDeadlines[i])
                    copy.category = to
                    remove(deadline: completedDeadlines[i], completed: true)
                    self.completedDeadlines.append(copy)
                }
            }
        }
        
        self.categories.remove(at: idx!)
        self.categories.insert(to, at: idx!)
    }
    
    func copyDeadline(deadline: Deadline) -> Deadline{
        return Deadline(name: deadline.name,category: deadline.category, dueDate: deadline.dueDate, notes: deadline.notes, completed: deadline.completed)
    }
    
    func addCategory(category: Category){
        self.categories.append(category)
    }
    
    func remove(deadline: Deadline, completed: Bool = true){
        if !completed{
            self.deadlines.remove(at: self.deadlines.firstIndex(of: deadline)!)
        }else{
            self.completedDeadlines.remove(at: self.completedDeadlines.firstIndex(of: deadline)!)
        }
    }
    
    func markDone(deadline: Deadline, save: Bool = false){
        self.deadlines.remove(at: self.deadlines.firstIndex(of: deadline)!)
        
        if save{
            var copy = deadline
            copy.completed = true
            completedDeadlines.append(copy)
        }
    }
    
    func addDeadline(deadline: Deadline){
        self.deadlines.append(deadline)
        recentlyAdded = deadline
    }
    
    func sortedDeadlines() -> [Deadline] {
        return self.deadlines.sorted {
            $0.dueDate < $1.dueDate
        }
    }
    
    func overdueDeadlines() -> [Deadline] {
        return self.validSortedDeadlines().filter {
            $0.dueDate < Date()
        }
    }
    
    func todayDeadlines() -> [Deadline] {
        return self.validSortedDeadlines().filter {
            Calendar.current.isDateInToday($0.dueDate) &&
            $0.dueDate > Date()
        }
    }
    
    func tomorrowDeadlines() -> [Deadline] {
        return self.validSortedDeadlines().filter {
            Calendar.current.isDateInTomorrow($0.dueDate)
        }
    }
    
    func weekDeadlines() -> [Deadline] {
        let week = Date.now.formatted(.dateTime.week())
        return self.validSortedDeadlines().filter {
            !Calendar.current.isDateInToday($0.dueDate) && $0.dueDate.formatted(.dateTime.week()) == week &&
                $0.dueDate > Date()
        }
    }
    
    func laterDeadlines() -> [Deadline] {
        let week = Date.now.formatted(.dateTime.week())
        return self.validSortedDeadlines().filter {
            !Calendar.current.isDateInToday($0.dueDate) && $0.dueDate.formatted(.dateTime.week()) != week && $0.dueDate > Date()
        }
    }
    
    func validSortedDeadlines() -> [Deadline] {
        return self.deadlines.sorted {
            $0.dueDate < $1.dueDate
        }.filter{
            ($0.category == currentCategory || currentCategory.name == "All")
        }
        
    }
    
    func completedSortedDeadlines() -> [Deadline] {
        return self.completedDeadlines.sorted{
            $0.dueDate < $1.dueDate
        }
    }
    // File location URL
    private var deadlineFileURL: URL {
        FileManager.default
            .urls(for: .documentDirectory, in: .userDomainMask)[0]
            .appendingPathComponent("deadlines.json")
    }
    // File location URL
    private var categoryFileURL: URL {
        FileManager.default
            .urls(for: .documentDirectory, in: .userDomainMask)[0]
            .appendingPathComponent("categories.json")
    }
    
    
    init() {
        loadCategories()
        loadDeadlines()
        currentCategory = categories[0]
    }
    
    
    private func saveDeadlines() {
        do {
            let data = try JSONEncoder().encode(deadlines)
            try data.write(to: deadlineFileURL, options: [.atomic, .completeFileProtection])
            print("Saved Deadlines!")
        } catch {
            print("❌ Failed to save deadlines: \(error.localizedDescription)")
        }
    }
    private func saveCategories() {
        do {
            let data = try JSONEncoder().encode(categories)
            try data.write(to: categoryFileURL, options: [.atomic, .completeFileProtection])
            print("Saved Categories!")
        } catch {
            print("❌ Failed to save categories: \(error.localizedDescription)")
        }
    }
    
    private func loadDeadlines() {
        do {
            let data = try Data(contentsOf: deadlineFileURL)
            self.deadlines = try JSONDecoder().decode([Deadline].self, from: data)
        } catch {
            // Falls back to an empty array on first app launch
            self.deadlines = []
            print("Populating Deadlines...")
        }
    }
    
    private func loadCategories() {
        do {
            let data = try Data(contentsOf: categoryFileURL)
            self.categories = try JSONDecoder().decode([Category].self, from: data)
        } catch {
            // Falls back to an empty array on first app launch
            self.categories = [Category.all, Category.personal, Category.work]
            print("Populating Categories...")
        }
    }
    
}
