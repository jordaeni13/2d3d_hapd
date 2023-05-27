//
//  GalleryView.swift
//  demoapp
//
//  Created by Iron Bae on 2023/05/06.
//

import SwiftUI

struct GalleryView: View {
    @State private var tappedColor: Color?
    
    var viewPictureNum: Int

    var body: some View {
        VStack {
            Text("This is Gallery")
            Text("You are viewing \(viewPictureNum) picture")
                .padding(.bottom)
            Circle()
                .fill(tappedColor ?? .black)
                .frame(width: 100, height: 100)
                .padding()
            Image("picture\(viewPictureNum)")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .gesture(
                    SpatialTapGesture()
                        .onEnded { event in
                            if let color = getColorFromImage(at: event.location) {
                                tappedColor = color
//                              print(tappedColor)
                            }
                        }
                )
        }
    }

    private func getColorFromImage(at position: CGPoint) -> Color? {
        guard let image = UIImage(named: "picture\(viewPictureNum)") else { return nil }
        guard let data = image.cgImage?.dataProvider?.data else { return nil }
        let dataPtr: UnsafePointer<UInt8> = CFDataGetBytePtr(data)
        let bytesPerPixel = 4
        let bytesPerRow = bytesPerPixel * Int(image.size.width)
        let pixelIndex = (Int(position.y) * bytesPerRow) + (Int(position.x) * bytesPerPixel)
        guard pixelIndex < CFDataGetLength(data) else { return nil }
        let r = CGFloat(dataPtr[pixelIndex]) / 255.0
        let g = CGFloat(dataPtr[pixelIndex + 1]) / 255.0
        let b = CGFloat(dataPtr[pixelIndex + 2]) / 255.0
        let a = CGFloat(dataPtr[pixelIndex + 3]) / 255.0
        return Color(red: r, green: g, blue: b, opacity: a)
    }
}

struct GalleryView_Previews: PreviewProvider {
    static var previews: some View {
        GalleryView(viewPictureNum: 0)
    }
}
