import SwiftUI

struct NotificationView: View {
    @ObservedObject var dataManager = DataManager.shared
    @State private var animateList = false
    @State private var pulseGlow = false
    
    var body: some View {
        NavigationView {
            ZStack {
                // Background
                Color(UIColor.systemBackground).ignoresSafeArea()
                
                // Glow Effect
                Circle()
                    .fill(Color.blue.opacity(0.15))
                    .frame(width: 300, height: 300)
                    .blur(radius: 100)
                    .offset(x: 100, y: -200)
                    .scaleEffect(pulseGlow ? 1.2 : 1.0)
                    .animation(.easeInOut(duration: 3).repeatForever(autoreverses: true), value: pulseGlow)
                
                VStack(spacing: 0) {
                    // Header
                    HStack {
                        Text("Activity")
                            .font(.system(size: 34, weight: .black, design: .rounded))
                            .foregroundColor(.primary)
                        
                        Spacer()
                        
                        if !dataManager.notifications.isEmpty {
                            Button(action: { dataManager.clearNotifications() }) {
                                Text("Clear")
                                    .font(.subheadline).fontWeight(.bold).foregroundColor(.gray)
                                    .padding(.horizontal, 12).padding(.vertical, 6)
                                    .background(Color.gray.opacity(0.1)).cornerRadius(12)
                            }
                        }
                    }
                    .padding(.horizontal, 24).padding(.top, 20).padding(.bottom, 10)
                    
                    if dataManager.notifications.isEmpty {
                        EmptyNotificationState()
                    } else {
                        ScrollView {
                            LazyVStack(spacing: 16) {
                                ForEach(Array(dataManager.notifications.enumerated()), id: \.element.id) { index, item in
                                    NotificationCard(item: item)
                                        .offset(y: animateList ? 0 : 50)
                                        .opacity(animateList ? 1 : 0)
                                        .animation(.spring().delay(Double(index) * 0.1), value: animateList)
                                }
                            }
                            .padding(.horizontal, 20).padding(.top, 10)
                        }
                    }
                }
            }
            .navigationBarHidden(true)
            .onAppear {
                animateList = true
                pulseGlow = true
            }
        }
    }
}

// MARK: - Components

struct NotificationCard: View {
    let item: NotificationItem
    @Environment(\.colorScheme) var colorScheme // Detect Dark/Light Mode
    
    var body: some View {
        HStack(spacing: 16) {
            ZStack {
                Circle().fill(Color(UIColor.systemBackground))
                    .frame(width: 50, height: 50)
                    .shadow(color: .black.opacity(0.1), radius: 5)
                Image(systemName: item.iconName)
                    .foregroundColor(.green)
                    .font(.system(size: 20))
            }
            VStack(alignment: .leading, spacing: 4) {
                Text(item.title).font(.headline).fontWeight(.bold).foregroundColor(.primary).lineLimit(1)
                Text(item.message).font(.subheadline).foregroundColor(.gray).lineLimit(2)
            }
            Spacer()
            Text(item.timeAgo).font(.caption2).fontWeight(.bold).foregroundColor(.gray)
        }
        .padding(16)
        // MANUAL ADAPTIVE STYLE (No external dependency)
        .background(
            colorScheme == .dark ? Color.white.opacity(0.05) : Color(UIColor.secondarySystemBackground)
        )
        .cornerRadius(20)
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(
                    colorScheme == .light ? Color.black : Color.white.opacity(0.1),
                    lineWidth: 1
                )
        )
    }
}

struct EmptyNotificationState: View {
    var body: some View {
        VStack(spacing: 20) {
            Spacer()
            ZStack {
                Circle().fill(Color.gray.opacity(0.1)).frame(width: 150, height: 150)
                Image(systemName: "bell.slash.fill").font(.system(size: 60)).foregroundColor(.gray)
            }
            VStack(spacing: 8) {
                Text("All Caught Up").font(.title2).fontWeight(.bold).foregroundColor(.primary)
                Text("When spots get updated, you'll see them here.")
                    .font(.body).foregroundColor(.gray).multilineTextAlignment(.center).padding(.horizontal, 40)
            }
            Spacer(); Spacer()
        }
    }
}


// MARK: - PREVIEW CODE 🖼️
struct NotificationView_Previews: PreviewProvider {
    static var previews: some View {
        // We inject some fake data just for the canvas
        let demo = NotificationView()
        
        // This code runs only in preview
        demo.onAppear {
            DataManager.shared.notifications = [
                NotificationItem(title: "Status Update: Library", message: "is now marked as QUIET", timestamp: Date(), iconName: "book.fill"),
                NotificationItem(title: "Status Update: Jollibee", message: "is now marked as LONG LINE", timestamp: Date().addingTimeInterval(-3600), iconName: "flame.fill")
            ]
        }
        
        return demo
            .preferredColorScheme(.dark)
    }
}
