//: A UIKit based Playground for presenting user interface
  
import UIKit
import PlaygroundSupport
//
//  ViewController.swift
//  hapticdemo
//
//  Created by Iron Bae on 2023/05/07.
//
import UIKit

class ViewController: UIViewController {

    private var isCameraView = false
    private var viewPictureNum = 0
    private let imageCount = 4
    private var imageView: UIImageView!
    private var rectangleView: UIView!
    private var panGesture: UIPanGestureRecognizer!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Add gallery view and camera view
        imageView = UIImageView(frame: view.bounds)
        imageView.contentMode = .scaleAspectFit
        view.addSubview(imageView)
        
        // Add rectangle view
        rectangleView = UIView()
        rectangleView.backgroundColor = .black
        view.addSubview(rectangleView)
        
        // Add pan gesture to rectangle view
        panGesture = UIPanGestureRecognizer(target: self, action: #selector(onPanGesture(_:)))
        rectangleView.addGestureRecognizer(panGesture)
        
        // Set initial view
        showGalleryView()
    }
    
    private func showGalleryView() {
        imageView.isHidden = false
        rectangleView.isHidden = false
        isCameraView = false
        updateImage()
    }
    
    private func showCameraView() {
        imageView.isHidden = true
        rectangleView.isHidden = true
        isCameraView = true
    }
    
    private func updateImage() {
        let imageName = "image\(viewPictureNum + 1)"
        if let image = UIImage(named: imageName) {
            imageView.image = image
        }
    }
    
    @objc private func onPanGesture(_ gesture: UIPanGestureRecognizer) {
        let translation = gesture.translation(in: view)
        if abs(translation.x) < abs(translation.y) {
            // Vertical swipe, toggle camera view
            showCameraView()
        } else {
            // Horizontal swipe, change image
            if translation.x > 0 && viewPictureNum < imageCount - 1 {
                viewPictureNum += 1
                updateImage()
            } else if translation.x < 0 && viewPictureNum > 0 {
                viewPictureNum -= 1
                updateImage()
            }
        }
    }
}



// Present the view controller in the Live View window
PlaygroundPage.current.liveView = ViewController()
