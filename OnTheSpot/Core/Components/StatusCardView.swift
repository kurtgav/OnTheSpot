import SwiftUI

struct StatusCardView: View {
    let location: Location

    var body: some View {
        HStack(spacing: 16) {
            // 1. Animated Live Icon
            LiveStatusIcon(status: location.currentStatus)
            
            // 2. Text Details
            VStack(alignment: .leading, spacing: 4) {
                Text(location.name)
                    .font(.headline)
                    .foregroundColor(.white)
                
                HStack {
                    // Dynamic Category Icon
                    Image(systemName: getCategoryIcon(location.category))
                    Text(location.category.uppercased())
                }
                .font(.system(size: 10, weight: .bold))
                .foregroundColor(.secondaryText)
            }
            
            Spacer()
            
            // 3. Status Pill
            HStack(spacing: 6) {
                Circle()
                    .fill(location.currentStatus.color)
                    .frame(width: 6, height: 6)
                
                Text(location.currentStatus.title.uppercased())
                    .font(.system(size: 11, weight: .bold))
                    .foregroundColor(location.currentStatus.color)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(Color.black.opacity(0.4))
            .cornerRadius(20)
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(location.currentStatus.color.opacity(0.3), lineWidth: 1)
            )
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 24)
                .fill(Color.white.opacity(0.05))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 24)
                .stroke(LinearGradient(
                    colors: [.white.opacity(0.1), .clear],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                ), lineWidth: 1)
        )
        .padding(.horizontal)
    }
    
    // Helper function for Icons
    func getCategoryIcon(_ category: String) -> String {
        switch category {
        case "Fast Food", "Canteen": return "fork.knife"
        case "Parking": return "car.fill"
        case "Terminal": return "bus.fill"
        case "Study Spot": return "book.fill"
        case "Facility": return "building.columns.fill"
        default: return "mappin.circle.fill"
        }
    }
}
