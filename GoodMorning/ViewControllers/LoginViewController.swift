//
//  LoginViewController.swift
//  GoodMorning
//
//  Created by Casey Corvino on 1/12/18.
//  Copyright © 2018 corvino. All rights reserved.
//

import UIKit

let accountServices = AccountServices()
let helping = Helper()

class LoginViewController: UIViewController {
    
    @IBOutlet var passwordField: UITextField!
    
    @IBOutlet var emailField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func loginButtonClicked(_ sender: Any) {
        
        accountServices.login(email: emailField.text!, password: passwordField.text!, view: self, completionHandler: {
            
            })
        
        
    }
    
    //keyboard dismissed on touches
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true);
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
