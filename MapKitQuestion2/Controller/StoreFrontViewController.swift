//
//  StoreFrontViewController.swift
//  MapKitQuestion2
//

import UIKit

class StoreFrontViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, LocationManagerToStoreVCDelegate {
    
    var collectionView: UICollectionView!
    
    var pointsLabel: UILabel! = {
        let label = UILabel()
        label.text = "Points: 0"
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let listItems = [Item(name: "Camry", point: 20), Item(name: "Accent", point: 5), Item(name: "Mercedes", point: 30), Item(name: "Vios", point: 5), Item(name: "Honda City", point: 5), Item(name: "Honda Civic", point: 10), Item(name: "Honda CRV", point: 15), Item(name: "Madza 3", point: 10), Item(name: "Madza 6", point: 15)]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        title = "Store Front"
        
        // Set Location Manager delegate
        LocationManager.shared.toStoreVCdelegate = self
        
        // Add pointsLabel to the view
        view.addSubview(pointsLabel)
        setupPointsLabelConstraints()
        
        // Setup UICollectionView for grid
        setupCollectionView()
        
        // Ensure navigationController is not nil and toolbar is shown
        navigationController?.isToolbarHidden = false
        configureToolbar()  // Setup toolbar
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
    
    // LocationManagerToStoreVCDelegate methods
    func didReachTreasure() {
        updateLabelPoints()
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
        let nib = UINib(nibName: "ItemCollectionViewCell", bundle: .main)
        collectionView.register(nib, forCellWithReuseIdentifier: "ItemCollectionViewCell")
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
        let buttonOrderHistory = UIBarButtonItem(title: "OrderHistory", style: .plain, target: self, action: #selector(toolbarButtonTapped(_:)))
        let buttonMap = UIBarButtonItem(title: "Map", style: .plain, target: self, action: #selector(toolbarButtonTapped(_:)))
        
        let toolbarItems = [buttonProfile, flexibleSpace, buttonOrderHistory, flexibleSpace, buttonMap]
        
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
    @objc func toolbarButtonTapped(_ sender: UIBarButtonItem) {
        if sender.title == "Profile" {
            let profileVC = ProfileViewController()
            navigationController?.pushViewController(profileVC, animated: true)
        } else if sender.title == "OrderHistory" {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let vc = storyboard.instantiateViewController(withIdentifier: "OrderHistoryViewController")
            navigationController?.pushViewController(vc, animated: true)
        } else if sender.title == "Map" {
            let mapVC = MapViewController()
            navigationController?.pushViewController(mapVC, animated: true)
        }
    }
    
    // MARK: - UICollectionView Methods
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return listItems.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ItemCollectionViewCell", for: indexPath) as! ItemCollectionViewCell
    
        cell.lbName.text = listItems[indexPath.item].name
        return cell
    }
    
    // MARK: - DidSelectItemAt for Cell Selection
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let item = listItems[indexPath.item]
        // Display the first alert asking if the user wants to purchase
        let alert = UIAlertController(title: "Purchase", message: "Do you want to purchase " + item.name + " for " + String(item.point) + " point?", preferredStyle: .alert)
        
        // "Yes" action
        let yesAction = UIAlertAction(title: "Yes", style: .default) { _ in
            // Show another alert indicating the item has been purchased
            if UserModel.shared.point < item.point {
                let purchaseAlert = UIAlertController(title: "Don't enough point!", message: "You haven't enough point! Please reach treasure!", preferredStyle: .alert)
                purchaseAlert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                self.present(purchaseAlert, animated: true, completion: nil)
                return
            }
            UserModel.shared.point = UserModel.shared.point - item.point
            UserModel.shared.listItemPurchased.append(item)
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
