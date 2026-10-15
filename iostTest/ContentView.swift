//
//  ContentView.swift
//  iostTest
//
//  Created by Hugo Andersson on 10/6/26.
//

import SwiftUI


#Preview {
    ContentView()
        .environment(DeadlineStore())
}

enum theme : String, Codable, CaseIterable{
    case blue,red,yellow,purple,orange,green,brown, pink, cyan,gray
    
    var color : Color {
        switch self{
        case .blue: return .blue
        case .red: return .red
        case .yellow: return .yellow
        case .purple: return .purple
        case .orange: return .orange
        case .green: return .green
        case .gray: return .gray
        case .pink: return .pink
        case .cyan: return .cyan
        case .brown: return .brown
        }
    }
}

struct Category: Identifiable, Equatable, Hashable, Codable {
    var id = UUID()
    var name : String
    var theme : theme
    var icon : String
    static let all = Self(name: "All", theme: .yellow, icon: "star")
    static var work = Self(name: "Work", theme: .red, icon: "briefcase.fill")
    static var personal = Self(name: "Personal", theme: .blue, icon: "person.fill")
    func getIconElement(big: Bool = false) -> some View {
        var size : CGFloat = 60
        var font : Font = .title2
        if(big){
            size = 80
            font = .title
        }
        let result = Image(systemName: icon)
            .font(font)
            .bold()
            .frame(width: size, height: size)
            .foregroundStyle(.white)
            .background(theme.color, in: RoundedRectangle(cornerRadius: 25))
        return result
    }
}

struct DeadlineUnit : View{
    @State var deadline : Deadline
    var body: some View{
        NavigationLink(destination: DeadlineDetailView(deadline: deadline)){
            DeadlineCard(deadline: deadline)               .transition(.asymmetric(
                insertion: .move(edge: .trailing).combined(with: .opacity), // Slide from right + fade in
                removal: .opacity.combined(with: .scale(scale: 0.9))         // Fade out + shrink away
            ))
        }
    }
}

struct CategoryTab : View {
    @Environment(DeadlineStore.self) private var store
    var body : some View{
        ScrollView(.horizontal){
            LazyHStack{
                ForEach(store.categories) { category in
                    Button(action: {
                        withAnimation(.smooth) {
                            store.currentCategory = category
                        }
                    }) {
                        HStack(spacing: 6) {
                            Text(category.name)
                                .foregroundStyle(store.currentCategory == category ? .blue : .gray)
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 10)
                        //.background(.tertiary, in: RoundedRectangle(cornerRadius: 25))
                    }
                    
                }
            }
            .padding()
        }
    }
}


struct ContentView: View {
    
    @Environment(DeadlineStore.self) private var store
    @State var addingDeadline : Bool = false
    @State private var selectedTab = 1
    var weekday = Date().formatted(.dateTime.weekday(.wide))
    var monthDate = Date().formatted(.dateTime.month().day())
    var body: some View {
        TabView(selection: $selectedTab) {
            NavigationStack {
                VStack (spacing: 20){
                    ZStack{
                        VStack(alignment: .center){
                            Text(weekday)
                                .font(.largeTitle)
                                .fontWeight(.semibold)
                            Text(monthDate)
                                .font(.title2)
                        }
                        HStack{
                            Spacer()
                            Button(action: {
                                addingDeadline = true
                            })
                            {
                                Label("Add Deadline",systemImage: "plus.circle.fill")
                                    .font(.largeTitle)
                                    .labelStyle(.iconOnly)
                            }
                        }
                        .frame(width:300)
                    }
                    CategoryTab()
                        .frame(height:40)
                    ScrollView(.vertical) {

                        withAnimation(.bouncy) {
                            
                            LazyVStack(alignment: .center){
                                let validDeadlines = store.validSortedDeadlines()
                                let overdueDeadlines = store.overdueDeadlines()
                                let todayDeadlines = store.todayDeadlines()
                                let weekDeadlines = store.weekDeadlines()
                                let laterDeadlines = store.laterDeadlines()
                                if overdueDeadlines.count > 0{
                                    Text("Overdue")
                                        .font(.title)
                                    ForEach(overdueDeadlines){
                                            deadline in
                                            DeadlineUnit(deadline: deadline)
                                        }
                                }
                                if todayDeadlines.count > 0{
                                    Text("Today")
                                        .font(.title)
                                    ForEach(todayDeadlines){
                                            deadline in
                                            DeadlineUnit(deadline: deadline)
                                        }
                                }
                                if weekDeadlines.count > 0{
                                    Text("This Week")
                                        .font(.title)
                                    ForEach(weekDeadlines){
                                        deadline in
                                        DeadlineUnit(deadline: deadline)
                                    }
                                }
                                if laterDeadlines.count > 0{
                                    Text("Later")
                                        .font(.title)
                                    ForEach(laterDeadlines){
                                        deadline in
                                        DeadlineUnit(deadline: deadline)
                                    }
                                }
                                if validDeadlines.count < 1 {
                                    Image(systemName: "checkmark")
                                        .font(.largeTitle)
                                        .foregroundStyle(.primary)
                                        .padding()
                                    Text("All done")
                                }
                            }
                            .padding()
                        }
                    }
                }
                .sheet(isPresented: $addingDeadline){
                    AddDeadlineView(editing: false, deadline:Deadline(name:"",category: store.categories[1],dueDate: Date(),notes:""))
                }
            }
            .tabItem {
                Label("Deadlines", systemImage: "checklist")
            }.tag(1)
            NavigationStack {
                VStack (spacing: 20){
                Text("Completed Deadlines")
                    ScrollView(.vertical) {
                        withAnimation(.bouncy) {
                            LazyVStack(alignment: .center){
                                ForEach(store.completedDeadlines.reversed()) { deadline in
                                    DeadlineUnit(deadline: deadline)
                                }
                            }
                        }
                    }
                }.padding()
            }.tabItem{
                Label("Completed", systemImage: "checkmark.circle")
            }.tag(2)
            ProfileView().tabItem {
                Label("Profile", systemImage: "person")
            }.tag(3)
        }
        .onOpenURL { url in
            guard url.scheme == "deadlines" else { return }
            selectedTab = 1
            store.currentCategory = store.categories.first(where: { $0.name == "All" }) ?? store.currentCategory
            if url.host == "add" { addingDeadline = true }
        }
    }
}
