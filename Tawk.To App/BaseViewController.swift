//
//  BaseViewController.swift
//  Tawk.To App
//
//  Created by Raghav Kakria on 15/02/22.
//

import UIKit

class BaseViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        // hide back button title
        self.hideBackButtonTitle()
    }
    
    // MARK: - Hide back button title
    
    func hideBackButtonTitle() {
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
    }
}
