import SwiftUI
import AVFoundation

struct CameraView: UIViewRepresentable {
    @Binding var isShown: Bool
    @Binding var image: UIImage?
    
    class Coordinator: NSObject, AVCapturePhotoCaptureDelegate {
        var parent: CameraView
        var captureSession: AVCaptureSession?
        var photoOutput: AVCapturePhotoOutput?
        
        init(parent: CameraView) {
            self.parent = parent
        }
        
        func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
            if let imageData = photo.fileDataRepresentation(), let image = UIImage(data: imageData) {
                parent.image = image
                parent.isShown = false
            }
        }
        
        func setupCaptureSession() {
            let captureSession = AVCaptureSession()
            captureSession.sessionPreset = .photo
            
            guard let backCamera = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back),
                  let input = try? AVCaptureDeviceInput(device: backCamera) else {
                print("Unable to access camera")
                return
            }
            
            if captureSession.canAddInput(input) {
                captureSession.addInput(input)
            }
            
            let photoOutput = AVCapturePhotoOutput()
            if captureSession.canAddOutput(photoOutput) {
                captureSession.addOutput(photoOutput)
                self.photoOutput = photoOutput
            }
            
            self.captureSession = captureSession
        }
        
        func takePhoto() {
            guard let photoOutput = photoOutput else { return }
            
            let settings = AVCapturePhotoSettings()
            photoOutput.capturePhoto(with: settings, delegate: self)
        }
    }
    
    func makeCoordinator() -> Coordinator {
        return Coordinator(parent: self)
    }
    
    func makeUIView(context: Context) -> UIView {
        let view = UIView(frame: UIScreen.main.bounds)
        
        context.coordinator.setupCaptureSession()
        
        guard let captureSession = context.coordinator.captureSession else {
            return view
        }
        
        let previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer.frame = view.bounds
        previewLayer.videoGravity = .resizeAspectFill
        view.layer.addSublayer(previewLayer)
        
        DispatchQueue.global(qos: .userInitiated).async {
            captureSession.startRunning()
        }
        
        return view
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {}
    
    static func dismantleUIView(_ uiView: UIView, coordinator: Coordinator) {
        coordinator.captureSession?.stopRunning()
    }
}