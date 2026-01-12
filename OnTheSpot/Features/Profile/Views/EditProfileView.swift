import SwiftUI

struct EditProfileView: View {
    @ObservedObject var dataManager = DataManager.shared
    @Environment(\.presentationMode) var presentationMode
    
    // Image Picker State
    @State private var showingImagePicker = false
    @State private var inputImage: UIImage?
    
    // Tags State
    @State private var selectedTags: Set<String> = []
    
    // Available Vibes
    let vibes = ["☕️ Coffee Lover", "💻 Deep Work", "🗣️ Social", "📚 Student", "🚀 Founder", "🎨 Creative", "🌙 Night Owl", "🏃‍♂️ Gym Rat", "🍜 Foodie"]
    
    var body: some View {
        NavigationView {
            ZStack {
                Color(UIColor.systemGroupedBackground).ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        
                        // 1. PHOTO SECTION
                        Button(action: { showingImagePicker = true }) {
                            VStack {
                                ZStack {
                                    if let image = inputImage ?? dataManager.profileImage {
                                        Image(uiImage: image)
                                            .resizable().scaledToFill()
                                            .frame(width: 100, height: 100).clipShape(Circle())
                                    } else {
                                        Circle().fill(Color.gray.opacity(0.1)).frame(width: 100, height: 100)
                                        Image(systemName: "camera.fill").foregroundColor(.gray)
                                    }
                                    
                                    // Edit Badge
                                    Circle().fill(Color.blue).frame(width: 28, height: 28)
                                        .overlay(Image(systemName: "pencil").foregroundColor(.white).font(.caption))
                                        .offset(x: 35, y: 35)
                                }
                                Text("Edit Photo").font(.caption).foregroundColor(.blue)
                            }
                        }
                        .padding(.top, 20)
                        
                        // 2. IDENTITY CARD
                        VStack(spacing: 0) {
                            EditRow(icon: "person.fill", title: "Name", text: $dataManager.userName)
                            Divider()
                            EditRow(icon: "text.quote", title: "Bio", text: $dataManager.userBio)
                            Divider()
                            EditRow(icon: "mappin.and.ellipse", title: "Location", text: $dataManager.userLocation)
                        }
                        .background(Color(UIColor.secondarySystemBackground))
                        .cornerRadius(12)
                        .padding(.horizontal)
                        
                        // 3. WORK CARD
                        VStack(spacing: 0) {
                            EditRow(icon: "briefcase.fill", title: "Role", text: $dataManager.userRole)
                            Divider()
                            EditRow(icon: "building.2.fill", title: "Company", text: $dataManager.userCompany)
                        }
                        .background(Color(UIColor.secondarySystemBackground))
                        .cornerRadius(12)
                        .padding(.horizontal)
                        
                        // 4. VIBE SELECTOR
                        VStack(alignment: .leading, spacing: 12) {
                            Text("MY VIBE (Select 3)")
                                .font(.caption).fontWeight(.bold).foregroundColor(.gray)
                                .padding(.leading, 4)
                            
                            LazyVGrid(columns: [GridItem(.adaptive(minimum: 100))], spacing: 10) {
                                ForEach(vibes, id: \.self) { vibe in
                                    Button(action: { toggleTag(vibe) }) {
                                        Text(vibe)
                                            .font(.caption).fontWeight(.bold)
                                            .padding(.vertical, 8).frame(maxWidth: .infinity)
                                            .background(selectedTags.contains(vibe) ? Color.blue.opacity(0.1) : Color(UIColor.secondarySystemBackground))
                                            .foregroundColor(selectedTags.contains(vibe) ? .blue : .primary)
                                            .cornerRadius(8)
                                            .overlay(RoundedRectangle(cornerRadius: 8).stroke(selectedTags.contains(vibe) ? Color.blue : Color.clear, lineWidth: 1))
                                    }
                                }
                            }
                        }
                        .padding(.horizontal)
                        
                        // 5. Birthday (Read Only or Edit)
                        // Optional: Add DatePicker here if you want them to edit it
                        
                        Spacer(minLength: 50)
                    }
                    .padding(.bottom, 100)
                }
                
                // FLOATING SAVE BUTTON
                VStack {
                    Spacer()
                    Button(action: saveChanges) {
                        Text("Save Changes")
                            .font(.headline).fontWeight(.bold)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .cornerRadius(16)
                            .shadow(color: .blue.opacity(0.3), radius: 10, y: 5)
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 20)
                }
            }
            .navigationTitle("Edit Profile")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") { presentationMode.wrappedValue.dismiss() }
                }
            }
            .sheet(isPresented: $showingImagePicker) { ImagePicker(image: $inputImage) }
            .onAppear { selectedTags = Set(dataManager.userTags) }
        }
    }
    
    func toggleTag(_ tag: String) {
        if selectedTags.contains(tag) { selectedTags.remove(tag) }
        else { if selectedTags.count < 3 { selectedTags.insert(tag) } }
    }
    
    func saveChanges() {
        if let img = inputImage { dataManager.saveProfileImage(img) }
        CloudDataManager.shared.saveUserProfile(
            name: dataManager.userName,
            bio: dataManager.userBio,
            location: dataManager.userLocation,
            role: dataManager.userRole,
            company: dataManager.userCompany,
            status: dataManager.userStatus,
            birthday: dataManager.userBirthday,
            tags: Array(selectedTags)
        )
        presentationMode.wrappedValue.dismiss()
    }
}

// Clean Row Component
struct EditRow: View {
    let icon: String; let title: String; @Binding var text: String
    var body: some View {
        HStack {
            Image(systemName: icon).foregroundColor(.gray).frame(width: 24)
            TextField(title, text: $text)
        }
        .padding()
    }
}
