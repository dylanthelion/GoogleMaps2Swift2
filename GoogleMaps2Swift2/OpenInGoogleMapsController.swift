//
//  OpenInGoogleMapsController.swift
//  GoogleMaps2Swift2
//
//  Created by Dylan on 6/9/15.
//  Copyright © 2015 Dylan. All rights reserved.
//

import Foundation
import CoreLocation

private let globalMapController = OpenInGoogleMapsController()

// SWIFT GIVE ME TYPE OPTIONS

/*typedef NS_OPTIONS(NSInteger, GoogleMapsViewOptions){
    /**
    *  Satellite view.
    */
    kGoogleMapsViewOptionSatellite = 1 << 0,
    /**
    *  Show traffic information.
    */
    kGoogleMapsViewOptionTraffic = 1 << 1,
    /**
    *  Show public transit routes.
    */
    kGoogleMapsViewOptionTransit = 1 << 2
};*/

enum GoogleMapsTravelMode : Int {
    
    case kGoogleMapsTravelModeDriving = 1
    case kGoogleMapsTravelModeTransit
    case kGoogleMapsTravelModeBiking
    case kGoogleMapsTravelModeWalking
}

enum GoogleMapsFallback : Int {
    
    case kGoogleMapsFallbackNone
    case kGoogleMapsFallbackAppleMaps
    case kGoogleMapsFallbackChromeThenSafari
    case kGoogleMapsFallbackChromeThenAppleMaps
    case kGoogleMapsFallbackSafari
}

class GoogleMapDefinition : NSObject {
    
    var queryString : String?
    var center : CLLocationCoordinate2D?
    
    //var viewOptions : GoogleMapsViewOptions?
    
    var zoomLevel : Float?
}

class GoogleStreetViewDefinition : NSObject {
    
    var center : CLLocationCoordinate2D?
}

class GoogleDirectionsWaypoint : NSObject {
    
    var queryString : String?
    var location : CLLocationCoordinate2D?
    
    override init() {
        super.init()
    }
    
    init(queryString : String) {
        self.queryString = queryString
    }
    
    init(location : CLLocationCoordinate2D) {
        self.location = location
    }
}

class GoogleDirectionsDefinition : NSObject {
    
    var startingPoint : GoogleDirectionsWaypoint?
    var destinationPoint : GoogleDirectionsWaypoint?
    var travelMode : GoogleMapsTravelMode?
}

class OpenInGoogleMapsController : NSObject {
    
    override init() {
        super.init()
    }
    
    var callbackURL : NSURL?
    var fallbackStrategy : GoogleMapsFallback?
    
    
    internal var googleMapsInstalled : Bool {
        
        get {
            return false
        }
    }
    
    class var sharedInstance : OpenInGoogleMapsController {
        return globalMapController
    }
    
    
    // Needs definition
    
    func openMap(definition : GoogleMapDefinition) -> Bool {
        
        return true
    }
    
    func openStreetView(definition : GoogleStreetViewDefinition) -> Bool {
        
        return true
    }
    
    func openDirections(definition : GoogleDirectionsDefinition) -> Bool {
        
        return true
    }
}