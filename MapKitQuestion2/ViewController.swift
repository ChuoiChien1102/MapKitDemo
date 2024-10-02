//
//  ViewController.swift
//  MapKitQuestion2
//
//

import UIKit
import MapKit
import CoreLocation

// Extension to handle login success and update the toolbar
extension ViewController: LoginViewControllerDelegate {
    
    func didLoginSuccessfully() {
        isLoggedIn = true  // Update the login status
        setupToolbar(isLoggedIn: isLoggedIn)
    }
}


class ViewController: UIViewController, MKMapViewDelegate, LocationManagerDelegate, CLLocationManagerDelegate, LoginViewController.LoginViewControllerDelegate {
    
    var treasureManager = TreasureManager() // Treasure manager for handling treasure generation
    var locationManager = LocationManager()// Initialize LocationManager
    var mapView: MKMapView! // MapView instance to display the map
    var explorationTimerManager: ExplorationTimerManager?
    var collectedTreasures: [CLLocationCoordinate2D] = []
    var difficultyControl: UISegmentedControl! // Difficulty control segmented UI
    var points: Int = 0
    var timerLabel: UILabel!
    var timeLimit: TimeInterval = 1800
    var currentPolyline: MKPolyline?
    var selectedTreasure: CLLocationCoordinate2D?
    
    // UI Labels
    var velocityLabel: UILabel!
    var distanceLabel: UILabel!
    var timeUsedLabel: UILabel!
    var timeRemainingLabel: UILabel!
    
    // Track login status
    var isLoggedIn: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Setup map view
        setupMapView()
        
        setupToolbar(isLoggedIn: isLoggedIn)
        
        // Set Location Manager delegate
        locationManager.delegate = self
        
        // Setup UI components
        setupDifficultyControl()
        setupLabels()
        setupTimerLabel()
        addRestartButton()
        
        // Initialize the timer manager
        explorationTimerManager = ExplorationTimerManager(timeLimit: timeLimit, timerLabel: timerLabel) { [weak self] in
            self?.timeLimitReached()
            self?.showNoMovementAlert()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.isToolbarHidden = false
    }
    
    // Setup the map view
    func setupMapView() {
        mapView = MKMapView(frame: self.view.bounds)
        mapView.delegate = self
        mapView.showsUserLocation = true // Enable user location (blue dot)
        mapView.userTrackingMode = .follow
        self.view.addSubview(mapView)
    }
    
    // Setup difficulty control for treasure generation
    func setupDifficultyControl() {
        difficultyControl = UISegmentedControl(items: ["Easy", "Medium", "Hard"])
        difficultyControl.selectedSegmentIndex = 0
        difficultyControl.addTarget(self, action: #selector(difficultyChanged), for: .valueChanged)
        difficultyControl.frame = CGRect(x: 20, y: 80, width: view.frame.width - 40, height: 30)
        self.view.addSubview(difficultyControl)
        resetTimeLimit()
    }
    
    // Setup UI Labels for velocity, distance, time used, and time remaining
    func setupLabels() {
        velocityLabel = createLabel(text: "Velocity: 0 m/s", yOffset: 130)
        distanceLabel = createLabel(text: "Distance: 0 m", yOffset: 160)
        timeUsedLabel = createLabel(text: "Time Used: 0 s", yOffset: 190)
        timeRemainingLabel = createLabel(text: "Time Remaining: 0 s", yOffset: 220)
    }
    
    // Create label method to simplify label creation
    func createLabel(text: String, yOffset: CGFloat) -> UILabel {
        let label = UILabel()
        label.text = text
        label.font = UIFont.systemFont(ofSize: 16)
        label.textColor = .black
        label.frame = CGRect(x: 20, y: yOffset, width: view.frame.width - 40, height: 30)
        view.addSubview(label)
        return label
    }
    
    // Setup the timer label just below the other information labels
    func setupTimerLabel() {
        timerLabel = UILabel()
        timerLabel.text = "Time Remaining: \(timeLimit) seconds"
        timerLabel.font = UIFont.systemFont(ofSize: 16)
        timerLabel.textColor = .black
        timerLabel.textAlignment = .center
        timerLabel.frame = CGRect(x: 20, y: 250, width: view.frame.width - 40, height: 30)
        self.view.addSubview(timerLabel)
    }
    
    // Add a restart button in the bottom-right corner
    func addRestartButton() {
        let restartButton = UIButton(type: .system)
        restartButton.frame = CGRect(x: view.frame.width - 120, y: view.frame.height - 180, width: 100, height: 30)
        restartButton.setTitle("Restart", for: .normal)
        restartButton.setTitleColor(.blue, for: .normal)
        restartButton.addTarget(self, action: #selector(restartGame), for: .touchUpInside)
        
        self.view.addSubview(restartButton)
    }
    
    // CLLocationManagerDelegate method to handle location updates
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        
        // Center the map on the user's location
        let region = MKCoordinateRegion(center: location.coordinate, latitudinalMeters: 500, longitudinalMeters: 500)
        mapView.setRegion(region, animated: true)
    }
    
    // LocationManagerDelegate methods
    func didUpdateVelocity(_ velocity: Double) {
        velocityLabel.text = String(format: "Velocity: %.2f m/s", velocity)
    }
    
    func didUpdateDistanceRemaining(_ distanceRemaining: Double) {
        distanceLabel.text = String(format: "Distance: %.2f m", distanceRemaining)
    }
    
    func didUpdateTimeUsed(_ timeUsed: Double) {
        timeUsedLabel.text = String(format: "Time Used: %.0f s", timeUsed)
    }
    
    func didUpdateTimeRemaining(_ timeRemaining: Double) {
        timeRemainingLabel.text = String(format: "Time Remaining: %.0f s", timeRemaining)
    }
    
    @objc func didReachTreasure() {
        let alert = UIAlertController(title: "Treasure Found", message: "You reached the treasure!", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    @objc func showNoMovementAlert() {
        let alert = UIAlertController(title: "Get Moving", message: "You have not moved for 11 seconds!", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    // Difficulty changed
    @objc func difficultyChanged(sender: UISegmentedControl) {
        collectedTreasures.removeAll()
        resetTimeLimit()
        timerLabel.text = "Time Remaining: \(timeLimit) seconds"
        explorationTimerManager?.invalidateTimers()
        
        // Generate treasures based on difficulty change
        treasureManager.generateRandomTreasures(from: locationManager.treasureLocation?.coordinate ?? CLLocationCoordinate2D(), mapView: mapView) {
            // hardcode set treasureLocation
            self.locationManager.setTreasureLocation(latitude: self.treasureManager.treasureLocations[2].latitude, longitude: self.treasureManager.treasureLocations[2].longitude, timeLimit: self.timeLimit)
            // Start the timer after treasures are generated
            self.explorationTimerManager?.resetTimer(newTimeLimit: self.timeLimit)
        }
    }
    
    // Reset the time limit based on the difficulty selected
    func resetTimeLimit() {
        switch difficultyControl.selectedSegmentIndex {
        case 0: timeLimit = 1800
        case 1: timeLimit = 1200
        case 2: timeLimit = 600
        default: timeLimit = 600
        }
        explorationTimerManager?.resetTimer(newTimeLimit: timeLimit)
    }
    
    // Reset label data
    func resetDataLabel() {
        velocityLabel.text = String(format: "Velocity: 0 m/s")
        distanceLabel.text = String(format: "Distance: 0 m")
        timeUsedLabel.text = String(format: "Time Used: 0 s")
        timeRemainingLabel.text = String(format: "Time Remaining: 0 s")
    }
    
    // Alert when time limit is reached
    @objc func timeLimitReached() {
        let alert = UIAlertController(title: "Time's up", message: "You didn't reach the location in time!", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    // Restart the game and reset the timer
    @objc func restartGame() {
        collectedTreasures.removeAll()
        explorationTimerManager?.invalidateTimers()
        self.resetDataLabel()
        // Generate new treasures when restarting
        treasureManager.generateRandomTreasures(from: locationManager.treasureLocation?.coordinate ?? CLLocationCoordinate2D(), mapView: mapView) {
            // hardcode set treasureLocation
            self.locationManager.setTreasureLocation(latitude: self.treasureManager.treasureLocations[2].latitude, longitude: self.treasureManager.treasureLocations[2].longitude, timeLimit: self.timeLimit)
            self.explorationTimerManager?.resetTimer(newTimeLimit: self.timeLimit)
            self.locationManager.locationMG.startUpdatingLocation()
        }
    }
}

extension UIViewController {
    
    func setupToolbar(isLoggedIn: Bool) {
        let toolbar = UIToolbar()
        toolbar.translatesAutoresizingMaskIntoConstraints = false

        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        
        // Toolbar buttons
        let button1 = UIBarButtonItem(title: "Option 1", style: .plain, target: self, action: #selector(toolbarButtonTapped(_:)))
        let button3 = UIBarButtonItem(title: "Option 3", style: .plain, target: self, action: #selector(toolbarButtonTapped(_:)))
        let button4 = UIBarButtonItem(title: "Option 4", style: .plain, target: self, action: #selector(toolbarButtonTapped(_:)))

        // Add Option 2 only if the user is logged in
        var toolbarItems = [button1, flexibleSpace]
        
        if isLoggedIn {
            let button2 = UIBarButtonItem(title: "Option 2", style: .plain, target: self, action: #selector(toolbarButtonTapped(_:)))
            toolbarItems.append(button2)
            toolbarItems.append(flexibleSpace)
        }
        
        toolbarItems.append(contentsOf: [button3, flexibleSpace, button4])
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
    
    @objc func toolbarButtonTapped(_ sender: UIBarButtonItem) {
        if sender.title == "Option 1" {
            let loginVC = LoginViewController()
            if let mainVC = self as? ViewController {
                loginVC.delegate = mainVC  // Set the delegate to receive login success
            }
            navigationController?.pushViewController(loginVC, animated: true)
        } else if sender.title == "Option 2" {
            let profileVC = ProfileViewController()
            navigationController?.pushViewController(profileVC, animated: true)
        } else if sender.title == "Option 3" {
            // Navigate back to the root view controller (ViewController)
            navigationController?.popToRootViewController(animated: true)
        }
    }
}
