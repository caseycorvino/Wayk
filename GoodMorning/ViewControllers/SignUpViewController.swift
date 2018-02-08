//
//  SignUpViewController.swift
//  GoodMorning
//
//  Created by Casey Corvino on 1/12/18.
//  Copyright © 2018 corvino. All rights reserved.
//

import UIKit

class SignUpViewController: UIViewController {

    @IBOutlet var emailField: UITextField!
    
    @IBOutlet var nameField: UITextField!
    
    @IBOutlet var passwordField: UITextField!
    
    @IBOutlet var confirmPasswordField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    @IBOutlet var segment: UISegmentedControl!
    
    @IBAction func signUpButtonClicked(_ sender: Any) {
        
        if(segment.selectedSegmentIndex == 1){
        if(passwordField.text! == confirmPasswordField.text!){
            accountServices.registerUser(sEmail: emailField.text!, sPassword: passwordField.text!, sUsername: nameField.text!,  view: self, completionHandler: {
                
            })
        }else{
            helping.displayAlertOK("Invalid Password", message: "Passwords do not match", view: self)
        }
        } else {
            helping.displayAlertOK("Terms Not Accepted", message: "You need to accept the Terms of Services and Privacy Policy in order to sign up", view: self)
        }
        
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    //keyboard dismissed on touches
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true);
    }

}
