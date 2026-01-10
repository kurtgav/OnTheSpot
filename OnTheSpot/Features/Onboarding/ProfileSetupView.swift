import SwiftUI
import FirebaseAuth

struct ProfileSetupView: View {
    @Binding var appState: AppState
    @StateObject private var dataManager = DataManager.shared
    
    // Wizard State
    @State private var step = 1
    
    // Form Inputs
    @State private var name: String = ""
    @State private var bio: String = ""
    @State private var location: String = ""
    @State private var inputImage: UIImage?
    @State private var selectedTags: Set<String> = []
    
    @State private var showingImagePicker = false
    @State private var isLoading = false
    
    // Available Vibes
    let vibes = ["☕️ Coffee Lover", "💻 Deep Work", "🗣️ Social", "📚 Student", "🚀 Founder", "🎨 Creative", "🌙 Night Owl", "🏃‍♂️ Gym Rat", "🍜 Foodie"]
    
    var body: some View {
        ZStack {
            Color(UIColor.systemBackground).ignoresSafeArea()
            
            VStack {
                // Progress Bar
                HStack(spacing: 4) {
                    Rectangle().fill(step >= 1 ? Color.green : Color.gray.opacity(0.2)).frame(height: 4).cornerRadius(2)
                    Rectangle().fill(step >= 2 ? Color.green : Color.gray.opacity(0.2)).frame(height: 4).cornerRadius(2)
                }
                .padding(.horizontal, 40)
                .padding(.top, 20)
                
                // Content Switcher
                if step == 1 {
                    StepOneView(name: $name, bio: $bio, location: $location, inputImage: $inputImage, showPicker: $showingImagePicker)
                        .transition(.move(edge: .leading))
                } else {
                    StepTwoView(selectedTags: $selectedTags, vibes: vibes)
                        .transition(.move(edge: .trailing))
                }
                
                Spacer()
                
                // Navigation Buttons
                HStack {
                    if step == 2 {
                        Button("Back") { withAnimation { step = 1 } }
                            .foregroundColor(.gray)
                    }
                    
                    Spacer()
                    
                    Button(action: nextStep) {
                        HStack {
                            if isLoading { ProgressView().padding(.trailing, 5) }
                            Text(step == 1 ? "Next" : "Finish").fontWeight(.bold)
                            Image(systemName: "arrow.right")
                        }
                        .foregroundColor(.white)
                        .padding(.vertical, 12)
                        .padding(.horizontal, 24)
                        .background(Color.green)
                        .cornerRadius(30)
                    }
                    .disabled(step == 1 && name.isEmpty) // Validation
                }
                .padding(30)
            }
        }
        .sheet(isPresented: $showingImagePicker) {
            ImagePicker(image: $inputImage)
        }
    }
    
    func nextStep() {
        if step == 1 {
            withAnimation { step = 2 }
        } else {
            completeSetup()
        }
    }
    
    func completeSetup() {
        isLoading = true
        
        if let img = inputImage { DataManager.shared.saveProfileImage(img) }
        
        CloudDataManager.shared.saveUserProfile(
            name: name,
            bio: bio,
            location: location,
            tags: Array(selectedTags)
        )
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            isLoading = false
            withAnimation { appState = .home }
        }
    }
}

// MARK: - Step 1: Identity
struct StepOneView: View {
    @Binding var name: String
    @Binding var bio: String
    @Binding var location: String
    @Binding var inputImage: UIImage?
    @Binding var showPicker: Bool
    
    var body: some View {
        VStack(spacing: 30) {
            VStack(spacing: 8) {
                Text("Who are you?").font(.title).fontWeight(.bold)
                Text("Your digital passport for the city.").foregroundColor(.gray)
            }
            .padding(.top, 20)
            
            Button(action: { showPicker = true }) {
                ZStack {
                    if let image = inputImage {
                        Image(uiImage: image).resizable().scaledToFill().frame(width: 120, height: 120).clipShape(Circle())
                    } else {
                        Circle().fill(Color.gray.opacity(0.1)).frame(width: 120, height: 120)
                        Image(systemName: "camera.fill").font(.title).foregroundColor(.gray)
                    }
                }
            }
            
            VStack(spacing: 16) {
                SetupTextField(icon: "person.fill", placeholder: "Name", text: $name)
                SetupTextField(icon: "mappin.and.ellipse", placeholder: "City / Campus", text: $location)
                SetupTextField(icon: "text.quote", placeholder: "Short Bio", text: $bio)
            }
            .padding(.horizontal, 30)
        }
    }
}

// MARK: - Step 2: Vibes (Tags)
struct StepTwoView: View {
    @Binding var selectedTags: Set<String>
    let vibes: [String]
    
    let columns = [GridItem(.adaptive(minimum: 100))]
    
    var body: some View {
        VStack(spacing: 20) {
            VStack(spacing: 8) {
                Text("What's your vibe?").font(.title).fontWeight(.bold)
                Text("Pick up to 3 tags.").foregroundColor(.gray)
            }
            .padding(.top, 20)
            
            ScrollView {
                LazyVGrid(columns: columns, spacing: 12) {
                    ForEach(vibes, id: \.self) { vibe in
                        Button(action: { toggleTag(vibe) }) {
                            Text(vibe)
                                .font(.caption).fontWeight(.bold)
                                .padding(.vertical, 12).frame(maxWidth: .infinity)
                                .background(selectedTags.contains(vibe) ? Color.green.opacity(0.2) : Color.gray.opacity(0.1))
                                .foregroundColor(selectedTags.contains(vibe) ? .green : .primary)
                                .cornerRadius(12)
                                .overlay(RoundedRectangle(cornerRadius: 12).stroke(selectedTags.contains(vibe) ? Color.green : Color.clear, lineWidth: 2))
                        }
                    }
                }
                .padding(.horizontal)
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
}

// Helper
struct SetupTextField: View {
    let icon: String; let placeholder: String; @Binding var text: String
    var body: some View {
        HStack {
            Image(systemName: icon).foregroundColor(.gray).frame(width: 20)
            TextField(placeholder, text: $text)
        }
        .padding().background(Color(UIColor.secondarySystemBackground)).cornerRadius(12)
    }
}
