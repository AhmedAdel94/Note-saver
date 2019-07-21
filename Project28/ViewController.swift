//
//  ViewController.swift
//  Project28
//
//  Created by Ahmed Adel on 7/21/19.
//  Copyright © 2019 Ahmed Adel. All rights reserved.
//

import UIKit
import LocalAuthentication

class ViewController: UIViewController {

    @IBOutlet weak var secret: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self,selector: #selector(adjustForKeyboard) , name: UIResponder.keyboardWillHideNotification , object: nil)
        notificationCenter.addObserver(self,selector: #selector(adjustForKeyboard) , name: UIResponder.keyboardWillChangeFrameNotification , object: nil)
        
        title = "Nothing to see here"
        
        notificationCenter.addObserver(self, selector: #selector(saveSecretMessage), name: UIApplication.willResignActiveNotification, object: nil)
    }
    
    @objc func adjustForKeyboard(notification:Notification)
    {
        guard let keyboardValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else {return}
        
        let keyboardScreenEndFrame = keyboardValue.cgRectValue
        let keyboardViewEndFrame = view.convert(keyboardScreenEndFrame, from:view.window)
        
        if notification.name == UIResponder.keyboardWillHideNotification{
            secret.contentInset = .zero
        }else{
            secret.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: keyboardViewEndFrame.height - view.safeAreaInsets.bottom, right: 0)
        }
        
        secret.scrollIndicatorInsets = secret.contentInset
        
        let selectedRange = secret.selectedRange
        secret.scrollRangeToVisible(selectedRange)
    }
    
    
    @IBAction func authenticateTapped(_ sender: UIButton) {
        let context = LAContext()
        var error:NSError?
        
        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error){
            let reason = "Identify Yourself!"
            
            context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason){
                [weak self] success , authenticationError in
                
                DispatchQueue.main.async {
                    if success{
                        self?.unlockSecretMessage()
                    }else{
                        let ac = UIAlertController(title: "Authentication Failed", message: "You could not be verified , please try again", preferredStyle: .alert)
                        ac.addAction(UIAlertAction(title: "OK", style: .default))
                        self?.present(ac,animated: true)
                    }
                }
            }
        }else{
            let ac = UIAlertController(title: "Bimoetry unavailable", message: "Your device doesn't support biometric authentication", preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "OK", style: .default))
            self.present(ac,animated: true)
        }
    }
    
    func unlockSecretMessage()
    {
        secret.isHidden = false
        title = "Secret Stuff!"
        
        if let text = KeychainWrapper.standard.string(forKey: "SecretMessage"){
            secret.text = text
        }
    }
    
    @objc func saveSecretMessage()
    {
        guard secret.isHidden == false else {return}
        
        KeychainWrapper.standard.set(secret.text, forKey: "SecretMessage")
        secret.resignFirstResponder()
        secret.isHidden = true
        title = "Nothing to see here"
    }
    

}

