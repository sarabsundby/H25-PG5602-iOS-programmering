//
//  CategoryAnimations.swift
//  Beacon
//
//

import SwiftUI

struct RestaurantAnimation: View {
    @State private var rotation: Double = 0
    
    var body: some View {
        Text("🍽️")
            .font(.system(size: 80))
            .foregroundColor(Color("BeaconOrange"))
            .rotationEffect(.degrees(rotation))
            .onAppear {
                withAnimation(.easeInOut(duration: 1.0)) {
                rotation = 360
                }
            }
    }
}

struct CafeAnimation: View {
    var body: some View {
        ZStack {
            Text("☕️")
                .font(.system(size: 80))
            
            ForEach(0..<3, id: \.self) { index in
                SteamParticle(delay: Double(index) * 0.3)
            }
        }
        .frame(height: 120)
    }
}

struct SteamParticle: View {
    let delay: Double
    @State private var offset: CGFloat = 0
    @State private var opacity: Double = 1.0
    
    var body: some View {
        Circle()
            .frame(width: 3, height: 3)
            .foregroundColor(.gray)
            .opacity(opacity)
            .offset(x: CGFloat.random(in: -10...10), y: offset)
            .onAppear {
                withAnimation(
                    .easeOut(duration: 2.0)
                    .repeatForever(autoreverses: false)
                    .delay(delay)
                ) {
                    offset = -70
                    opacity = 0.0
                }
            }
    }
}

struct HotelAnimation: View {
    @State private var scale: CGFloat = 0.5
    
    var body: some View {
        Text("🏨")
            .font(.system(size: 80))
            .foregroundColor(Color("BeaconOrange"))
            .scaleEffect(scale)
            .onAppear {
                withAnimation(.spring(response: 0.6, dampingFraction: 0.5, blendDuration: 0))
                {
                    scale = 1.0
                }
            }
    }
}
