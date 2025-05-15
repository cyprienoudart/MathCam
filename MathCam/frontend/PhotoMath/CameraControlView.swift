import SwiftUI

struct CameraControlView: View {
    @Binding var isShowingCamera: Bool
    @Binding var capturedImage: UIImage?
    var coordinator: CameraView.Coordinator
    
    var body: some View {
        VStack {
            Spacer()
            
            HStack {
                Spacer()
                
                Button(action: {
                    coordinator.takePhoto()
                }) {
                    Circle()
                        .fill(Color.white)
                        .frame(width: 70, height: 70)
                        .overlay(
                            Circle()
                                .stroke(Color.black.opacity(0.8), lineWidth: 2)
                                .frame(width: 65, height: 65)
                        )
                }
                
                Spacer()
            }
            .padding(.bottom, 30)
        }
    }
}