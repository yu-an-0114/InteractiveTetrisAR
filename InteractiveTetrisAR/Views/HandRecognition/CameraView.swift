//
//  CameraView.swift
//  InteractiveTetrisAR
//
//  Created by [Your Name] on [Date].
//

import SwiftUI
import AVFoundation
import Vision

// MARK: - CameraView
struct CameraView: UIViewControllerRepresentable {
    class Coordinator: NSObject, AVCaptureVideoDataOutputSampleBufferDelegate {
        var parent: CameraView
        private let handPoseRequest = VNDetectHumanHandPoseRequest()
        
        init(_ parent: CameraView) {
            self.parent = parent
            handPoseRequest.maximumHandCount = 1
        }
        
        func rotatePoints90Degrees(_ points: [VNHumanHandPoseObservation.JointName: CGPoint]) -> [VNHumanHandPoseObservation.JointName: CGPoint] {
            points.mapValues { point in
                CGPoint(x: point.y, y: 1 - point.x)
            }
        }
        
        func captureOutput(_ output: AVCaptureOutput,
                           didOutput sampleBuffer: CMSampleBuffer,
                           from connection: AVCaptureConnection) {
            guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }
            let handler = VNImageRequestHandler(cvPixelBuffer: pixelBuffer, orientation: .up)
            do {
                try handler.perform([handPoseRequest])
                if let observation = handPoseRequest.results?.first {
                    let recognizedPoints = try observation.recognizedPoints(.all)
                    let imagePoints = recognizedPoints.compactMapValues { $0.confidence > 0.7 ? $0.location : nil }
                    let rotatedPoints = rotatePoints90Degrees(imagePoints)
                    DispatchQueue.main.async {
                        self.parent.onPoints(rotatedPoints)
                    }
                }
            } catch {
                print("Vision error:", error)
            }
        }
    }
    
    var onPoints: ([VNHumanHandPoseObservation.JointName: CGPoint]) -> Void
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    func makeUIViewController(context: Context) -> UIViewController {
        let vc = UIViewController()
        let session = AVCaptureSession()
        session.beginConfiguration()
        guard let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back),
              let input = try? AVCaptureDeviceInput(device: device) else { return vc }
        session.addInput(input)
        let output = AVCaptureVideoDataOutput()
        output.videoSettings = [kCVPixelBufferPixelFormatTypeKey as String: kCVPixelFormatType_32BGRA]
        output.setSampleBufferDelegate(context.coordinator, queue: DispatchQueue(label: "videoQueue"))
        session.addOutput(output)
        if session.canSetSessionPreset(.high) {
            session.sessionPreset = .high
        }
        session.commitConfiguration()
        session.startRunning()
        let previewLayer = AVCaptureVideoPreviewLayer(session: session)
        previewLayer.videoGravity = .resizeAspectFill
        previewLayer.connection?.videoOrientation = .portrait
        previewLayer.frame = UIScreen.main.bounds
        vc.view.layer.addSublayer(previewLayer)
        return vc
    }
    
    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {}
}
