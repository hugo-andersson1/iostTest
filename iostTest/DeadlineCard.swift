//
//  DeadlineCard.swift
//  iostTest
//
//  Created by Hugo Andersson on 10/7/26.
//
import SwiftUI

#Preview {
    ContentView()
        .environment(DeadlineStore())
}

struct DeadlineCard: View{
    
    private let deadline : Deadline
    private let category : Category
    
    init(deadline: Deadline){
        self.deadline = deadline
        self.category = deadline.category
    }
    
    var body: some View {
        HStack {
            deadline.getIconElement()
            
            VStack(alignment: .leading){
                
                deadline.getCategoryElement()
                
                Text(deadline.name)
                    .foregroundStyle(.black)
                    .font(.title2)
                //"Today · 1h 12min"
                deadline.getProgressBarElement()
                
            }
            .padding()
        }
        .frame(height: 70)
        .padding()
        .background(category.theme.color.opacity(0.15), in: RoundedRectangle(cornerRadius: 30))
    }
        
}
