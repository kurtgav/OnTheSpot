import SwiftUI

struct GroupChatView: View {
    let plan: Plan
    @State private var messageText = ""
    @ObservedObject var cloudManager = CloudDataManager.shared
    @Environment(\.presentationMode) var presentationMode
    
    // Sheets
    @State private var showChatInfo = false
    @State private var showImagePicker = false
    @State private var inputImage: UIImage?
    
    var body: some View {
        ZStack {
            Color(UIColor.systemGroupedBackground).ignoresSafeArea()
            
            VStack(spacing: 0) {
                // 1. Message List
                ScrollView {
                    ScrollViewReader { proxy in
                        LazyVStack(spacing: 8) {
                            Color.clear.frame(height: 10)
                            ForEach(cloudManager.currentChatMessages) { msg in
                                ChatBubble(message: msg).id(msg.id)
                            }
                        }
                        .padding(.horizontal, 12).padding(.bottom, 20)
                        .onChange(of: cloudManager.currentChatMessages.count) { _ in
                            if let last = cloudManager.currentChatMessages.last { withAnimation { proxy.scrollTo(last.id, anchor: .bottom) } }
                        }
                    }
                }
                .onTapGesture { UIApplication.shared.endEditing(true) }
                
                // 2. Input Bar
                HStack(spacing: 12) {
                    Button(action: { showImagePicker = true }) {
                        Image(systemName: "plus.circle.fill").font(.system(size: 28)).foregroundColor(.gray)
                    }
                    TextField("Message...", text: $messageText)
                        .padding(10).padding(.horizontal, 4)
                        .background(Color(UIColor.systemBackground)).cornerRadius(20)
                        .overlay(RoundedRectangle(cornerRadius: 20).stroke(Color.gray.opacity(0.2), lineWidth: 1))
                    
                    if !messageText.isEmpty {
                        Button(action: sendMessage) {
                            Image(systemName: "arrow.up.circle.fill").font(.system(size: 32)).foregroundColor(.blue)
                        }.transition(.scale)
                    }
                }
                .padding(.horizontal).padding(.vertical, 10).background(.ultraThinMaterial)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        // 🔥 CRITICAL: HIDE SYSTEM BUTTON
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: { presentationMode.wrappedValue.dismiss() }) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.primary)
                }
            }
            // CENTER: Title
            ToolbarItem(placement: .principal) {
                VStack(spacing: 0) {
                    Text(plan.title).font(.headline).foregroundColor(.primary)
                    Text("\(plan.participants.count) members").font(.caption).foregroundColor(.gray)
                }
            }
            
            // RIGHT: Info Icon
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: { showChatInfo = true }) {
                    Image(systemName: "info.circle")
                        .font(.system(size: 22)) // Matched weight with back button
                        .foregroundColor(.blue)
                }
            }
        }
        .onAppear { if let planId = plan.id { CloudDataManager.shared.listenToChat(planId: planId) } }
        .sheet(isPresented: $showChatInfo) { ChatInfoView(plan: plan) }
        .sheet(isPresented: $showImagePicker) { ImagePicker(image: $inputImage) }
        .onChange(of: inputImage) { newImage in
            if let img = newImage, let planId = plan.id { CloudDataManager.shared.sendImageMessage(planId: planId, image: img) }
        }
    }
    
    func sendMessage() {
        guard !messageText.isEmpty, let planId = plan.id else { return }
        CloudDataManager.shared.sendMessage(planId: planId, text: messageText)
        messageText = ""
    }
}

// Subcomponents (ChatBubble)
struct ChatBubble: View {
    let message: ChatMessage
    var body: some View {
        HStack(alignment: .bottom, spacing: 8) {
            if message.isMe { Spacer() } else {
                Circle().fill(Color.gray.opacity(0.3)).frame(width: 28, height: 28)
                    .overlay(Text(message.senderName.prefix(1)).font(.caption2).bold().foregroundColor(.gray))
            }
            VStack(alignment: message.isMe ? .trailing : .leading, spacing: 2) {
                if !message.isMe { Text(message.senderName).font(.caption2).foregroundColor(.gray).padding(.leading, 4) }
                if let base64 = message.imageUrl, let data = Data(base64Encoded: base64), let uiImage = UIImage(data: data) {
                    Image(uiImage: uiImage).resizable().scaledToFill().frame(width: 200, height: 150).cornerRadius(16).clipped()
                } else {
                    Text(message.text).padding(.horizontal, 14).padding(.vertical, 8)
                        .background(message.isMe ? Color.blue : Color(UIColor.systemBackground))
                        .foregroundColor(message.isMe ? .white : .primary).cornerRadius(18)
                }
            }
            if !message.isMe { Spacer() }
        }
    }
}

extension UIApplication {
    func endEditing(_ force: Bool) { self.windows.filter{$0.isKeyWindow}.first?.endEditing(force) }
}
