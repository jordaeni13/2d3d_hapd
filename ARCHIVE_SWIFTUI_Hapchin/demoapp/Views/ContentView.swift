//
//  ContentView.swift
//  demoapp
//
//  Created by Iron Bae on 2023/05/06.
//

import SwiftUI

struct ContentView: View {
    @State private var isCameraView = false
    @State private var viewPictureNum = 0
    let imageCount = 4

    var body: some View {
        VStack {
            if isCameraView {
                CameraView()
                    .frame(maxHeight: .infinity) // Expand the CameraView to fill available space
            } else {
                GalleryView(viewPictureNum: viewPictureNum)
                    .frame(maxHeight: .infinity) // Expand the GalleryView to fill available space
            }

            Rectangle()
                .foregroundColor(.black)
                .frame(maxWidth: .infinity, maxHeight: 150)
                .gesture(
                    DragGesture(minimumDistance: 100, coordinateSpace: .global)
                        .onEnded { value in
                            if abs(value.translation.width) < abs(value.translation.height) {
                                self.isCameraView.toggle()
                            } else {
                                if !isCameraView {
                                    if value.translation.width > 0 && (imageCount - 1) > viewPictureNum {
                                        viewPictureNum += 1
                                    } else if value.translation.width < 0 && viewPictureNum > 0 {
                                        viewPictureNum -= 1
                                    }
                                }
                            }
                        }
                )
        }
        .ignoresSafeArea(.all, edges: .bottom) // Ignore safe area for the bottom edge to prevent overlap with the rectangle
    }
}




struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
