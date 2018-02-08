//
//  SettingsViewController.swift
//  GoodMorning
//
//  Created by Casey Corvino on 1/12/18.
//  Copyright © 2018 corvino. All rights reserved.
//

import UIKit

class SettingsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate{
    
    let settings = ["Change Photo", "Change Password", "Share Wayk!", "Terms of Services", "Privacy Policy"]
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return settings.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = UITableViewCell()
        cell.textLabel?.text = settings[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        switch indexPath {
        case [0,0]:
            helping.pushViewController(nav: navigationController, story: storyboard, identifier: "ChangePhotoVC")
            break;
        case [0,1]:
            changePassword()
            break;
        case [0,2]:
            shareWayk()
            break;
        case [0,3]:
            helping.pushViewController(nav: navigationController, story: storyboard, identifier: "TermsVC")
            break;
        case [0,4]:
            helping.pushViewController(nav: navigationController, story: storyboard, identifier: "PrivacyVC")
            break;
        default:
            break;
        }
        
    }
    
    func shareWayk(){
        print("sh")
        let text = "Yo!. Check out Wayk! http://applink.co".addingPercentEncoding(withAllowedCharacters: CharacterSet.urlHostAllowed)!
        if let url = URL(string: "sms:&body=\(text)") {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
            
        }
    }
    
    
    func changePassword() {
        let alert = UIAlertController(title: "Change Password?", message: "Are you sure you want to change your password? An email will be sent to reset your password", preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction((UIAlertAction(title: "Yes", style: .default, handler: { (action) -> Void in
            accountServices.resetPassword(email: accountServices.getActiveUser().email as String, view: self)
            alert.dismiss(animated: true, completion: nil)
        })))
        alert.addAction((UIAlertAction(title: "No", style: .default, handler: { (action) -> Void in
            alert.dismiss(animated: true, completion: nil)
        })))
        
        self.present(alert, animated: true, completion: nil)
    }

    @IBOutlet var wakeUpButton: UIButton!
    
    @IBOutlet var nameLabel: UILabel!
    
    @IBOutlet var profilePicImageView: UIImageView!
    
    @IBOutlet var requestCount: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        helping.putBorderOnButton(buttonView: profilePicImageView, radius: 50)
        
        nameLabel.text = accountServices.getActiveUser().name as String
        if accountServices.isAwake(){
            wakeUpButton.setTitle("Sleep", for: .normal)
        }
        self.profilePicImageView.image = UIImage.init(named: "ic_profile.png")
        accountServices.getProfPicAsync(userId: accountServices.getActiveUserId()) {(im: UIImage?) in
            if im != nil{
                self.profilePicImageView.image = im
            } 
        }
        helping.putBorderOnButton(buttonView: wakeUpButton, radius: 20)
        
        helping.putBorderOnButton(buttonView: requestCount, radius: 10)
        friendServices.getExternalUsersRequestCount { (count: Int) in
            if(count == 0 || count == -1){
                self.requestCount.isHidden = true;
            } else {
                self.requestCount.text = "\(count)"
            }
        }
        
        // Do any additional setup after loading the view.
    }

    
    override func viewWillAppear(_ animated: Bool) {
        self.requestCount.isHidden = false;
        friendServices.getExternalUsersRequestCount { (count: Int) in
            if(count == 0 || count == -1){
                self.requestCount.isHidden = true;
            } else {
                self.requestCount.text = "\(count)"
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    @IBAction func requestsButtonClicked(_ sender: Any) {
        helping.pushViewController(nav: navigationController, story: storyboard, identifier: "RequestsVC")
    }
    
    @IBAction func logoutButtonClicked(_ sender: Any) {
        accountServices.logout(view: self)
    }
    
    
    @IBAction func wakeUpButtonClicked(_ sender: Any) {
        if(accountServices.isAwake()){
            accountServices.sleep(view: self, completionHandler: { (b:Bool) in
                if(!b){
                    self.wakeUpButton.setTitle("Wayk up!", for: .normal)
                }
            })
        } else {
            accountServices.wakeUp(view: self, completionHandler: { (b: Bool) in
                if(b){
                        self.wakeUpButton.setTitle("Sleep", for: .normal)
                }
            })
        }
    }
    
}
