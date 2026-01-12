import SwiftUI
import FirebaseAuth

struct ProfileSetupView: View {
    @Binding var appState: AppState
    @StateObject private var dataManager = DataManager.shared
    
    // Wizard State
    @State private var step = 1
    @State private var totalSteps = 4
    
    // DATA FIELDS
    @State private var inputImage: UIImage?
    @State private var showingImagePicker = false
    
    // Step 1: Basics + Birthday
    @State private var name: String = ""
    @State private var location: String = ""
    @State private var bio: String = "" // Basic bio for step 1
    @State private var birthday: Date = Date() // 🔥 NEW: Birthday State
    
    // Step 2: Work
    @State private var role: String = "" // e.g. Product Manager
    @State private var company: String = "" // e.g. Freelance
    
    // Step 3: Vibe
    @State private var selectedTags: Set<String> = []
    let vibes = ["☕️ Coffee", "💻 Tech", "🎨 Design", "🚀 Startups", "📷 Photo", "🧘‍♂️ Wellness", "📚 Books", "🎵 Music", "✈️ Travel"]
    
    // Step 4: Status
    @State private var status: String = "Open to Chat"
    let statuses = ["👋 Open to Chat", "💼 Deep Work", "🤝 Networking", "👀 Just Browsing"]
    
    @State private var isLoading = false
    
    var body: some View {
        ZStack {
            Color(UIColor.systemBackground).ignoresSafeArea()
            
            VStack {
                // Header (Progress)
                HStack {
                    ForEach(1...totalSteps, id: \.self) { i in
                        RoundedRectangle(cornerRadius: 2)
                            .fill(i <= step ? Color.green : Color.gray.opacity(0.2))
                            .frame(height: 4)
                    }
                }
                .padding(.horizontal, 30)
                .padding(.top, 20)
                
                Spacer()
                
                // --- STEP CONTENT SWITCHER ---
                Group {
                    if step == 1 {
                        // Pass birthday binding
                        IdentityStep(image: $inputImage, showPicker: $showingImagePicker, name: $name, location: $location, bio: $bio, birthday: $birthday)
                    }
                    else if step == 2 { WorkStep(role: $role, company: $company) }
                    else if step == 3 { VibeStep(tags: $selectedTags, options: vibes) }
                    else if step == 4 { StatusStep(status: $status, options: statuses) }
                }
                .transition(.asymmetric(insertion: .move(edge: .trailing), removal: .move(edge: .leading)))
                
                Spacer()
                
                // Footer Buttons
                HStack {
                    if step > 1 {
                        Button("Back") { withAnimation { step -= 1 } }.foregroundColor(.gray)
                    }
                    
                    Spacer()
                    
                    Button(action: nextStep) {
                        HStack {
                            if isLoading { ProgressView().padding(.trailing, 5) }
                            Text(step == totalSteps ? "Finish" : "Next").fontWeight(.bold)
                            Image(systemName: "arrow.right")
                        }
                        .foregroundColor(.white)
                        .padding(.vertical, 14).padding(.horizontal, 30)
                        .background(Color.green) // Nomad Green
                        .cornerRadius(30)
                        .shadow(color: Color.green.opacity(0.3), radius: 10, y: 5)
                    }
                    .disabled(step == 1 && name.isEmpty) // Basic validation
                }
                .padding(30)
            }
        }
        .sheet(isPresented: $showingImagePicker) { ImagePicker(image: $inputImage) }
    }
    
    func nextStep() {
        if step < totalSteps {
            withAnimation { step += 1 }
        } else {
            completeSetup()
        }
    }
    
    func completeSetup() {
        isLoading = true
        if let img = inputImage { DataManager.shared.saveProfileImage(img) }
        
        // Full Bio Construction
        let finalBio = bio.isEmpty ? "\(role) @ \(company)" : bio
        
        // THIS NOW MATCHES THE CLOUD MANAGER
        CloudDataManager.shared.saveUserProfile(
            name: name,
            bio: finalBio,
            location: location,
            role: role,
            company: company,
            status: status,
            birthday: birthday, // Matches new parameter
            tags: Array(selectedTags)
        )
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            isLoading = false
            withAnimation { appState = .home }
        }
    }
}

// MARK: - SUBVIEWS

struct IdentityStep: View {
    @Binding var image: UIImage?
    @Binding var showPicker: Bool
    @Binding var name: String
    @Binding var location: String
    @Binding var bio: String
    @Binding var birthday: Date // 🔥 Birthday Binding
    
    var body: some View {
        VStack(spacing: 30) {
            Text("Let's get started.").font(.title).fontWeight(.heavy)
            
            Button(action: { showPicker = true }) {
                if let img = image {
                    Image(uiImage: img).resizable().scaledToFill().frame(width: 120, height: 120).clipShape(Circle())
                } else {
                    Circle().fill(Color.gray.opacity(0.1)).frame(width: 120, height: 120)
                        .overlay(Image(systemName: "camera.fill").foregroundColor(.gray))
                }
            }
            VStack(spacing: 15) {
                WizardField(icon: "person", placeholder: "Full Name", text: $name)
                WizardField(icon: "mappin", placeholder: "Home Base (City)", text: $location)
                
                // 🔥 BIRTHDAY PICKER
                HStack {
                    Image(systemName: "calendar").foregroundColor(.gray).frame(width: 24)
                    DatePicker("Birthday", selection: $birthday, displayedComponents: .date)
                        .labelsHidden()
                        .accentColor(.green)
                    Spacer()
                }
                .padding()
                .background(Color(UIColor.secondarySystemBackground))
                .cornerRadius(12)
                
                WizardField(icon: "text.quote", placeholder: "Short Bio", text: $bio)
            }
        }
        .padding(.horizontal)
    }
}

struct WorkStep: View {
    @Binding var role: String; @Binding var company: String
    var body: some View {
        VStack(spacing: 30) {
            Text("What do you do?").font(.title).fontWeight(.heavy)
            Text("Help others connect with you professionally.").foregroundColor(.gray)
            
            VStack(spacing: 15) {
                WizardField(icon: "briefcase", placeholder: "Role (e.g. Designer)", text: $role)
                WizardField(icon: "building.2", placeholder: "Company / Project", text: $company)
            }
        }
        .padding(.horizontal)
    }
}

struct VibeStep: View {
    @Binding var tags: Set<String>; let options: [String]
    var body: some View {
        VStack(spacing: 20) {
            Text("Pick your interests.").font(.title).fontWeight(.heavy)
            LazyVGrid(columns: [GridItem(.adaptive(minimum: 100))], spacing: 12) {
                ForEach(options, id: \.self) { tag in
                    Button(action: {
                        if tags.contains(tag) { tags.remove(tag) } else { if tags.count < 5 { tags.insert(tag) } }
                    }) {
                        Text(tag).font(.caption).bold().padding(.vertical, 12).frame(maxWidth: .infinity)
                            .background(tags.contains(tag) ? Color.green.opacity(0.2) : Color.gray.opacity(0.1))
                            .foregroundColor(tags.contains(tag) ? .green : .primary)
                            .cornerRadius(12)
                            .overlay(RoundedRectangle(cornerRadius: 12).stroke(tags.contains(tag) ? Color.green : Color.clear, lineWidth: 2))
                    }
                }
            }
        }
        .padding(.horizontal)
    }
}

struct StatusStep: View {
    @Binding var status: String; let options: [String]
    var body: some View {
        VStack(spacing: 20) {
            Text("What's your intent?").font(.title).fontWeight(.heavy)
            ForEach(options, id: \.self) { opt in
                Button(action: { status = opt }) {
                    HStack {
                        Text(opt).fontWeight(.medium)
                        Spacer()
                        if status == opt { Image(systemName: "checkmark.circle.fill").foregroundColor(.green) }
                    }
                    .padding()
                    .background(status == opt ? Color.green.opacity(0.1) : Color.gray.opacity(0.05))
                    .cornerRadius(12)
                    .foregroundColor(status == opt ? .green : .primary)
                    .overlay(RoundedRectangle(cornerRadius: 12).stroke(status == opt ? Color.green : Color.clear, lineWidth: 2))
                }
            }
        }
        .padding(.horizontal)
    }
}

// Helper Field
struct WizardField: View {
    let icon: String; let placeholder: String; @Binding var text: String
    var body: some View {
        HStack {
            Image(systemName: icon).foregroundColor(.gray).frame(width: 24)
            TextField(placeholder, text: $text)
        }
        .padding().background(Color(UIColor.secondarySystemBackground)).cornerRadius(12)
    }
}
