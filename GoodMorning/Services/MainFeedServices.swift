//
//  MainFeedServices.swift
//  GoodMorning
//
//  Created by Casey Corvino on 1/12/18.
//  Copyright © 2018 corvino. All rights reserved.
//

import Foundation

var totalFriendList: [String] = []

public class MainFeedServices{
    
    let backendless = Backendless.sharedInstance()
    
    
    func setFriendList(completionHandler: @escaping ([String])->()){
        
        let activeUserId = (backendless?.userService.currentUser.objectId)!
        
        var count = 0;
        getFriendCount(userId: activeUserId as String) { (res : Int) in
            count = res
            var friendList:[String] = [];
            let query = DataQueryBuilder().setWhereClause("( friend1 = '\(activeUserId)' OR friend2 = '\(activeUserId)' ) AND verified = 1")
            _ = query?.setPageSize(100).setOffset(0)
            let dataStore = self.backendless?.data.of(Friend.ofClass())
            _ = dataStore?.find(query,
                                response: { (results: [Any]? ) in
                                    
                                    let friendObjects = results as! [Friend]
                                    for f in friendObjects{
                                        if(f.friend1 == activeUserId as String){
                                            friendList.append(f.friend2)
                                        } else if(f.friend2 == activeUserId as String){
                                            friendList.append(f.friend1)
                                        }
                                    }
                                    
                                    self.retrieveNextFriendPage(friendList: friendList, friendCount: count, query: query!, data: dataStore!, completionHandler: { (list: [String]) in
                                        totalFriendList = list
                                        completionHandler(list)
                                    })
                                    
                                    
            }, error: { (fault: Fault?) in
                print("\(fault?.message ?? "fault"))")
                completionHandler([])
            })
        }
        
    }
    
    
    
    func retrieveNextFriendPage(friendList:[String], friendCount: Int, query: DataQueryBuilder, data: IDataStore, completionHandler: @escaping ([String])->()){
        let activeUserId = (backendless?.userService.currentUser.objectId)!
        var tempList = friendList
        print("\(tempList.count) < \(friendCount) ")
        if(friendList.count < friendCount){

           _ = query.prepareNextPage()
        
            data.find(query, response: { (results: [Any]?) in
                let friendObjects = results as! [Friend]
                for f in friendObjects{
                    if(f.friend1 == activeUserId as String){
                        tempList.append(f.friend2)
                    } else if(f.friend2 == activeUserId as String){
                        tempList.append(f.friend1)
                    }
                }
                
                
                self.retrieveNextFriendPage(friendList: tempList, friendCount: friendCount, query: query, data: data, completionHandler: {(list: [String]) in
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
    
    func getAwakeFriends(completionHandler: @escaping ([BackendlessUser])->()){
        setFriendList { (friends: [String]) in
            var whereClause = "( objectId = "
            for (i, f) in friends.enumerated() {
                if(i != friends.count - 1){
                    whereClause += "'\(f)' OR objectId = "
                } else {
                    whereClause += "'\(f)' )"
                }
            }
            whereClause += " AND awake = 1"
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
    
    func getAsleepFriends(completionHandler: @escaping ([BackendlessUser])->()){
        setFriendList { (friends: [String]) in
            var whereClause = "( objectId = "
            for (i, f) in friends.enumerated() {
                if(i != friends.count - 1){
                    whereClause += "'\(f)' OR objectId = "
                } else {
                    whereClause += "'\(f)' )"
                }
            }
            whereClause += " AND awake = '0'"
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
    
    
    
    
    
}
