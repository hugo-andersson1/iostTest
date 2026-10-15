//
//  DeadlineDetails.swift
//  iostTest
//
//  Created by Hugo Andersson on 10/7/26.
//

import SwiftUI

#Preview {
    ContentView()
        .environment(DeadlineStore())
}

struct DeadlineDetailView : View{
    
    @Environment(DeadlineStore.self) private var store
    @Environment(\.dismiss) private var dismiss
    
    @State var deadline : Deadline
    @State var isEditing : Bool = false
    
    var body : some View{
        NavigationStack{
            VStack(spacing: 10){
                deadline.getIconElement(big: true)
                deadline.getCategoryElement(font: .body)
                Text(deadline.name)
                    .font(.largeTitle)
                Text(deadline.getReadableDateTime())
                //Text(park.id)
                deadline.getProgressBarElement(text: "\(deadline.getFormattedTimeLeft())")
                    .padding()
                if !deadline.notes.isEmpty{
                    Text("NOTES")
                        .font(.caption)
                    Text(deadline.notes)
                    Divider()
                        .padding()
                }
                if deadline.completed{
                    Button(role: .destructive, action: {
                        var copy = deadline
                        copy.completed = false
                        store.addDeadline(deadline: copy)
                        
                        store.remove(deadline: deadline)
                        dismiss()
                    })
                    {
                        Label("Undo completed", systemImage: "arrow.uturn.backward")
                            .labelStyle(.titleAndIcon)
                        //.font(.subheadline)
                    }
                    Button(role: .destructive, action: {
                        store.remove(deadline: deadline)
                        dismiss()
                    })
                    {
                        Label("Delete", systemImage: "trash")
                            .labelStyle(.titleAndIcon)
                        //.font(.subheadline)
                    }
                }else{
                    Button(action: {
                        store.markDone(deadline: deadline, save: true)
                        dismiss()
                    })
                    {
                        Label("Mark completed", systemImage: "checkmark.circle.fill")
                            .labelStyle(.titleAndIcon)
                        //.font(.subheadline)
                    }
                    
                }
            }
            .padding(.horizontal,50)
            .toolbar{
                ToolbarItem(placement: .principal){
                    Label("Deadline Details",systemImage: "plus")
                        .labelStyle(.titleOnly)
                        .padding()
                }
                if !deadline.completed{
                    ToolbarItem(placement: .topBarTrailing){
                        Button(action:{
                            //BRING BACK
                            store.markDone(deadline: deadline)
                            isEditing = true
                        })
                        {
                            Label("Edit",systemImage: "square.and.pencil")
                        }
                    }
                }
            }
        }.sheet(isPresented: $isEditing, onDismiss: {
            //BRING THIS BACK IF FAILS
            deadline = store.recentlyAdded
        }){
            ////BRING THIS BACK IF FAILS
            AddDeadlineView(editing: true, deadline: Deadline(name:deadline.name,category: deadline.category,dueDate: deadline.dueDate,notes:deadline.notes), original: deadline)
        }
    }
}


struct SandBox: View {
    
    @Environment(DeadlineStore.self) private var store
    //@Namespace private var shit
    //var deadlines : [Deadline] = []
    //init(){
      //  deadlines = store.deadlines
    //}
    var body: some View {
        NavigationStack {
        }
        .padding()
    }
    
}
