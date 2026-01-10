import SwiftUI
import Combine

struct UserProfileView: View {
    let userId: String
    @StateObject private var viewModel = OtherUserViewModel()
    
    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                // 1. Cover Image (Gradient)
                LinearGradient(colors: [.blue, .purple], startPoint: .topLeading, endPoint: .bottomTrailing)
                    .frame(height: 150)
                
                // 2. Avatar (Overlapping)
                ZStack {
                    Circle().fill(Color(UIColor.systemBackground)).frame(width: 110, height: 110)
                    Image(systemName: "person.crop.circle.fill")
                        .font(.system(size: 100))
                        .foregroundColor(.gray)
                }
                .offset(y: -50)
                .padding(.bottom, -50)
                
                // 3. Details
                VStack(spacing: 8) {
                    Text(viewModel.name)
                        .font(.title2).fontWeight(.bold)
                    
                    Text(viewModel.bio)
                        .font(.body).foregroundColor(.gray)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                    
                    HStack {
                        Image(systemName: "mappin.and.ellipse")
                        Text(viewModel.location)
                    }
                    .font(.caption).bold().foregroundColor(.blue)
                }
                .padding(.bottom, 24)
                
                Divider()
                
                // 4. Stats Row
                HStack(spacing: 40) {
                    VStack {
                        Text("\(viewModel.points)").font(.title3).bold()
                        Text("Points").font(.caption).foregroundColor(.gray)
                    }
                    VStack {
                        Text(viewModel.level).font(.title3).bold().foregroundColor(.purple)
                        Text("Rank").font(.caption).foregroundColor(.gray)
                    }
                }
                .padding(.vertical, 20)
                
                Divider()
                
                // 5. Actions
                Button(action: { CloudDataManager.shared.blockUser(uidToBlock: userId) }) {
                    Text("Block User")
                        .font(.headline).foregroundColor(.red)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.red.opacity(0.1))
                        .cornerRadius(12)
                }
                .padding(24)
            }
        }
        .edgesIgnoringSafeArea(.top)
        .onAppear { viewModel.fetchUser(uid: userId) }
    }
}

// ViewModel (Same as before)
class OtherUserViewModel: ObservableObject {
    @Published var name = "Loading..."
    @Published var bio = "..."
    @Published var location = "..."
    @Published var points = 0
    @Published var isLoading = true
    var level: String { points > 500 ? "Legend" : (points > 200 ? "Pro" : "Rookie") }
    func fetchUser(uid: String) {
        CloudDataManager.shared.fetchAnyUserProfile(uid: uid) { data in
            DispatchQueue.main.async {
                self.name = data["name"] as? String ?? "User"
                self.bio = data["bio"] as? String ?? "Rookie"
                self.location = data["location"] as? String ?? "Unknown"
                self.points = data["points"] as? Int ?? 0
                self.isLoading = false
            }
        }
    }
}
