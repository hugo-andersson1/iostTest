//
//  AddCategoryView.swift
//  iostTest
//
//  Created by Hugo Andersson on 10/9/26.
//

import SwiftUI

struct AddCategoryView : View{
    
    @Environment(DeadlineStore.self) private var store
    @Environment(\.dismiss) private var dismiss
    
    @State var category = Category(name: "", theme: theme.yellow, icon: "plus")
    
    var editing : Bool = false
    var original : Category
    let icons : [String] = ["macbook","graduationcap.fill","person.fill","briefcase.fill","airplane","dumbbell.fill","doc.plaintext.fill","star.fill","suitcase.fill","car.fill"]
    
    let themes : [theme] = theme.allCases
    
    init(editing: Bool=false, category: Category = Category(name: "err", theme: theme.red, icon: "minus"), original: Category = Category(name: "err", theme: theme.red, icon: "minus")){
        self.editing = editing
        self.category = category
        self.original = original
    }
    
    var body : some View{
        NavigationStack{
            VStack(alignment: .center, spacing: 10){
                category.getIconElement(big: true)
                
                TextField("Category Name", text: $category.name)
                    .multilineTextAlignment(.center)
                    .font(.largeTitle)
                    .autocorrectionDisabled()
                
                let columns = [
                    GridItem(.flexible()),
                    GridItem(.flexible()),
                    GridItem(.flexible()),
                    GridItem(.flexible()),
                    GridItem(.flexible())
                ]
                Text("Select icon")
                LazyVGrid(columns: columns, spacing: 16){
                    ForEach(icons, id: \.self){ icon in
                        Button(action: {
                            category.icon = icon
                        })
                        {
                            ZStack{
                                let selected = category.icon == icon
                                RoundedRectangle(cornerRadius: 15)
                                    .foregroundStyle(selected ? Color.blue.opacity(0.4) : Color.secondary.opacity(0.2))
                                    .frame(width:50,height:50)
                                Image(systemName: icon)
                                    .font(.title2)
                                    .foregroundStyle(selected ? .white : .black)
                            }
                        }
                    }
                }
                .padding()
                .background(.gray.opacity(0.1), in: RoundedRectangle(cornerRadius: 25))
                Text("Select color")
                LazyVGrid(columns: columns, spacing: 16){
                    ForEach(themes, id: \.self){ theme in
                        Button(action: {
                            category.theme = theme
                        })
                        {
                            ZStack{
                                let selected = category.theme == theme
                                RoundedRectangle(cornerRadius: 15)
                                    .foregroundStyle(theme.color)
                                    .frame(width:50,height:50)
                            }
                        }
                    }
                }
                .padding()
                .background(.gray.opacity(0.1), in: RoundedRectangle(cornerRadius: 25))
                
                //FIX THIS COLOR PICKER
                //ColorPicker("Color", selection: $category.theme)
            }
            .padding(.horizontal, 20)
            .toolbar{
                ToolbarItem(placement: .principal){
                    Label(editing ? "Edit Category" : "New Category",systemImage: "plus")
                        .labelStyle(.titleOnly)
                        .padding()
                }
                ToolbarItem(placement: .topBarTrailing){
                    Button(action:{
                        confirm()
                    })
                    {
                        Label("Done",systemImage: "checkmark")
                    }
                }
                ToolbarItem(placement: .topBarLeading){
                    Button(action:{
                        if editing{
                            store.addCategory(category:original)
                        }
                        dismiss()
                    })
                    {
                        Label("Exit",systemImage: "xmark")
                    }
                    .foregroundStyle(.red)
                }
            }
        }
        .padding()
    }
    
    func confirm(){
        if category.name != ""{
            if editing{
                store.replaceCategory(original: original, to: category)
            }else{
                store.addCategory(category: category)
            }
            store.currentCategory = category
            dismiss()
        }else{
            store.addCategory(category: original)
        }
    }
}

#Preview{
    AddCategoryView()
        .environment(DeadlineStore())
}
