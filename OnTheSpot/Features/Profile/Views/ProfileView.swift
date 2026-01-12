import SwiftUI

struct ProfileView: View {
    @ObservedObject var dataManager = DataManager.shared
    @State private var showEditProfile = false
    @State private var animateRing = false
    
    var body: some View {
        NavigationView {
            ZStack {
                Color(UIColor.systemBackground).ignoresSafeArea()
                
                // animated bg blob
                Circle()
                    .fill(Color.primaryAccent.opacity(0.15))
                    .frame(width: 400, height: 400)
                    .blur(radius: 120)
                    .offset(x: 0, y: -250)
                    .rotationEffect(.degrees(animateRing ? 360 : 0))
                    .animation(.linear(duration: 30).repeatForever(autoreverses: false), value: animateRing)
                
                ScrollView {
                    VStack(spacing: 24) {
                        // header (ava+name)
                        ProfileHeaderSubView(
                            userName: dataManager.userName,
                            userBio: dataManager.userBio,
                            userLocation: dataManager.userLocation,
                            levelProgress: dataManager.progressToNextLevel,
                            profileImage: dataManager.profileImage,
                            animateRing: animateRing,
                            onEdit: { showEditProfile = true }
                        )
                        
                        // vibe tags
                        if !DataManager.shared.userTags.isEmpty {
                            VibeTagsRow(tags: DataManager.shared.userTags)
                        }
                        
                        // stats (pts/lvl)
                        ProfileStatsSubView(
                            points: dataManager.contributionPoints,
                            spots: dataManager.spotsAdded,
                            level: dataManager.userLevel
                        )
                        
                        // setting list
                        ProfileSettingsSubView(
                            isDarkMode: $dataManager.isDarkMode
                        )
                    }
                    .padding(.bottom, 100)
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
    let profileImage: UIImage?
    let animateRing: Bool
    let onEdit: () -> Void
    
    var body: some View {
        VStack(spacing: 20) {
            // edit button (top right)
            HStack {
                Spacer()
                Button(action: onEdit) {
                    Image(systemName: "pencil")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(.primary)
                        .padding(10)
                        .background(Color(UIColor.secondarySystemBackground))
                        .clipShape(Circle())
                }
            }
            .padding(.horizontal, 24)
            .padding(.top, 10)
            
            // ava center
            ZStack {
                // lvl ring
                Circle()
                    .stroke(Color.gray.opacity(0.1), lineWidth: 6)
                    .frame(width: 140, height: 140)
                
                Circle()
                    .trim(from: 0, to: animateRing ? levelProgress : 0)
                    .stroke(Color.primaryAccent, style: StrokeStyle(lineWidth: 6, lineCap: .round))
                    .frame(width: 140, height: 140)
                    .rotationEffect(.degrees(-90))
                    .animation(.easeOut(duration: 1.5), value: animateRing)
                
                // img
                if let image = profileImage {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 120, height: 120)
                        .clipShape(Circle())
                } else {
                    Image(systemName: "person.crop.circle.fill")
                        .font(.system(size: 120))
                        .foregroundColor(.gray.opacity(0.3))
                }
                
                // lvl badge
                VStack {
                    Spacer()
                    Text("LVL \(Int(levelProgress * 10) + 1)") // mock lvl calc
                        .font(.system(size: 10, weight: .black))
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.primaryAccent)
                        .foregroundColor(.black)
                        .cornerRadius(8)
                        .offset(y: 12)
                }
                .frame(height: 140)
            }
            
            // Info
            VStack(spacing: 6) {
                Text(userName)
                    .font(.title).fontWeight(.heavy)
                    .foregroundColor(.primary)
                
                Text(userBio)
                    .font(.body).fontWeight(.medium)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
                
                HStack(spacing: 4) {
                    Image(systemName: "mappin.and.ellipse")
                    Text(userLocation)
                }
                .font(.caption).fontWeight(.bold)
                .foregroundColor(.gray)
                .padding(.top, 4)
            }
        }
    }
}

// MARK: - 2. Vibe Tags Row
struct VibeTagsRow: View {
    let tags: [String]
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                ForEach(tags, id: \.self) { tag in
                    Text(tag.uppercased())
                        .font(.system(size: 10, weight: .bold))
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(Color.primaryAccent.opacity(0.2))
                        .foregroundColor(.primaryAccent) // Adaptive Green
                        .cornerRadius(20)
                }
            }
            .padding(.horizontal, 24)
        }
    }
}

// MARK: - 3. Stats SubView
struct ProfileStatsSubView: View {
    let points: Int
    let spots: Int
    let level: String
    
    var body: some View {
        HStack(spacing: 12) {
            StatBox(title: "POINTS", value: "\(points)", icon: "star.fill", color: .yellow)
            StatBox(title: "SPOTS", value: "\(spots)", icon: "mappin", color: .blue)
            StatBox(title: "RANK", value: level, icon: "trophy.fill", color: .purple)
        }
        .padding(.horizontal, 24)
    }
}

struct StatBox: View {
    let title: String; let value: String; let icon: String; let color: Color
    var body: some View {
        VStack(spacing: 10) {
            Image(systemName: icon)
                .font(.title3).foregroundColor(color)
                .padding(10)
                .background(color.opacity(0.1))
                .clipShape(Circle())
            
            VStack(spacing: 2) {
                Text(value)
                    .font(.headline).fontWeight(.bold).foregroundColor(.primary)
                Text(title)
                    .font(.system(size: 10, weight: .bold)).foregroundColor(.gray)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .background(Color(UIColor.secondarySystemBackground))
        .cornerRadius(16)
    }
}

// MARK: - 4. Settings SubView
struct ProfileSettingsSubView: View {
    @Binding var isDarkMode: Bool
    
    var body: some View {
        VStack(spacing: 0) {
            SettingRow(icon: "moon.stars.fill", title: "Dark Mode", toggle: $isDarkMode)
            Divider()
            SettingRow(icon: "bell.fill", title: "Notifications", toggle: .constant(true))
            Divider()
            SettingRow(icon: "lock.fill", title: "Privacy", isLink: true)
            Divider()
            
            Button(action: { DataManager.shared.logOut() }) {
                HStack {
                    Image(systemName: "rectangle.portrait.and.arrow.right")
                        .foregroundColor(.red)
                    Text("Log Out").fontWeight(.bold).foregroundColor(.red)
                    Spacer()
                }
                .padding()
            }
        }
        .background(Color(UIColor.secondarySystemBackground))
        .cornerRadius(16)
        .padding(.horizontal, 24)
    }
}

struct SettingRow: View {
    let icon: String
    let title: String
    var toggle: Binding<Bool>? = nil
    var isLink: Bool = false
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(.gray)
                .frame(width: 24)
            Text(title).fontWeight(.medium)
            Spacer()
            
            if let toggle = toggle {
                Toggle("", isOn: toggle).labelsHidden()
            } else if isLink {
                Image(systemName: "chevron.right").font(.caption).foregroundColor(.gray)
            }
        }
        .padding()
    }
}
