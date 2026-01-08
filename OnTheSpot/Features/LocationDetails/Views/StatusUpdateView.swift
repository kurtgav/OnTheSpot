import SwiftUI

struct StatusUpdateView: View {
    let locationType: String
    let onUpdate: (LocationStatus) -> Void

    var body: some View {
        VStack(spacing: 16) {
            Text("Update Status")
                .font(.headline)
                .foregroundColor(.secondaryText)
            
            HStack(spacing: 12) {
                // Logic for new categories
                if isQueueBased(locationType) {
                    // Fast Food, Canteens, Terminals, Cafes
                    StatusButton(status: .noLine, onUpdate: onUpdate)
                    StatusButton(status: .shortLine, onUpdate: onUpdate)
                    StatusButton(status: .longLine, onUpdate: onUpdate)
                }
                else if isAvailabilityBased(locationType) {
                    // Parking, Laundry, Gyms
                    StatusButton(status: .available, onUpdate: onUpdate)
                    StatusButton(status: .inUse, onUpdate: onUpdate)
                }
                else {
                    // Study Spots, Libraries
                    StatusButton(status: .quiet, onUpdate: onUpdate)
                    StatusButton(status: .justRight, onUpdate: onUpdate)
                    StatusButton(status: .noisy, onUpdate: onUpdate)
                }
            }
            .padding(.horizontal)
        }
    }
    
    // Helpers to group categories
    func isQueueBased(_ type: String) -> Bool {
        return ["Cafe", "Fast Food", "Canteen", "Terminal", "Marketplace"].contains(type)
    }
    
    func isAvailabilityBased(_ type: String) -> Bool {
        return ["Laundry", "Parking", "Facility"].contains(type)
    }
}

struct StatusButton: View {
    let status: LocationStatus
    let onUpdate: (LocationStatus) -> Void

    var body: some View {
        Button(action: { onUpdate(status) }) {
            VStack(spacing: 8) {
                Image(systemName: status.iconName)
                    .font(.system(size: 24))
                Text(status.title)
                    .font(.caption)
                    .fontWeight(.bold)
                    .fixedSize(horizontal: false, vertical: true)
                    .multilineTextAlignment(.center)
            }
            .foregroundColor(status.color == .primaryAccent ? .black : .white)
            .frame(maxWidth: .infinity)
            .frame(height: 90)
            .background(status.color)
            .cornerRadius(16)
            .shadow(color: status.color.opacity(0.3), radius: 8, x: 0, y: 4)
        }
    }
}
