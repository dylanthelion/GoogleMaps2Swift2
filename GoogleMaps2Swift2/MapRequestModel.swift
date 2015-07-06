//
//  MapRequestModel.swift
//  GoogleMaps2Swift2
//
//  Created by Dylan on 6/24/15.
//  Copyright © 2015 Dylan. All rights reserved.
//

import Foundation
import CoreLocation

class  MapRequestModel: NSObject {
    
    
    
    internal var startQueryString : String?
    internal var startLocation : CLLocationCoordinate2D?
    internal var startCurrentLocation : Bool = true
    internal var destinationQueryString : String?
    internal var destinationLocation : CLLocationCoordinate2D?
    internal var destinationCurrentLocation : Bool = true
    
    var travelMode : TravelMode?
    var travelModeDescriptions : [TravelMode : String] = [:]
    let locationManager = GlobalLocationManager.appLocationManager
    
    override init() {
         super.init()
        
        travelModeDescriptions[.NotSpecified] = "(Unspecified)"
        travelModeDescriptions[.Driving] = "Driving"
        travelModeDescriptions[.PublicTransit] = "Transit"
        travelModeDescriptions[.Bicycling] = "Biking"
        travelModeDescriptions[.Walking] = "Walking"
        
        travelMode = .NotSpecified
        
        startLocation = kCLLocationCoordinate2DInvalid
        destinationLocation = kCLLocationCoordinate2DInvalid
    }
    
    func setQueryString(query : String?, group : LocationGroup) {
        
        setQueryString(query, center: kCLLocationCoordinate2DInvalid, group: group)
    }
    
    func setQueryString(query: String?, center : CLLocationCoordinate2D, group : LocationGroup) {
        
        switch group {
            
        case .Start :
            startCurrentLocation = false
            startQueryString = query
            startLocation = center
        case .End :
            destinationCurrentLocation = false
            destinationQueryString = query
            destinationLocation = center
        }
    }
    
    func useCurrentLocationForGroup(group : LocationGroup) {
        
        // I could not figure out how the other sample app accesses current location, so I used Apple's CLLocationManager class, which is the standard class for accessing device location. The GlobalLocationManager class provides a singleton, with location updates set to significant, the lightest option. The straight port of the sample app did not break, but did not open a map when the Use Current Location option was chosen.
        
        switch group {
            
        case .Start :
            startQueryString = nil
            startLocation = locationManager.location!.coordinate
            startCurrentLocation = true
        case .End :
            destinationQueryString = nil
            destinationLocation = kCLLocationCoordinate2DInvalid
            destinationCurrentLocation = true
        }
    }
    
    func descriptionForGroup(group : LocationGroup) -> String {
        
        // Swift give me equality operators for enums
        
        switch group {
            
        case .Start :
            return makeDescriptionForSearch(startQueryString, location: startLocation!, currentLocation: startCurrentLocation)
        default :
            return makeDescriptionForSearch(destinationQueryString, location: destinationLocation!, currentLocation: destinationCurrentLocation)
        }
    }
    
    // Swift Dictionary does not have the same parallel Array functionality for keys and values that Obj-C Dictionaries did. Attempting to build an extension to add this functionality would be a significant project of its own. I'm returning an Array of Strings, without any specific sorting logic. This shouldn't cause any performance problems, though a change of the TravelModeDescriptions var may cause an error, if this method is not changed.
    
    func sortedTravelModeDescriptions() -> [String] {
        return [travelModeDescriptions[TravelMode.Bicycling]!, travelModeDescriptions[TravelMode.Driving]!, travelModeDescriptions[TravelMode.NotSpecified]!, travelModeDescriptions[TravelMode.PublicTransit]!, travelModeDescriptions[TravelMode.Walking]!]
    }
    
    func travelModeDescription() -> String {
        return travelModeDescriptions[travelMode!]!
    }
    
    func makeDescriptionForSearch(searchString : String?, location : CLLocationCoordinate2D, currentLocation : Bool) -> String {
        
        let isLocationValid = CLLocationCoordinate2DIsValid(location)
        
        if(searchString == nil && isLocationValid == false && currentLocation == false) {
            return "-- Location not set --"
        } else if(currentLocation == true) {
            return "(Current Location)"
        } else if(isLocationValid == false && searchString != nil) {
            return searchString!
        } else if(searchString == nil && isLocationValid == true) {
            let latitude = location.latitude.description
            let longitude = location.longitude.description
            return String(format: "Lat: %@, Long: %@", latitude, longitude)
        } else {
            let latitude = location.latitude.description
            let longitude = location.longitude.description
            return String(format: "%@ near (%@, %@)", searchString!, latitude, longitude)
        }
    }
    
}