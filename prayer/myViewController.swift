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
    @IBOutlet weak var remainingTime: UILabel!
    
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
   // var array = [Int]()

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
        minutesLabel.text = "\(minutes)"
        secondsLabel.text = "\(seconds)"
        //customizeNavBarColor()
    
    }
    
    
    func getTimeAsInt(string: String)-> String{
        
        let replaced = string.replacingOccurrences(of: " (EET)", with: "")
       
        
        
        return replaced
    }
    
    
    var onlyHours = 0
    var onlyMinutes = 0
    
    func calHours(time1: String ,time2: String){
       
        
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        
        let date1 = formatter.date(from: time1)!
        let date2 = formatter.date(from: time2)!
        
        let elapsedTime = date2.timeIntervalSince(date1)
        
        let hours = floor(elapsedTime / 60 / 60)
        let minutesOutput = floor((elapsedTime - (hours * 60 * 60)) / 60)
        
        let hoursModified = String(hours)
        let result = hoursModified.replacingOccurrences(of: "-", with: "")
        let doubleResult = Double(result)
        
        onlyHours = Int(doubleResult!-1)
        onlyMinutes = Int(minutesOutput-1)
        
        
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
            minutesLabel.text = "\(minutes)"
            
        }
        if minutes == 0 {
            seconds = 60
            minutes = 60
            hours -= 1
            hoursLabel.text = "\(hours)"

        }
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
        
        
        
        hijriDate.text = "\(dayname) - \(daynum) \(month)"
        year.text = " هـ \(json["data"][day-1]["date"]["hijri"]["year"].stringValue)"
       
        let fajrInt = getTimeAsInt(string: json["data"][day-1]["timings"]["Fajr"].stringValue)
        fajrTime.text = fajrInt
        
        let shorouqInt = getTimeAsInt(string: json["data"][day-1]["timings"]["Sunrise"].stringValue)
        shorouqTime.text = shorouqInt
        
        let duhrInt = getTimeAsInt(string: json["data"][day-1]["timings"]["Dhuhr"].stringValue)
        duhrTime.text = duhrInt
       
        let asrInt = getTimeAsInt(string: json["data"][day-1]["timings"]["Asr"].stringValue)
        asrTime.text = asrInt
        
        let maghribInt = getTimeAsInt(string: json["data"][day-1]["timings"]["Maghrib"].stringValue)
        maghribTime.text = maghribInt
        
        let ishaInt = getTimeAsInt(string: json["data"][day-1]["timings"]["Isha"].stringValue)
        ishaTime.text = ishaInt
        
        print(hours,minutes)
        print(fajrInt)
        if hours >= 18 || hours <= 5 {
            remainingTime.text = "متبقي علي صلاة الفجر"
            calHours(time1: "\(fajrInt)", time2: "\(hours-12):\(minutes)")
            if hours >= 0 && hours <= 5 {
                calHours(time1: "\(fajrInt)", time2: "\(hours):\(minutes)")

            }
            hoursLabel.text = String(onlyHours)
            minutesLabel.text = String(onlyMinutes)
            
        }else if hours > 12 || hours <= 15 {
            remainingTime.text = "متبقي علي صلاة العصر"
            calHours(time1: "\(asrInt)", time2: "\(hours):\(minutes)")
            
            hoursLabel.text = String(onlyHours)
            minutesLabel.text = String(onlyMinutes)
            
            
        }
        
        print("system \(hours):\(minutes)")
        print(" asr \(asrInt)")
        print(calHours(time1: "\(asrInt)", time2:"\(hours):\(minutes)"))

        
        
        
    }

    
    func sideMenues(){
        if revealViewController() != nil {
        //left button animation statements
            leftButton.target = revealViewController()
            leftButton.action = #selector(SWRevealViewController.revealToggle(_:))
            revealViewController()?.rearViewRevealWidth = 210
           
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

