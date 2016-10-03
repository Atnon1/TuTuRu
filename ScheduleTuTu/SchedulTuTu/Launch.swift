//
//  Launch.swift
//  SchedulTuTu
//
//  Created by Admin on 29.09.16.
//  Copyright © 2016 MakeY. All rights reserved.
//

import Foundation
import UIKit

class LaunchController : UIViewController {
    var stations=[String]()
    override func viewDidLoad(){
        super.viewDidLoad()
        DataManager.getStationsDataFromFileWithSuccess{ (data) -> Void in
            do {
                
                let parsedObject: AnyObject? = try NSJSONSerialization.JSONObjectWithData(data,
                    options: NSJSONReadingOptions.AllowFragments)
                if let directions = parsedObject as? NSDictionary {
                    if let countries = directions["citiesFrom"] as? NSArray{
                        for country in countries {
                            if let countryName = country["countryTitle"] as? String {
                                self.stations.append(countryName)
                            }
                        }
                    }
                }
                
            } catch let error as NSError? {
                print("error: \(error?.localizedDescription)")
            }
        }
    }
    
}
