//
//  Helper.swift
//  GoodMorning
//
//  Created by Casey Corvino on 1/12/18.
//  Copyright © 2018 corvino. All rights reserved.
//

import Foundation

public class Helper {
    
    func alphabatizeArray(array: [BackendlessUser])->[BackendlessUser]{
        
        return array.sorted { ($0.name as String) < ($1.name as String) }
        
    }
    
    func stringInArray(str: String, arr: [String])->Int{
        for (index, element) in arr.enumerated() {
            if(element == str){
                return index;
            }
        }
        return -1;
    }
    
    //==================buttons==================//
    func putBorderOnButton(buttonView: UIView, radius: Int ){
        buttonView.layer.borderWidth = 2
        buttonView.layer.cornerRadius = CGFloat(radius)
        buttonView.layer.borderColor = UIColor.white.cgColor
        buttonView.layer.masksToBounds = true;
    }
    ///===========text field=======================//
    func underlineTextField(field : UITextField){
        field.isEnabled = true;
        let border = CALayer()
        let width = CGFloat(2.0)
        border.borderColor = UIColor.black.cgColor
        border.frame = CGRect(x: 0, y: field.frame.size.height - width, width:  field.frame.size.width, height: 1)
        
        border.borderWidth = width
        field.layer.addSublayer(border)
    }
    
    //===========Dispay Alert==============//
    
    func displayAlertOK(_ title: String, message: String, view :UIViewController) {
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction((UIAlertAction(title: "OK", style: .default, handler: { (action) -> Void in
            
            alert.dismiss(animated: true, completion: nil)
        })))
        
        view.present(alert, animated: true, completion: nil)
    }
    func pushViewController(nav: UINavigationController?, story: UIStoryboard?, identifier: String){
        let viewController = story?.instantiateViewController(withIdentifier: identifier) as UIViewController!
        nav?.pushViewController(viewController!, animated: true)
    }
}
