//
//  PushNotificationsServices.swift
//  GoodMorning
//
//  Created by Casey Corvino on 1/14/18.
//  Copyright © 2018 corvino. All rights reserved.
//

import Foundation

let pushNotificationsService = PushNotificationsService()


public class PushNotificationsService{
    
    let backendless = Backendless.sharedInstance()
    
    func saveDeviceId(user: BackendlessUser){
        
        user.setProperty("deviceId", object: getCurrentDeviceID())
        backendless?.userService.update(user,
                                          response: {
                                            (_ : BackendlessUser?) -> Void in
                                            
        },
                                          error: {
                                            (fault : Fault?) -> Void in
                                            //helping.displayAlertOK("Server Reported an Error", message: (fault?.message)!, view: view)
                                            print("Server reported an error: \(String(describing: fault?.message))")
        })
    }
    
    func removeDeviceId(user: BackendlessUser){
        user.setProperty("deviceId", object: "none")
        backendless?.userService.update(user,
                                        response: {
                                            (_ : BackendlessUser?) -> Void in
                                            
        },
                                        error: {
                                            (fault : Fault?) -> Void in
                                            //helping.displayAlertOK("Server Reported an Error", message: (fault?.message)!, view: view)
                                            print("Server reported an error: \(String(describing: fault?.message))")
        })
    }
    
    
    func getCurrentDeviceID() -> String {
        let deviceRegistration: DeviceRegistration = backendless!.messaging.currentDevice()
        let deviceId: String = deviceRegistration.deviceId
        return deviceId
    }
    
    func getDeviceRegistration(deviceId: String, completionHandler: @escaping (DeviceRegistration?)->()) {
        backendless?.messaging.getRegistration(
            deviceId,
            response: {
                (registration: DeviceRegistration?) -> Void in
                print("Registration: \(registration ?? DeviceRegistration())")
                if(registration != nil ){
                    completionHandler(registration)
                } else{
                    completionHandler(nil)
                }
        },
            error: {
                (fault: Fault?) -> Void in
                print("Server reported an error: \((fault?.description)!)")
                completionHandler(nil)
        })
    }
    
    
    func publishPushNotification(message: String, deviceId:String) {
        let publishOptions = PublishOptions()
        publishOptions.assignHeaders(["ios-alert": message,
                                      "ios-badge":1, 
                                      "ios-sound":"default"])
        
        let deliveryOptions = DeliveryOptions()
        deliveryOptions.pushSinglecast = [deviceId]
        
        backendless?.messaging.publish(
            "default",
            message: message,
            publishOptions:publishOptions,
            deliveryOptions:deliveryOptions,
            response: {
                (status: MessageStatus?) -> Void in
                print("Status: \(status!)")
        },
            error: {
                (fault: Fault?) -> Void in
                print("Server reported an error: \((fault?.message)!)")
        })
    }
    
    func cancelDeviceRegistration(deviceId: String) {
        backendless?.messaging.unregisterDevice(deviceId,
                                               response: {
                                                (result : Any?) -> Void in
                                                print("Device registration canceled: \(result!)")
        },
                                               error: {
                                                (fault : Fault?) -> Void in
                                                print("Server reported an error: \((fault?.message)!)")
        })
    }
    
}
