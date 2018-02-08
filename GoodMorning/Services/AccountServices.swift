//
//  AccountServices.swift
//  GoodMorning
//
//  Created by Casey Corvino on 1/12/18.
//  Copyright © 2018 corvino. All rights reserved.
//

import Foundation


public class AccountServices{
    
    var backendless = Backendless.sharedInstance()
    
    
    func isAwake()->Bool{
        
        let activeUser = backendless?.userService.currentUser
        return activeUser?.getProperty("awake") as! Bool;
        
    }
    
    func wakeUp(view: UIViewController, completionHandler: @escaping(Bool)->()){
        
        let activeUser = backendless?.userService.currentUser
        activeUser?.setProperty("awake", object: true)
        backendless?.userService.update(activeUser, response: { (updatedUser: BackendlessUser?) in
            completionHandler(true)
        }, error: { (fault: Fault?) in
            helping.displayAlertOK("Server Reported an Error", message: (fault?.message)!, view: view)
            completionHandler(false)
        })
        
        
    }
    func sleep(view: UIViewController, completionHandler: @escaping(Bool)->()){

        let activeUser = backendless?.userService.currentUser
        activeUser?.setProperty("awake", object: false)
        backendless?.userService.update(activeUser, response: { (updatedUser: BackendlessUser?) in
            completionHandler(false)
        }, error: { (fault: Fault?) in
            helping.displayAlertOK("Server Reported an Error", message: (fault?.message)!, view: view)
            completionHandler(true)
        })
        
        
    }
    
    
    func checkIfLoggedIn(view:UIViewController, completionHandler: @escaping()->()){
        backendless?.userService.isValidUserToken({
            (result : NSNumber?) -> Void in
            if(result?.boolValue == true){
                view.performSegue(withIdentifier: "loginSuccess", sender: nil)
                completionHandler()
            } else {
                view.performSegue(withIdentifier: "noLogin", sender: nil)
                completionHandler()
            }
            print("Is login valid? - \(result?.boolValue ?? false)")
        },
                                                  error: {
                                                    (fault : Fault?) -> Void in
                                                 
                                                    //helping.displayAlertOK("Server Reported an Error", message: (fault?.message)!, view: view)
                                                    print("Server reported an error: \(fault?.message ?? "fault")")
                                                    view.performSegue(withIdentifier: "noLogin", sender: nil)
                                                    completionHandler()
        })
    }
    func changePassword(view: UIViewController){
        let alert = UIAlertController(title: "Change Password?", message: "A reset password email will be sent", preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction((UIAlertAction(title: "Yes", style: .default, handler: { (action) -> Void in
         self.backendless?.userService.restorePassword((self.backendless?.userService.currentUser.email)! as String,
                                                          response: {
                                                            (result : Any) -> Void in
                                                            helping.displayAlertOK("Email Sent", message: "Please check your email inbox to reset your password", view: view)
                                                            print("Please check your email inbox to reset your password")
            },
                                                          error: {
                                                            (fault : Fault?) -> Void in
                                                            helping.displayAlertOK("Server Reported an Error", message: (fault?.message)!, view: view)
                                                            print("Server reported an error: \(fault?.message ?? "Fault"))")
            })
            
        })))
        alert.addAction((UIAlertAction(title: "No", style: .default, handler: { (action) -> Void in
            alert.dismiss(animated: true, completion: nil)
        })))
        view.present(alert, animated: true, completion: nil)
    }
    
    func logout(view: UIViewController){
        let alert = UIAlertController(title: "Logout?", message: "Are you sure you want to logout?", preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction((UIAlertAction(title: "Yes", style: .default, handler: { (action) -> Void in
            pushNotificationsService.removeDeviceId(user: accountServices.getActiveUser())
            
            self.backendless?.userService.logout({ (result: Any?) in
                print("User has been logged out")
                view.navigationController?.isNavigationBarHidden = true;
                view.performSegue(withIdentifier: "logout", sender: nil)
                alert.dismiss(animated: true, completion: nil)
            },
                                                 error: { (fault: Fault?) in
                                                  
                                                    helping.displayAlertOK("Server Reported an Error", message: (fault?.message)!, view: view)
                                                    print("Server reported an error: \(String(describing: fault?.message))")
                                                    alert.dismiss(animated: true, completion: nil)
            })
            
        })))
        alert.addAction((UIAlertAction(title: "No", style: .default, handler: { (action) -> Void in
            
            alert.dismiss(animated: true, completion: nil)
        })))
        view.present(alert, animated: true, completion: nil)
    }
    
    func resetPassword(email: String, view: UIViewController){
        if(isValidEmail(testStr: email)){
            backendless?.userService.restorePassword(email,
                                                     response: {
                                                        (result : Any) -> Void in
                                                        helping.displayAlertOK("Email Sent", message: "Please check your email inbox to reset your password", view: view)
                                                        print("Please check your email inbox to reset your password")
            },
                                                     error: {
                                                        (fault : Fault?) -> Void in
                                                        helping.displayAlertOK("Server Reported an Error", message: (fault?.message)!, view: view)
                                                        print("Server reported an error: \(fault?.message ?? "Fault"))")
            })
        } else {
            helping.displayAlertOK("Invalid Email", message: "Please check the email field and try again", view: view)
        }
    }
    
    func login(email: String, password: String, view: UIViewController, completionHandler: @escaping ()->()) {
        
        if(isValidEmail(testStr: email) && isValidPassword(testStr: password)){
            backendless?.userService.login(email,
                                           password: password,
                                           response: {
                                            (loggedUser : BackendlessUser?) -> Void in
                                            self.backendless?.userService.setStayLoggedIn(true)
                                            pushNotificationsService.saveDeviceId(user: loggedUser!)
                                            
                                            view.navigationController?.isNavigationBarHidden = false;
                                            view.performSegue(withIdentifier: "loginSuccess", sender: nil)
                                            completionHandler()
            },
                                           error: {
                                            (fault : Fault?) -> Void in
                                            
                                            helping.displayAlertOK("Server Reported an Error", message: (fault?.message)!, view: view)
                                            completionHandler()
            })
            
        } else {
           
            helping.displayAlertOK("Invalid Fields", message: "Please check your entered information and try again", view: view)
            completionHandler()
        }
    }
    
    
    
    func registerUser(sEmail: String, sPassword: String, sUsername: String, view: UIViewController, completionHandler: @escaping ()->()){
        
        if(!isValidEmail(testStr: sEmail) || !isValidPassword(testStr: sPassword) || !isValidUsername(testStr: sUsername)){
            helping.displayAlertOK("Invalid Fields", message: "Please check your fields and try again", view: view)
            completionHandler()
            return;
        }
        let newUser = BackendlessUser()
        newUser.setProperty("email", object: sEmail)
        newUser.name = sUsername as NSString
        newUser.password = sPassword as NSString
        newUser.setProperty("awake", object: false)
        newUser.setProperty("deviceId", object: "none")
        backendless?.userService.register(newUser,
                                          response: {
                                            (registeredUser : BackendlessUser?) -> Void in
                                            
                                            print("User registered \(String(describing: registeredUser?.value(forKey: "email")!))")
                                            helping.displayAlertOK("Success", message: "Sign up successfull. Please go back to the login screen and login", view: view)
                                            completionHandler()
        },
                                          error: {
                                            (fault : Fault?) -> Void in
                                            helping.displayAlertOK("Server Reported an Error", message: (fault?.message)!, view: view)
                                            print("Server reported an error: \(String(describing: fault?.message))")
                                            completionHandler()
                                            
        })
        
        
    }
    
    func getProfPicAsync(userId: String, completionHandler: @escaping (UIImage?)->()){
        //change keys
        if let url = URL(string: "https://api.backendless.com/33C70641-D6A9-683B-FF8D-3986E221BF00/BFC4CB2D-83B3-25A1-FF25-05A95B992E00/files/ProfilePicture/\(userId).jpeg"){
        
        DispatchQueue.global().async {
            if let data = try? Data(contentsOf: url){ //make sure your image in this url does exist, otherwise unwrap in a if let check / try-catch
                DispatchQueue.main.async {
                    completionHandler(UIImage(data: data))
                }} else {
                completionHandler(nil)
            }
        }
        
        } else {
            completionHandler(nil)
        }
        
    }
    
    func getActiveUserId()->String{
        return (backendless?.userService.currentUser.objectId)! as String
    }
    func getActiveUser()->BackendlessUser{
        return (backendless?.userService.currentUser)! as BackendlessUser
    }
    
    func uploadProfilePic(profPic: UIImage, view: UIViewController, completionHandler: @escaping (Bool)->()) -> Void{
        
        print("\n============ Uploading profile picture with the ASYNC API ============")
        
        let compressedPic = profPic.resizeWith(width: 255)
        
        let data = UIImageJPEGRepresentation(compressedPic!, 1)
        
        
        backendless?.file.saveFile("ProfilePicture/\(getActiveUserId()).jpeg", content: data! as Data, overwriteIfExist: true, response: { (file: BackendlessFile?) in
            print("Upload Succesful. File URL is - \(file?.fileURL ?? "PATH ERROR")")
            completionHandler(true)
        }, error: { (fault: Fault?) in
            print("Error: \(fault?.description ?? "Unknown Fault")")
            helping.displayAlertOK("Server Reported an Error", message: (fault?.message)!, view: view)
             completionHandler(false)
        })
        
    }
    
    
    //=================REGEX=========================
    func isValidEmail(testStr:String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailTest.evaluate(with: testStr)
    }
    func isValidUsername(testStr:String) -> Bool {
        let usernameRegEx = "^[a-zA-Z ]{8,18}$"
        let usernameTest = NSPredicate(format:"SELF MATCHES %@", usernameRegEx)
        return usernameTest.evaluate(with: testStr)
    }
    func isValidPassword(testStr: String) -> Bool{
        let passwordRegEx = "^(?=.*[a-z].*[a-z].*[a-z]).{8,30}"
        let passwordTest = NSPredicate(format:"SELF MATCHES %@", passwordRegEx)
        return passwordTest.evaluate(with: testStr)
    }
    
}

extension UIImage {
    func resizeWith(width: CGFloat) -> UIImage? {
        let imageView = UIImageView(frame: CGRect(origin: .zero, size: CGSize(width: width, height: CGFloat(ceil(width/size.width * size.height)))))
        imageView.contentMode = .scaleAspectFit
        imageView.image = self
        UIGraphicsBeginImageContextWithOptions(imageView.bounds.size, false, scale)
        guard let context = UIGraphicsGetCurrentContext() else { return nil }
        imageView.layer.render(in: context)
        guard let result = UIGraphicsGetImageFromCurrentImageContext() else { return nil }
        UIGraphicsEndImageContext()
        return result
    }
}
