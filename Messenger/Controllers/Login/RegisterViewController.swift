import UIKit
import FirebaseAuth
import JGProgressHUD

class RegisterViewController: UIViewController {
    
    private let spinner = JGProgressHUD(style: .dark)

    private let scrollView: UIScrollView = {
        // ui container for smaller devices to work properly when adding many fields
        let scrollView = UIScrollView()
        scrollView.clipsToBounds = true
        return scrollView
    }()
    
    private let imageView: UIImageView = {
        // Adding imageview for images to be shown on the ui
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "person.circle")
        imageView.tintColor = .gray
        imageView.contentMode = .scaleAspectFit
        imageView.layer.masksToBounds = true
        imageView.layer.borderWidth = 2
        imageView.layer.borderColor = UIColor.lightGray.cgColor
        return imageView
    }()
    
    // fields
    private let firstNameField: UITextField = {
        let field = UITextField()
        field.autocapitalizationType = .none
        field.autocorrectionType = .no
        // this is for return key to make it pass to the password field
        field.returnKeyType = .continue
        field.layer.cornerRadius = 12
        field.layer.borderWidth = 1
        field.layer.borderColor = UIColor.lightGray.cgColor
        field.attributedPlaceholder = NSAttributedString(string: "First name...",
                                                         attributes: [NSAttributedString.Key.foregroundColor: UIColor.lightGray])
        // this is for the placeholder to pop up correctly
        field.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 5, height: 0))
        field.leftViewMode = .always
//        field.backgroundColor = .white
        return field
    }()
    
    private let lastNameField: UITextField = {
        let field = UITextField()
        field.autocapitalizationType = .none
        field.autocorrectionType = .no
        // this is for return key to make it pass to the password field
        field.returnKeyType = .continue
        field.layer.cornerRadius = 12
        field.layer.borderWidth = 1
        field.layer.borderColor = UIColor.lightGray.cgColor
        field.attributedPlaceholder = NSAttributedString(string: "Last name...",
                                                         attributes: [NSAttributedString.Key.foregroundColor: UIColor.lightGray])
        field.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 5, height: 0))
        field.leftViewMode = .always
        field.backgroundColor = .white
        return field
    }()
    
    private let emailField: UITextField = {
        let field = UITextField()
        field.autocapitalizationType = .none
        field.autocorrectionType = .no
        // this is for return key to make it pass to the password field
        field.returnKeyType = .continue
        field.layer.cornerRadius = 12
        field.layer.borderWidth = 1
        field.layer.borderColor = UIColor.lightGray.cgColor
        field.attributedPlaceholder = NSAttributedString(string: "Email address...",
                                                         attributes: [NSAttributedString.Key.foregroundColor: UIColor.lightGray])
        field.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 5, height: 0))
        field.leftViewMode = .always
        field.backgroundColor = .white
        return field
    }()
    
    private let passwordField: UITextField = {
        let field = UITextField()
        field.autocapitalizationType = .none
        field.autocorrectionType = .no
        // this is for return key to make it done
        field.returnKeyType = .done
        field.layer.cornerRadius = 12
        field.layer.borderWidth = 1
        field.layer.borderColor = UIColor.lightGray.cgColor
        field.attributedPlaceholder = NSAttributedString(string: "Password...",
                                                         attributes: [NSAttributedString.Key.foregroundColor: UIColor.lightGray])
        field.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 5, height: 0))
        field.leftViewMode = .always
        field.backgroundColor = .white
        field.isSecureTextEntry = true
        return field
    }()

    private let registerButton: UIButton = {
        let button = UIButton()
        button.setTitle("Register", for: .normal)
        button.backgroundColor = .systemGreen
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 12
        // it cuts out extra things (bgcolor etc) that are out of bounds
        button.layer.masksToBounds = true
        button.titleLabel?.font = .systemFont(ofSize: 20, weight: .bold)
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Register"
        view.backgroundColor = .white
        // register button
        navigationItem.rightBarButtonItem = UIBarButtonItem(title:"Register",
                                                            style: .done,
                                                            target: self,
                                                            action: #selector(didTapRegister))
        
        registerButton.addTarget(self,
                              action: #selector(registerButtonTapped),
                              for: .touchUpInside)
        
        emailField.delegate = self
        passwordField.delegate = self
        // Add subviews
        view.addSubview(scrollView)
        scrollView.addSubview(imageView)
        scrollView.addSubview(firstNameField)
        scrollView.addSubview(lastNameField)
        scrollView.addSubview(emailField)
        scrollView.addSubview(passwordField)
        scrollView.addSubview(registerButton)
        
        imageView.isUserInteractionEnabled = true
        scrollView.isUserInteractionEnabled = true
        
        // adding a button to change profile pic
        let gesture = UITapGestureRecognizer(target: self,
                                          action: #selector(didTapChangeProfilePic))
        imageView.addGestureRecognizer(gesture)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        // entirety of the screen
        scrollView.frame = view.bounds
        // Here we give the frame to the imageview
        let size = scrollView.width / 3
        imageView.frame = CGRect(x: (scrollView.width - size) / 2,
                                 y: 20,
                                 width: size,
                                 height: size)
        imageView.layer.cornerRadius = imageView.width / 2.0
        
        firstNameField.frame = CGRect(x: 30,
                                  y: imageView.bottom + 10, // from extensions
                                  width: scrollView.width - 60,
                                  height: 52) // standard
        lastNameField.frame = CGRect(x: 30,
                                  y: firstNameField.bottom + 10, // from extensions
                                  width: scrollView.width - 60,
                                  height: 52) // standard
        emailField.frame = CGRect(x: 30,
                                  y: lastNameField.bottom + 10, // from extensions
                                  width: scrollView.width - 60,
                                  height: 52) // standard
        passwordField.frame = CGRect(x: 30,
                                     y: emailField.bottom + 10,
                                     width: scrollView.width - 60,
                                     height: 52)
        registerButton.frame = CGRect(x: 30,
                                   y: passwordField.bottom + 10,
                                   width: scrollView.width - 60,
                                   height: 52)
    }
    
    
    // actions for buttons
    @objc private func didTapChangeProfilePic() {
        presentPhotoActionSheet()
    }
    
    // Firebase Log In
    
    @objc private func registerButtonTapped() {
        emailField.resignFirstResponder()
        passwordField.resignFirstResponder()
        firstNameField.resignFirstResponder()
        lastNameField.resignFirstResponder()
        
        guard let firstName = firstNameField.text,
              let lastName = lastNameField.text,
              let email = emailField.text,
              let password = passwordField.text,
              !firstName.isEmpty,
              !lastName.isEmpty,
              !email.isEmpty,
              !password.isEmpty,
              password.count >= 6 else{
            alertUserLoginError()
            return
        }
        
        spinner.show(in: view)
        
        
        DatabaseManager.shared.userExists(with: email, completion: { [weak self] exists in
            // We use strongself but not self to not leak memory
            guard let strongSelf = self else{
                return
            }
            
            DispatchQueue.main.async {
                strongSelf.spinner.dismiss()
            }
            
            guard !exists else{
                
                // user already exists
                strongSelf.alertUserLoginError(message: "Looks like a user account for that email already exists")
                return
            }
            
            FirebaseAuth.Auth.auth().createUser(withEmail: email, password: password, completion: { authResult, error in
                guard authResult != nil, error == nil else{
                    print("Error creating user")
                    return
                }
                
                let chatUser = ChatAppUser(firstName: firstName,
                                           lastName: lastName,
                                           emailAddress: email)
                
                DatabaseManager.shared.insertUser(with: chatUser, completion: { success in
                    if success {
                        guard let image = strongSelf.imageView.image,
                              let data = image.pngData() else {
                            return
                        }
                        
                        let fileName = chatUser.profilePictureFileName
                        StorageManager.shared.uploadProfilePicture(with: data, fileName: fileName, completion: { result in
                            switch result {
                            case.success(let downloadURL):
                                // UserDefaults is for caching the downloadURL
                                UserDefaults.standard.set(downloadURL, forKey: "profile_picture_url")
                                print(downloadURL)
                            case.failure(let error):
                                print("Storage manager error: \(error)")
                            }
                        })
                    }
                    
                })
                strongSelf.navigationController?.dismiss(animated: true, completion: nil)
            })
        })
        
        
    }
    
    func alertUserLoginError(message: String = "Please fill in all information when creating user"){
        let alert = UIAlertController(title: "Woops",
                                      message: message,
                                      preferredStyle: .alert)
        // action to dismiss
        alert.addAction(UIAlertAction(title: "Dismiss",
                                      style: .cancel,
                                      handler: nil))
        // show
        present(alert, animated: true)
    }
    
    @objc private func didTapRegister() {
        // objective c function for action to register button
        let vc = RegisterViewController()
        vc.title = "Create account"
        navigationController?.pushViewController(vc, animated: true)
    }
    
    
}

// extension for return button focused on passwordfield to automatically push the login button
extension RegisterViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == emailField {
            passwordField.becomeFirstResponder()
        }
        else if textField == passwordField {
            registerButtonTapped()
        }
        
        return true
    }
    
}

// for picking photos from camera or camera roll
extension RegisterViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    
    func presentPhotoActionSheet() {
        let actionSheet = UIAlertController(title: "Profile picture",
                                            message: "How would you like to select a picture",
                                            preferredStyle: .actionSheet)
        actionSheet.addAction(UIAlertAction(title: "Cancel",
                                            style: .cancel,
                                            handler: nil))
        actionSheet.addAction(UIAlertAction(title: "Take Photo",
                                            style: .default,
                                            handler: { [weak self] _ in
            self?.presentCamera()
        }))
        actionSheet.addAction(UIAlertAction(title: "Choose Photo",
                                            style: .default,
                                            handler: { [weak self] _ in
            self?.presentPhotoPicker()
        }))
        
        present(actionSheet, animated: true)
    }
    
    func presentCamera() {
        let vc = UIImagePickerController()
        vc.sourceType = .camera
        vc.delegate = self
        vc.allowsEditing = true
        present(vc, animated: true)
    }
    
    func presentPhotoPicker() {
        let vc = UIImagePickerController()
        vc.sourceType = .photoLibrary
        vc.delegate = self
        vc.allowsEditing = true
        present(vc, animated: true)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true, completion: nil)
        guard let selectedImage = info[UIImagePickerController.InfoKey.editedImage] as? UIImage else{
            return
        }
        self.imageView.image = selectedImage
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
}
