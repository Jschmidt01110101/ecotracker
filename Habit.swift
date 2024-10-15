//
//  Habit.swift
//  EcoHabit Tracker
//
//  Created by Jack Casper on 9/30/24.
//
import Foundation

struct Habit: Identifiable {
    let id = UUID()
    let name: String
    let points: Int
    let illustrationName: String
    var isCompleted = false
}
