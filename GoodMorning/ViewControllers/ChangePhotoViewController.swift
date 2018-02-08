//
//  ChangePhotoViewController.swift
//  GoodMorning
//
//  Created by Casey Corvino on 1/13/18.
//  Copyright © 2018 corvino. All rights reserved.
//

import UIKit

class ChangePhotoViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate{

    @IBOutlet var profilePic: UIImageView!
    
    var changed = false
    
    let picker = UIImagePickerController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        picker.delegate = self
        helping.putBorderOnButton(buttonView: profilePic, radius: 64)
        self.profilePic.image = UIImage.init(named: "ic_profile.png")
        accountServices.getProfPicAsync(userId: accountServices.getActiveUserId(), completionHandler: { (im: UIImage?) in
            if im != nil{
                self.profilePic.image = im
            }
        })
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func selectPhotoButtonClicked(_ sender: Any) {
        picker.allowsEditing = false;
        picker.sourceType = .photoLibrary
        picker.modalPresentationStyle = .popover
        //picker.mediaTypes = UIImagePickerController.availableMediaTypes(for: .photoLibrary)!
        present(picker, animated: true, completion: nil)
    }
    
    @IBAction func confirmChangeButtonClicked(_ sender: Any) {
        if(changed){
            
            accountServices.uploadProfilePic(profPic: profilePic.image!, view: self, completionHandler: { (res: Bool) in
                if(res){
                    self.dismiss(animated: true, completion: nil)
                }
            })
            
        } else {
            helping.displayAlertOK("No New Photo Selected", message: "You need to select a new photo to chang your profile pic", view: self)
        }
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
            profilePic.image = image
            changed = true
        } else{
            print("Error loading image from camera roll")
        }
        dismiss(animated:true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
        
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
