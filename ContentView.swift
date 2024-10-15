//
//  ContentView.swift
//  EcoHabit Tracker
//
//  Created by Jack Casper on 9/30/24.
//


import SwiftUI
import AVFoundation
import UserNotifications
import StoreKit
import GameKit

struct ContentView: View {
    @StateObject private var user: EcoUser = EcoUser.load()
    @State private var habits = [
        Habit(name: "Use a Reusable Bottle", points: 10, illustrationName: "drop.fill"),
        Habit(name: "Take Shorter Showers", points: 15, illustrationName: "shower.fill"),
        Habit(name: "Recycle", points: 5, illustrationName: "arrow.2.circlepath"),
        Habit(name: "Use Public Transport", points: 20, illustrationName: "bus")
    ]
    @State private var showRewardAnimation = false
    @State private var showDonationOptions = false
    @StateObject private var gameCenterManager = GameCenterManager() // Added Game Center manager

    @State private var showAlert = false
    @State private var alertMessage = ""

    var body: some View {
        NavigationView {
            ZStack {
                LinearGradient(gradient: Gradient(colors: [Color.green, Color.blue]), startPoint: .top, endPoint: .bottom)
                    .edgesIgnoringSafeArea(.all)

                ScrollView {
                    VStack(spacing: 15) {
                        profileSection
                        donateLink
                        pointsDisplay
                        dailyTipSection
                        habitsList
                        gardenLink
                        leaderboardLink // Added Leaderboard link

                        if showRewardAnimation {
                            playRewardAnimation()
                                .frame(maxWidth: .infinity, maxHeight: .infinity)
                        }
                    }
                    .padding(.horizontal)
                    .padding(.top, 20)
                }
            }
            .navigationTitle("EcoHabit Tracker")
            .onAppear {
                requestNotificationPermission()
                gameCenterManager.authenticateUser() // Authenticate the user when the view appears
            }
            .alert(isPresented: $showAlert) {
                Alert(title: Text("Game Center"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
            }
        }
    }

    // MARK: - Profile Section
    private var profileSection: some View {
        NavigationLink(destination: ProfileView(user: Binding(
            get: { User(nickname: user.nickname, points: user.points, badges: user.badges) },
            set: { newValue in
                user.nickname = newValue.nickname
                user.points = newValue.points
                user.badges = newValue.badges
                user.save()
            }
        ))) {
            HStack {
                Image(systemName: "person.crop.circle")
                    .resizable()
                    .frame(width: 60, height: 60)
                    .foregroundColor(.white)
                    .padding()
                    .background(Circle().fill(Color.green))
                    .shadow(radius: 10)

                VStack(alignment: .leading) {
                    Text("Welcome Back,")
                        .font(.caption)
                        .foregroundColor(.white)
                    Text(user.nickname)
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                }
                Spacer()
                Image(systemName: "chevron.right")
                    .foregroundColor(.white)
            }
            .padding()
            .background(LinearGradient(gradient: Gradient(colors: [Color.green.opacity(0.8), Color.green]), startPoint: .leading, endPoint: .trailing))
            .cornerRadius(20)
            .shadow(radius: 5)
        }
        .padding(.horizontal)
        .onTapGesture {
            playClickSound()
        }
    }

    // MARK: - Donation Link
    private var donateLink: some View {
        VStack {
            Button(action: {
                withAnimation {
                    showDonationOptions.toggle()
                }
            }) {
                HStack {
                    Image(systemName: "hands.sparkles.fill")
                        .foregroundColor(.white)
                    Text("Save the Environment - Donate")
                        .font(.headline)
                        .padding()
                        .foregroundColor(.white)
                }
                .padding()
                .background(Color.green)
                .cornerRadius(15)
                .padding(.horizontal)
            }

            if showDonationOptions {
                donationOptions
            }
        }
        .onTapGesture {
            playClickSound()
        }
    }

    // MARK: - Donation Options
    private var donationOptions: some View {
        VStack(spacing: 20) {
            Text("Support Green Future Mission 🌿")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.white)
                .padding(.top, 10)

            Text("Choose an amount to support our efforts to protect the environment and fight climate change.")
                .font(.body)
                .multilineTextAlignment(.center)
                .foregroundColor(.white)
                .padding(.horizontal)

            HStack(spacing: 20) {
                donationButton(amount: 1, productId: "donation_1")
                donationButton(amount: 5, productId: "donation_5")
                donationButton(amount: 10, productId: "donation_10")
            }
        }
        .padding()
        .background(Color.white.opacity(0.2))
        .cornerRadius(15)
        .padding(.horizontal)
    }

    // MARK: - Donation Button
    private func donationButton(amount: Int, productId: String) -> some View {
        Button(action: {
            purchaseProduct(productId: productId)
        }) {
            Text("$\(amount)")
                .font(.headline)
                .padding()
                .frame(width: 80)
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(10)
                .shadow(radius: 5)
        }
    }

    // MARK: - Purchase Product
    private func purchaseProduct(productId: String) {
        // Integrate with StoreKit to handle in-app purchase requests
        print("Purchasing product with ID: \(productId)")
        // In a real app, you'd use StoreKit to initiate the purchase here.
    }

    // MARK: - Points Display
    private var pointsDisplay: some View {
        VStack {
            Text("\(user.points)")
                .font(.system(size: 50, weight: .heavy, design: .rounded))
                .foregroundColor(.white)
                .padding()
                .frame(width: 120, height: 120)
                .background(Color.green.opacity(0.8))
                .clipShape(Circle())
                .shadow(radius: 10)
                .minimumScaleFactor(0.5)
                .lineLimit(1)
                .multilineTextAlignment(.center)

            HStack {
                Image(systemName: "leaf.fill")
                    .foregroundColor(.white)
                Text("Total Eco Points")
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding(.top, 5)
            }
        }
        .padding()
        .onTapGesture {
            reportScoreToGameCenter(score: user.points, leaderboardID: "com.yourapp.leaderboard")
        }
    }

    // MARK: - Daily Tip Section
    private var dailyTipSection: some View {
        VStack {
            HStack {
                Image(systemName: "lightbulb.fill")
                    .foregroundColor(Color.yellow)
                Text("Daily Eco Tip")
                    .font(.title3)
                    .fontWeight(.semibold)
                    .foregroundColor(Color.green)
                    .padding(.bottom, 5)
            }
            Text("Save water by turning off the tap while brushing your teeth.")
                .font(.body)
                .multilineTextAlignment(.center)
                .foregroundColor(.white)
                .padding()
            Image(systemName: "leaf.arrow.circlepath")
                .resizable()
                .scaledToFit()
                .frame(height: 150)
                .padding(.bottom, 10)
                .foregroundColor(Color.green)
        }
        .padding()
        .background(Color.yellow.opacity(0.8))
        .cornerRadius(20)
        .shadow(radius: 5)
        .padding(.horizontal)
    }

    // MARK: - Habits List
    private var habitsList: some View {
        VStack(alignment: .leading, spacing: 20) {
            HStack {
                Image(systemName: "checkmark.seal.fill")
                    .foregroundColor(.white)
                Text("Daily Eco Habits")
                    .font(.title3)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
            }
            .padding(.leading)

            ForEach(habits.indices) { index in
                HabitCard(habit: habits[index], user: user, showRewardAnimation: $showRewardAnimation)
            }
        }
        .padding(.horizontal)
    }

    // MARK: - Garden Link
    private var gardenLink: some View {
        NavigationLink(destination: GardenView(user: user)) {
            HStack {
                Image(systemName: "leaf.arrow.circlepath")
                    .foregroundColor(.white)
                Text("View Your Garden 🌸")
                    .font(.headline)
                    .padding()
                    .foregroundColor(.white)
            }
            .padding()
            .background(Color.green)
            .cornerRadius(15)
            .padding(.horizontal)
        }
        .onTapGesture {
            playClickSound()
        }
    }

    // MARK: - Leaderboard Link
    private var leaderboardLink: some View {
        Button(action: {
            showLeaderboard()
        }) {
            HStack {
                Image(systemName: "star.fill")
                    .foregroundColor(.white)
                Text("View Leaderboard")
                    .font(.headline)
                    .padding()
                    .foregroundColor(.white)
            }
            .padding()
            .background(Color.orange)
            .cornerRadius(15)
            .padding(.horizontal)
        }
        .onTapGesture {
            playClickSound()
        }
    }

    // MARK: - Authenticate Game Center User
    class GameCenterManager: NSObject, ObservableObject, GKGameCenterControllerDelegate {
        @Published var isAuthenticated = false

        func authenticateUser() {
            let localPlayer = GKLocalPlayer.local
            localPlayer.authenticateHandler = { viewController, error in
                if let viewController = viewController {
                    if let rootVC = UIApplication.shared.windows.first?.rootViewController {
                        rootVC.present(viewController, animated: true, completion: nil)
                    }
                } else if localPlayer.isAuthenticated {
                    self.isAuthenticated = true
                    print("Game Center authentication successful")
                } else if let error = error {
                    print("Game Center authentication failed: \(error.localizedDescription)")
                }
            }
        }

        func gameCenterViewControllerDidFinish(_ gameCenterViewController: GKGameCenterViewController) {
            gameCenterViewController.dismiss(animated: true, completion: nil)
        }
    }

    // MARK: - Show Leaderboard Function
    private func showLeaderboard() {
        guard gameCenterManager.isAuthenticated else {
            alertMessage = "You need to be authenticated with Game Center to view the leaderboard."
            showAlert = true
            return
        }

        let viewController = GKGameCenterViewController(leaderboardID: "com.yourapp.leaderboard", playerScope: .global, timeScope: .allTime)
        viewController.gameCenterDelegate = gameCenterManager

        if let rootVC = UIApplication.shared.windows.first?.rootViewController {
            rootVC.present(viewController, animated: true, completion: nil)
        }
    }

    // MARK: - Report Score to Game Center
    private func reportScoreToGameCenter(score: Int, leaderboardID: String) {
        guard gameCenterManager.isAuthenticated else {
            alertMessage = "You must be signed in to Game Center to submit your score."
            showAlert = true
            return
        }

        let scoreReporter = GKScore(leaderboardIdentifier: leaderboardID)
        scoreReporter.value = Int64(score)
        GKScore.report([scoreReporter]) { error in
            if let error = error {
                alertMessage = "Failed to report score: \(error.localizedDescription)"
                showAlert = true
            } else {
                alertMessage = "Score successfully reported to Game Center!"
                showAlert = true
            }
        }
    }

    // MARK: - Sound Feedback
    private func playClickSound() {
        AudioServicesPlaySystemSound(1104) // System click sound
    }

    // MARK: - Reward Animation
    private func playRewardAnimation() -> some View {
        Text("🎉 Reward Earned!")
            .font(.largeTitle)
            .fontWeight(.bold)
            .foregroundColor(.yellow)
            .padding()
    }

    // MARK: - Notification Permission
    private func requestNotificationPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
            if granted {
                print("Notification permission granted.")
                scheduleDailyReminder()
            } else if let error = error {
                print("Error requesting notification permission: \(error.localizedDescription)")
            } else {
                print("Notification permission denied.")
            }
        }
    }

    // MARK: - Schedule Daily Reminder
    private func scheduleDailyReminder() {
        let content = UNMutableNotificationContent()
        content.title = "🌍 Friendly Eco Reminder"
        content.body = "Remember, small actions make a big difference. Take a moment today to do something great for the environment!"
        content.sound = UNNotificationSound.default

        var dateComponents = DateComponents()
        dateComponents.hour = 9 // Reminder time
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)

        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)

        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error scheduling notification: \(error.localizedDescription)")
            }
        }
    }
}
