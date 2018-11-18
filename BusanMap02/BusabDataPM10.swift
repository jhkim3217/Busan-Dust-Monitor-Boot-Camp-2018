//
//  BusabDataPM10.swift
//  BusanMap02
//
//  Created by amadeus on 16/11/2018.
//  Copyright © 2018 김종현. All rights reserved.
//

import Foundation
import MapKit

class BusanDataPM10: NSObject, MKAnnotation {
    var coordinate: CLLocationCoordinate2D
    var title: String?
    var subtitle: String?
    
    var pm10: String?
    var pm10Cai: String?
    
    var area: String? // 용도
    var network: String? // 측정망
    
    init(coordinate: CLLocationCoordinate2D, title: String, subtitle: String,
         pm10: String, pm10Cai: String,
         area: String, network: String) {
        self.coordinate = coordinate
        self.title = title
        self.subtitle = subtitle
        self.pm10 = pm10
        self.pm10Cai = pm10Cai
        self.area = area
        self.network = network
    }
}
