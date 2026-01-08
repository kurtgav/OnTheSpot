import SwiftUI

struct EditProfileView: View {
    @ObservedObject var dataManager = DataManager.shared
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.appBackground.ignoresSafeArea()
                
                // Animated Glow
                AtmosphereBackground(color: .blue).opacity(0.2)
                
                VStack(spacing: 30) {
                    // 1. Photo Edit (Simulation)
                    VStack {
                        ZStack {
                            Circle()
                                .fill(Color.primaryAccent.opacity(0.2))
                                .frame(width: 120, height: 120)
                            
                            Image(systemName: "person.crop.circle.badge.plus")
                                .font(.system(size: 60))
                                .foregroundColor(.primaryAccent)
                        }
                        Text("Change Photo")
                            .font(.caption)
                            .fontWeight(.bold)
                            .foregroundColor(.secondaryText)
                    }
                    .padding(.top, 20)
                    
                    // 2. Form Fields
                    VStack(spacing: 20) {
                        CustomInputRow(icon: "person.fill", title: "Name", text: $dataManager.userName)
                        CustomInputRow(icon: "text.quote", title: "Bio", text: $dataManager.userBio)
                        CustomInputRow(icon: "mappin.and.ellipse", title: "Location", text: $dataManager.userLocation)
                    }
                    .padding(.horizontal)
                    
                    Spacer()
                }
            }
            .navigationTitle("Edit Profile")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        presentationMode.wrappedValue.dismiss()
                    }
                    .fontWeight(.bold)
                    .foregroundColor(.primaryAccent)
                }
            }
        }
    }
}

struct CustomInputRow: View {
    let icon: String
    let title: String
    @Binding var text: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title.uppercased())
                .font(.caption2)
                .fontWeight(.bold)
                .foregroundColor(.secondaryText)
            
            HStack {
                Image(systemName: icon)
                    .foregroundColor(.primaryAccent)
                    .frame(width: 20)
                
                TextField(title, text: $text)
                    .foregroundColor(.primaryText)
            }
            .padding()
            .background(Color.primaryText.opacity(0.05))
            .cornerRadius(12)
            .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.primaryText.opacity(0.1), lineWidth: 1))
        }
    }
}
