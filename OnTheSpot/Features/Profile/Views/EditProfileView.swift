import SwiftUI

struct EditProfileView: View {
    @ObservedObject var dataManager = DataManager.shared
    @Environment(\.presentationMode) var presentationMode
    
    // Image Picker State
    @State private var showingImagePicker = false
    @State private var inputImage: UIImage?
    
    // Tags State
    @State private var selectedTags: Set<String> = []
    
    // Available Vibes (Same as Onboarding)
    let vibes = ["☕️ Coffee Lover", "💻 Deep Work", "🗣️ Social", "📚 Student", "🚀 Founder", "🎨 Creative", "🌙 Night Owl", "🏃‍♂️ Gym Rat", "🍜 Foodie"]
    
    var body: some View {
        NavigationView {
            ZStack {
                Color(UIColor.systemBackground).ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 30) {
                        // 1. Photo Edit
                        Button(action: { showingImagePicker = true }) {
                            VStack {
                                ZStack {
                                    if let image = inputImage ?? dataManager.profileImage {
                                        Image(uiImage: image)
                                            .resizable().scaledToFill()
                                            .frame(width: 120, height: 120).clipShape(Circle())
                                    } else {
                                        Circle().fill(Color.green.opacity(0.2)).frame(width: 120, height: 120)
                                        Image(systemName: "person.crop.circle.badge.plus")
                                            .font(.system(size: 60)).foregroundColor(.green)
                                    }
                                }
                                Text("Change Photo").font(.caption).fontWeight(.bold).foregroundColor(.gray)
                            }
                        }
                        .padding(.top, 20)
                        
                        // 2. Text Fields
                        VStack(spacing: 20) {
                            CustomInputRow(icon: "person.fill", title: "Name", text: $dataManager.userName)
                            CustomInputRow(icon: "text.quote", title: "Bio", text: $dataManager.userBio)
                            CustomInputRow(icon: "mappin.and.ellipse", title: "Location", text: $dataManager.userLocation)
                        }
                        .padding(.horizontal)
                        
                        // 3. Vibe Tags Selector (NEW)
                        VStack(alignment: .leading, spacing: 15) {
                            Text("MY VIBE (Select up to 3)")
                                .font(.caption).fontWeight(.bold).foregroundColor(.gray)
                                .padding(.horizontal)
                            
                            LazyVGrid(columns: [GridItem(.adaptive(minimum: 100))], spacing: 10) {
                                ForEach(vibes, id: \.self) { vibe in
                                    Button(action: { toggleTag(vibe) }) {
                                        Text(vibe)
                                            .font(.caption).fontWeight(.bold)
                                            .padding(.vertical, 10).frame(maxWidth: .infinity)
                                            .background(selectedTags.contains(vibe) ? Color.green.opacity(0.2) : Color(UIColor.secondarySystemBackground))
                                            .foregroundColor(selectedTags.contains(vibe) ? .green : .primary)
                                            .cornerRadius(12)
                                            .overlay(
                                                RoundedRectangle(cornerRadius: 12)
                                                    .stroke(selectedTags.contains(vibe) ? Color.green : Color.clear, lineWidth: 2)
                                            )
                                    }
                                }
                            }
                            .padding(.horizontal)
                        }
                        
                        Spacer(minLength: 50)
                    }
                }
            }
            .navigationTitle("Edit Profile")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") { saveChanges() }
                        .fontWeight(.bold).foregroundColor(.green)
                }
            }
            .sheet(isPresented: $showingImagePicker) {
                ImagePicker(image: $inputImage)
            }
            .onAppear {
                // Load existing tags
                selectedTags = Set(dataManager.userTags)
            }
        }
    }
    
    func toggleTag(_ tag: String) {
        if selectedTags.contains(tag) {
            selectedTags.remove(tag)
        } else {
            if selectedTags.count < 3 { selectedTags.insert(tag) }
        }
    }
    
    func saveChanges() {
        // Save Image Locally
        if let img = inputImage {
            dataManager.saveProfileImage(img)
        }
        
        // Save Everything to Cloud
        CloudDataManager.shared.saveUserProfile(
            name: dataManager.userName,
            bio: dataManager.userBio,
            location: dataManager.userLocation,
            tags: Array(selectedTags) // Save the new tags
        )
        
        presentationMode.wrappedValue.dismiss()
    }
}

// Keep CustomInputRow (Reuse existing)
struct CustomInputRow: View {
    let icon: String; let title: String; @Binding var text: String
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title.uppercased()).font(.caption2).fontWeight(.bold).foregroundColor(.gray)
            HStack {
                Image(systemName: icon).foregroundColor(.green).frame(width: 20)
                TextField(title, text: $text).foregroundColor(.primary)
            }
            .padding().background(Color(UIColor.secondarySystemBackground)).cornerRadius(12)
        }
    }
}
