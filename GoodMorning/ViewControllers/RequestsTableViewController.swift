//
//  RequestsTableViewController.swift
//  GoodMorning
//
//  Created by Casey Corvino on 1/12/18.
//  Copyright © 2018 corvino. All rights reserved.
//

import UIKit

class RequestsTableViewController: UITableViewController {

    var results: [BackendlessUser] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        friendServices.getExternalUsersRequests(view: self) { (users: [BackendlessUser]) in
            self.results = users
            print(self.results)
            self.tableView.reloadData()
        }
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
        return results.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "requestCell", for: indexPath) as? RequestTableViewCell{
            
            cell.acceptButton.addTarget(self, action: #selector(acceptButtonClicked(sender:)), for: .touchUpInside)
            cell.declineButton.addTarget(self, action: #selector(declineButtonClicked(sender:)), for: .touchUpInside)
            cell.nameLabel.setTitle(results[indexPath.row].name as String, for: .normal)
            cell.user = results[indexPath.row]
            cell.profilePicImageView.image = UIImage.init(named: "profile.png")
            accountServices.getProfPicAsync(userId: (cell.user?.objectId)! as String,  completionHandler: {(im: UIImage?) in
                if(im != nil){
                    cell.profilePicImageView.image = im
                }
                
            })
            return cell
        }
        return UITableViewCell()
    }
 
    
    @objc func acceptButtonClicked(sender: UIButton?) {
        if let cell = tableView.cellForRow(at: [0, (sender?.tag)!]) as? RequestTableViewCell{
            friendServices.acceptFriendReq(userId: (cell.user?.objectId)! as String, view: self) {(res: Bool) in
                if(res){
                    self.results.remove(at: (sender?.tag)!)
                    self.tableView.reloadData()
                }
            }
        }
        
        
    }
    @objc func declineButtonClicked(sender: UIButton?) {
        
        if let cell = tableView.cellForRow(at: [0, (sender?.tag)!]) as? RequestTableViewCell{
            friendServices.declineFriendReq(userId: (cell.user?.objectId)! as String, view: self, completionHandler: {(res: Bool) in
                if(res){
                    self.results.remove(at: (sender?.tag)!)
                    self.tableView.reloadData()
                }
            })
        }
        
        
    }
   

}
