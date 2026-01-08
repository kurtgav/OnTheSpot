import SwiftUI

// MARK: - Main Profile View
struct ProfileView: View {
    @ObservedObject var dataManager = DataManager.shared
    @State private var showEditProfile = false
    @State private var animateRing = false
    
    var body: some View {
        NavigationView {
            ZStack {
                // Standard System Background
                Color(UIColor.systemBackground).ignoresSafeArea()
                
                // Simple Animated Background
                Circle()
                    .fill(Color.green.opacity(0.2))
                    .frame(width: 300, height: 300)
                    .blur(radius: 100)
                    .offset(x: -100, y: -200)
                    .rotationEffect(.degrees(animateRing ? 360 : 0))
                    .animation(.linear(duration: 20).repeatForever(autoreverses: false), value: animateRing)
                
                ScrollView {
                    VStack(spacing: 30) {
                        // 1. Header
                        ProfileHeaderSubView(
                            userName: dataManager.userName,
                            userBio: dataManager.userBio,
                            userLocation: dataManager.userLocation,
                            levelProgress: dataManager.progressToNextLevel,
                            animateRing: animateRing,
                            onEdit: { showEditProfile = true }
                        )
                        
                        // 2. Stats
                        ProfileStatsSubView(
                            points: dataManager.contributionPoints,
                            spots: dataManager.spotsAdded
                        )
                        
                        // 3. Settings
                        ProfileSettingsSubView(
                            isDarkMode: $dataManager.isDarkMode
                        )
                    }
                }
            }
            .navigationBarHidden(true)
            .sheet(isPresented: $showEditProfile) { EditProfileView() }
            .onAppear { animateRing = true }
        }
    }
}

// MARK: - 1. Header SubView
struct ProfileHeaderSubView: View {
    let userName: String
    let userBio: String
    let userLocation: String
    let levelProgress: Double
    let animateRing: Bool
    let onEdit: () -> Void
    
    var body: some View {
        VStack(spacing: 15) {
            HStack {
                Text("My Profile")
                    .font(.system(size: 34, weight: .black, design: .rounded))
                    .foregroundColor(.primary)
                Spacer()
                Button(action: onEdit) {
                    Text("Edit")
                        .fontWeight(.bold)
                        .foregroundColor(.green)
                        .padding(.horizontal, 16).padding(.vertical, 8)
                        .background(Color.green.opacity(0.1)).cornerRadius(20)
                }
            }
            .padding(.horizontal)
            .padding(.top, 20)
            
            ZStack {
                Circle().stroke(Color.gray.opacity(0.2), lineWidth: 8)
                    .frame(width: 130, height: 130)
                
                Circle()
                    .trim(from: 0, to: animateRing ? levelProgress : 0)
                    .stroke(Color.green, style: StrokeStyle(lineWidth: 8, lineCap: .round))
                    .frame(width: 130, height: 130).rotationEffect(.degrees(-90))
                    .animation(.easeOut(duration: 1.5), value: animateRing)
                
                Image(systemName: "person.crop.circle.fill")
                    .font(.system(size: 110))
                    .foregroundColor(.gray.opacity(0.5))
            }
            
            VStack(spacing: 6) {
                Text(userName)
                    .font(.title2).fontWeight(.bold).foregroundColor(.primary)
                Text(userBio)
                    .font(.subheadline).fontWeight(.medium).foregroundColor(.green)
                    .multilineTextAlignment(.center).padding(.horizontal)
                Text(userLocation)
                    .font(.caption).foregroundColor(.gray).padding(.top, 2)
            }
        }
    }
}

// MARK: - 2. Stats SubView
struct ProfileStatsSubView: View {
    let points: Int
    let spots: Int
    
    var body: some View {
        HStack(spacing: 15) {
            // Stat 1
            VStack(spacing: 10) {
                Image(systemName: "star.fill").font(.title2).foregroundColor(.yellow)
                    .padding(10).background(Color.yellow.opacity(0.2)).clipShape(Circle())
                VStack(spacing: 2) {
                    Text("\(points)").font(.title3).fontWeight(.bold).foregroundColor(.primary)
                    Text("Points").font(.caption).foregroundColor(.gray)
                }
            }
            .frame(maxWidth: .infinity).padding(.vertical, 20)
            .background(Color(UIColor.secondarySystemBackground)).cornerRadius(20)
            
            // Stat 2
            VStack(spacing: 10) {
                Image(systemName: "mappin.and.ellipse").font(.title2).foregroundColor(.blue)
                    .padding(10).background(Color.blue.opacity(0.2)).clipShape(Circle())
                VStack(spacing: 2) {
                    Text("\(spots)").font(.title3).fontWeight(.bold).foregroundColor(.primary)
                    Text("Spots").font(.caption).foregroundColor(.gray)
                }
            }
            .frame(maxWidth: .infinity).padding(.vertical, 20)
            .background(Color(UIColor.secondarySystemBackground)).cornerRadius(20)
            
            // Stat 3
            VStack(spacing: 10) {
                Image(systemName: "arrow.triangle.2.circlepath").font(.title2).foregroundColor(.green)
                    .padding(10).background(Color.green.opacity(0.2)).clipShape(Circle())
                VStack(spacing: 2) {
                    Text("42").font(.title3).fontWeight(.bold).foregroundColor(.primary)
                    Text("Updates").font(.caption).foregroundColor(.gray)
                }
            }
            .frame(maxWidth: .infinity).padding(.vertical, 20)
            .background(Color(UIColor.secondarySystemBackground)).cornerRadius(20)
        }
        .padding(.horizontal)
    }
}

// MARK: - 3. Settings SubView
struct ProfileSettingsSubView: View {
    @Binding var isDarkMode: Bool
    
    var body: some View {
        VStack(spacing: 15) {
            // Header
            Text("App Settings").font(.caption).fontWeight(.bold).foregroundColor(.gray)
                .frame(maxWidth: .infinity, alignment: .leading).padding(.top, 10).padding(.leading, 10)
            
            VStack(spacing: 0) {
                // Dark Mode Toggle
                HStack {
                    Image(systemName: "moon.stars.fill").foregroundColor(.gray).frame(width: 24)
                    Text("Dark Mode").font(.body).foregroundColor(.primary)
                    Spacer()
                    Toggle("", isOn: $isDarkMode)
                }
                .padding()
                
                Divider()
                
                // Notification Dummy
                HStack {
                    Image(systemName: "bell.badge.fill").foregroundColor(.gray).frame(width: 24)
                    Text("Notifications").font(.body).foregroundColor(.primary)
                    Spacer()
                    Image(systemName: "chevron.right").font(.caption).foregroundColor(.gray)
                }
                .padding()
            }
            .background(Color(UIColor.secondarySystemBackground))
            .cornerRadius(20)
            
            // Account Header
            Text("Account").font(.caption).fontWeight(.bold).foregroundColor(.gray)
                .frame(maxWidth: .infinity, alignment: .leading).padding(.top, 10).padding(.leading, 10)
            
            VStack(spacing: 0) {
                // Subscription Dummy
                HStack {
                    Image(systemName: "creditcard.fill").foregroundColor(.gray).frame(width: 24)
                    Text("Subscription").font(.body).foregroundColor(.primary)
                    Spacer()
                    Image(systemName: "chevron.right").font(.caption).foregroundColor(.gray)
                }
                .padding()
                
                Divider()
                
                // Log Out Dummy
                Button(action: {}) {
                    Text("Log Out").fontWeight(.bold).foregroundColor(.red)
                        .frame(maxWidth: .infinity).padding()
                }
            }
            .background(Color(UIColor.secondarySystemBackground))
            .cornerRadius(20)
        }
        .padding(.horizontal).padding(.bottom, 40)
    }
}


struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileView()
            .preferredColorScheme(.dark)
    }
}
