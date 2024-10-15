//
//  SplashScreenView.swift
//  EcoHabit Tracker
//
//  Created by Jack Casper on 9/30/24.
//

import SwiftUI

struct SplashScreenView: View {
    @State private var isActive = false
    @State private var loadingProgress = 0.0

    var body: some View {
        if isActive {
            ContentView() // Navigate to ContentView after splash screen
        } else {
            VStack {
                Image("AppIcon") // Display AppIcon.png
                    .resizable()
                    .scaledToFit()
                    .frame(width: 150, height: 150)
                    .padding()
                
                ProgressView(value: loadingProgress, total: 100)
                    .progressViewStyle(LinearProgressViewStyle())
                    .frame(width: 200)
                    .padding(.top, 20)
                
                Spacer()
            }
            .onAppear {
                startLoading()
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(LinearGradient(gradient: Gradient(colors: [Color.green, Color.blue]), startPoint: .top, endPoint: .bottom))
            .edgesIgnoringSafeArea(.all)
        }
    }
    
    private func startLoading() {
        Timer.scheduledTimer(withTimeInterval: 0.02, repeats: true) { timer in
            loadingProgress += 1
            if loadingProgress >= 100 {
                timer.invalidate()
                withAnimation {
                    isActive = true
                }
            }
        }
    }
}
