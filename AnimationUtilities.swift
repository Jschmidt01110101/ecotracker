//
//  Animationutilities.swift
//  EcoHabit Tracker
//
//  Created by Jack Casper on 9/30/24.
//


import SwiftUI

struct RewardAnimationView: View {
    @State private var animate = false
    
    var body: some View {
        ZStack {
            ForEach(0..<15, id: \.self) { index in
                Circle()
                    .fill(randomColor())
                    .frame(width: CGFloat.random(in: 10...20), height: CGFloat.random(in: 10...20))
                    .scaleEffect(animate ? 1 : 0)
                    .position(randomPosition())
                    .animation(Animation.easeOut(duration: 1.5).repeatCount(1, autoreverses: false), value: animate)
            }
        }
        .onAppear {
            animate = true
        }
    }
    
    private func randomPosition() -> CGPoint {
        let screenWidth = UIScreen.main.bounds.width
        let screenHeight = UIScreen.main.bounds.height
        return CGPoint(
            x: CGFloat.random(in: 0...screenWidth),
            y: CGFloat.random(in: 0...screenHeight / 2)  // Confetti burst at the top half of the screen
        )
    }
    
    private func randomColor() -> Color {
        let colors: [Color] = [.yellow, .green, .blue, .red, .orange, .pink, .purple]
        return colors.randomElement() ?? .yellow
    }
}

func playRewardAnimation() -> some View {
    RewardAnimationView()
}
