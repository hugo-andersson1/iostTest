//
//  CategoryListView.swift
//  iostTest
//
//  Created by Hugo Andersson on 10/15/26.
//
import SwiftUI

#Preview{
    CategoryListView()
        .environment(DeadlineStore())
}

struct CategoryListView : View {
    @Environment(DeadlineStore.self) private var store
    @State var isAdding : Bool = false
    var body: some View{
        NavigationStack {
            VStack (spacing: 20){
                ScrollView(.vertical) {
                    withAnimation(.bouncy) {
                        LazyVStack(alignment: .center){
                            ForEach(store.categories.filter{
                                $0.name != "All"
                            }) { category in
                                CategoryUnit(category: category)
                            }
                            Button(action:{
                                isAdding = true
                            })
                            {
                                Label("New Category", systemImage: "plus")
                            }
                            .padding()
                        }
                        .padding()
                    }
                }
            }
            .sheet(isPresented: $isAdding){
                AddCategoryView(editing: false, category: Category(name:"",theme:theme.gray,icon:"plus"))
            }.toolbar{
                ToolbarItem(placement: .principal){
                    Label("Manage Categories",systemImage: "tag")
                        .labelStyle(.titleOnly)
                        .padding()
                }
            }
        }
    }
}

struct CategoryUnit : View {
    @Environment(DeadlineStore.self) private var store
    var category : Category
    @State var isEditing : Bool = false
    var body : some View{
        NavigationStack{
            HStack{
                HStack{
                    category.getIconElement()
                        .padding()
                    Text(category.name.uppercased())
                        .foregroundStyle(category.theme.color)
                        .font(.body)
                        .bold()
                    Spacer()
                    Button(action: {
                        isEditing = true
                    })
                    {
                        Label("Edit", systemImage: "square.and.pencil")
                            .labelStyle(.iconOnly)
                            .font(.title2)
                    }
                    .padding()
                    Button(role: .destructive, action: {
                        store.deleteCategory(category: category)
                    })
                    {
                        Label("Delete", systemImage: "trash")
                            .labelStyle(.iconOnly)
                            .font(.title2)
                    }
                    .padding()
                    .disabled(store.categories.count <= 2 ? true : false)
                }
                .background(category.theme.color.opacity(0.15), in: RoundedRectangle(cornerRadius: 30))
            }
            .sheet(isPresented: $isEditing){
                AddCategoryView(editing: true, category: Category(name: category.name, theme: category.theme, icon: category.icon), original: category)
            }
        }
    }
}
