import SwiftUI
import FirebaseAuth

struct LocationDetailView: View {
    @Binding var location: Location
    
    // State
    @State private var showEditSheet = false
    @State private var showCreatePlanSheet = false
    @State private var showDeleteAlert = false
    
    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        ZStack {
            Color(UIColor.systemBackground).ignoresSafeArea()

            VStack(spacing: 24) {
                // 1. Icon & Header
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
                            .font(.largeTitle).fontWeight(.bold).foregroundColor(.primary)
                            .multilineTextAlignment(.center)
                        
                        Text(location.category.uppercased())
                            .font(.caption).fontWeight(.bold).foregroundColor(.gray)
                            .padding(.horizontal, 10).padding(.vertical, 4)
                            .background(Color.gray.opacity(0.1)).cornerRadius(8)
                    }
                    
                    Text(location.currentStatus.title.uppercased())
                        .font(.title3).fontWeight(.heavy).foregroundColor(location.currentStatus.color)
                        .padding(.horizontal, 24).padding(.vertical, 12)
                        .background(location.currentStatus.color.opacity(0.1)).cornerRadius(16)
                }
                .padding(.horizontal)

                // (Removed the buttons from here)

                Spacer()
                
                // 2. SOCIAL PLANS SECTION
                VStack(alignment: .leading) {
                    Text("Active Hangouts")
                        .font(.headline).foregroundColor(.primary)
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 12) {
                            Button(action: { showCreatePlanSheet = true }) {
                                VStack {
                                    Image(systemName: "plus.circle.fill")
                                        .font(.title).foregroundColor(.primary)
                                    Text("Host").font(.caption).foregroundColor(.primary)
                                }
                                .padding()
                                .background(Color.primary.opacity(0.05))
                                .cornerRadius(12)
                            }
                            
                            ForEach(CloudDataManager.shared.activePlans) { plan in
                                PlanCard(plan: plan)
                            }
                        }
                    }
                }
                .padding(.horizontal)
                .onAppear {
                    CloudDataManager.shared.listenForPlans(at: location.id.uuidString)
                }

                // 3. Status Update Buttons
                StatusUpdateView(locationType: location.category) { newStatus in
                    CloudDataManager.shared.updateStatus(for: location, newStatus: newStatus)
                    DataManager.shared.triggerNotification(for: location)
                }
                
                Spacer().frame(height: 20)
            }
            .padding(.top, 20)
        }
        .navigationBarTitleDisplayMode(.inline)
        // 🔥 FIXED: All 3 Buttons in Top Right Toolbar
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                HStack(spacing: 20) {
                    // 1. Navigate
                    Button(action: openMaps) {
                        Image(systemName: "arrow.triangle.turn.up.right.circle.fill")
                            .font(.system(size: 20))
                            .foregroundColor(.blue)
                    }
                    
                    // 2. Edit
                    Button(action: { showEditSheet = true }) {
                        Image(systemName: "square.and.pencil")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(.primary)
                    }
                    
                    // 3. Delete
                    Button(action: { showDeleteAlert = true }) {
                        Image(systemName: "trash")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(.red)
                    }
                }
            }
        }
        // Sheets & Alerts
        .sheet(isPresented: $showEditSheet) {
            EditLocationView(location: $location)
        }
        .sheet(isPresented: $showCreatePlanSheet) {
            CreatePlanView(locationId: location.id.uuidString, locationName: location.name)
        }
        .alert(isPresented: $showDeleteAlert) {
            Alert(
                title: Text("Remove Spot?"), // Changed from "Delete"
                message: Text("This will hide this spot from YOUR map only. Other users can still see it."),
                primaryButton: .destructive(Text("Remove")) {
                    deleteLocation()
                },
                secondaryButton: .cancel()
            )
        }
    }
    
    func openMaps() {
        let lat = location.latitude
        let long = location.longitude
        if let url = URL(string: "http://maps.apple.com/?daddr=\(lat),\(long)") {
            UIApplication.shared.open(url)
        }
    }
    
    func deleteLocation() {
        CloudDataManager.shared.hideLocation(spotId: location.id.uuidString)
        
        presentationMode.wrappedValue.dismiss()
    }
}

// (Keep PlanCard and EditLocationView structs as they were)
struct PlanCard: View {
    let plan: Plan
    @State private var showActionSheet = false
    @State private var navigateToChat = false
    let currentUserId = FirebaseAuth.Auth.auth().currentUser?.uid ?? ""
    var isHost: Bool { plan.hostId == currentUserId }
    var isJoined: Bool { plan.participants.contains(currentUserId) }
    var isFull: Bool { plan.participants.count >= plan.maxParticipants }
    var body: some View {
        ZStack {
            NavigationLink(destination: GroupChatView(plan: plan), isActive: $navigateToChat) { EmptyView() }
            Button(action: { if isJoined { navigateToChat = true } else { showActionSheet = true } }) {
                VStack(alignment: .leading, spacing: 6) {
                    Text(plan.tag.uppercased()).font(.system(size: 8, weight: .bold)).padding(4).background(Color.green.opacity(0.2)).foregroundColor(.green).cornerRadius(4)
                    Text(plan.title).font(.subheadline).fontWeight(.bold).foregroundColor(.primary).lineLimit(1)
                    Text("by \(plan.hostName)").font(.caption).foregroundColor(.gray)
                    HStack {
                        Image(systemName: "person.2.fill").font(.caption2)
                        Text("\(plan.participants.count)/\(plan.maxParticipants)").font(.caption2).fontWeight(.bold)
                        if isFull && !isJoined { Text("FULL").font(.caption2).fontWeight(.black).foregroundColor(.red) }
                    }.foregroundColor(isJoined ? .green : .primary)
                }
                .padding(12).frame(width: 140, height: 100).background(Color(UIColor.secondarySystemBackground)).cornerRadius(12)
                .overlay(RoundedRectangle(cornerRadius: 12).stroke(isJoined ? Color.green : Color.clear, lineWidth: 2))
            }
            .actionSheet(isPresented: $showActionSheet) {
                if isHost {
                    return ActionSheet(title: Text(plan.title), buttons: [.default(Text("Open Chat")) { navigateToChat = true }, .destructive(Text("Delete Plan")) { CloudDataManager.shared.deletePlan(plan) }, .cancel()])
                } else {
                    return ActionSheet(title: Text(plan.title), buttons: [isFull ? .default(Text("Plan is Full")) {} : .default(Text("Join Hangout")) { CloudDataManager.shared.joinPlan(plan); DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { navigateToChat = true } }, .cancel()])
                }
            }
        }
    }
}

struct EditLocationView: View {
    @Binding var location: Location
    @Environment(\.presentationMode) var presentationMode
    let allCategories = ["Study Spot", "Fast Food", "Canteen", "Cafe", "Terminal", "Parking", "Facility", "Laundry", "Gym", "Gas Station", "Barbershop", "Salon", "Mall", "Park", "Hospital", "Restroom"]
    @State private var searchText = ""
    var filteredCategories: [String] { searchText.isEmpty ? allCategories : allCategories.filter { $0.localizedCaseInsensitiveContains(searchText) } }
    var body: some View {
        NavigationView {
            ZStack {
                Color(UIColor.systemBackground).ignoresSafeArea()
                VStack(spacing: 20) {
                    Text("Edit Details").font(.largeTitle).fontWeight(.heavy).foregroundColor(.primary).padding(.top, 20)
                    VStack(alignment: .leading) {
                        Text("NAME").font(.caption).fontWeight(.bold).foregroundColor(.gray)
                        TextField("Name", text: $location.name).padding().background(Color.gray.opacity(0.1)).cornerRadius(12).foregroundColor(.primary)
                    }
                    VStack(alignment: .leading) {
                        Text("CATEGORY").font(.caption).fontWeight(.bold).foregroundColor(.gray)
                        TextField("Search...", text: $searchText).padding(10).background(Color.gray.opacity(0.1)).cornerRadius(10)
                        ScrollView {
                            LazyVGrid(columns: [GridItem(.adaptive(minimum: 100))], spacing: 10) {
                                ForEach(filteredCategories, id: \.self) { category in
                                    Button(action: { location.category = category }) {
                                        Text(category).font(.caption).fontWeight(.bold).foregroundColor(location.category == category ? .black : .primary).padding(.vertical, 10).frame(maxWidth: .infinity).background(location.category == category ? Color.green : Color.gray.opacity(0.1)).cornerRadius(12)
                                    }
                                }
                            }
                        }
                        .frame(maxHeight: 250)
                    }
                    Spacer()
                    Button("Save") { CloudDataManager.shared.addLocation(location); presentationMode.wrappedValue.dismiss() }.font(.headline).fontWeight(.bold).foregroundColor(.black).frame(maxWidth: .infinity).padding().background(Color.green).cornerRadius(16).padding(.bottom, 20)
                }
                .padding(.horizontal, 24)
            }
            .navigationBarHidden(true)
        }
    }
}
