//
//  MapViewController.swift
//  MapKitQuestion2
//
//

import UIKit
import MapKit
import CoreLocation

// Extension to handle login success and update the toolbar
extension MapViewController: LoginViewControllerDelegate {
    
    func didLoginSuccessfully() {
        setupToolbar()
    }
}


class MapViewController: UIViewController, MKMapViewDelegate, LocationManagerDelegate, CLLocationManagerDelegate {
    
    var treasureManager = TreasureManager() // Treasure manager for handling treasure generation
    var mapView: MKMapView! // MapView instance to display the map
    var explorationTimerManager: ExplorationTimerManager?
    var pointsLabel: UILabel!
    var collectedTreasures: [CLLocationCoordinate2D] = []
    var difficultyControl: UISegmentedControl! // Difficulty control segmented UI
    var timerLabel: UILabel!
    var timeLimit: TimeInterval = 1800
    var currentPolyline: MKPolyline?
    var selectedTreasure: CLLocationCoordinate2D?
    var noMovementTimer: Timer?
    let movementThreshold: Double = -2.00  // Velocity threshold in m/s
    let noMovementDuration: TimeInterval = 10.0
    
    // UI Labels
    var velocityLabel: UILabel!
    var distanceLabel: UILabel!
    var timeUsedLabel: UILabel!
    var timeRemainingLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Setup map view
        setupMapView()
        
        setupToolbar()
        
        // Set Location Manager delegate
        LocationManager.shared.delegate = self
        
        // Setup UI components
        setupDifficultyControl()
        setupLabels()
        addRestartButton()
        
        setupPointsLabel()
        
        // Initialize the timer manager
        explorationTimerManager = ExplorationTimerManager(timeLimit: timeLimit, timerLabel: timerLabel) { [weak self] in
            self?.timeLimitReached()
            self?.showNoMovementAlert()
            
            
        }
    }
    
    func setupPointsLabel(in containerView: UIView) {
        pointsLabel = UILabel(frame: CGRect(x: 10, y: 10, width: 150, height: 40))
        pointsLabel.text = "Points: 0"
        containerView.addSubview(pointsLabel)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destinationVC = segue.destination as? StoreFrontViewController {
            destinationVC.pointsLabel = pointsLabel
        }
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.isToolbarHidden = false
        updateLabelPoints()
    }
    
    // Setup the map view
    func setupMapView() {
        mapView = MKMapView(frame: self.view.bounds)
        mapView.delegate = self
        mapView.showsUserLocation = true // Enable user location (blue dot)
        mapView.userTrackingMode = .follow
        self.view.addSubview(mapView)
    }
    
    // Add the dynamic points label to the top-right corner
    func setupPointsLabel() {
        pointsLabel = UILabel()
        pointsLabel.text = "Points: \(UserModel.shared.point)"
        pointsLabel.font = UIFont.boldSystemFont(ofSize: 18)
        pointsLabel.textColor = .white
        pointsLabel.textAlignment = .right
        pointsLabel.backgroundColor = UIColor.black.withAlphaComponent(0.6)
        pointsLabel.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(pointsLabel)
        
        // Set constraints for the points label (right under difficulty control)
        NSLayoutConstraint.activate([
            pointsLabel.topAnchor.constraint(equalTo: difficultyControl.bottomAnchor, constant: 10),
            pointsLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            pointsLabel.widthAnchor.constraint(equalToConstant: 100),
            pointsLabel.heightAnchor.constraint(equalToConstant: 30)
        ])
    }
    
    
    func updateLabelPoints() {
        pointsLabel.text = "Points: \(UserModel.shared.point)"
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
        showLabelData(isShow: false)
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
    
    func showLabelData(isShow: Bool) {
        if isShow {
            velocityLabel.isHidden = false
            distanceLabel.isHidden = false
            timeUsedLabel.isHidden = false
            timeRemainingLabel.isHidden = false
        } else {
            velocityLabel.isHidden = true
            distanceLabel.isHidden = true
            timeUsedLabel.isHidden = true
            timeRemainingLabel.isHidden = true
        }
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
        
        if velocity < movementThreshold {
            startNoMovementTimer()  // Start the timer when velocity is below the threshold
        } else {
            stopNoMovementTimer()   // Stop the timer if movement is detected
        }
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
        
        // Update points when treasure is found
        updateLabelPoints()
    }
    
    // MARK: - No Movement Logic
    
    func startNoMovementTimer() {
        if noMovementTimer == nil {
            // Start a timer for no movement detection
            noMovementTimer = Timer.scheduledTimer(timeInterval: noMovementDuration, target: self, selector: #selector(showNoMovementAlert), userInfo: nil, repeats: false)
        }
    }
    
    func stopNoMovementTimer() {
        noMovementTimer?.invalidate()
        noMovementTimer = nil  // Reset the timer
    }
    
    @objc func showNoMovementAlert() {
        let alert = UIAlertController(title: "No Movement Detected", message: "You haven't moved for a while. Please start moving to continue.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    // Difficulty changed
    @objc func difficultyChanged(sender: UISegmentedControl) {
        collectedTreasures.removeAll()
        resetTimeLimit()
        explorationTimerManager?.invalidateTimers()
        
        // Generate treasures based on difficulty change
        treasureManager.generateRandomTreasures(from: LocationManager.shared.treasureLocation?.coordinate ?? CLLocationCoordinate2D(), mapView: mapView) {
            // Start the timer after treasures are generated
            LocationManager.shared.startTime = Date()
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
        self.resetTimeLimit()
        // Generate new treasures when restarting
        treasureManager.generateRandomTreasures(from: LocationManager.shared.treasureLocation?.coordinate ?? CLLocationCoordinate2D(), mapView: mapView) {
            LocationManager.shared.startTime = Date()
            self.explorationTimerManager?.resetTimer(newTimeLimit: self.timeLimit)
            LocationManager.shared.locationMG.startUpdatingLocation()
        }
    }
}

extension UIViewController {
    
    func setupToolbar() {
        let toolbar = UIToolbar()
        toolbar.translatesAutoresizingMaskIntoConstraints = false
        
        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        
        // Toolbar buttons
        if UserModel.shared.isLogin {
            // if user is login
            let buttonProfile = UIBarButtonItem(title: "Profile", style: .plain, target: self, action: #selector(toolbarButtonTapped(_:)))
            let buttonMap = UIBarButtonItem(title: "Map", style: .plain, target: self, action: #selector(toolbarButtonTapped(_:)))
            let toolbarItems = [buttonProfile, flexibleSpace, buttonMap]
            toolbar.setItems(toolbarItems, animated: false)
        } else {
            // If user no login
            let buttonLogin = UIBarButtonItem(title: "Login", style: .plain, target: self, action: #selector(toolbarButtonTapped(_:)))
            let buttonMap = UIBarButtonItem(title: "Map", style: .plain, target: self, action: #selector(toolbarButtonTapped(_:)))
            let toolbarItems = [buttonLogin, flexibleSpace, buttonMap]
            toolbar.setItems(toolbarItems, animated: false)
        }
        
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
        if sender.title == "Login" {
            let loginVC = LoginViewController()
            if let mainVC = self as? MapViewController {
                loginVC.delegate = mainVC  // Set the delegate to receive login success
            }
            navigationController?.pushViewController(loginVC, animated: true)
        } else if sender.title == "Profile" {
            let profileVC = ProfileViewController()
            navigationController?.pushViewController(profileVC, animated: true)
        } else if sender.title == "Map" {
            // Navigate back to the root view controller (ViewController)
            navigationController?.popToRootViewController(animated: true)
        }
        
    }
}
