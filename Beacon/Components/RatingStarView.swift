//
//  RatingStarView.swift
//  Beacon
//
//

import SwiftUI

struct RatingStarView: View {
    let averageRating: Double
    let size: CGFloat
    
    init(averageRating: Double, size: CGFloat = 20) {
        self.averageRating = averageRating
        self.size = size
    }
    
    var body: some View {
        ZStack(alignment: .leading) {
            Image(systemName: "star.fill")
                .font(.system(size: size))
                .foregroundColor(Color("HighlightOrange"))
                .mask(GeometryReader { geometry in
                    Rectangle()
                        .frame(width: geometry.size.width * fillPercentage)
                })
        }
    }
    
    private var fillPercentage: CGFloat {
        CGFloat(min(max(averageRating, 0), 5) / 5.0)
    }
}

#Preview {
    VStack(spacing:20) {
        HStack {
            Text("1 star")
            RatingStarView(averageRating: 1.0, size: 30)
        }
        HStack {
            Text("2,5 star")
            RatingStarView(averageRating: 2.5, size: 30)
        }
        HStack {
            Text("4 star")
            RatingStarView(averageRating: 4.0, size: 30)
        }
        HStack {
            Text("5 star")
            RatingStarView(averageRating: 5.0, size: 30)
        }
    }
    .padding()
}
