import CoreHaptics
import PhotosUI
import SwiftUI


struct EmptyView: View {
    var body: some View {
        VStack{}
    }
    
}

struct ContentView: View {
    @Environment(\.colorScheme) var colorScheme
    @GestureState private var dragLocation: CGPoint = .zero
    @State private var colorRGB: (red: CGFloat, green: CGFloat, blue: CGFloat) = (0, 0, 0)
    let hapticManager = HapticManager()
    
    @State private var selectedItem: PhotosPickerItem? = nil
    @State private var selectedImageData: Data? = nil
    @State private var showSelectPhotoText = true
    
    @State private var feedback = UINotificationFeedbackGenerator()

    
    var body: some View {
        NavigationView {
            VStack {
                ZStack {
                    if let selectedImageData,
                       let uiImage = UIImage(data: selectedImageData)
                    {
                        GeometryReader { geometry in
                            Image(uiImage: uiImage)
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(maxWidth: .infinity, maxHeight: .infinity)
                                .alignmentGuide(HorizontalAlignment.center) { _ in
                                    geometry.frame(in: .global).midX
                                }
                                .alignmentGuide(VerticalAlignment.center) { _ in
                                    geometry.frame(in: .global).midY
                                }
                                .gesture(DragGesture()
                                    .updating($dragLocation) { value, state, _ in
                                        state = value.location
                                        giveFeedback(state: state, imageFrame: geometry.frame(in: .global))
                                    }
                                )
                        }
                    }
                    
                    VStack {
                        Spacer()
                        
                        HStack {
                            Button(action: {
                                // Perform action when the button is tapped
                            }) {
                                PhotosPicker(
                                    selection: $selectedItem,
                                    matching: .images,
                                    photoLibrary: .shared()
                                ) {
                                    if colorScheme == .dark {
                                        Image(systemName: "photo")
                                            .font(.title)
                                            .foregroundColor(.white)
                                    
                                    } else {
                                        Image(systemName: "photo")
                                            .font(.title)
                                            .foregroundColor(.black)
                                    }
                                }
                                .onChange(of: selectedItem) { newItem in
                                    Task {
                                        // Retrieve selected asset in the form of Data
                                        if let data = try? await newItem?.loadTransferable(type: Data.self) {
                                            let imaage = getMidasImage(on: UIImage(data: data)!)
                                            selectedImageData = imaage.pngData()
                                        }
                                    }
                                }
                            }
                            Spacer()
                            Text("Intensity: \(pow(Float(colorRGB.red + colorRGB.green + colorRGB.blue) / 3, 2))")
                                .padding()
                            
                            Spacer()
                            
                            NavigationLink(destination: CameraView()) {
                                if colorScheme == .dark {
                                    Image(systemName: "camera")
                                        .font(.title)
                                        .foregroundColor(.white)
                                        
                                        .padding(.trailing)
                                
                                } else {
                                    Image(systemName: "camera")
                                        .font(.title)
                                        .foregroundColor(.black)
                                                    
                                        .padding(.trailing)
                                }
                            }
                        }
                    }
                    .padding()
                }
                .padding(.bottom)
                .toolbar {
                    ToolbarItem(placement: .principal) {
                        VStack {
                            Spacer()
                            HStack {
                                Text("HapD")
                                    .font(.system(size: 30))
                                    .foregroundColor(.black)
                                    .fontWeight(.bold)
                                
                                    .padding(.vertical,10)
                                    .padding(.horizontal,20)
                                    .background(Color.white)
                                    .clipShape(Capsule())
                                Spacer()
                            }
                        }
                            }
                        }
                
             
                
                    
            }
            
            .ignoresSafeArea()
        }
        
    }
    

    private func giveFeedback(state: CGPoint, imageFrame: CGRect) {
        DispatchQueue.main.async {
            let convertedPoint = convertToImageCoordinates(point: state, imageFrame: imageFrame)
            colorRGB = rgbValue(of: convertedPoint)
            // Calculate intensity based on the RGB value
            let intensity = Float(colorRGB.red + colorRGB.green + colorRGB.blue) / 3
            // Play haptic feedback
            hapticManager.playHaptic(intensity: intensity)
        }
    }

    private func convertToImageCoordinates(point: CGPoint, imageFrame: CGRect) -> CGPoint {
        guard let imageData = selectedImageData, let image = UIImage(data: imageData) else {
            return .zero
        }
        // Use the 'image' variable here, which is a non-optional UIImage
        let imageScale: CGFloat
        let imageSize: CGSize
        if image.size.width / image.size.height > imageFrame.size.width / imageFrame.size.height {
            imageScale = imageFrame.size.width / image.size.width
            let height = image.size.height * imageScale
            imageSize = CGSize(width: imageFrame.size.width, height: height)
        } else {
            imageScale = imageFrame.size.height / image.size.height
            let width = image.size.width * imageScale
            imageSize = CGSize(width: width, height: imageFrame.size.height)
        }
        let imageX = (point.x - (imageFrame.size.width - imageSize.width) / 2) / imageScale
        let imageY = (point.y - (imageFrame.size.height - imageSize.height) / 2) / imageScale
        return CGPoint(x: imageX, y: imageY)
    }

    private func rgbValue(of point: CGPoint) -> (red: CGFloat, green: CGFloat, blue: CGFloat) {
        guard let imageData = selectedImageData, let image = UIImage(data: imageData) else {
            return (0, 0, 0)
        }
      
        // Use the 'image' variable here, which is a non-optional UIImage
        let imageX = point.x
        let imageY = point.y
        // Ensure the point is within the image bounds
        guard imageX >= 0 && imageX < image.size.width && imageY >= 0 && imageY < image.size.height else {
            return (0, 0, 0)
        }
        guard let cgImage = image.cgImage else {
            return (0, 0, 0)
        }
        let pixelData = cgImage.dataProvider?.data
        let data: UnsafePointer<UInt8> = CFDataGetBytePtr(pixelData)
        let bytesPerPixel = 4
        let bytesPerRow = bytesPerPixel * Int(image.size.width)
        let pixelInfo = Int(imageY) * bytesPerRow + Int(imageX) * bytesPerPixel
        let red = CGFloat(data[pixelInfo]) / 255.0
        let green = CGFloat(data[pixelInfo + 1]) / 255.0
        let blue = CGFloat(data[pixelInfo + 2]) / 255.0
        return (red, green, blue)
    }
}

// HapticManager implementation goes here...
class HapticManager {
    private var engine: CHHapticEngine?
    private var isEngineRunning = false
    
    init() {
        setupHapticEngine()
    }
    
    private func setupHapticEngine() {
        if CHHapticEngine.capabilitiesForHardware().supportsHaptics {
            do {
                engine = try CHHapticEngine()
                try engine?.start()
                isEngineRunning = true
            } catch {
                print("Failed to start the haptic engine: \(error)")
            }
        } else {
            print("Device does not support haptics")
        }
    }
    
    func playHaptic(intensity: Float) {
        guard isEngineRunning else {
            print("Haptic engine is not running")
            return
        }
        
        // Create a haptic pattern based on intensity
        let intensityParameter = CHHapticEventParameter(parameterID: .hapticIntensity, value: pow(intensity, 2))
        let sharpnessParameter = CHHapticEventParameter(parameterID: .hapticSharpness, value: pow(intensity, 2))
        
        let event = CHHapticEvent(eventType: .hapticContinuous, parameters: [intensityParameter, sharpnessParameter], relativeTime: 0, duration: 0.05)
        let pattern = try? CHHapticPattern(events: [event], parameters: [])
        
        // Play the haptic pattern
        do {
            let player = try engine?.makePlayer(with: pattern!)
            try player?.start(atTime: 0)
        } catch {
            print("Failed to play haptic: \(error)")
        }
    }
}
