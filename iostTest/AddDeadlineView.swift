//
//  AddDeadlineView.swift
//  iostTest
//
//  Created by Hugo Andersson on 10/7/26.
//

import SwiftUI

struct AddDeadlineView : View{
    
    @Environment(DeadlineStore.self) private var store
    @Environment(\.dismiss) private var dismiss
    
    var editing : Bool = false
    @State var deadline : Deadline
    
    var original : Deadline

    
    @State var addingCategory : Bool = false
    init(editing: Bool=false, deadline: Deadline = Deadline(name:"Err0", category: Category.all,dueDate: Date(),notes:""), original: Deadline = Deadline(name:"Err1",category: Category.all,dueDate: Date(),notes:"")){
        self.editing = editing
        self.deadline = deadline
        self.original = original
    }
    var body : some View{
        NavigationStack{
            VStack(alignment: .center, spacing: 10){
                //deadline.wrappedValue
                deadline.category.getIconElement(big: true)
                TextField("Deadline Name", text: $deadline.name)
                    .multilineTextAlignment(.center)
                    .font(.largeTitle)
                    .autocorrectionDisabled()
                
                Menu{
                    Button(action: {
                        addingCategory = true
                        
                    }){
                        HStack{
                            Text("New Category")
                            Image(systemName: "plus")
                        }
                    }
                    ForEach(store.categories.filter{
                        $0.name != "All"
                    }){ category in
                        Button(action: {
                            deadline.category = category
                        }){
                            HStack{
                                Text(category.name)
                                Image(systemName: category.icon)
                            }
                        }
                    }
                }label:{
                    Label(deadline.category.name, systemImage: deadline.category.icon)
                        .foregroundStyle(deadline.category.theme.color)
                }
                DatePicker("Due Date",selection: $deadline.dueDate)
                    .datePickerStyle(.compact)
                TextField("Notes", text: $deadline.notes)
                    .multilineTextAlignment(.leading)
                    .font(.body)
                    .textFieldStyle(.roundedBorder)
            }
            .padding(.horizontal, 20)
            .toolbar{
                ToolbarItem(placement: .principal){
                    Label(editing ? "Edit Deadline" : "Add Deadline",systemImage: "plus")
                        .labelStyle(.titleOnly)
                        .padding()
                }
                // DONE BUTTON
                ToolbarItem(placement: .topBarTrailing){
                    Button(action:{
                        confirm()
                    })
                    {
                        Label("Done",systemImage: "checkmark")
                    }
                }
                // EXIT BUTTON
                ToolbarItem(placement: .topBarLeading){
                    Button(role: .destructive, action:{
                        if editing{
                            store.addDeadline(deadline: original)
                        }
                        dismiss()
                    })
                    {
                        Label("Exit",systemImage: "xmark")
                    }
                }
            }
        }
        .padding()
        .sheet(isPresented: $addingCategory, onDismiss: {
            deadline.category = store.currentCategory
        }){
            AddCategoryView(editing: false, category: Category(name:"",theme:theme.gray,icon:"plus"))
        }
    }
    
    func confirm(){
        if deadline.name != ""{
            store.addDeadline(deadline: deadline)
            dismiss()
        }
    }
}
