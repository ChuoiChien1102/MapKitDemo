//
//  PointsViewWallet.swift
//  MapKitQuestion2
//
//  Created by Alfredo Amezcua on 10/2/24.
//

import UIKit

class PointsViewWallet: UIViewController {

    var pointsLabel: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Initialize pointsLabel
        setupPointsLabel(in: self.view)

        // Example of adding the pointsLabel to another UIView
        let anotherView = UIView(frame: CGRect(x: 50, y: 100, width: 200, height: 200))
        self.view.addSubview(anotherView)
        setupPointsLabel(in: anotherView) // Add label to another view
    }

    // Create a method to setup the pointsLabel in any UIView
    func setupPointsLabel(in containerView: UIView) {
        if pointsLabel == nil {
            pointsLabel = UILabel()
            pointsLabel.frame = CGRect(x: 10, y: 10, width: 100, height: 40)
            pointsLabel.textAlignment = .center
            pointsLabel.text = "Points: 0"
            containerView.addSubview(pointsLabel)
        } else {
            pointsLabel.removeFromSuperview() // Remove it from the current container
            containerView.addSubview(pointsLabel) // Re-attach it to a new container
        }
    }

    // Function to update pointsLabel text
    func updatePointsLabel(with points: Int) {
        pointsLabel.text = "Points: \(points)"
    }
}


