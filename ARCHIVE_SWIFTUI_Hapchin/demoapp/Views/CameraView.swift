//
//  CameraView.swift
//  demoapp
//
//  Created by Iron Bae on 2023/05/06.
//

import SwiftUI

struct CameraView: View {
    
    @State private var tapCount = 0
    var body: some View {
        ZStack {
            Color.black
                .ignoresSafeArea(.all, edges: .all)
        }
        VStack {
            Spacer()
            
            HStack{
                Button(action: {}, label: {
                    ZStack{
                        Circle()
                            .fill(Color.white)
                            .frame(width: 65, height: 65)
                        Circle()
                            .stroke(Color.white, lineWidth: 2)
                            .frame(width: 75, height: 75)
                    }
                })
            }
        }
    }
}

class CameraModel: ObservedObject{
    @Published var isTaken = false
}

struct CameraView_Previews: PreviewProvider {
    static var previews: some View {
        CameraView()
    }
}
