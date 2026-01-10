import SwiftUI

struct ChatInfoView: View {
    let plan: Plan
    @ObservedObject var cloudManager = CloudDataManager.shared
    @Environment(\.presentationMode) var presentationMode
    
    // Filter messages that have images
    var galleryImages: [ChatMessage] {
        cloudManager.currentChatMessages.filter { $0.imageUrl != nil }
    }
    
    var body: some View {
        NavigationView {
            List {
                // 1. Plan Details
                Section(header: Text("PLAN DETAILS")) {
                    HStack {
                        Image(systemName: "mappin.and.ellipse")
                        Text(plan.locationName)
                    }
                    HStack {
                        Image(systemName: "clock")
                        // FIX: Changed 'time' to 'startTime'
                        Text(plan.startTime, style: .time)
                    }
                }
                
                // 2. Members
                Section(header: Text("MEMBERS (\(plan.participants.count))")) {
                    ForEach(plan.participants, id: \.self) { userId in
                        NavigationLink(destination: UserProfileView(userId: userId)) {
                            HStack {
                                Image(systemName: "person.crop.circle.fill")
                                    .foregroundColor(.gray)
                                Text(userId == plan.hostId ? "Host" : "Member") // Ideally fetch names
                                    .font(.caption)
                            }
                        }
                    }
                }
                
                // 3. Media Gallery
                Section(header: Text("SHARED MEDIA")) {
                    if galleryImages.isEmpty {
                        Text("No images shared yet.").foregroundColor(.gray)
                    } else {
                        LazyVGrid(columns: [GridItem(.adaptive(minimum: 80))], spacing: 10) {
                            ForEach(galleryImages) { msg in
                                if let data = Data(base64Encoded: msg.imageUrl ?? ""),
                                   let uiImage = UIImage(data: data) {
                                    Image(uiImage: uiImage)
                                        .resizable()
                                        .scaledToFill()
                                        .frame(width: 80, height: 80)
                                        .cornerRadius(8)
                                        .clipped()
                                }
                            }
                        }
                        .padding(.vertical)
                    }
                }
            }
            .navigationTitle("Group Info")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") { presentationMode.wrappedValue.dismiss() }
                }
            }
        }
    }
}
