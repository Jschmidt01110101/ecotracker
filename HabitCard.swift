//
//  HabitCard.swift
//  EcoHabit Tracker
//
//  Created by Jack Casper on 9/30/24.
//
import SwiftUI
import AVFoundation

struct HabitCard: View {
    var habit: Habit
    @ObservedObject var user: EcoUser
    @Binding var showRewardAnimation: Bool

    @State private var isCompleted = false

    var body: some View {
        HStack {
            Image(systemName: habit.illustrationName)
                .resizable()
                .frame(width: 50, height: 50)
                .padding(10)
            VStack(alignment: .leading) {
                Text(habit.name)
                    .font(.headline)
                    .foregroundColor(.primary)
                Text("\(habit.points) points")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            Spacer()
            Button(action: {
                markHabitAsCompleted()
            }) {
                Image(systemName: isCompleted ? "checkmark.circle.fill" : "circle")
                    .font(.title)
                    .foregroundColor(isCompleted ? .green : .gray)
                    .padding()
                    .background(isCompleted ? Color.green.opacity(0.2) : Color.gray.opacity(0.2))
                    .clipShape(Circle())
            }
            .animation(.easeInOut(duration: 0.2), value: isCompleted)
        }
        .padding()
        .background(isCompleted ? Color.green.opacity(0.1) : Color.white.opacity(0.8))
        .cornerRadius(15)
        .shadow(radius: 5)
    }

    private func markHabitAsCompleted() {
        if !isCompleted {
            isCompleted = true
            user.points += habit.points
            user.save()
            showRewardAnimation = true

            // Show reward animation for 2 seconds
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                showRewardAnimation = false
            }

            // Reset the habit after 5 seconds
            DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
                isCompleted = false
            }
        }
    }
}
