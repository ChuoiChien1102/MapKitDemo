//
//  loginView.swift
//  MapKitQuestion2
//
//

import UIKit

protocol LoginViewControllerDelegate: AnyObject {
    func didLoginSuccessfully()
}

class LoginViewController: UIViewController {
    
    weak var delegate: LoginViewControllerDelegate? 
    
    // UI elements
    let usernameTextField = UITextField()
    let passwordTextField = UITextField()
    let loginButton = UIButton(type: .system)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupToolbar(isLoggedIn: false)
        
        view.backgroundColor = .white
        setupUI()
    }
    
    // Setup the UI for the login form
    func setupUI() {
        // Username TextField
        usernameTextField.placeholder = "Username"
        usernameTextField.borderStyle = .roundedRect
        usernameTextField.autocapitalizationType = .none
        usernameTextField.frame = CGRect(x: 20, y: 150, width: view.frame.width - 40, height: 40)
        view.addSubview(usernameTextField)
        
        // Password TextField
        passwordTextField.placeholder = "Password"
        passwordTextField.borderStyle = .roundedRect
        passwordTextField.isSecureTextEntry = true
        passwordTextField.frame = CGRect(x: 20, y: 200, width: view.frame.width - 40, height: 40)
        view.addSubview(passwordTextField)
        
        // Login Button
        loginButton.setTitle("Login", for: .normal)
        loginButton.addTarget(self, action: #selector(handleLogin), for: .touchUpInside)
        loginButton.frame = CGRect(x: 20, y: 250, width: view.frame.width - 40, height: 40)
        view.addSubview(loginButton)
    }
    
    @objc func handleLogin() {
        let hardcodedUsername = "user123"
        let hardcodedPassword = "password123"
        
        guard let username = usernameTextField.text, let password = passwordTextField.text else { return }
        
        if username == hardcodedUsername && password == hardcodedPassword {
            // Navigate to StoreFrontView
            let storeFrontVC = StoreFrontViewController()
            navigationController?.pushViewController(storeFrontVC, animated: true)
        } else {
            // Show an alert for incorrect credentials
            let alert = UIAlertController(title: "Error", message: "Invalid username or password", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            present(alert, animated: true, completion: nil)
        }
    }
    
    protocol LoginViewControllerDelegate: AnyObject {
        func didLoginSuccessfully()
    }
    
    class LoginViewController: UIViewController {
        
        weak var delegate: LoginViewControllerDelegate?
        
        // UI elements
        let usernameTextField = UITextField()
        let passwordTextField = UITextField()
        let loginButton = UIButton(type: .system)
        
        override func viewDidLoad() {
            super.viewDidLoad()
            
            view.backgroundColor = .white
            title = "Login"
            setupUI()
        }
        
        // Setup the UI for the login form
        func setupUI() {
            // Username and password setup...
        }
        
        @objc func handleLogin() {
            let hardcodedUsername = "user123"
            let hardcodedPassword = "password123"
            
            guard let username = usernameTextField.text, let password = passwordTextField.text else { return }
            
            if username == hardcodedUsername && password == hardcodedPassword {
                // Notify delegate on successful login
                delegate?.didLoginSuccessfully()
                // Navigate to the StoreFrontViewController
                           let storeFrontVC = StoreFrontViewController()
                           navigationController?.pushViewController(storeFrontVC, animated: true)
            } else {
                // Show an alert for incorrect credentials
                let alert = UIAlertController(title: "Error", message: "Invalid username or password", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                present(alert, animated: true, completion: nil)
            }
        }
       
    }
    
}
