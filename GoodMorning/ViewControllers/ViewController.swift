//
//  ViewController.swift
//  GoodMorning
//
//  Created by Casey Corvino on 1/10/18.
//  Copyright © 2018 corvino. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
    }

    override func viewDidAppear(_ animated: Bool) {
        accountServices.checkIfLoggedIn(view: self, completionHandler: {
            
        })

    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

