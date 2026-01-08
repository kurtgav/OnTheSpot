import SwiftUI

struct AddSpotView: View {
    @Environment(\.presentationMode) var presentationMode
    var onSave: (String, String) -> Void
    
    @State private var name = ""
    @State private var category = "Study Spot"
    
    let categories = ["Study Spot", "Fast Food", "Canteen", "Cafe", "Terminal", "Parking", "Facility", "Laundry"]

    var body: some View {
        NavigationView {
            ZStack {
                Color.appBackground.ignoresSafeArea()
                
                Form {
                    Section(header: Text("New Spot Details").foregroundColor(.primaryAccent)) {
                        TextField("Spot Name (e.g. 7-Eleven)", text: $name)
                            .foregroundColor(.white) // Visible text
                        
                        Picker("Category", selection: $category) {
                            ForEach(categories, id: \.self) { cat in
                                Text(cat).tag(cat)
                            }
                        }
                        .pickerStyle(MenuPickerStyle())
                    }
                    .listRowBackground(Color.white.opacity(0.05))
                }
                .onAppear {
                    UITableView.appearance().backgroundColor = .clear
                }
            }
            .navigationTitle("Add New Spot")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") { presentationMode.wrappedValue.dismiss() }
                        .foregroundColor(.white)
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        onSave(name, category)
                        presentationMode.wrappedValue.dismiss()
                    }
                    .disabled(name.isEmpty)
                    .foregroundColor(name.isEmpty ? .secondaryText : .primaryAccent)
                }
            }
        }
        .preferredColorScheme(.dark)
    }
}
