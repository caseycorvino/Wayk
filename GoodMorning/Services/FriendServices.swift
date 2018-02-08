//
//  FriendServices.swift
//  GoodMorning
//
//  Created by Casey Corvino on 1/12/18.
//  Copyright © 2018 corvino. All rights reserved.
//

import Foundation

var activeRequestedFriendsList:[String] = []

public class FriendServices{
    
    let backendless = Backendless.sharedInstance()
    
    func getFriendsClickedUser(userId: String, view: UIViewController, completionHandler: @escaping ([BackendlessUser])->()){
        
    }
    
    func getFriendCount (userId: String, completionHandler: @escaping (Int)->()) {
        let dataStore = self.backendless?.persistenceService.of(Friend.ofClass())
        let query = DataQueryBuilder().setWhereClause("( friend1 = '\(userId)' OR friend2 = '\(userId)' ) AND verified = '1'")
        dataStore?.getObjectCount(query,
                                  response: {
                                    (objectCount : NSNumber?) -> () in
                                    //print("Found following objects: \(objectCount ?? 0)")
                                    completionHandler((objectCount?.intValue) ?? 0)
        },
                                  error: {
                                    (fault : Fault?) -> () in
                                    print("Server reported an error: \(fault?.description ?? "Unknown fault")")
                                    completionHandler(-1)
        })
    }
    
    func setFriendList(userId: String, completionHandler: @escaping ([String])->()){
        
        var count = 0;
        getFriendCount(userId: userId as String) { (res : Int) in
            count = res
            var friendList:[String] = [];
            let query = DataQueryBuilder().setWhereClause("( friend1 = '\(userId)' OR friend2 = '\(userId)' ) AND verified = 1")
            _ = query?.setPageSize(100).setOffset(0)
            let dataStore = self.backendless?.data.of(Friend.ofClass())
            _ = dataStore?.find(query,
                                response: { (results: [Any]? ) in
                                    
                                    let friendObjects = results as! [Friend]
                                    for f in friendObjects{
                                        if(f.friend1 == userId as String){
                                            friendList.append(f.friend2)
                                        } else if(f.friend2 == userId as String){
                                            friendList.append(f.friend1)
                                        }
                                    }
                                    
                                    self.retrieveNextFriendPage(userId: userId, friendList: friendList, friendCount: count, query: query!, data: dataStore!, completionHandler: { (list: [String]) in
                                        
                                        completionHandler(list)
                                    })
                                    
                                    
            }, error: { (fault: Fault?) in
                print("\(fault?.message ?? "fault"))")
                completionHandler([])
            })
        }
        
    }
    
    
    
    func retrieveNextFriendPage(userId: String, friendList:[String], friendCount: Int, query: DataQueryBuilder, data: IDataStore, completionHandler: @escaping ([String])->()){
        
        var tempList = friendList
        print("\(tempList.count) < \(friendCount) ")
        if(friendList.count < friendCount){
            
            _ = query.prepareNextPage()
            
            data.find(query, response: { (results: [Any]?) in
                let friendObjects = results as! [Friend]
                for f in friendObjects{
                    if(f.friend1 == userId as String){
                        tempList.append(f.friend2)
                    } else if(f.friend2 == userId as String){
                        tempList.append(f.friend1)
                    }
                }
                
                
                self.retrieveNextFriendPage(userId: userId, friendList: tempList, friendCount: friendCount, query: query, data: data, completionHandler: {(list: [String]) in
                    completionHandler(tempList)
                })
                
            }, error: { (fault: Fault?) in
                print(fault?.description ?? "fault")
                completionHandler(tempList)
            })
        } else {
            completionHandler(tempList)
        }
    }
    
    func getAllFriends(userId: String, completionHandler: @escaping ([BackendlessUser])->()){
        setFriendList(userId: userId) { (friends: [String]) in
            var whereClause = "( objectId = "
            for (i, f) in friends.enumerated() {
                if(i != friends.count - 1){
                    whereClause += "'\(f)' OR objectId = "
                } else {
                    whereClause += "'\(f)' )"
                }
            }
            
            let query = DataQueryBuilder().setWhereClause(whereClause)
            _ = query?.setPageSize(100).setOffset(0)
            let dataStore = self.backendless?.data.of(BackendlessUser.ofClass())
            _ = dataStore?.find(query, response: { (results: [Any]?) in
                var count = 0;
                self.getWhereFriendsCount(whereClause: whereClause) { (res : Int) in
                    count = res
                    self.retrieveNextWhereFriendPage(friendList: results as! [BackendlessUser], friendCount: count, query: query!, data: dataStore!, completionHandler: { (results : [BackendlessUser]) in
                        completionHandler(results)
                    })
                }
            },//if error print error
                error: { (fault: Fault?) in
                    print("\(String(describing: fault))")
                    completionHandler([]);
            })
        }
        
    }
    
    
    func retrieveNextWhereFriendPage(friendList:[BackendlessUser], friendCount: Int, query: DataQueryBuilder, data: IDataStore, completionHandler: @escaping ([BackendlessUser])->()){
        
        var tempList = friendList
        if(friendList.count < friendCount){
            _ = query.prepareNextPage()
            
            data.find(query, response: { (results: [Any]?) in
                let friendObjects = results as! [BackendlessUser]
                for f in friendObjects{
                    tempList.append(f)
                }
                
                self.retrieveNextWhereFriendPage(friendList: tempList, friendCount: friendCount, query: query, data: data, completionHandler: {(list: [BackendlessUser]) in
                    completionHandler(tempList)
                })
                
            }, error: { (fault: Fault?) in
                print(fault?.description ?? "fault")
                completionHandler(tempList)
            })
        } else {
            completionHandler(tempList)
        }
        
    }
    
    func getWhereFriendsCount(whereClause: String, completionHandler: @escaping (Int)->()){
        let dataStore = self.backendless?.persistenceService.of(BackendlessUser.ofClass())
        let query = DataQueryBuilder().setWhereClause(whereClause)
        dataStore?.getObjectCount(query,
                                  response: {
                                    (objectCount : NSNumber?) -> () in
                                    //print("Found following objects: \(objectCount ?? 0)")
                                    completionHandler((objectCount?.intValue) ?? 0)
        },
                                  error: {
                                    (fault : Fault?) -> () in
                                    print("Server reported an error: \(fault?.description ?? "Unknown fault")")
                                    completionHandler(-1)
        })
    }
    
    
    func isAlreadyFriended(userId: String, view: UIViewController, completionHandler: @escaping (Friend?)->()){
        let activeUserId = accountServices.getActiveUserId()
        let dataStore = self.backendless?.persistenceService.of(Friend.ofClass())
        let query = DataQueryBuilder().setWhereClause("( friend1 = '\(activeUserId)' AND friend2 = '\(userId)' ) OR ( friend2 = '\(activeUserId)' AND friend1 = '\(userId)' )")
        dataStore?.find(query, response: { (res: [Any]?) in
            if((res?.count)! > 0){
                let results = res as! [Friend]
                print(results)
                completionHandler(results[0])
            } else {
                completionHandler(nil)
            }
        }, error: { (fault: Fault?) in
            helping.displayAlertOK("Server Reported an Error", message: (fault?.message)!, view: view)
            completionHandler(nil)
        })
        
    }
    
    func acceptFriendReq(userId: String, view: UIViewController, completionHandler: @escaping (Bool)->()){
        isAlreadyFriended(userId: userId, view: view) { (fr: Friend?) in
            fr?.verified = true;
            let dataStore = self.backendless?.data.of(Friend.ofClass())
            dataStore?.save(fr, response: { (new: Any?) in
                print((new as! Friend).friend2);
                totalFriendList.append(userId)
                completionHandler(true)
            }, error: { (fault: Fault?) in
                let helping = Helper()
                helping.displayAlertOK("Server Reported an Error", message: (fault?.message)!, view: view)
                completionHandler(false)
            })
        }
    }
    
    func declineFriendReq(userId: String, view: UIViewController, completionHandler: @escaping (Bool)->()){
        
        isAlreadyFriended(userId: userId, view: view) { (fr: Friend?) in
            
            let dataStore = self.backendless?.data.of(Friend.ofClass())
            dataStore?.remove(fr, response: { (new: Any?) in
                print("removing")
                completionHandler(true)
            }, error: { (fault: Fault?) in
                let helping = Helper()
                helping.displayAlertOK("Server Reported an Error", message: (fault?.message)!, view: view)
                completionHandler(false)
            })
        }
    }
    
    
    func setActiveRequestedFriendList(completionHandler: @escaping ([String])->()){
        let activeUserId = (backendless?.userService.currentUser.objectId)!
        
            var friendList:[String] = [];
            let query = DataQueryBuilder().setWhereClause("friend1 = '\(activeUserId)' AND verified = '0'")
            _ = query?.setPageSize(100).setOffset(0)
            let dataStore = self.backendless?.data.of(Friend.ofClass())
            _ = dataStore?.find(query,
                                response: { (results: [Any]? ) in
                                    
                                    let friendObjects = results as! [Friend]
                                    for f in friendObjects{
                                        
                                            friendList.append(f.friend2)
                                        
                                    }
                                    activeRequestedFriendsList = friendList
                                    completionHandler(friendList)
                                    
            }, error: { (fault: Fault?) in
                print("\(fault?.message ?? "fault"))")
                completionHandler([])
            })
        
    }
    
    func getExternalUserRequestedFriendList(completionHandler: @escaping ([String])->()){
        let activeUserId = (backendless?.userService.currentUser.objectId)!
        
        var friendList:[String] = [];
        let query = DataQueryBuilder().setWhereClause("friend2 = '\(activeUserId)' AND verified = '0'")
        _ = query?.setPageSize(100).setOffset(0)
        let dataStore = self.backendless?.data.of(Friend.ofClass())
        _ = dataStore?.find(query,
                            response: { (results: [Any]? ) in
                                
                                let friendObjects = results as! [Friend]
                                for f in friendObjects{
                                    
                                    friendList.append(f.friend1)
                                    
                                }
                                activeRequestedFriendsList = friendList
                                completionHandler(friendList)
                                
        }, error: { (fault: Fault?) in
            print("\(fault?.message ?? "fault"))")
            completionHandler([])
        })
        
    }
    
    func getExternalUsersRequests(view: UIViewController, completionHandler: @escaping ([BackendlessUser])->()){
        
        getExternalUserRequestedFriendList { (userList: [String]) in
        
            if userList.count > 0{
                var whereClause = "objectId = "
                for (i, f) in userList.enumerated() {
                    if(i != userList.count - 1){
                        whereClause += "'\(f)' OR objectId = "
                    } else {
                        whereClause += "'\(f)'"
                    }
                }
                let query = DataQueryBuilder().setWhereClause(whereClause)
                _ = query?.setPageSize(100).setOffset(0)
                let dataStore = self.backendless?.data.of(BackendlessUser.ofClass())
                dataStore?.find(query, response: { (results: [Any]? ) in
                    let requestedFriends = results as! [BackendlessUser]
                    completionHandler(requestedFriends)
                    
                }, error: { (fault: Fault?) in
                    helping.displayAlertOK("Server Reported an Error", message: (fault?.message)!, view: view)
                    completionHandler([])
                })
                
                
            } else {
                completionHandler([])
            }
        }
        
        
    }
    
    func getExternalUsersRequestCount(completionHandler: @escaping (Int)->()){
        
        let activeUserId = (backendless?.userService.currentUser.objectId)!
        
        let query = DataQueryBuilder().setWhereClause("friend2 = '\(activeUserId)' AND verified = '0'")
        let dataStore = self.backendless?.data.of(Friend.ofClass())
        _ = dataStore?.getObjectCount(query,
                                      response: {
                                        (objectCount : NSNumber?) -> () in
                                        //print("Found following objects: \(objectCount ?? 0)")
                                        completionHandler((objectCount?.intValue) ?? 0)
            },
                                      error: {
                                        (fault : Fault?) -> () in
                                        print("Server reported an error: \(fault?.description ?? "Unknown fault")")
                                        completionHandler(-1)
            })
        
    }
    
    
    
    func friendUser(view: UIViewController, userId: String, completionHandler: @escaping(Bool) -> ()) {
        
        isAlreadyFriended(userId: userId, view: view) { (fr: Friend?) in
            if fr != nil{
                fr?.verified = true;
                let dataStore = self.backendless?.data.of(Friend.ofClass())
                dataStore?.save(fr, response: { (new: Any?) in
                    print((new as! Friend).friend2);
                    totalFriendList.append(userId)
                    completionHandler(true)
                }, error: { (fault: Fault?) in
                    let helping = Helper()
                    helping.displayAlertOK("Server Reported an Error", message: (fault?.detail)!, view: view)
                    completionHandler(false)
                })
            } else {
                let activeUserId = (self.backendless?.userService.currentUser.objectId)!
                let newFriend = Friend()
                newFriend.friend1 = "\(activeUserId)"
                newFriend.friend2 = "\(userId)"
                
                let dataStore = self.backendless?.data.of(Friend.ofClass())
                dataStore?.save(newFriend, response: { (new: Any?) in
                    print((new as! Friend).friend2);
                    activeRequestedFriendsList.append(userId)
                    completionHandler(true)
                }, error: { (fault: Fault?) in
                    let helping = Helper()
                    helping.displayAlertOK("Server Reported an Error", message: (fault?.detail)!, view: view)
                    completionHandler(false)
                })
            }
            
        }
    }
    
    func searchForUsers(searchText: String, completionHandler: @escaping ([BackendlessUser])->()){
        var result:[BackendlessUser] = [];
        let dataStore = backendless?.data.of(BackendlessUser.ofClass())
        let query = DataQueryBuilder().setWhereClause("name LIKE '%\(searchText)%'")
        dataStore?.find(query, response: { (anyObjects: [Any]?) in
            for user in anyObjects as! [BackendlessUser]{
                result.append(user)
            }
            completionHandler(result)
        }, error: { (fault: Fault?) in
            print(fault  ?? "fault")
            completionHandler([])
        })
    }
    
}
