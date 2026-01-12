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
        // ❌ REMOVED the "NavigationView" wrapper here.
        // This ensures we use the main app's bar and the Back button works correctly.
        ZStack {
            Color(UIColor.systemBackground).ignoresSafeArea()

            VStack(spacing: 24) {
                // 1. Hero Icon & Header
                VStack(spacing: 20) {
                    ZStack {
                        Circle()
                            .fill(location.currentStatus.color.opacity(0.15))
                            .frame(width: 120, height: 120)
                        
                        Image(systemName: location.currentStatus.iconName)
                            .font(.system(size: 55))
                            .foregroundColor(location.currentStatus.color)
                    }
                    .padding(.top, 20)
                    
                    VStack(spacing: 6) {
                        Text(location.name)
                            .font(.system(size: 28, weight: .heavy, design: .rounded))
                            .foregroundColor(.primary)
                            .multilineTextAlignment(.center)
                        
                        Text(location.category.uppercased())
                            .font(.caption).fontWeight(.bold)
                            .foregroundColor(.gray)
                            .padding(.horizontal, 12).padding(.vertical, 5)
                            .background(Color(UIColor.secondarySystemBackground))
                            .cornerRadius(10)
                    }
                    
                    Text(location.currentStatus.title.uppercased())
                        .font(.headline).fontWeight(.black)
                        .foregroundColor(location.currentStatus.color)
                        .padding(.horizontal, 24).padding(.vertical, 12)
                        .background(location.currentStatus.color.opacity(0.1))
                        .cornerRadius(16)
                }
                .padding(.horizontal)

                Spacer()
                
                // 2. Social Plans
                VStack(alignment: .leading, spacing: 12) {
                    Text("Active Hangouts")
                        .font(.headline).fontWeight(.bold).foregroundColor(.primary)
                        .padding(.horizontal)
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 12) {
                            Button(action: { showCreatePlanSheet = true }) {
                                VStack {
                                    Image(systemName: "plus.circle.fill")
                                        .font(.title2).foregroundColor(.primary)
                                    Text("Host").font(.caption).bold().foregroundColor(.primary)
                                }
                                .frame(width: 80, height: 100)
                                .background(Color.primary.opacity(0.05))
                                .cornerRadius(16)
                            }
                            
                            ForEach(CloudDataManager.shared.activePlans) { plan in
                                PlanCard(plan: plan)
                            }
                        }
                        .padding(.horizontal)
                    }
                }
                .onAppear {
                    CloudDataManager.shared.listenForPlans(at: location.id.uuidString)
                }

                // 3. Status Update Buttons
                VStack(alignment: .leading) {
                    Text("Report Status").font(.headline).bold().padding(.horizontal)
                    StatusUpdateView(locationType: location.category) { newStatus in
                        CloudDataManager.shared.updateStatus(for: location, newStatus: newStatus)
                        DataManager.shared.triggerNotification(for: location)
                    }
                }
                
                Spacer().frame(height: 20)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        // 🔥 FIXED: 3 Bubble Buttons in Top Right
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                HStack(spacing: 12) {
                    // 1. Navigate Bubble
                    Button(action: openMaps) {
                        Image(systemName: "arrow.triangle.turn.up.right.circle.fill")
                            .font(.system(size: 18))
                            .foregroundColor(.blue)
                            .frame(width: 36, height: 36)
                            .background(Color.blue.opacity(0.1))
                            .clipShape(Circle())
                    }
                    
                    // 2. Edit Bubble
                    Button(action: { showEditSheet = true }) {
                        Image(systemName: "pencil")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(.primary)
                            .frame(width: 36, height: 36)
                            .background(Color(UIColor.secondarySystemBackground))
                            .clipShape(Circle())
                    }
                    
                    // 3. Delete Bubble
                    Button(action: { showDeleteAlert = true }) {
                        Image(systemName: "trash")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(.red)
                            .frame(width: 36, height: 36)
                            .background(Color.red.opacity(0.1))
                            .clipShape(Circle())
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
                title: Text("Remove Spot?"),
                message: Text("Hide this spot from your map?"),
                primaryButton: .destructive(Text("Remove")) { deleteLocation() },
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

// (Keep PlanCard and EditLocationView structs below exactly as they were)
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
