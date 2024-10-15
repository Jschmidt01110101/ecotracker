//
//  EcoUser.swift
//  EcoHabit Tracker
//
//  Created by Jack Casper on 10/1/24.
//

import SwiftUI

// MARK: - EcoUser Model
class EcoUser: ObservableObject, Codable {
    @Published var points: Int
    var nickname: String
    var badges: [String]
    
    enum CodingKeys: CodingKey {
        case points, nickname, badges
    }

    init(nickname: String, points: Int, badges: [String]) {
        self.nickname = nickname
        self.points = points
        self.badges = badges
    }

    required convenience init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let points = try container.decode(Int.self, forKey: .points)
        let nickname = try container.decode(String.self, forKey: .nickname)
        let badges = try container.decode([String].self, forKey: .badges)
        self.init(nickname: nickname, points: points, badges: badges)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(points, forKey: .points)
        try container.encode(nickname, forKey: .nickname)
        try container.encode(badges, forKey: .badges)
    }

    func save() {
        if let encoded = try? JSONEncoder().encode(self) {
            UserDefaults.standard.set(encoded, forKey: "ecoUser")
        }
    }

    static func load() -> EcoUser {
        if let savedUserData = UserDefaults.standard.data(forKey: "ecoUser"),
           let decodedUser = try? JSONDecoder().decode(EcoUser.self, from: savedUserData) {
            return decodedUser
        } else {
            return EcoUser(nickname: "Eco Enthusiast", points: 0, badges: [])
        }
    }
}
