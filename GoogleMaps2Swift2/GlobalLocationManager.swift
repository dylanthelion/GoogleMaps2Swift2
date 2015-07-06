//
//  GlobalLocationManager.swift
//  GoogleMaps2Swift2
//
//  Created by Dylan on 7/6/15.
//  Copyright © 2015 Dylan. All rights reserved.
//

import Foundation
import CoreLocation

private let globalManager = GlobalLocationManager()

class GlobalLocationManager: CLLocationManager {
    
    var isLocating : Bool = false
    
    override init() {
        super.init()
    }
    
    class  var appLocationManager: GlobalLocationManager {
        return globalManager
    }
    
    func startLocating(delegate : CLLocationManagerDelegate) {
        
        self.delegate = delegate
        
        if(!isLocating) {
            self.requestAlwaysAuthorization()
            self.desiredAccuracy = kCLLocationAccuracyBest
            self.startMonitoringSignificantLocationChanges()
            isLocating = true
        }
    }
}