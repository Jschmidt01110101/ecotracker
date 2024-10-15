//
//  ProfileView.swift
//  EcoHabit Tracker
//
//  Created by Jack Casper on 9/30/24.
//
//


import SwiftUI

struct ProfileView: View {
    @Binding var user: User
    @State private var isEditingNickname = false
    @State private var newNickname: String = ""

    var body: some View {
        VStack(spacing: 20) {
            // Profile Picture Section
            profilePictureSection
            
            // Nickname Section
            nicknameSection
            
            // Points and Progress
            pointsAndProgressSection
            
            // Badges Section
            badgesSection

            Spacer()
        }
        .padding()
        .background(
            LinearGradient(gradient: Gradient(colors: [Color("SkyBlue"), Color("LightGreen")]), startPoint: .top, endPoint: .bottom)
                .edgesIgnoringSafeArea(.all)
        )
        .onAppear {
            newNickname = user.nickname
        }
    }

    // MARK: - Profile Picture Section
    private var profilePictureSection: some View {
        VStack {
            Image(systemName: "person.crop.circle.fill")
                .resizable()
                .frame(width: 120, height: 120)
                .foregroundColor(.white)
                .background(Circle().fill(Color.green).frame(width: 130, height: 130))
                .shadow(radius: 10)
                .padding()

            Button(action: {
                // Placeholder action for changing profile picture
            }) {
                Text("Change Profile Picture")
                    .font(.subheadline)
                    .foregroundColor(.white)
                    .padding(8)
                    .background(Color.blue)
                    .cornerRadius(10)
                    .shadow(radius: 5)
            }
        }
    }

    // MARK: - Nickname Section
    private var nicknameSection: some View {
        VStack {
            HStack {
                Text("Nickname: ")
                    .font(.title2)
                    .foregroundColor(.white)

                if isEditingNickname {
                    TextField("Enter new nickname", text: $newNickname)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .frame(width: 150)
                } else {
                    Text(user.nickname)
                        .font(.title2)
                        .foregroundColor(.white)
                        .bold()
                }

                Button(action: {
                    if isEditingNickname {
                        user.nickname = newNickname
                    }
                    withAnimation {
                        isEditingNickname.toggle()
                    }
                }) {
                    Image(systemName: isEditingNickname ? "checkmark.circle.fill" : "pencil")
                        .foregroundColor(.white)
                        .font(.title2)
                }
            }
            .padding(.horizontal)
        }
    }

    // MARK: - Points and Progress Section
    private var pointsAndProgressSection: some View {
        VStack(alignment: .leading) {
            Text("Points: \(user.points)")
                .font(.title)
                .foregroundColor(.white)
                .padding(.top, 10)
            
            ProgressView(value: Double(user.points) / 100.0, total: 100.0) {
                Text("Your Progress Towards Next Badge")
                    .font(.headline)
                    .foregroundColor(.white)
            }
            .progressViewStyle(LinearProgressViewStyle(tint: Color.yellow))
            .padding(.horizontal)
            .shadow(radius: 5)

            Text("Reach 100 points to earn your next badge!")
                .font(.subheadline)
                .foregroundColor(.white)
                .padding(.top, 5)
        }
        .padding(.top)
    }

    // MARK: - Badges Section
    private var badgesSection: some View {
        VStack(alignment: .leading) {
            Text("Badges")
                .font(.title2)
                .foregroundColor(.white)
                .bold()
                .padding(.bottom, 10)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 20) {
                    ForEach(user.badges, id: \.self) { badge in
                        VStack {
                            Image(systemName: "star.fill")
                                .resizable()
                                .frame(width: 50, height: 50)
                                .foregroundColor(.yellow)
                                .shadow(radius: 5)
                            Text(badge)
                                .font(.caption)
                                .foregroundColor(.white)
                                .padding(.top, 5)
                        }
                        .padding()
                        .background(Color.white.opacity(0.2))
                        .cornerRadius(15)
                        .shadow(radius: 5)
                    }

                    if user.badges.isEmpty {
                        Text("No badges earned yet.")
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.8))
                            .padding()
                    }
                }
                .padding(.horizontal)
            }
        }
        .padding()
    }
}

struct ProfileView_Previews: PreviewProvider {
    @State static var user = User(nickname: "Eco Champion", points: 50, badges: ["Eco-Warrior", "Water Saver"])

    static var previews: some View {
        ProfileView(user: $user)
    }
}

