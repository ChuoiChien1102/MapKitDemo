//
//  StoreFrontViewController.swift
//  MapKitQuestion2
//

import UIKit

class StoreFrontViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, LocationManagerDelegate{
    
    var collectionView: UICollectionView!
    
    var pointsLabel: UILabel! = {
        let label = UILabel()
        label.text = "Points: 0"
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        title = "Store Front"
        
        // Set Location Manager delegate
        LocationManager.shared.delegate = self
        
        // Add pointsLabel to the view
        view.addSubview(pointsLabel)
        setupPointsLabelConstraints()
        
        // Setup UICollectionView for grid
        setupCollectionView()
        
        // Ensure navigationController is not nil and toolbar is shown
        navigationController?.isToolbarHidden = false
        configureToolbar()  // Setup toolbar
        
        // Reload the collection view to display data
        collectionView.reloadData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateLabelPoints()
    }
    
    func updateLabelPoints() {
        pointsLabel.text = "Points: \(UserModel.shared.point)"
    }
    
    // MARK: - Setup Points Label Constraints
    func setupPointsLabelConstraints() {
        NSLayoutConstraint.activate([
            pointsLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            pointsLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            pointsLabel.widthAnchor.constraint(equalToConstant: 150),
            pointsLabel.heightAnchor.constraint(equalToConstant: 40)
        ])
    }
    
    // LocationManagerDelegate methods
    func didUpdateVelocity(_ velocity: Double) {
        
    }
    
    func didUpdateDistanceRemaining(_ distanceRemaining: Double) {
        
    }
    
    func didUpdateTimeUsed(_ timeUsed: Double) {
        
    }
    
    func didUpdateTimeRemaining(_ timeRemaining: Double) {
        
    }
    
    func didReachTreasure() {
        updateLabelPoints()
    }
    
    func showNoMovementAlert() {
        
    }
    
    // MARK: - CollectionView Setup
    func setupCollectionView() {
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: view.frame.width / 2 - 20, height: view.frame.width / 2 - 20)
        layout.sectionInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .white
        collectionView.delegate = self
        collectionView.dataSource = self
        
        // Register a UICollectionViewCell class
        collectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "cell")
        
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(collectionView)
        
        // Add constraints to ensure the collection view doesn't overlap the label or the toolbar
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: pointsLabel.bottomAnchor, constant: 10),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -60)  // Reserve space for toolbar
        ])
    }
    
    // MARK: - Toolbar Setup
    func configureToolbar() {
        let toolbar = UIToolbar()
        toolbar.translatesAutoresizingMaskIntoConstraints = false
        
        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        
        // Toolbar buttons
        let buttonProfile = UIBarButtonItem(title: "Profile", style: .plain, target: self, action: #selector(toolbarButtonTapped(_:)))
        let buttonMap = UIBarButtonItem(title: "Map", style: .plain, target: self, action: #selector(toolbarButtonTapped(_:)))
        
        let toolbarItems = [buttonProfile, flexibleSpace, buttonMap]
        
        toolbar.setItems(toolbarItems, animated: false)
        
        // Add the toolbar to the view
        view.addSubview(toolbar)
        
        // Add constraints to position the toolbar at the bottom
        NSLayoutConstraint.activate([
            toolbar.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            toolbar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            toolbar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            toolbar.heightAnchor.constraint(equalToConstant: 44)
        ])
    }
    
    // MARK: - Toolbar Button Actions
    @objc override func toolbarButtonTapped(_ sender: UIBarButtonItem) {
        if sender.title == "Profile" {
            let profileVC = ProfileViewController()
            navigationController?.pushViewController(profileVC, animated: true)
        } else if sender.title == "Map" {
            let mapVC = MapViewController()
            navigationController?.pushViewController(mapVC, animated: true)
        }
    }
    
    // MARK: - UICollectionView Methods
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 8 // Display 8 items
    }
    
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
    
    // MARK: - DidSelectItemAt for Cell Selection
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        // Display the first alert asking if the user wants to purchase
        let alert = UIAlertController(title: "Purchase", message: "Do you want to purchase for 10 point?", preferredStyle: .alert)
        
        // "Yes" action
        let yesAction = UIAlertAction(title: "Yes", style: .default) { _ in
            // Show another alert indicating the item has been purchased
            if UserModel.shared.point < 10 {
                let purchaseAlert = UIAlertController(title: "Don't enough point!", message: nil, preferredStyle: .alert)
                purchaseAlert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                self.present(purchaseAlert, animated: true, completion: nil)
                return
            }
            UserModel.shared.point -= 10
            self.updateLabelPoints()
            let purchaseAlert = UIAlertController(title: "Purchased!", message: nil, preferredStyle: .alert)
            purchaseAlert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(purchaseAlert, animated: true, completion: nil)
        }
        
        // "No" action
        let noAction = UIAlertAction(title: "No", style: .cancel, handler: nil)
        
        // Add actions to the alert
        alert.addAction(yesAction)
        alert.addAction(noAction)
        
        // Present the alert
        self.present(alert, animated: true, completion: nil)
    }
}
