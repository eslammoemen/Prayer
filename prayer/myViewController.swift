//  ViewController.swift
//  prayer
//
//  Created by Eslam Moemen on 10/18/18.
//  Copyright © 2018 Eslam Moemen. All rights reserved.
import Foundation
import UIKit
import Alamofire
import SwiftyJSON
import CoreLocation

class myViewController: UIViewController,CLLocationManagerDelegate {
    @IBOutlet weak var hijriDate: UILabel!
    @IBOutlet weak var year: UILabel!
    @IBOutlet weak var fajrTime: UILabel!
    @IBOutlet weak var shorouqTime: UILabel!
    @IBOutlet weak var duhrTime: UILabel!
    @IBOutlet weak var asrTime: UILabel!
    @IBOutlet weak var maghribTime: UILabel!
    @IBOutlet weak var ishaTime: UILabel!
    
    @IBOutlet weak var leftButton: UIBarButtonItem!
    @IBOutlet weak var rightButton: UIBarButtonItem!
    @IBOutlet weak var hoursLabel: UILabel!
    @IBOutlet weak var minutesLabel: UILabel!
    @IBOutlet weak var secondsLabel: UILabel!
    
    let locationManager = CLLocationManager()
    let date = Date()
    let calendar = Calendar.current
    

    
    
    
    
    var timer = Timer()
    var isTimerRunning = false
    var array = [Int]()

    lazy var hours = calendar.component(.hour, from: date)
    lazy var minutes = calendar.component(.minute, from: date)
    lazy var seconds = calendar.component(.second, from: date)
    lazy var yearnum = calendar.component(.year, from: date)
    lazy var month = calendar.component(.month, from: date)
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        sideMenues()
        runTimer()
        
        hoursLabel.text = "\(hours)"
        minutesLabel.text = ":\(minutes):"
        secondsLabel.text = "\(seconds)"
        //customizeNavBarColor()
    
    }
    
   
    
    func runTimer() {
        timer = Timer.scheduledTimer(timeInterval: 1, target: self,   selector: (#selector(self.updateTimer)), userInfo: nil, repeats: true)
        
       
    }
    
    
    @objc func updateTimer() {
        
          seconds -= 1
         secondsLabel.text = "\(seconds)"
        
        
        if seconds == 0 {
            seconds = 60
            minutes -= 1
            minutesLabel.text = ":\(minutes):"
            
        }
        if minutes == 0 {
            seconds = 60
            minutes = 60
            hours -= 1
            hoursLabel.text = "\(hours)"

        }
    }
    
    func getTimeAsInt(string: String)-> Int{
        var done = 0
        if let converted = Int(string.components(separatedBy: CharacterSet.decimalDigits.inverted).joined()) {

            done = converted
        }
        
        return done
    }
        
    
    
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation])  {
        let location = locations[locations.count - 1]
        if location.horizontalAccuracy > 0 {
            
            self.locationManager.stopUpdatingLocation()
            
            //print("longitude = \(location.coordinate.longitude), latitude = \(location.coordinate.latitude)")
            
            let latitude = String(location.coordinate.latitude)
            let longitude = String(location.coordinate.longitude)
            
            networking(longtitude:longitude , lattitude:latitude )
        }
        
    }
    
    func networking (longtitude: String, lattitude: String){
        
        
        
        Alamofire.request("http://api.aladhan.com/v1/calendar?latitude=\(lattitude)&longitude=\(longtitude)&method=2&month=\(month)&year=\(yearnum)").responseJSON { (responseData) -> Void in
            if((responseData.result.value) != nil) {
                let swiftyJsonVar = JSON(responseData.result.value!)
                self.parse(json: swiftyJsonVar)
            }else{
                print("URL Error")
            }
            
        }
        
    }
   
    
    func parse (json :JSON){
        let day = calendar.component(.day, from: date)

        
        
        
        
        let dayname = json["data"][day-1]["date"]["hijri"]["weekday"]["ar"].stringValue
        let month = json["data"][day-1]["date"]["hijri"]["month"]["ar"].stringValue
        let daynum = json["data"][day-1]["date"]["hijri"]["day"].stringValue
        
        let test = json["data"][day-1]["timings"]["Maghrib"].stringValue
        
        print(getTimeAsInt(string: test))
        
        
        hijriDate.text = "\(dayname) - \(daynum) \(month)"
        year.text = " هـ \(json["data"][day-1]["date"]["hijri"]["year"].stringValue)"
        fajrTime.text = json["data"][day-1]["timings"]["Fajr"].stringValue
        shorouqTime.text = json["data"][day-1]["timings"]["Sunrise"].stringValue
        duhrTime.text = json["data"][day-1]["timings"]["Dhuhr"].stringValue
        asrTime.text = json["data"][day-1]["timings"]["Asr"].stringValue
        maghribTime.text = json["data"][day-1]["timings"]["Maghrib"].stringValue
        ishaTime.text = json["data"][day-1]["timings"]["Isha"].stringValue

        
        
        
        
    }

    
    func sideMenues(){
        if revealViewController() != nil {
        //left button animation statements
            leftButton.target = revealViewController()
            leftButton.action = #selector(SWRevealViewController.revealToggle(_:))
            revealViewController()?.rearViewRevealWidth = 275
           
//        //right button animation statements
//            rightButton.target = revealViewController()
//            rightButton.action = #selector(SWRevealViewController.rightRevealToggle(_:))
//            revealViewController()?.rightViewRevealWidth = 275

            view.addGestureRecognizer(self.revealViewController()!.panGestureRecognizer())
            
        }
        
    }
    
        
//    func customizeNavBarColor(){
//
//        navigationController?.navigationBar.tintColor = UIColor(red: 255/255, green: 255/255, blue: 255/255, alpha: 1)
//        navigationController?.navigationBar.barTintColor = UIColor(red: 255/255, green: 87/255, blue: 35/255, alpha: 1)
//        navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
//
//
//    }
    
    
}

