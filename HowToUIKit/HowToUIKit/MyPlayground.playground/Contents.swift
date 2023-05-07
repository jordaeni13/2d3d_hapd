//: A UIKit based Playground for presenting user interface
  
import UIKit
import PlaygroundSupport

class MyViewController : UIViewController {
    override func loadView() {
        let view = UIView()
        view.backgroundColor = .white
        
        let cardView = UIView()
        cardView.frame = CGRect(x: 20, y: 20, width: 300, height: 250)
        cardView.backgroundColor = .blue
        cardView.layer.cornerRadius = 30
        cardView.layer.cornerCurve = .continuous
        
        //shadow
        cardView.layer.shadowColor = UIColor.black.cgColor
        cardView.layer.shadowOpacity = 0.5
        cardView.layer.shadowOffset = CGSize(width: 30, height: 70)
        cardView.layer.shadowRadius = 20
        
        view.addSubview(cardView)
        self.view = view
    }
}
// Present the view controller in the Live View window
PlaygroundPage.current.liveView = MyViewController()
