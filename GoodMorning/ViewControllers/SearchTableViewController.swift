//
//  SearchTableViewController.swift
//  GoodMorning
//
//  Created by Casey Corvino on 1/12/18.
//  Copyright © 2018 corvino. All rights reserved.
//

import UIKit

let friendServices = FriendServices()

class SearchTableViewController: UITableViewController,  UISearchBarDelegate {

    var results:[BackendlessUser] = [];
    var filteredResults:[BackendlessUser] = [];
    
    @IBOutlet var searchBar: UISearchBar!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredResults.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "SearchCell", for: indexPath) as? SearchTableViewCell{
            cell.user = filteredResults[indexPath.row]
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
    
    //keyboard dismissed on scroll
    override func  scrollViewDidScroll(_ scrollView: UIScrollView) {
        self.searchBar.endEditing(true)
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        filteredResults = [];
        for user in results{
            if user.name.lowercased.contains(searchText.lowercased())
            {
                filteredResults.append(user);
            }
        }
        tableView.reloadData()
    }
    
    //keyboard dismissed on search clicked
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        self.searchBar.endEditing(true);
        friendServices.searchForUsers(searchText: searchBar.text!) { (users: [BackendlessUser]?) in
            if users != nil{
                self.results = users!
                self.filteredResults = users!
                self.tableView.reloadData();
            } else {
                self.results = [];
                self.filteredResults = [];
                self.tableView.reloadData();
            }
        }
        
    }

}
