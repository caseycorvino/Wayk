//
//  ClickedUserViewController.swift
//  GoodMorning
//
//  Created by Casey Corvino on 1/13/18.
//  Copyright © 2018 corvino. All rights reserved.
//

import UIKit

class ClickedUserViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet var profilePicView: UIImageView!
    
    @IBOutlet var nameLabel: UILabel!
    
    @IBOutlet var awaykButton: UIButton!
    
    @IBOutlet var tableView: UITableView!
    
    
    var friends: [BackendlessUser] = []
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return friends.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "SearchCell") as? SearchTableViewCell{
            cell.user = friends[indexPath.row]
            cell.name.tag = indexPath.row
            cell.name.setTitle((cell.user?.name)! as String, for: .normal)
            cell.profilePicImageView.image = UIImage.init(named: "profile.png")
            accountServices.getProfPicAsync(userId: (cell.user?.objectId)! as String, completionHandler: {(im: UIImage?)in
                if(im != nil){
                    cell.profilePicImageView.image = im
                }
            })
            cell.name.addTarget(self, action: #selector(self.nameButtonClicked(sender:)), for: .touchUpInside)
            if(totalFriendList.contains((cell.user?.objectId)! as String) || activeRequestedFriendsList.contains((cell.user?.objectId)! as String) || (cell.user?.objectId)! as String == accountServices.getActiveUserId()){
                print("friends already")
                cell.friendButton.isHidden = true
            } else {
                cell.friendButton.tag = indexPath.row
                cell.friendButton.addTarget(self, action: #selector(self.friendButtonClicked(sender:)), for: .touchUpInside)
            }
            
            return cell
        }
        return UITableViewCell()
    }
    
    @objc func friendButtonClicked(sender: UIButton?) {
        UIApplication.shared.beginIgnoringInteractionEvents()
        let cell = tableView.cellForRow(at: [0,(sender?.tag)!]) as! SearchTableViewCell
        if(!totalFriendList.contains((cell.user?.objectId)! as String)){
            friendServices.friendUser(view: self, userId: (cell.user?.objectId)! as String, completionHandler: { (res: Bool) in
                if(res){
                    cell.friendButton.isHidden = true
                    
                    if let deviceId = cell.user?.getProperty("deviceId") as? String{
                        if deviceId != "none" {
                            pushNotificationsService.publishPushNotification(message: "New Friend Request!", deviceId: cell.user?.getProperty("deviceId") as! String)
                        }
                    }
                    
                    
                }
                
                UIApplication.shared.endIgnoringInteractionEvents()
            })
        }
        
    }
    
    @objc func nameButtonClicked(sender: UIButton?){
        if let viewController = storyboard?.instantiateViewController(withIdentifier: "ClickedUserVC") as? ClickedUserViewController {
            if let cell = tableView.cellForRow(at: [0,(sender?.tag)!]) as? SearchTableViewCell{
                viewController.clickedUser = cell.user!
                navigationController?.pushViewController(viewController, animated: true)
            }
        }
    }

    public var clickedUser = BackendlessUser()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        awaykButton.isEnabled = false
        helping.putBorderOnButton(buttonView: awaykButton, radius: 20)
        helping.putBorderOnButton(buttonView: profilePicView, radius: 50)
        profilePicView.image = UIImage(named: "ic_profile.png")
        accountServices.getProfPicAsync(userId: (clickedUser.objectId)! as String) { (im: UIImage?) in
            if im != nil{
                self.profilePicView.image = im
            }
        }
        if let awake = clickedUser.getProperty("awake") as? Bool{
            if !awake{
                awaykButton.setTitle("Asleep", for: .normal)
            }
        }
        nameLabel.text = (clickedUser.name)! as String
        // Do any additional setup after loading the view.
        
        friendServices.getAllFriends(userId: (clickedUser.objectId)! as String) { (results: [BackendlessUser]) in
            self.friends = helping.alphabatizeArray(array: results)
            self.tableView.reloadData()
        }
        
        if(totalFriendList.contains((clickedUser.objectId)! as String)){
            bottomFriendButton.setTitle("Unfriend", for: .normal)
        }
        if(activeRequestedFriendsList.contains((clickedUser.objectId)! as String)){
            bottomFriendButton.setTitle("Unfriend", for: .normal)
        }
        
        if((clickedUser.objectId)! as String == accountServices.getActiveUserId()){
            bottomFriendButton.isHidden = true
        }
        
        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBOutlet var bottomFriendButton: UIButton!
    @IBAction func bottomFriendButtonClicked(_ sender: Any) {
        UIApplication.shared.beginIgnoringInteractionEvents()
        if(totalFriendList.contains((clickedUser.objectId)! as String) || activeRequestedFriendsList.contains((clickedUser.objectId)! as String)){
            friendServices.declineFriendReq(userId: clickedUser.objectId as String, view: self, completionHandler: { (res:Bool) in
                if res{
                    if(totalFriendList.contains((self.clickedUser.objectId)! as String)){
                        totalFriendList.remove(at: helping.stringInArray(str: (self.clickedUser.objectId)! as String, arr: totalFriendList))
                    }
                    if(activeRequestedFriendsList.contains((self.clickedUser.objectId)! as String)){
                        activeRequestedFriendsList.remove(at: helping.stringInArray(str: (self.clickedUser.objectId)! as String, arr: activeRequestedFriendsList))
                    }
                    
                    self.bottomFriendButton.setTitle("+ Friend", for: .normal)
                    UIApplication.shared.endIgnoringInteractionEvents()

                }
            })
        } else {
            friendServices.friendUser(view: self, userId: (clickedUser.objectId)! as String, completionHandler: { (res:Bool) in
                if res{
                    self.bottomFriendButton.setTitle("Unfriend", for: .normal)
                    if let deviceId = self.clickedUser.getProperty("deviceId") as? String{
                        if deviceId != "none" {
                            pushNotificationsService.publishPushNotification(message: "New Friend Request!", deviceId: self.clickedUser.getProperty("deviceId") as! String)
                        }
                    }
                    
                    
                    
                }
                UIApplication.shared.endIgnoringInteractionEvents()
            })
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

}
