//
//  storeFrontView.swift
//  MapKitQuestion2
//
//
import UIKit

class StoreFrontViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {

    var collectionView: UICollectionView!

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        title = "Store Front"

        // Ensure navigationController is not nil and toolbar is shown
        navigationController?.isToolbarHidden = false
        setupToolbar(isLoggedIn: true)  // Setup the toolbar based on login status

        // Setup UICollectionView for grid
        setupCollectionView()
    }

    func setupCollectionView() {
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: view.frame.width / 2 - 20, height: view.frame.width / 2 - 20)
        layout.sectionInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)

        collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: layout)
        collectionView.backgroundColor = .white
        collectionView.delegate = self
        collectionView.dataSource = self

        // Register a UICollectionViewCell class
        collectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "cell")

        view.addSubview(collectionView)
    }

    // Number of items in the grid
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 8 // Display 8 items
    }

    // Create cells for each item in the grid
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath)
        cell.backgroundColor = .systemBlue

        // Label for each item
        let label = UILabel(frame: cell.contentView.bounds)
        label.text = "Item \(indexPath.item + 1)"
        label.textAlignment = .center
        label.textColor = .white
        label.font = UIFont.boldSystemFont(ofSize: 16)
        cell.contentView.addSubview(label)

        return cell
    }
}
