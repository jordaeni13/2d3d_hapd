//
//  CameraView.swift
//  demoapp
//
//  Created by Iron Bae on 2023/05/06.
//

//
//  CameraView.swift
//  SwiftUI_JJaseCam
//
//  Created by 이영빈 on 2021/09/22.
//

import SwiftUI
import AVFoundation
import Combine


class Camera: NSObject, ObservableObject {
    var session = AVCaptureSession()
        var videoDeviceInput: AVCaptureDeviceInput!
        let output = AVCapturePhotoOutput()
        var photoData = Data(count: 0)
        
        @Published var recentImage: UIImage?
        @Published var capturedPhotos: [UIImage] = []
        
    func setUpCamera() {
            if let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back) {
                do {
                    videoDeviceInput = try AVCaptureDeviceInput(device: device)
                    if session.canAddInput(videoDeviceInput) {
                        session.addInput(videoDeviceInput)
                    }
                    
                    if session.canAddOutput(output) {
                        session.addOutput(output)
                        
                        // Set the desired photo aspect ratio to 4:3
                        let desiredWidth: Int32 = 1920
                        let desiredHeight: Int32 = 1440
                        var selectedFormat: AVCaptureDevice.Format?
                        
                        for format in device.formats {
                            let formatDescription = format.formatDescription
                            let dimensions = CMVideoFormatDescriptionGetDimensions(formatDescription)
                            if dimensions.width == desiredWidth && dimensions.height == desiredHeight {
                                selectedFormat = format
                                break
                            }
                        }
                        
                        if let format = selectedFormat {
                            try device.lockForConfiguration()
                            device.activeFormat = format
                            device.unlockForConfiguration()
                        }
                    }
                    
                    session.startRunning()
                } catch {
                    print(error)
                }
            }
        }
    
    func requestAndCheckPermissions() {
        // 카메라 권한 상태 확인
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .notDetermined:
            // 권한 요청
            AVCaptureDevice.requestAccess(for: .video) { [weak self] authStatus in
                if authStatus {
                    DispatchQueue.main.async {
                        self?.setUpCamera()
                    }
                }
            }
        case .restricted:
            break
        case .authorized:
            // 이미 권한 받은 경우 셋업
            setUpCamera()
        default:
            // 거절했을 경우
            print("Permession declined")
        }
    }
    
    func capturePhoto() {
        // 사진 옵션 세팅
        let photoSettings = AVCapturePhotoSettings()
        
        self.output.capturePhoto(with: photoSettings, delegate: self)
        
        print("[Camera]: Photo's taken")
    }
    
    func savePhoto(_ imageData: Data) {
        guard let image = UIImage(data: imageData) else { return }
        

        UIImageWriteToSavedPhotosAlbum(getMidasImage(on: image), nil, nil, nil)
        UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
        
        
        print(capturedPhotos)
        // 사진 저장하기
        print("[Camera]: Photo's saved")
    }
}

extension Camera: AVCapturePhotoCaptureDelegate {
    func photoOutput(_ output: AVCapturePhotoOutput, willBeginCaptureFor resolvedSettings: AVCaptureResolvedPhotoSettings) {
    }
    
    func photoOutput(_ output: AVCapturePhotoOutput, willCapturePhotoFor resolvedSettings: AVCaptureResolvedPhotoSettings) {

    }
    
    func photoOutput(_ output: AVCapturePhotoOutput, didCapturePhotoFor resolvedSettings: AVCaptureResolvedPhotoSettings) {
    }
    
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        guard let imageData = photo.fileDataRepresentation() else { return }
        self.recentImage = UIImage(data: imageData)
        self.savePhoto(imageData)
        
        
        print("[CameraModel]: Capture routine's done")
    }
}

struct CameraView: View {
    @ObservedObject var viewModel = CameraViewModel()
    


    var body: some View {
        ZStack {
            viewModel.cameraPreview
                .ignoresSafeArea()
                .onAppear {
                    viewModel.configure()
                }
            
            if let previewImage = viewModel.recentImage {
                Image(uiImage: previewImage)
                    .resizable()
                    .scaledToFill()
                    .edgesIgnoringSafeArea(.all)
            }
            
            VStack {
                Spacer()
                
                HStack {
                    Spacer()
                    
                    // 사진찍기 버튼
                    Button(action: { viewModel.capturePhoto() }) {
                        Circle()
                            .stroke(lineWidth: 5)
                            .frame(width: 75, height: 75)
                            .padding()
                    }
                    
                    Spacer()
                    
                    // 전후면 카메라 교체
                    
                }
            }
            .foregroundColor(.white)
        }
    }

}


struct CameraPreviewView: UIViewRepresentable {
    class VideoPreviewView: UIView {
        override class var layerClass: AnyClass {
             AVCaptureVideoPreviewLayer.self
        }
        
        var videoPreviewLayer: AVCaptureVideoPreviewLayer {
            return layer as! AVCaptureVideoPreviewLayer
        }
    }
    
    let session: AVCaptureSession
   
    func makeUIView(context: Context) -> VideoPreviewView {
        let view = VideoPreviewView()
        
        view.videoPreviewLayer.session = session
        view.backgroundColor = .black
        view.videoPreviewLayer.videoGravity = .resizeAspectFill
        view.videoPreviewLayer.cornerRadius = 0
        view.videoPreviewLayer.connection?.videoOrientation = .portrait

        return view
    }
    
    func updateUIView(_ uiView: VideoPreviewView, context: Context) {
        
    }
}

class CameraViewModel: ObservableObject {
    private let model: Camera
    private let session: AVCaptureSession
    private var subscriptions = Set<AnyCancellable>()
    let cameraPreview: AnyView

    @Published var recentImage: UIImage?
    @Published var isFlashOn = false
    @Published var isSilentModeOn = false
    
    // 초기 세팅
    func configure() {
        model.requestAndCheckPermissions()
    }
    
   
    // 사진 촬영
    func capturePhoto() {
        model.capturePhoto()
        print("[CameraViewModel]: Photo captured!")
    }
    
    // 전후면 카메라 스위칭
   
    
    init() {
        model = Camera()
        session = model.session
        cameraPreview = AnyView(CameraPreviewView(session: session))
        
        model.$recentImage.sink { [weak self] (photo) in
            guard let pic = photo else { return }
            self?.recentImage = pic
        }
        .store(in: &self.subscriptions)
    }
}



