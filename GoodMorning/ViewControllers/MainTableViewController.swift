//
//  MainTableViewController.swift
//  GoodMorning
//
//  Created by Casey Corvino on 1/12/18.
//  Copyright © 2018 corvino. All rights reserved.
//

import UIKit

let mainFeedServices = MainFeedServices()

class MainTableViewController: UITableViewController {

    var results:[BackendlessUser] = []
    
    var awake:[BackendlessUser] = []
    var asleep:[BackendlessUser] = []

    var requestCount = 0;
    
    let backendless = Backendless.sharedInstance()
    override func viewDidLoad() {
        super.viewDidLoad()
        mainFeedServices.getAwakeFriends { (awakeUsers: [BackendlessUser]) in
            self.awake = awakeUsers
            self.results = helping.alphabatizeArray(array: self.awake)
            self.tableView.reloadData()
        }
        friendServices.setActiveRequestedFriendList { (_) in
            
        }
        friendServices.getExternalUsersRequestCount { (count: Int) in
           
                self.requestCount = count
                self.tableView.reloadData()
        
        }
        
    }
    
    @IBOutlet var segmentControl: UISegmentedControl!
    
    @IBAction func SegmentSwitched(_ sender: Any) {
        switch segmentControl.selectedSegmentIndex {
        case 0:
            results = awake
            self.results = helping.alphabatizeArray(array: self.awake)
            tableView.reloadData()
            break
        case 1:
            if(asleep == []){
                mainFeedServices.getAsleepFriends(completionHandler: { (asleepFriends: [BackendlessUser]) in
                    self.asleep = asleepFriends
                    self.results = helping.alphabatizeArray(array: self.asleep)
                    self.tableView.reloadData()
                })
            } else {
                results = asleep
                self.results = helping.alphabatizeArray(array: self.asleep)
                self.tableView.reloadData()
            }
            break
        default:
            self.results = helping.alphabatizeArray(array: self.awake)
            tableView.reloadData()
        }
        
    }
    
    var loading = false;
    
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        //let height = scrollView.frame.size.height
        let contentYoffset = scrollView.contentOffset.y
        let distanceFromTop = 0 - contentYoffset;
        if(distanceFromTop > 150 && !loading){
            print("reloading")
            loading = true
            self.reload()
            
        }
        
    }
    
    @IBAction func searchButtonClicked(_ sender: Any) {
        helping.pushViewController(nav: navigationController, story: storyboard, identifier: "SearchVC")
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return results.count + 1
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath == [0,0]{
        if let cell = tableView.dequeueReusableCell(withIdentifier: "MyAccCell", for: indexPath) as? MyAccTableViewCell{
            if let activeUser = backendless?.userService.currentUser{
                cell.nameLabel.text = (activeUser.name)! as String
                cell.profilePicImageView.image = UIImage.init(named: "ic_profile.png")
                accountServices.getProfPicAsync(userId: activeUser.objectId! as String,  completionHandler: {(im: UIImage?)in
                    if im != nil{
                        cell.profilePicImageView.image = im
                    }
                })
                
                cell.requestCount.isHidden = false
                cell.requestCount.text = "\(requestCount)"
                if(requestCount == 0 || requestCount == -1){
                    cell.requestCount.isHidden = true
                }
                
                
                cell.settingsButton.addTarget(self, action: #selector(settingsButtonClicked(sender:)), for: .touchUpInside)
                cell.wakeUpButton.addTarget(self, action: #selector(wakeUpButtonClicked(sender:)), for: .touchUpInside)
                cell.requestsButton.addTarget(self, action: #selector(requestsButtonClicked(sender:)), for: .touchUpInside)
                if(accountServices.isAwake()){
                    cell.wakeUpButton.setTitle("Sleep", for: .normal)
                }
                
                return cell
            }
            
        }
            
        } else {
            if let cell = tableView.dequeueReusableCell(withIdentifier: "listCell", for: indexPath) as? ListCellTableViewCell{
                cell.user = results[indexPath.row - 1]
                cell.nameField.setTitle((cell.user?.name)! as String, for: .normal)
                cell.nameField.tag = indexPath.row
                cell.profilePic.image = UIImage.init(named: "profile.png")
                accountServices.getProfPicAsync(userId: results[indexPath.row - 1].objectId as String, completionHandler: {(im: UIImage?) in
                    if im != nil{
                        cell.profilePic.image = im
                    }
                })
                cell.nameField.addTarget(self, action: #selector(nameButtonClicked(sender:)), for: .touchUpInside)
                return cell
            }
        }
        return UITableViewCell()
    
    }
    
    @objc func settingsButtonClicked(sender: UIButton?) {
        helping.pushViewController(nav: navigationController, story: storyboard, identifier: "SettingsVC")
    }
    
    @objc func wakeUpButtonClicked(sender: UIButton?) {
        if(accountServices.isAwake()){
            accountServices.sleep(view: self, completionHandler: { (b:Bool) in
                if(!b){
                    if let cell = self.tableView.cellForRow(at: [0,0]) as? MyAccTableViewCell{
                        cell.wakeUpButton.setTitle("Wayk up!", for: .normal)
                    }
                }
        })
        } else {
            accountServices.wakeUp(view: self, completionHandler: { (b: Bool) in
                if(b){
                    if let cell = self.tableView.cellForRow(at: [0,0]) as? MyAccTableViewCell{
                        cell.wakeUpButton.setTitle("Sleep", for: .normal)
                    }
                }
            })
        }
        
    }
    
    @objc func requestsButtonClicked(sender: UIButton?) {
        
        helping.pushViewController(nav: navigationController, story: storyboard, identifier: "RequestsVC")
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        friendServices.getExternalUsersRequestCount { (count: Int) in
            
            self.requestCount = count
            self.tableView.reloadData()
            
        }
    }
    
    @objc func nameButtonClicked(sender: UIButton?){
        if let viewController = storyboard?.instantiateViewController(withIdentifier: "ClickedUserVC") as? ClickedUserViewController {
            if let cell = tableView.cellForRow(at: [0,(sender?.tag)!]) as? ListCellTableViewCell{
                viewController.clickedUser = cell.user!
                navigationController?.pushViewController(viewController, animated: true)
            }
        }
    }

    func reload(){
        if segmentControl.selectedSegmentIndex == 0{
            mainFeedServices.getAwakeFriends { (awakeUsers: [BackendlessUser]) in
                self.awake = awakeUsers
                self.results = helping.alphabatizeArray(array: self.awake)
                self.tableView.reloadData()
                let when = DispatchTime.now() + 5 // change 2 to desired number of seconds
                DispatchQueue.main.asyncAfter(deadline: when) {
                    self.loading = false
                }
            }
        } else {
            mainFeedServices.getAsleepFriends { (asleepUsers: [BackendlessUser]) in
                self.asleep = asleepUsers
                self.results = helping.alphabatizeArray(array: self.asleep)
                self.tableView.reloadData()
                let when = DispatchTime.now() + 5 // change 2 to desired number of seconds
                DispatchQueue.main.asyncAfter(deadline: when) {
                    self.loading = false
                }
            }
        }
    }
    
    
    

}
