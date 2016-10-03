//
//  DataManager.swift
//  SchedulTuTu
//
//  Created by Admin on 28.09.16.
//  Copyright © 2016 MakeY. All rights reserved.
//

import Foundation

//для извлечения данных из json
public class DataManager {
    public class func getStationsDataFromFileWithSuccess(success: ((data: NSData) -> Void)) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
            let filePath = NSBundle.mainBundle().pathForResource("allStations", ofType:"json")
            let data = try! NSData(contentsOfFile:filePath!,
                options: NSDataReadingOptions.DataReadingUncached)
            success(data: data)
        })
    }
    
}