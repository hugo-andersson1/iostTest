//
//  ProfileView.swift
//  iostTest
//
//  Created by Hugo Andersson on 10/10/26.
//
import SwiftUI

struct ProfileView : View {
    @Environment(DeadlineStore.self) static var store
    @State var viewCategories : Bool = false
    var body : some View{
        NavigationStack{
            VStack(alignment: .center, spacing: 10){
                ZStack{
                    Image(systemName: "person.fill")
                        .font(.title)
                        .bold()
                        .frame(width: 80, height: 80)
                        .foregroundStyle(.white)
                        .background(.blue, in: RoundedRectangle(cornerRadius: 25))
                }
                
                Text("Hugo Andersson")
                    .font(.largeTitle)
                
                .padding()
                
                Button(action:{
                    viewCategories = true
                }){
                    Text("Manage Categories")
                }
                Spacer()
                
            }
            .padding(.horizontal, 20)
            .toolbar{
                ToolbarItem(placement: .principal){
                    Label("Profile",systemImage: "plus")
                        .labelStyle(.titleOnly)
                        .padding()
                }
                ToolbarItem(placement: .topBarTrailing){
                    Button(action:{
                        
                    })
                    {
                        Label("settings",systemImage: "ellipsis")
                    }
                }
            }
            .sheet(isPresented: $viewCategories, onDismiss: {
                //deadline.category = store.currentCategory
            }){
                CategoryListView()
                //AddCategoryView()
            }
        }
        .padding()
    }
}

#Preview{
    ProfileView()
        .environment(DeadlineStore())
}
