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
        Text("Tap Count: \(tapCount)")
                    .onTapGesture(count: 2){
                        tapCount+=1
                    }
    }
}

struct CameraView_Previews: PreviewProvider {
    static var previews: some View {
        CameraView()
    }
}
