//
//  ViewController.swift
//  Messenger
//
//  Created by Асанали Батырхан on 30.04.2024.
//

import UIKit
import FirebaseAuth

class ConversationsViewController: UIViewController {

    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        validateAuth()
        
    }
    
    private func validateAuth(){
        if FirebaseAuth.Auth.auth().currentUser == nil {
            let vc = LoginViewController()
            let nav = UINavigationController(rootViewController: vc)
            // modalpresentation is for user to not swipe down when login
            nav.modalPresentationStyle = .fullScreen
            
            present(nav, animated: false)
        }
    }
    
    


}

