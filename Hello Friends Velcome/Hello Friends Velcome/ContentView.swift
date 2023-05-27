import SwiftUI
import CoreHaptics

struct ContentView: View {
    @GestureState private var dragLocation: CGPoint = .zero
    @State private var colorRGB: (red: CGFloat, green: CGFloat, blue: CGFloat) = (0, 0, 0)
    let hapticManager = HapticManager()

    var body: some View {
        VStack {
            Image("picture0")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .gesture(DragGesture()
                            .updating($dragLocation) { value, state, _ in
                                state = value.location
                                updateColorRGB(state: state)
                            })

            Text("RGB Value: \(Int(colorRGB.red * 255)), \(Int(colorRGB.green * 255)), \(Int(colorRGB.blue * 255))")
                .padding()
                
            Rectangle()
                .fill(Color(red: colorRGB.red, green: colorRGB.green, blue: colorRGB.blue))
                .frame(width: 50, height: 50)
                .padding(.top, 10)
        }
    }

    private func updateColorRGB(state: CGPoint) {
        DispatchQueue.main.async {
            let convertedPoint = convertToImageCoordinates(point: state)
            colorRGB = rgbValue(of: convertedPoint)
            
            // Calculate intensity based on the RGB value
            let intensity = Float(colorRGB.red + colorRGB.green + colorRGB.blue) / 3
            
            // Play haptic feedback
            hapticManager.playHaptic(intensity: intensity)
        }
    }

    private func convertToImageCoordinates(point: CGPoint) -> CGPoint {
        guard let image = UIImage(named: "picture0") else {
            return .zero
        }

        let imageFrame = CGRect(x: 0, y: 0, width: image.size.width, height: image.size.height)
        let imageViewFrame = imageFrame.aspectFit(frame: UIScreen.main.bounds)
        
        let imageX = point.x * imageFrame.width / imageViewFrame.width
        let imageY = point.y * imageFrame.height / imageViewFrame.height
        
        return CGPoint(x: imageX, y: imageY)
    }

    private func rgbValue(of point: CGPoint) -> (red: CGFloat, green: CGFloat, blue: CGFloat) {
        guard let image = UIImage(named: "picture0") else {
            return (0, 0, 0)
        }

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

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

extension CGRect {
    func aspectFit(frame: CGRect) -> CGRect {
        let aspectRatio = self.size.width / self.size.height
        let targetAspectRatio = frame.size.width / frame.size.height
        
        var newSize = frame.size
        
        if aspectRatio > targetAspectRatio {
            newSize.width = frame.size.width
            newSize.height = frame.size.width / aspectRatio
        } else {
            newSize.height = frame.size.height
            newSize.width = frame.size.height * aspectRatio
        }
        
        let originX = frame.origin.x + (frame.size.width - newSize.width) / 2
        let originY = frame.origin.y + (frame.size.height - newSize.height) / 2
        
        return CGRect(x: originX, y: originY, width: newSize.width, height: newSize.height)
    }
}


import CoreHaptics

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
        let intensityParameter = CHHapticEventParameter(parameterID: .hapticIntensity, value: intensity)
        let sharpnessParameter = CHHapticEventParameter(parameterID: .hapticSharpness, value: intensity)
        
        let event = CHHapticEvent(eventType: .hapticContinuous, parameters: [intensityParameter, sharpnessParameter], relativeTime: 0, duration: 1)
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
