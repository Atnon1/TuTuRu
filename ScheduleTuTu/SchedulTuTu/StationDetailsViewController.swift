//
//  StationDetail.swift
//  SchedulTuTu
//
//  Created by Admin on 01.10.16.
//  Copyright © 2016 MakeY. All rights reserved.
//

import UIKit
import MapKit

class StationDetailsViewController: UIViewController, MKMapViewDelegate {
   
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var countryLabel: UILabel!
    @IBOutlet weak var regionLabel: UILabel!
    @IBOutlet weak var districtLabel: UILabel!
    @IBOutlet weak var cityLabel: UILabel!
    @IBOutlet weak var mapView: MKMapView!

    
    var country = String()
    var city = String()
    var name = String()
    var district = String()
    var region = String()
    var latitude = Double()
    var longitude = Double()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        nameLabel.text = name
        countryLabel.text = country
        regionLabel.text = region
        districtLabel.text = district
        cityLabel.text = city
        
        //настраиваем карту
        mapView.delegate = self
        let stationLocation = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        let stationPlacemark = MKPlacemark(coordinate: stationLocation, addressDictionary: nil)
        let stationAnnotation = MKPointAnnotation()
        stationAnnotation.title = name
        if let location = stationPlacemark.location {
            stationAnnotation.coordinate = location.coordinate
        }
        self.mapView.showAnnotations([stationAnnotation], animated: true )
    }
    
}
