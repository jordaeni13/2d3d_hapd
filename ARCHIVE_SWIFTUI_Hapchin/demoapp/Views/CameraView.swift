//
//  CameraView.swift
//  demoapp
//
//  Created by Iron Bae on 2023/05/06.
//

import SwiftUI

struct CameraView: View {
    @State private var tapCount = 0
    @StateObject var camera = CameraModel()

    var body: some View {
        ZStack {
            Color.black
                .ignoresSafeArea(.all, edges: .all)
        }
        VStack {
            Spacer()

            HStack {
                if camera.isTaken {
                    Button(action: {}, label: {
                        Text("Save")
                            .foregroundColor(.black)
                            .fontWeight(.semibold)
                            .padding(.vertical, 10)
                            .padding(.horizontal, 20)
                            .background(Color.white)
                            .clipShape(Capsule())
                    })

                    Spacer()
                } else {
                    
                }
            }
            .frame(height: 75)
        }
    }
}


class CameraModel: ObservableObject{
    @Published var isTaken = false
}

struct CameraView_Previews: PreviewProvider {
    static var previews: some View {
        CameraView()
    }
}
