//
//  ProfileViewController.swift
//  MapKitQuestion2
//
//
import UIKit

class ProfileViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    let imageView = UIImageView()
    let textView = UITextView()
    let postButton = UIButton(type: .system)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        title = "Profile"
        
        setupImageView()
        setupTextView()
        setupPostButton()
    }
    
    // Setup image view for photo posting
    func setupImageView() {
        imageView.frame = CGRect(x: 20, y: 100, width: view.frame.width - 40, height: 200)
        imageView.contentMode = .scaleAspectFit
        imageView.backgroundColor = .lightGray
        view.addSubview(imageView)
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(selectImage))
        imageView.isUserInteractionEnabled = true
        imageView.addGestureRecognizer(tapGesture)
    }
    
    // Setup text view for text posting
    func setupTextView() {
        textView.frame = CGRect(x: 20, y: 320, width: view.frame.width - 40, height: 100)
        textView.layer.borderWidth = 1
        textView.layer.borderColor = UIColor.lightGray.cgColor
        textView.font = UIFont.systemFont(ofSize: 16)
        view.addSubview(textView)
    }
    
    // Setup post button to post photo and text
    func setupPostButton() {
        postButton.setTitle("Post", for: .normal)
        postButton.frame = CGRect(x: 20, y: 440, width: view.frame.width - 40, height: 50)
        postButton.addTarget(self, action: #selector(handlePost), for: .touchUpInside)
        view.addSubview(postButton)
    }
    
    // Open image picker to select photo
    @objc func selectImage() {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = .photoLibrary
        present(imagePicker, animated: true, completion: nil)
    }
    
    // Handle image picker selection
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let selectedImage = info[.originalImage] as? UIImage {
            imageView.image = selectedImage
        }
        dismiss(animated: true, completion: nil)
    }
    
    // Handle posting of text and image
    @objc func handlePost() {
        guard let image = imageView.image else {
            showAlert(message: "Please select an image.")
            return
        }
        
        let text = textView.text ?? ""
        
        // Here, you can handle uploading the image and text, or saving it locally.
        // For now, we will just show an alert.
        showAlert(message: "Posted successfully with image and text!")
    }
    
    // Helper to show alert
    func showAlert(message: String) {
        let alert = UIAlertController(title: "Profile", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
}
