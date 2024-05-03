//
//  ViewController.swift
//  Messenger
//
//  Created by Асанали Батырхан on 30.04.2024.
//

import UIKit

class ConversationsViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .red
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        // check if user is logged in
        let isLoggedIn = UserDefaults.standard.bool(forKey: "logged_in")
        
        if !isLoggedIn {
            let vc = LoginViewController()
            let nav = UINavigationController(rootViewController: vc)
            // modalpresentation is for user to not swipe down when login
            nav.modalPresentationStyle = .fullScreen
            
            present(nav, animated: false)
        }
    }
    
    


}

