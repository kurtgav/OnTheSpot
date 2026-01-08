import SwiftUI

struct LocationDetailView: View {
    @Binding var location: Location
    @State private var showEditSheet = false

    var body: some View {
        ZStack {
            Color.appBackground.ignoresSafeArea()

            VStack(spacing: 30) {
                // Large Animated Status Icon
                VStack(spacing: 20) {
                    ZStack {
                        Circle()
                            .fill(location.currentStatus.color.opacity(0.2))
                            .frame(width: 140, height: 140)
                            .blur(radius: 20)
                        
                        Image(systemName: location.currentStatus.iconName)
                            .font(.system(size: 60))
                            .foregroundColor(location.currentStatus.color)
                    }
                    .padding(.top, 40)
                    
                    VStack(spacing: 8) {
                        Text(location.name)
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .foregroundColor(.primaryText)
                            .multilineTextAlignment(.center)
                        
                        Text(location.category.uppercased())
                            .font(.caption)
                            .fontWeight(.bold)
                            .foregroundColor(.secondaryText)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 4)
                            .background(Color.white.opacity(0.1))
                            .cornerRadius(8)
                    }
                    
                    Text(location.currentStatus.title.uppercased())
                        .font(.title3)
                        .fontWeight(.heavy)
                        .foregroundColor(location.currentStatus.color)
                        .padding(.horizontal, 24)
                        .padding(.vertical, 12)
                        .background(location.currentStatus.color.opacity(0.1))
                        .cornerRadius(16)
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(location.currentStatus.color.opacity(0.3), lineWidth: 1)
                        )
                    
                    Text("Last updated \(location.lastUpdate, style: .relative) ago")
                        .font(.subheadline)
                        .foregroundColor(.secondaryText)
                }
                .padding(.horizontal)

                Spacer()

                // Status Update Buttons
                StatusUpdateView(locationType: location.category) { newStatus in
                    withAnimation {
                        // 1. Update the Location
                        self.location.currentStatus = newStatus
                        self.location.lastUpdate = Date()
                        
                        // 2. TRIGGER NOTIFICATION (The Connection)
                        DataManager.shared.triggerNotification(for: self.location)
                    }
                }

                Spacer()
            }
            .padding(.top, 20)
        }
        .navigationTitle("Status Check")
        .navigationBarTitleDisplayMode(.inline)
        // --- NEW EDIT BUTTON ---
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: { showEditSheet = true }) {
                    Image(systemName: "square.and.pencil")
                        .foregroundColor(.primaryAccent)
                }
            }
        }
        // --- NEW EDIT SHEET ---
        .sheet(isPresented: $showEditSheet) {
            EditLocationView(location: $location)
        }
    }
}

// MARK: - The Edit Sheet Component
// 👇 THIS IS THE PART THAT WAS MISSING 👇
struct EditLocationView: View {
    @Binding var location: Location
    @Environment(\.presentationMode) var presentationMode
    
    let categories = ["Study Spot", "Fast Food", "Canteen", "Cafe", "Terminal", "Parking", "Facility", "Laundry"]
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.appBackground.ignoresSafeArea()
                
                Form {
                    Section(header: Text("Location Details").foregroundColor(.primaryAccent)) {
                        TextField("Name", text: $location.name)
                            .foregroundColor(.white)
                        
                        Picker("Category", selection: $location.category) {
                            ForEach(categories, id: \.self) { category in
                                Text(category).tag(category)
                            }
                        }
                        .pickerStyle(MenuPickerStyle())
                        .accentColor(.white)
                    }
                    .listRowBackground(Color.white.opacity(0.05))
                    
                    Section(header: Text("Status Override").foregroundColor(.primaryAccent)) {
                        Text("Current: \(location.currentStatus.title)")
                            .foregroundColor(.secondaryText)
                    }
                    .listRowBackground(Color.white.opacity(0.05))
                }
                .onAppear {
                    UITableView.appearance().backgroundColor = .clear
                }
            }
            .navigationTitle("Edit Spot")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") { presentationMode.wrappedValue.dismiss() }
                        .foregroundColor(.white)
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") { presentationMode.wrappedValue.dismiss() }
                        .foregroundColor(.primaryAccent)
                        .fontWeight(.bold)
                }
            }
        }
        .preferredColorScheme(.dark)
    }
}
struct LocationDetailView_Previews: PreviewProvider {
    static var previews: some View {
        // You MUST provide a constant value for bindings!
        LocationDetailView(location: .constant(Location.mockData[0]))
    }
}

