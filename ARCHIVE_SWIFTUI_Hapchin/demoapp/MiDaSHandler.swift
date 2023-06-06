//
//  ContentView.swift
//  MiDaS-HapD
//
//  Created by Woojun Sun on 2023/05/29.
//
import Accelerate
import CoreImage
import Foundation
import SwiftUI
import TensorFlowLite

public struct PixelData {
    var a: UInt8
    var r: UInt8
    var g: UInt8
    var b: UInt8
}



extension UIImage {
    convenience init?(pixels: [PixelData], width: Int, height: Int) {
        guard width > 0 && height > 0, pixels.count == width * height else { return nil }
        var data = pixels
        guard let providerRef = CGDataProvider(data: Data(bytes: &data, count: data.count * MemoryLayout<PixelData>.size) as CFData)
            else { return nil }
        guard let cgim = CGImage(
            width: width,
            height: height,
            bitsPerComponent: 8,
            bitsPerPixel: 32,
            bytesPerRow: width * MemoryLayout<PixelData>.size,
            space: CGColorSpaceCreateDeviceRGB(),
            bitmapInfo: CGBitmapInfo(rawValue: CGImageAlphaInfo.premultipliedFirst.rawValue),
            provider: providerRef,
            decode: nil,
            shouldInterpolate: false,
            intent: .defaultIntent)
        else { return nil }
        self.init(cgImage: cgim)
    }
}

func resizeImage(image: UIImage, newWidth: CGFloat, newHeight: CGFloat) -> UIImage? {
    UIGraphicsBeginImageContextWithOptions(CGSize(width: newWidth, height: newHeight), false, 0.0)
    image.draw(in: CGRect(x: 0, y: 0, width: newWidth, height: newHeight))
    let resizedImage = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()
    return resizedImage
}

func getMidasImage(on inimage: UIImage) -> UIImage {
    let defaultimg = UIImage(named: "example.png")!
    let modelHandler: ModelDataHandler
    var InputImage: CVPixelBuffer?
    let sourceRect: CGRect
    let image: UIImage
    modelHandler = ModelDataHandler()
    InputImage = loadImageAsPixelBuffer(on: fixOrientation(img: inimage)) ?? 0 as! CVPixelBuffer
    //InputImage = convertPixelFormat(of: loadImageFromPathAsPixelBuffer(from: Bundle.main.path(forResource: "example", ofType: "jpeg") ?? "") ?? 0 as! CVPixelBuffer)
    sourceRect = CGRect(x: 0, y: 0, width: CVPixelBufferGetWidth(InputImage ?? 0 as! CVPixelBuffer) , height: CVPixelBufferGetHeight(InputImage ?? 0 as! CVPixelBuffer) )
    let (pixel, width, height) = modelHandler.runMidas(on: InputImage ?? 0 as! CVPixelBuffer , from: sourceRect) ?? ([],0,0)
    image = resizeImage(image: UIImage(pixels: pixel, width: width, height: height) ?? defaultimg, newWidth: sourceRect.size.width, newHeight: sourceRect.size.height) ?? defaultimg
    
    return image
}
/*
func loadImageFromPathAsPixelBuffer(from imagePath: String) -> CVPixelBuffer? {
    guard let image = UIImage(contentsOfFile: imagePath) else {
        return nil
    }

    let options: [String: Any] = [
        kCVPixelBufferCGImageCompatibilityKey as String: true,
        kCVPixelBufferCGBitmapContextCompatibilityKey as String: true
    ]
    var pixelBuffer: CVPixelBuffer?
    let status = CVPixelBufferCreate(
        kCFAllocatorDefault,
        Int(image.size.width),
        Int(image.size.height),
        kCVPixelFormatType_32ARGB,
        options as CFDictionary,
        &pixelBuffer
    )

    if status == kCVReturnSuccess, let buffer = pixelBuffer {
        CVPixelBufferLockBaseAddress(buffer, .readOnly)
        let context = CGContext(
            data: CVPixelBufferGetBaseAddress(buffer),
            width: Int(image.size.width),
            height: Int(image.size.height),
            bitsPerComponent: 8,
            bytesPerRow: CVPixelBufferGetBytesPerRow(buffer),
            space: CGColorSpaceCreateDeviceRGB(),
            bitmapInfo: CGImageAlphaInfo.noneSkipFirst.rawValue
        )

        if let context = context {
            context.draw(image.cgImage!, in: CGRect(x: 0, y: 0, width: image.size.width, height: image.size.height))
        }

        CVPixelBufferUnlockBaseAddress(buffer, .readOnly)
        return buffer
    } else {
        return nil
    }
}
*/

func fixOrientation(img: UIImage) -> UIImage {
  if (img.imageOrientation == .up) {
    return img
  }
  UIGraphicsBeginImageContextWithOptions(img.size, false, img.scale)
  let rect = CGRect(x: 0, y: 0, width: img.size.width, height: img.size.height)
  img.draw(in: rect)
  let normalizedImage = UIGraphicsGetImageFromCurrentImageContext()!
  UIGraphicsEndImageContext()
  return normalizedImage
}

func loadImageAsPixelBuffer(on image: UIImage) -> CVPixelBuffer? {
    let options: [String: Any] = [
        kCVPixelBufferCGImageCompatibilityKey as String: true,
        kCVPixelBufferCGBitmapContextCompatibilityKey as String: true
    ]
    var pixelBuffer: CVPixelBuffer?
    let status = CVPixelBufferCreate(
        kCFAllocatorDefault,
        Int(image.size.width),
        Int(image.size.height),
        kCVPixelFormatType_32BGRA,
        options as CFDictionary,
        &pixelBuffer
    )

    if status == kCVReturnSuccess, let buffer = pixelBuffer {
        CVPixelBufferLockBaseAddress(buffer, .readOnly)
        let context = CGContext(
            data: CVPixelBufferGetBaseAddress(buffer),
            width: Int(image.size.width),
            height: Int(image.size.height),
            bitsPerComponent: 8,
            bytesPerRow: CVPixelBufferGetBytesPerRow(buffer),
            space: CGColorSpaceCreateDeviceRGB(),
            bitmapInfo: CGImageAlphaInfo.noneSkipFirst.rawValue
        )

        if let context = context {
            context.draw(image.cgImage!, in: CGRect(x: 0, y: 0, width: image.size.width, height: image.size.height))
        }

        CVPixelBufferUnlockBaseAddress(buffer, .readOnly)
        return buffer
    } else {
        return nil
    }
}

class ModelDataHandler {
    
    private var interpreter: Interpreter
    
    private var inputTensor: Tensor
    
    private var outputTensor: Tensor
    
    init() {
        guard let modelPath = Bundle.main.path(forResource: Model.file.name, ofType: Model.file.file_extension
            )
        else {
            fatalError("Failed to load the model file with name: \(Model.file.name).")
        }
        
        do{
            interpreter = try Interpreter(modelPath: modelPath)
            
            try interpreter.allocateTensors()

            inputTensor = try interpreter.input(at: 0)
            outputTensor = try interpreter.output(at: 0)
            
        } catch {
            fatalError("Failed to load the model file with name: \(Model.file.name).")
        }
        
    }
    func runMidas(on pixelbuffer: CVPixelBuffer, from source: CGRect)
    -> ([PixelData], Int, Int)?
    {
        guard let data = preprocess(of: pixelbuffer, from: source) else {
          os_log("Preprocessing failed", type: .error)
          return nil
        }
        inference(from: data)
        let results: [Float]
        switch outputTensor.dataType {
        case .uInt8:
          guard let quantization = outputTensor.quantizationParameters else {
            print("No results returned because the quantization values for the output tensor are nil.")
            return nil
          }
          let quantizedResults = [UInt8](outputTensor.data)
          results = quantizedResults.map {
            quantization.scale * Float(Int($0) - quantization.zeroPoint)
          }
        case .float32:
            results = [Float32](unsafeData: outputTensor.data) ?? []
        default:
          print("Output tensor data type \(outputTensor.dataType) is unsupported for this example app.")
          return nil
        }
        var multiplier : Float = 1.0;
        
        let max_val : Float = results.max() ?? 0
        let min_val : Float = results.min() ?? 0
        
        if((max_val - min_val) > 0) {
            multiplier = 255 / (max_val - min_val);
        }
                            
        var pixels: [PixelData] = .init(repeating: .init(a: 255, r: 0, g: 0, b: 0), count: Model.input.width * Model.input.height)
                 
        for i in pixels.indices {
            let val = UInt8((results[i] - min_val) * multiplier)
                
            pixels[i].r = val
            pixels[i].g = val
            pixels[i].b = val
        }
        
        return (pixels, Model.input.width, Model.input.height)
    }
    
    private func preprocess(of pixelBuffer: CVPixelBuffer, from targetSquare: CGRect) -> Data? {
      let sourcePixelFormat = CVPixelBufferGetPixelFormatType(pixelBuffer)
      assert(sourcePixelFormat == kCVPixelFormatType_32BGRA)
      
      // Resize `targetSquare` of input image to `modelSize`.
      let modelSize = CGSize(width: Model.input.width, height: Model.input.height)
      guard let thumbnail = pixelBuffer.resize(from: targetSquare, to: modelSize)
      else {
        return nil
      }

      // Remove the alpha component from the image buffer to get the initialized `Data`.
      guard
        let inputData = thumbnail.rgbData(
          isModelQuantized: Model.isQuantized
        )
      else {
        os_log("Failed to convert the image buffer to RGB data.", type: .error)
        return nil
      }

      return inputData
    }
    
    
    private func inference(from data: Data) {
      // Copy the initialized `Data` to the input `Tensor`.
      do {
        try interpreter.copy(data, toInputAt: 0)

        // Run inference by invoking the `Interpreter`.
        try interpreter.invoke()

        // Get the output `Tensor` to process the inference results.
        outputTensor = try interpreter.output(at: 0)
          

      } catch let error {
        os_log(
          "Failed to invoke the interpreter with error: %s", type: .error,
          error.localizedDescription)
        return
      }
    }
}
//    private func sigmoid(_ x: Float32) -> Float32 {
//      return (1.0 / (1.0 + exp(-x)))
//    }

func convertPixelFormat(of pixelBuffer: CVPixelBuffer) -> CVPixelBuffer? {
    let attributes: [String: Any] = [
        kCVPixelBufferCGImageCompatibilityKey as String: true,
        kCVPixelBufferCGBitmapContextCompatibilityKey as String: true,
        kCVPixelBufferPixelFormatTypeKey as String: kCVPixelFormatType_32BGRA
    ]

    var convertedPixelBuffer: CVPixelBuffer?
    CVPixelBufferCreate(nil, CVPixelBufferGetWidth(pixelBuffer), CVPixelBufferGetHeight(pixelBuffer), kCVPixelFormatType_32BGRA, attributes as CFDictionary, &convertedPixelBuffer)

    guard let convertedBuffer = convertedPixelBuffer else {
        return nil
    }

    let sourceImage = CIImage(cvPixelBuffer: pixelBuffer)
    let context = CIContext()

    context.render(sourceImage, to: convertedBuffer)

    return convertedPixelBuffer
}

typealias FileInfo = (name: String, file_extension: String)

enum Model {
  static let file: FileInfo = (
    name: "model_opt", file_extension: ".tflite"
  )

  static let input = (batchSize: 1, height: 256, width: 256, channelSize: 3)
  static let output = (batchSize: 1, height: 256, width: 256, channelSize: 1)
  static let isQuantized = false
}

extension Array {
  /// Creates a new array from the bytes of the given unsafe data.
  ///
  /// - Warning: The array's `Element` type must be trivial in that it can be copied bit for bit
  ///     with no indirection or reference-counting operations; otherwise, copying the raw bytes in
  ///     the `unsafeData`'s buffer to a new array returns an unsafe copy.
  /// - Note: Returns `nil` if `unsafeData.count` is not a multiple of
  ///     `MemoryLayout<Element>.stride`.
  /// - Parameter unsafeData: The data containing the bytes to turn into an array.
  init?(unsafeData: Data) {
    guard unsafeData.count % MemoryLayout<Element>.stride == 0 else { return nil }
    #if swift(>=5.0)
    self = unsafeData.withUnsafeBytes { .init($0.bindMemory(to: Element.self)) }
    #else
    self = unsafeData.withUnsafeBytes {
      .init(UnsafeBufferPointer<Element>(
        start: $0,
        count: unsafeData.count / MemoryLayout<Element>.stride
      ))
    }
    #endif  // swift(>=5.0)
  }
}
