import SwiftUI

struct ProfileView: View {
    var body: some View {
        NavigationView {
            ZStack {
                Color.appBackground.ignoresSafeArea()
                
                VStack {
                    Text("User Profile")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.primaryText)
                    
                    Text("Total Contributions: 15")
                        .foregroundColor(.secondaryText)
                        .padding(.top, 4)

                    Spacer()
                    
                    // Premium Subscription CTA
                    VStack {
                        Text("Unlock 'Notify Me'")
                            .font(.headline)
                            .foregroundColor(.appBackground)
                        Text("49 PHP / month")
                            .font(.subheadline)
                            .foregroundColor(.appBackground.opacity(0.8))
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.primaryAccent)
                    .cornerRadius(12)
                    .padding()
                }
                .padding()
            }
            .navigationTitle("Profile")
            .navigationBarHidden(true)
        }
        .preferredColorScheme(.dark)
    }
}
