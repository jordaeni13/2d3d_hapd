//
//  GalleryView.swift
//  demoapp
//
//  Created by Iron Bae on 2023/05/06.
//

import SwiftUI

struct GalleryView: View {
    var viewPictureNum: Int
    var body: some View {
        VStack{
            Text("This is Gallery")
            Text("You are viewing \(viewPictureNum) picture")
            
        }
    }
}

struct GalleryView_Previews: PreviewProvider {
    static var previews: some View {
        GalleryView(viewPictureNum: 0)
    }
}
