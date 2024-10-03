//
//  ProfileViewController.swift
//  MapKitQuestion2
//
//


import UIKit
import MessageUI

class ProfileViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, MFMessageComposeViewControllerDelegate {
    
    let scrollView = UIScrollView()  // Scrollable view
    let contentView = UIView()       // Content view inside scrollView
    
    let imageView = UIImageView()
    let textView = UITextView()
    let postButton = UIButton(type: .system)
    let postsStackView = UIStackView() // Stack view to hold the posts
    
    // Array to store posted items (each post has an image and text)
    var posts: [(image: UIImage, text: String)] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        title = "Profile"
        
        setupScrollView() // Setup scrollable content
        
        setupImageView()
        setupTextView()
        setupPostButton()
        setupPostsStackView()  // For displaying multiple posts
        
        // Add "Done" button to dismiss keyboard
        addDoneButtonOnKeyboard()
    }
    
    // Setup scrollView and contentView
    func setupScrollView() {
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        contentView.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        // ScrollView constraints to take up the full screen
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
        // ContentView constraints to fill the ScrollView
        NSLayoutConstraint.activate([
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor)  // Fix width to match scrollView
        ])
    }
    
    // Setup image view for photo posting
    func setupImageView() {
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        imageView.backgroundColor = .lightGray
        contentView.addSubview(imageView)
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(selectImage))
        imageView.isUserInteractionEnabled = true
        imageView.addGestureRecognizer(tapGesture)
        
        // ImageView constraints
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 20),
            imageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            imageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            imageView.heightAnchor.constraint(equalToConstant: 200)
        ])
    }
    
    // Setup text view for text posting
    func setupTextView() {
        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.layer.borderWidth = 1
        textView.layer.borderColor = UIColor.lightGray.cgColor
        textView.font = UIFont.systemFont(ofSize: 16)
        contentView.addSubview(textView)
        
        // TextView constraints
        NSLayoutConstraint.activate([
            textView.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 20),
            textView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            textView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            textView.heightAnchor.constraint(equalToConstant: 100)
        ])
    }
    
    // Setup post button to post photo and text
    func setupPostButton() {
        postButton.translatesAutoresizingMaskIntoConstraints = false
        postButton.setTitle("Post", for: .normal)
        postButton.addTarget(self, action: #selector(handlePost), for: .touchUpInside)
        contentView.addSubview(postButton)
        
        // PostButton constraints
        NSLayoutConstraint.activate([
            postButton.topAnchor.constraint(equalTo: textView.bottomAnchor, constant: 20),
            postButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            postButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            postButton.heightAnchor.constraint(equalToConstant: 50)
        ])
    }
    
    // Setup stack view to hold multiple posts
    func setupPostsStackView() {
        postsStackView.translatesAutoresizingMaskIntoConstraints = false
        postsStackView.axis = .vertical
        postsStackView.spacing = 20
        contentView.addSubview(postsStackView)
        
        // PostsStackView constraints
        NSLayoutConstraint.activate([
            postsStackView.topAnchor.constraint(equalTo: postButton.bottomAnchor, constant: 20),
            postsStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            postsStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            postsStackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])
    }
    
    // Add toolbar with Done button to dismiss the keyboard
    func addDoneButtonOnKeyboard() {
        let toolbar: UIToolbar = UIToolbar()
        toolbar.sizeToFit()
        
        let doneButton = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(doneButtonAction))
        let flexSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        toolbar.setItems([flexSpace, doneButton], animated: false)
        
        // Add the toolbar to the textView's inputAccessoryView
        textView.inputAccessoryView = toolbar
    }

    // Action for Done button to dismiss keyboard
    @objc func doneButtonAction() {
        textView.resignFirstResponder() // Dismiss the keyboard
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
        
        // Add the post to the array
        posts.append((image: image, text: text))
        
        // Add new post to the stack view
        addPostToStackView(image: image, text: text)
        
        // Clear the input fields
        imageView.image = nil
        textView.text = ""
    }
    
    // Add the post (image + text) to the stack view, with a share button
    func addPostToStackView(image: UIImage, text: String) {
        let postView = UIView()
        postView.translatesAutoresizingMaskIntoConstraints = false
        
        // Image view for the post
        let postImageView = UIImageView(image: image)
        postImageView.translatesAutoresizingMaskIntoConstraints = false
        postImageView.contentMode = .scaleAspectFit
        postImageView.heightAnchor.constraint(equalToConstant: 200).isActive = true
        
        // Text view for the post
        let postTextView = UITextView()
        postTextView.translatesAutoresizingMaskIntoConstraints = false
        postTextView.text = text
        postTextView.isEditable = false
        postTextView.layer.borderWidth = 1
        postTextView.layer.borderColor = UIColor.lightGray.cgColor
        postTextView.heightAnchor.constraint(equalToConstant: 100).isActive = true
        
        // Share button for the post
        let shareButton = UIButton(type: .system)
        shareButton.setTitle("Share via iMessage", for: .normal)
        shareButton.translatesAutoresizingMaskIntoConstraints = false
        shareButton.addTarget(self, action: #selector(sharePost(_:)), for: .touchUpInside)
        shareButton.tag = posts.count - 1 // Tag the button with the index of the post
        
        // Add image, text, and share button to postView
        postView.addSubview(postImageView)
        postView.addSubview(postTextView)
        postView.addSubview(shareButton)
        
        // Add constraints for image, text, and share button inside postView
        NSLayoutConstraint.activate([
            postImageView.topAnchor.constraint(equalTo: postView.topAnchor),
            postImageView.leadingAnchor.constraint(equalTo: postView.leadingAnchor),
            postImageView.trailingAnchor.constraint(equalTo: postView.trailingAnchor),
            
            postTextView.topAnchor.constraint(equalTo: postImageView.bottomAnchor, constant: 10),
            postTextView.leadingAnchor.constraint(equalTo: postView.leadingAnchor),
            postTextView.trailingAnchor.constraint(equalTo: postView.trailingAnchor),
            
            shareButton.topAnchor.constraint(equalTo: postTextView.bottomAnchor, constant: 10),
            shareButton.leadingAnchor.constraint(equalTo: postView.leadingAnchor),
            shareButton.trailingAnchor.constraint(equalTo: postView.trailingAnchor),
            shareButton.bottomAnchor.constraint(equalTo: postView.bottomAnchor)
        ])
        
        // Add postView to the stack view
        postsStackView.addArrangedSubview(postView)
    }
    
    // Share a specific post via iMessage
    @objc func sharePost(_ sender: UIButton) {
        let postIndex = sender.tag
        
        if postIndex < posts.count {
            let post = posts[postIndex]
            
            if !MFMessageComposeViewController.canSendText() {
                showAlert(message: "iMessage is not available.")
                return
            }
            
            let messageVC = MFMessageComposeViewController()
            messageVC.messageComposeDelegate = self
            messageVC.body = "Check out my new post: \(post.text)"
            
            // Attach the post image
            if let imageData = post.image.jpegData(compressionQuality: 1.0) {
                messageVC.addAttachmentData(imageData, typeIdentifier: "public.data", filename: "image.jpeg")
            }
            
            present(messageVC, animated: true, completion: nil)
        }
    }
    
    // Helper to show alert
    func showAlert(message: String) {
        let alert = UIAlertController(title: "Profile", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    // MFMessageComposeViewControllerDelegate method
    func messageComposeViewController(_ controller: MFMessageComposeViewController, didFinishWith result: MessageComposeResult) {
        controller.dismiss(animated: true, completion: nil)
    }
}
