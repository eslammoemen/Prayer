//  ViewController.swift
//  prayer
//
//  Created by Eslam Moemen on 10/18/18.
//  Copyright © 2018 Eslam Moemen. All rights reserved.

import UIKit
import Alamofire
import SwiftyJSON

class myViewController: UIViewController {
   
    @IBOutlet weak var leftButton: UIBarButtonItem!
    @IBOutlet weak var rightButton: UIBarButtonItem!
    
    let ApiUrl: String = "http://api.androidhive.info/contacts/"

    override func viewDidLoad() {
        super.viewDidLoad()
       
       networking(url: ApiUrl)
       sideMenues()
       customizeNavBarColor()
    
    }
    
    func networking (url: String){
        
        Alamofire.request(url).responseJSON { (responseData) -> Void in
            if((responseData.result.value) != nil) {
                let swiftyJsonVar = JSON(responseData.result.value!)
                self.parse(json: swiftyJsonVar)
            }
            
        }
        
    }
    
    func parse (json: JSON){
        
        let contactName = json["contacts"][0]["name"]
        print(contactName)
    }

    
    func sideMenues(){
        if revealViewController() != nil {
        //left button animation statements
            leftButton.target = revealViewController()
            leftButton.action = #selector(SWRevealViewController.revealToggle(_:))
            revealViewController()?.rearViewRevealWidth = 275
           
        //right button animation statements
            rightButton.target = revealViewController()
            rightButton.action = #selector(SWRevealViewController.rightRevealToggle(_:))
            revealViewController()?.rightViewRevealWidth = 275

            view.addGestureRecognizer(self.revealViewController()!.panGestureRecognizer())
            
        }
        
    }
    
        
    func customizeNavBarColor(){
        
        navigationController?.navigationBar.tintColor = UIColor(red: 255/255, green: 255/255, blue: 255/255, alpha: 1)
        navigationController?.navigationBar.barTintColor = UIColor(red: 255/255, green: 87/255, blue: 35/255, alpha: 1)
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
        
        
    }
    
    
}

