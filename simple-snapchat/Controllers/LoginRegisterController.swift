//
//  LoginController.swift
//  Chat for Fun
//
//  Created by Jeffrey on 22/08/2016.
//  Copyright © 2016 University of Melbourne. All rights reserved.
//

import UIKit
import Firebase
import Photos

@IBDesignable
class LoginRegisterController: UIViewController {
    
    let spinnerView: UIActivityIndicatorView = {
        let sv = UIActivityIndicatorView()
        sv.translatesAutoresizingMaskIntoConstraints = false
        sv.stopAnimating()
        sv.color = .black
        return sv
    }()
    
    let profileImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "Snapchat_Logo")
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    lazy var loginRegisterSegmentedControl: UISegmentedControl = {
        let sc = UISegmentedControl(items: ["Login", "Register"])
        sc.translatesAutoresizingMaskIntoConstraints = false
        sc.tintColor = UIColor(r: 0, g: 188, b: 255)
        sc.selectedSegmentIndex = 1
        sc.addTarget(self, action: #selector(handleLoginRegisterChange), for: .valueChanged)
        return sc
    }()
    
    let inputContainerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor.white
        view.layer.cornerRadius = 5
        view.layer.masksToBounds = true
        return view
    }()

    lazy var loginRegisterButton: UIButton = {
        let button = UIButton(type: .system)
        button.backgroundColor = UIColor(r: 255, g: 96, b: 136)
        button.setTitle("Register", for: UIControlState())
        button.setTitleColor(UIColor.white, for: UIControlState())
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        button.translatesAutoresizingMaskIntoConstraints = false
        
        button.addTarget(self, action: #selector(handleLoginOrRegister), for: .touchUpInside)
        
        return button
    }()
    
    lazy var forgetPasswordButton: UIButton = {
        let button = UIButton(type: .system)
        button.backgroundColor = UIColor(r: 255, g: 96, b: 136)
        button.setTitle("", for: UIControlState())
        button.setTitleColor(UIColor.white, for: UIControlState())
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        button.translatesAutoresizingMaskIntoConstraints = false
        
        button.addTarget(self, action: #selector(handleForgetPassword), for: .touchUpInside)
        
        return button
    }()

    
    let nameTextField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "Name"
        tf.translatesAutoresizingMaskIntoConstraints = false
        return tf
    }()
    
    let nameSeparatorView: UIView = {
        let ns = UIView()
        ns.backgroundColor = UIColor(r: 220, g: 220, b: 220)
        ns.translatesAutoresizingMaskIntoConstraints = false
        return ns
    }()
    
    let emailTextField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "Email address"
        tf.translatesAutoresizingMaskIntoConstraints = false
        return tf
    }()
    
    let emailSeparatorView: UIView = {
        let es = UIView()
        es.backgroundColor = UIColor(r: 220, g: 220, b: 220)
        es.translatesAutoresizingMaskIntoConstraints = false
        return es
    }()
    
    let passwordTextField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "Password"
        tf.isSecureTextEntry = true
        tf.translatesAutoresizingMaskIntoConstraints = false
        return tf
    }()
    
    func handleLoginOrRegister() {
        spinnerView.startAnimating()
        loginRegisterButton.isUserInteractionEnabled = false
        loginRegisterSegmentedControl.selectedSegmentIndex == 0 ? handleLogin() : handleRegister()
    }
    
    func handleLogin() {
        guard let email = emailTextField.text, let password = passwordTextField.text else {
            print("Form is not valid!")
            return
        }
        if email.isEmpty || password.isEmpty {
            self.spinnerView.stopAnimating()
            self.loginRegisterButton.isUserInteractionEnabled = true
            self.displayAlert(title: "Invalid Form", message: "Please fill in all fields!")
            return
        }
        
        FIRAuth.auth()?.signIn(withEmail: email, password: password, completion: { (user, error) in
            self.spinnerView.stopAnimating()
            if let error = error {
                self.loginRegisterButton.isUserInteractionEnabled = true
                if let errCode = FIRAuthErrorCode(rawValue: error._code) {
                    switch errCode {
                    case .errorCodeUserNotFound:
                        self.displayAlert(title: "Email Not Found", message: "Please check your email!")
                    case .errorCodeInvalidEmail:
                        self.displayAlert(title: "Invalid Email", message: "Please check your email format!")
                    case .errorCodeWrongPassword:
                        self.displayAlert(title: "Wrong Password", message: "Please check your password!")
                    case .errorCodeNetworkError:
                        self.displayAlert(title: "Netword Error", message: "No network connection!")
                    default:
                        print("unknown error")
                        print(error)
                    }
                }
                return
            } else {

                self.dismiss(animated: true, completion: nil)
                
            }
        })
    
        
    }
    
    func displayAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let defaultAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(defaultAction)
        self.present(alert, animated: true, completion: nil)
    }
    
    func handleForgetPassword (){
        guard let email = emailTextField.text else{
             self.displayAlert(title: "Invalid Form", message: "Please fill in your email!")
             return
        }
        
        FIRAuth.auth()?.sendPasswordReset(withEmail: email, completion: { (error) in
    
             if let error = error {
                if let errCode = FIRAuthErrorCode(rawValue: error._code) {
                    switch errCode {
                    case .errorCodeInvalidEmail:
                        self.displayAlert(title: "Invalid Email", message: "Please check your email format!")
                    case .errorCodeNetworkError:
                        self.displayAlert(title: "Netword Error", message: "No network connection!")
                    case .errorCodeUserNotFound:
                         self.displayAlert(title: "No User Found", message: "No user record found!")
                    default:
                        print("unknown error")
                        print(error)
                    }
                }
            }else{
                self.emailTextField.text = ""
                self.displayAlert(title: "Success", message: "Password reset email sent!")

            }
        })

    }
    
    func handleRegister() {
        guard let email = emailTextField.text, let username = nameTextField.text, let password = passwordTextField.text else {
            print("Form is not valid!")
            return
        }
        if email.isEmpty || password.isEmpty || username.isEmpty {
            self.spinnerView.stopAnimating()
            self.loginRegisterButton.isUserInteractionEnabled = true
            self.displayAlert(title: "Invalid Form", message: "Please fill in all fields!")
            return
        }
        
        FIRAuth.auth()?.createUser(withEmail: email, password: password, completion: { (user, error) in
            self.spinnerView.stopAnimating()
            if let error = error {
                self.loginRegisterButton.isUserInteractionEnabled = true
                if let errCode = FIRAuthErrorCode(rawValue: error._code) {
                    switch errCode {
                    case .errorCodeInvalidEmail:
                        self.displayAlert(title: "Invalid Email", message: "Please check your email format!")
                    case .errorCodeEmailAlreadyInUse:
                        self.displayAlert(title: "Email Already Registered", message: "Please use another email!")
                    case .errorCodeWeakPassword:
                        self.displayAlert(title: "Weak Password", message: "Your password is too weak!")
                    case .errorCodeNetworkError:
                        self.displayAlert(title: "Netword Error", message: "No network connection!")
                    default:
                        print("unknown error")
                        print(error)
                    }
                }
                return
            } else {
                
                guard let uid = user?.uid else {
                    return
                }
                
                let ref = FIRDatabase.database().reference()
                let userRef = ref.child("users").child(uid)
                let values = ["name": username, "email": email]
 
                userRef.updateChildValues(values, withCompletionBlock: { (error, ref) in
                    if error != nil {
                        print(error)
                        return
                    } else {
                        self.dismiss(animated: true, completion: nil)
                    }
                })
            }
        })

    
    }
    
    
    func handleLoginRegisterChange() {
        let title = loginRegisterSegmentedControl.titleForSegment(at: loginRegisterSegmentedControl.selectedSegmentIndex)
        loginRegisterButton.setTitle(title, for: UIControlState())
        
        // inputContainerView height
        inputContainerViewHeightConstraint?.constant = loginRegisterSegmentedControl.selectedSegmentIndex == 0 ? 100 : 150
        
        // nameTextField height
        nameTextFieldHeightConstraint?.isActive = false
        nameTextFieldHeightConstraint = nameTextField.heightAnchor.constraint(equalTo: inputContainerView.heightAnchor, multiplier: loginRegisterSegmentedControl.selectedSegmentIndex == 0 ? 0 : 1/3)
        nameTextFieldHeightConstraint?.isActive = true
        
        // nameTextField placeholder and text
        nameTextField.placeholder = loginRegisterSegmentedControl.selectedSegmentIndex == 0 ? "" : "Name"
        nameTextField.text = nil
        
        // nameSeparator Height
        nameSeparatorHeightConstraint?.isActive = false
        nameSeparatorHeightConstraint = nameSeparatorView.heightAnchor.constraint(equalToConstant: loginRegisterSegmentedControl.selectedSegmentIndex == 0 ? 0 : 1)
        nameSeparatorHeightConstraint?.isActive = true
        
        // emailTextField height
        emailTextFieldHeightConstraint?.isActive = false
        emailTextFieldHeightConstraint = emailTextField.heightAnchor.constraint(equalTo: inputContainerView.heightAnchor, multiplier: loginRegisterSegmentedControl.selectedSegmentIndex == 0 ? 1/2 : 1/3)
        emailTextFieldHeightConstraint?.isActive = true
        
        
        // passwordTextField height
        passwordTextFieldHeightConstraint?.isActive = false
        passwordTextFieldHeightConstraint = passwordTextField.heightAnchor.constraint(equalTo: inputContainerView.heightAnchor, multiplier:loginRegisterSegmentedControl.selectedSegmentIndex == 0 ? 1/2 : 1/3)
        passwordTextFieldHeightConstraint?.isActive = true
        
        forgetPasswordHeightConstraint?.isActive = false
        forgetPasswordHeightConstraint = forgetPasswordButton.heightAnchor.constraint(equalToConstant: loginRegisterSegmentedControl.selectedSegmentIndex == 0 ? 50 : 0)
        if loginRegisterSegmentedControl.selectedSegmentIndex == 1 {
            forgetPasswordButton.setTitle("", for: UIControlState())
        }else{
            forgetPasswordButton.setTitle("Forget Password", for: UIControlState())
        }
        forgetPasswordHeightConstraint?.isActive = true
        
        // Handle centerYAnchor for input container
        if loginRegisterSegmentedControl.selectedSegmentIndex == 0{
            inputContainerCenterYAnchor?.constant -= 12
        }else{
            inputContainerCenterYAnchor?.constant += 12
        }
        

        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor(r: 255, g: 254, b: 0)
        
        view.addSubview(inputContainerView)
        view.addSubview(loginRegisterButton)
        view.addSubview(profileImageView)
        view.addSubview(loginRegisterSegmentedControl)
        view.addSubview(spinnerView)
        view.bringSubview(toFront: spinnerView)
        view.addSubview(forgetPasswordButton)
        
        setupSpinnerView()
        setupInputContainerView()
        setupLoginRegisterButton()
        setupProfileImageView()
        setupLoginRegisterSegmentedControl()
        
        setupForgetPasswordButton()
        setupKeyboardObservers()
    }
    
    func setupSpinnerView() {
        spinnerView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        spinnerView.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        spinnerView.widthAnchor.constraint(equalToConstant: 20).isActive = true
        spinnerView.heightAnchor.constraint(equalToConstant: 20).isActive = true
    }
    
    fileprivate func setupLoginRegisterSegmentedControl() {
        //setup constraints, x, y, width, height
        loginRegisterSegmentedControl.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        loginRegisterSegmentedControl.bottomAnchor.constraint(equalTo: inputContainerView.topAnchor, constant: -12).isActive = true
        loginRegisterSegmentedControl.widthAnchor.constraint(equalTo: view.widthAnchor, constant: -24).isActive = true
        loginRegisterSegmentedControl.heightAnchor.constraint(equalToConstant: 36).isActive = true
        
    }
    
    var inputContainerViewHeightConstraint: NSLayoutConstraint?
    var nameTextFieldHeightConstraint: NSLayoutConstraint?
    var emailTextFieldHeightConstraint: NSLayoutConstraint?
    var passwordTextFieldHeightConstraint: NSLayoutConstraint?
    var nameSeparatorHeightConstraint: NSLayoutConstraint?
    var forgetPasswordHeightConstraint: NSLayoutConstraint?
    var inputContainerCenterYAnchor : NSLayoutConstraint?
    fileprivate func setupInputContainerView() {
        //setup constraints, x, y, width, height
        inputContainerView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        inputContainerView.widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true
        inputContainerCenterYAnchor =  inputContainerView.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        inputContainerCenterYAnchor?.isActive = true
        inputContainerViewHeightConstraint = inputContainerView.heightAnchor.constraint(equalToConstant: 150)
        inputContainerViewHeightConstraint?.isActive = true
        
        //setup fields in container
        inputContainerView.addSubview(nameTextField)
        inputContainerView.addSubview(nameSeparatorView)
        inputContainerView.addSubview(emailTextField)
        inputContainerView.addSubview(emailSeparatorView)
        inputContainerView.addSubview(passwordTextField)
        
        //setup constraints, x, y, width, height
        nameTextField.leftAnchor.constraint(equalTo: inputContainerView.leftAnchor, constant: 12).isActive = true
        nameTextField.topAnchor.constraint(equalTo: inputContainerView.topAnchor).isActive = true
        nameTextField.widthAnchor.constraint(equalTo: inputContainerView.widthAnchor).isActive = true
        nameTextFieldHeightConstraint = nameTextField.heightAnchor.constraint(equalTo: inputContainerView.heightAnchor, multiplier: 1/3)
        nameTextFieldHeightConstraint?.isActive = true
        
        //setup constraints, x, y, width, height
        nameSeparatorView.leftAnchor.constraint(equalTo: inputContainerView.leftAnchor).isActive = true
        nameSeparatorView.topAnchor.constraint(equalTo: nameTextField.bottomAnchor).isActive = true
        nameSeparatorView.widthAnchor.constraint(equalTo: inputContainerView.widthAnchor).isActive = true
        nameSeparatorHeightConstraint = nameSeparatorView.heightAnchor.constraint(equalToConstant: 1)
        nameSeparatorHeightConstraint?.isActive = true
        
        //setup constraints, x, y, width, height
        emailTextField.leftAnchor.constraint(equalTo: inputContainerView.leftAnchor, constant: 12).isActive = true
        emailTextField.topAnchor.constraint(equalTo: nameTextField.bottomAnchor).isActive = true
        emailTextField.widthAnchor.constraint(equalTo: inputContainerView.widthAnchor).isActive = true
        emailTextFieldHeightConstraint = emailTextField.heightAnchor.constraint(equalTo: inputContainerView.heightAnchor, multiplier: 1/3)
        emailTextFieldHeightConstraint?.isActive = true
        
        //setup constraints, x, y, width, height
        emailSeparatorView.leftAnchor.constraint(equalTo: inputContainerView.leftAnchor).isActive = true
        emailSeparatorView.topAnchor.constraint(equalTo: emailTextField.bottomAnchor).isActive = true
        emailSeparatorView.widthAnchor.constraint(equalTo: inputContainerView.widthAnchor).isActive = true
        emailSeparatorView.heightAnchor.constraint(equalToConstant: 1).isActive = true
        
        //setup constraints, x, y, width, height
        passwordTextField.leftAnchor.constraint(equalTo: inputContainerView.leftAnchor, constant: 12).isActive = true
        passwordTextField.topAnchor.constraint(equalTo: emailTextField.bottomAnchor).isActive = true
        passwordTextField.widthAnchor.constraint(equalTo: inputContainerView.widthAnchor).isActive = true
        passwordTextFieldHeightConstraint = passwordTextField.heightAnchor.constraint(equalTo: inputContainerView.heightAnchor, multiplier: 1/3)
        passwordTextFieldHeightConstraint?.isActive = true

    }
    
    fileprivate func setupLoginRegisterButton() {
        //setup constraints, x, y, width, height
        loginRegisterButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        loginRegisterButton.topAnchor.constraint(equalTo: inputContainerView.bottomAnchor, constant: 12).isActive = true
        loginRegisterButton.widthAnchor.constraint(equalTo: inputContainerView.widthAnchor).isActive = true
        loginRegisterButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
    }
    
    fileprivate func setupForgetPasswordButton() {
        //setup constraints, x, y, width, height
        forgetPasswordButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        forgetPasswordButton.topAnchor.constraint(equalTo: loginRegisterButton.bottomAnchor, constant: 12).isActive = true
        forgetPasswordButton.widthAnchor.constraint(equalTo: inputContainerView.widthAnchor).isActive = true
        forgetPasswordHeightConstraint = forgetPasswordButton.heightAnchor.constraint(equalToConstant: 0)
        forgetPasswordHeightConstraint?.isActive = true
        forgetPasswordHeightConstraint?.isActive = true

    }

    
    fileprivate func setupProfileImageView() {
        //setup constraints, x, y, width, height
        profileImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        profileImageView.bottomAnchor.constraint(equalTo: loginRegisterSegmentedControl.topAnchor, constant: -20).isActive = true
        profileImageView.widthAnchor.constraint(equalToConstant: 150).isActive = true
        profileImageView.heightAnchor.constraint(equalToConstant: 150).isActive = true
    }
    
    func setupKeyboardObservers(){
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardWillShow), name: .UIKeyboardWillShow, object: nil)
    }
    
    
    func handleKeyboardWillShow(notification: Notification){
        //get keyboard height
        let keyboardFrame = notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as! NSValue
        let height = keyboardFrame.cgRectValue.height
        let move = height/4
        
        let keyboardDuration = notification.userInfo?[UIKeyboardAnimationDurationUserInfoKey] as! NSNumber
        let duration = keyboardDuration.doubleValue
        
        inputContainerCenterYAnchor?.constant = -move
        
        UIView.animate(withDuration: duration) {
            self.view.layoutIfNeeded()
        }
    }
    
    func handleKeyboardWillHide(notification: Notification){
        
        let keyboardDuration = notification.userInfo?[UIKeyboardAnimationDurationUserInfoKey] as! NSNumber
        let duration = keyboardDuration.doubleValue
        inputContainerCenterYAnchor?.constant = 0
        UIView.animate(withDuration: duration) {
            self.view.layoutIfNeeded()
        }
    }
    


}

extension UIColor {
    convenience init(r: CGFloat, g: CGFloat, b: CGFloat) {
        self.init(red: r/255, green: g/255, blue: b/255, alpha: 1)
    }
}
