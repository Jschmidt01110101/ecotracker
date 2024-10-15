//
//  GardenView.swift
//  EcoHabit Tracker
//
//  Created by Jack Casper on 9/30/24.
//
import SwiftUI
import AVFoundation // For adding sound effects

// MARK: - Plant Model
struct Plant: Codable {
    let emoji: String
    let name: String
    let growthStages: [String]
    let growthDuration: TimeInterval
    let cost: Int
    let profit: Int
    var currentStage: Int = 0
    var growthProgress: Double = 0.0
    var isGrowing: Bool = false
    var timeRemaining: TimeInterval
}

// MARK: - PlantSlot Model
struct PlantSlot: Codable {
    var plant: Plant?
    var isLocked: Bool = false
}

// MARK: - Mission Model
struct Mission: Codable {
    let description: String
    var target: Int
    var progress: Int = 0
    let reward: Int
    var isCompleted: Bool {
        progress >= target
    }
}

// MARK: - GardenView
struct GardenView: View {
    @ObservedObject var user: EcoUser
    @State private var gardenGrid: [PlantSlot] = []
    @State private var selectedPlant: Plant?
    @State private var inventory: [Plant] = []
    @State private var missions: [Mission] = []
    @State private var soundPlayer: AVAudioPlayer?

    let plantOptions = [
        Plant(emoji: "🌱", name: "Sprout", growthStages: ["🌱", "🌿", "🌸"], growthDuration: 30, cost: 10, profit: 20, timeRemaining: 30),
        Plant(emoji: "🌻", name: "Sunflower", growthStages: ["🌻", "🌼", "🌼"], growthDuration: 45, cost: 15, profit: 30, timeRemaining: 45),
        Plant(emoji: "🌸", name: "Flower", growthStages: ["🌸", "🌷", "🌹"], growthDuration: 60, cost: 20, profit: 40, timeRemaining: 60)
    ]

    var body: some View {
        GeometryReader { geometry in
            ScrollView {
                VStack {
                    // Header: Title and points
                    Text("Your Eco Garden")
                        .font(.largeTitle)
                        .bold()
                        .padding()
                        .background(LinearGradient(gradient: Gradient(colors: [Color.green.opacity(0.6), Color.blue.opacity(0.6)]), startPoint: .topLeading, endPoint: .bottomTrailing))
                        .cornerRadius(12)
                        .padding()

                    Text("🌟 Points: \(user.points) 🌟")
                        .font(.title2)
                        .padding()
                        .background(Color.yellow.opacity(0.3))
                        .cornerRadius(8)

                    // Garden Grid
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 10), count: 3), spacing: 10) {
                        ForEach(0..<gardenGrid.count, id: \.self) { index in
                            ZStack {
                                if gardenGrid[index].isLocked {
                                    Color.gray
                                        .frame(width: geometry.size.width / 4, height: geometry.size.width / 4)
                                        .cornerRadius(10)
                                        .overlay(Text("Locked 🔒").foregroundColor(.white))
                                } else {
                                    getBackground(for: gardenGrid[index].plant)
                                        .frame(width: geometry.size.width / 4, height: geometry.size.width / 4)
                                        .cornerRadius(10)
                                        .shadow(radius: 5)

                                    if let plant = gardenGrid[index].plant {
                                        Text(plant.growthStages[plant.currentStage])
                                            .font(.largeTitle)
                                        if plant.isGrowing {
                                            VStack {
                                                ProgressView(value: plant.growthProgress)
                                                    .progressViewStyle(LinearProgressViewStyle())
                                                    .padding(.top, 5)
                                                Text("\(Int(plant.timeRemaining))s left")
                                                    .font(.caption)
                                            }
                                        } else if plant.currentStage == plant.growthStages.count - 1 {
                                            Button(action: {
                                                harvestPlant(at: index)
                                            }) {
                                                Text("Harvest 🎉")
                                                    .font(.caption)
                                                    .padding(5)
                                                    .background(Color.green)
                                                    .foregroundColor(.white)
                                                    .cornerRadius(5)
                                            }
                                        }
                                    }
                                }
                            }
                            .onTapGesture {
                                plantInGarden(at: index)
                            }
                        }
                    }
                    .padding()

                    // Plant selection header
                    Text("🌼 Select a Plant to Grow 🌼")
                        .font(.headline)
                        .padding(.top)

                    // Plant selection scroll view
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack {
                            ForEach(plantOptions, id: \.emoji) { plant in
                                Button(action: {
                                    selectedPlant = plant
                                    playSound("select") // Fun sound when selecting a plant
                                }) {
                                    VStack {
                                        Text(plant.emoji)
                                            .font(.largeTitle)
                                        Text("\(plant.name) - \(plant.cost) pts")
                                            .font(.caption)
                                    }
                                    .padding()
                                    .background(selectedPlant?.emoji == plant.emoji ? Color.yellow.opacity(0.5) : Color.clear)
                                    .cornerRadius(10)
                                }
                                .disabled(user.points < plant.cost)
                            }
                        }
                        .padding()
                    }

                    // Expansion Button
                    Button(action: {
                        expandGarden()
                        playSound("expand") // Fun sound when expanding the garden
                    }) {
                        Text("Expand Garden (-50 Points)")
                            .font(.headline)
                            .padding()
                            .background(user.points >= 50 ? Color.blue : Color.gray)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                    .padding(.top)
                    .disabled(user.points < 50)

                    // Missions Section
                    Text("🌱 Missions 🌱")
                        .font(.headline)
                        .padding(.top)

                    ForEach(missions.indices, id: \.self) { index in
                        let mission = missions[index]
                        HStack {
                            Text(mission.description)
                                .font(.body)
                            Spacer()
                            Text("\(mission.progress)/\(mission.target)")
                                .font(.body)
                                .padding(.trailing)
                            if mission.isCompleted {
                                Button(action: {
                                    completeMission(at: index)
                                    playSound("reward") // Reward sound
                                }) {
                                    Text("Claim Reward")
                                        .font(.caption)
                                        .padding(5)
                                        .background(Color.orange)
                                        .foregroundColor(.white)
                                        .cornerRadius(5)
                                }
                            }
                        }
                        .padding(.horizontal)
                    }

                    // Random Events Section
                    Button(action: {
                        triggerRandomEvent()
                        playSound("random") // Sound for triggering random events
                    }) {
                        Text("🌟 Trigger Random Event 🌟")
                            .font(.headline)
                            .padding()
                            .background(Color.purple)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                    .padding()
                }
                .padding()
                .onAppear {
                    loadGameState()
                    startGrowthTimers()
                }
                .onDisappear {
                    saveGameState()
                }
            }
        }
    }

    // MARK: - Garden Management Functions
    func plantInGarden(at index: Int) {
        guard gardenGrid[index].plant == nil, !gardenGrid[index].isLocked else { return }
        if let selectedPlant = selectedPlant, user.points >= selectedPlant.cost {
            var newPlant = selectedPlant
            newPlant.isGrowing = true
            newPlant.timeRemaining = newPlant.growthDuration
            gardenGrid[index].plant = newPlant
            user.points -= selectedPlant.cost
            user.save()
            updateMissionProgress(for: newPlant)
        }
    }

    func expandGarden() {
        if user.points >= 50 {
            for index in gardenGrid.indices {
                if gardenGrid[index].isLocked {
                    gardenGrid[index].isLocked = false
                    user.points -= 50
                    user.save()
                    break
                }
            }
        }
    }

    func harvestPlant(at index: Int) {
        if let plant = gardenGrid[index].plant {
            user.points += plant.profit
            gardenGrid[index].plant = nil
            updateHarvestMissionProgress()
            user.save()
        }
    }

    func completeMission(at index: Int) {
        if missions[index].isCompleted {
            user.points += missions[index].reward
            missions.remove(at: index)
            user.save()
        }
    }

    // MARK: - Mission Management Functions
    func updateMissionProgress(for newPlant: Plant) {
        for missionIndex in missions.indices {
            if missions[missionIndex].description.contains(newPlant.name) {
                missions[missionIndex].progress += 1
            }
        }
    }

    func updateHarvestMissionProgress() {
        for missionIndex in missions.indices {
            if missions[missionIndex].description.contains("Harvest") {
                missions[missionIndex].progress += 1
            }
        }
    }

    // MARK: - Random Event Function
    func triggerRandomEvent() {
        let randomEvent = Int.random(in: 1...5)
        switch randomEvent {
        case 1:
            // Double points event
            let bonusPoints = 20
            user.points += bonusPoints
            user.save()
            showAlert(title: "Lucky Day!", message: "You've earned a bonus of \(bonusPoints) points!")
        case 2:
            // Weather impacts growth speed
            for index in gardenGrid.indices {
                if var plant = gardenGrid[index].plant, plant.isGrowing {
                    plant.timeRemaining *= 0.9
                    gardenGrid[index].plant = plant
                }
            }
            showAlert(title: "Rainy Day!", message: "Plants are growing faster thanks to the rain!")
        case 3:
            // Animal visits and drops reward
            let reward = 15
            user.points += reward
            user.save()
            showAlert(title: "Friendly Animal Visit", message: "An animal visited your garden and left you \(reward) points!")
        case 4:
            // Pest attack reduces points
            let penalty = 10
            user.points = max(0, user.points - penalty)
            user.save()
            showAlert(title: "Pest Attack!", message: "Pests attacked your garden. You lost \(penalty) points!")
        case 5:
            // Free plant in inventory
            let freePlant = plantOptions.randomElement()!
            inventory.append(freePlant)
            showAlert(title: "Gift!", message: "You received a free \(freePlant.name) in your inventory!")
        default:
            break
        }
    }

    // MARK: - Timer for Growth
    func startGrowthTimers() {
        Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            for index in gardenGrid.indices {
                if var plant = gardenGrid[index].plant, plant.isGrowing {
                    plant.timeRemaining -= 1
                    plant.growthProgress = 1 - (plant.timeRemaining / plant.growthDuration)

                    if plant.timeRemaining <= 0, plant.currentStage < plant.growthStages.count - 1 {
                        plant.currentStage += 1
                        plant.timeRemaining = plant.growthDuration / Double(plant.growthStages.count)
                    }

                    if plant.currentStage == plant.growthStages.count - 1 {
                        plant.isGrowing = false
                    }

                    gardenGrid[index].plant = plant
                }
            }
        }
    }

    // MARK: - Save and Load Game State
    func saveGameState() {
        if let gardenData = try? JSONEncoder().encode(gardenGrid) {
            UserDefaults.standard.set(gardenData, forKey: "gardenGrid")
        }

        if let inventoryData = try? JSONEncoder().encode(inventory) {
            UserDefaults.standard.set(inventoryData, forKey: "inventory")
        }

        if let missionData = try? JSONEncoder().encode(missions) {
            UserDefaults.standard.set(missionData, forKey: "missions")
        }
    }

    func loadGameState() {
        if let gardenData = UserDefaults.standard.data(forKey: "gardenGrid"),
           let decodedGarden = try? JSONDecoder().decode([PlantSlot].self, from: gardenData) {
            gardenGrid = decodedGarden
        } else {
            gardenGrid = Array(repeating: PlantSlot(), count: 9)
        }

        if let inventoryData = UserDefaults.standard.data(forKey: "inventory"),
           let decodedInventory = try? JSONDecoder().decode([Plant].self, from: inventoryData) {
            inventory = decodedInventory
        }

        if let missionData = UserDefaults.standard.data(forKey: "missions"),
           let decodedMissions = try? JSONDecoder().decode([Mission].self, from: missionData) {
            missions = decodedMissions
        } else {
            missions = [
                Mission(description: "Plant 3 Sunflowers", target: 3, reward: 30),
                Mission(description: "Harvest 5 fully grown plants", target: 5, reward: 50)
            ]
        }
    }

    // MARK: - Helper Functions
    @ViewBuilder
    func getBackground(for plant: Plant?) -> some View {
        if let plant = plant {
            switch plant.emoji {
            case "🌱":
                LinearGradient(
                    gradient: Gradient(colors: [Color.green.opacity(0.4), Color.brown.opacity(0.5)]),
                    startPoint: .top,
                    endPoint: .bottom
                )

            case "🌻":
                RadialGradient(
                    gradient: Gradient(colors: [Color.yellow.opacity(0.5), Color.orange.opacity(0.4)]),
                    center: .center,
                    startRadius: 10,
                    endRadius: 50
                )

            case "🌸":
                AngularGradient(
                    gradient: Gradient(colors: [Color.pink.opacity(0.5), Color.purple.opacity(0.3)]),
                    center: .center
                )

            default:
                Color.green.opacity(0.3)
            }
        } else {
            LinearGradient(
                gradient: Gradient(colors: [Color.blue.opacity(0.2), Color.green.opacity(0.4)]),
                startPoint: .top,
                endPoint: .bottom
            )
        }
    }

    // Helper function to show alert messages
    func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))

        if let rootController = UIApplication.shared.windows.first?.rootViewController {
            rootController.present(alert, animated: true, completion: nil)
        }
    }

    // Helper function to play sounds
    func playSound(_ sound: String) {
        if let soundURL = Bundle.main.url(forResource: sound, withExtension: "mp3") {
            do {
                soundPlayer = try AVAudioPlayer(contentsOf: soundURL)
                soundPlayer?.play()
            } catch {
                print("Unable to play sound")
            }
        }
    }
}
