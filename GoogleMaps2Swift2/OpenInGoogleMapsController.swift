//
//  OpenInGoogleMapsController.swift
//  GoogleMaps2Swift2
//
//  Created by Dylan on 6/9/15.
//  Copyright © 2015 Dylan. All rights reserved.
//

import Foundation
import CoreLocation
import UIKit

private let globalMapController = OpenInGoogleMapsController()

let kGoogleMapsScheme : String = "comgooglemaps://"

let kGoogleMapsCallbackScheme : String = "comgooglemaps-x-callback://"

let kGoogleChromeOpenLink : String = "googlechrome-x-callback://x-callback-url/open/?url="

let kGoogleMapsStringTraffic : String = "traffic"

let kGoogleMapsStringTransit : String = "transit"

let kGoogleMapsStringSatellite : String = "satellite"

// Characters to be escaped in web URL

let kURLEscapeCharacters : NSCharacterSet = NSCharacterSet(charactersInString: "!*'();:@&=+$,/?%#[] ").invertedSet

func encodeByAddingPercentEscapes(input : String) -> String {
    return input.stringByAddingPercentEncodingWithAllowedCharacters(kURLEscapeCharacters)!
}

protocol GoogleMapsURLSchemable {
    
    func URLArgumentsForGoogleMaps() -> [String]
    func URLArgumentsForAppleMaps() -> [String]
    func URLArgumentsForWeb() -> [String]
    func anythingToSearchFor() -> Bool
}

struct GoogleMapsViewOptions : OptionSetType {
    
    let rawValue : Int
    
    static let Satellite = GoogleMapsViewOptions(rawValue: 1)
    static let Traffic = GoogleMapsViewOptions(rawValue: 2)
    static let Transit = GoogleMapsViewOptions(rawValue: 4)
}

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

class GoogleMapDefinition : NSObject, GoogleMapsURLSchemable {
    
    var queryString : String?
    var center : CLLocationCoordinate2D?
    
    var viewOptions : GoogleMapsViewOptions = GoogleMapsViewOptions()
    
    var zoomLevel : Float?
    
    override init() {
        super.init()
        center = kCLLocationCoordinate2DInvalid
    }
    
    func anythingToSearchFor() -> Bool {
        if let _ = queryString {
            return true
        } else if(CLLocationCoordinate2DIsValid(center!)) {
            return true
        }
        
        return false
    }
    
    func URLArgumentsForGoogleMaps() -> [String] {
        
        var urlArguments = [String]()
        if let _ = queryString {
            
            let args = encodeByAddingPercentEscapes(queryString!)
            urlArguments.append(String(format: "q=%@", args))
        }
        
        if(CLLocationCoordinate2DIsValid(center!)) {
            
            let latitude = center!.latitude.description
            let longitude = center!.longitude.description
            urlArguments.append(String(format: "center=%@,%@", latitude, longitude))
        } else {
            
            let latitude = "-81.0000"
            let longitude = "43.00000"
            urlArguments.append(String(format: "center=%@,%@", latitude, longitude))
        }
        
        if let _ = zoomLevel {
            let zoom = "\(zoomLevel!)"
            
            urlArguments.append(String(format: "zoom=%@", zoom))
        }
        
        if viewOptions.contains(.Satellite) {
            urlArguments.append("t=h")
        }
        
        
        return urlArguments
    }
    
    func URLArgumentsForAppleMaps() -> [String] {
        var urlArguments = [String]()
        
        if let _ = queryString {
            let args = encodeByAddingPercentEscapes(queryString!)
            urlArguments.append(String(format: "q=%@", args))
        }
        
        if(CLLocationCoordinate2DIsValid(center!)) {
            
            let latitude = center!.latitude.description
            let longitude = center!.longitude.description
            urlArguments.append(String(format: "ll=%@,%@", latitude, longitude))
        }
        
        if let _ = zoomLevel {
            let zoomAsInt = Int(zoomLevel!)
            let zoom = "\(zoomAsInt)"
            
            urlArguments.append(String(format: "z=%@", zoom))
        }
        
        if viewOptions.contains(.Satellite) {
            urlArguments.append("t=h")
        }
        
        return urlArguments
    }
    
    func URLArgumentsForWeb() -> [String] {
        var urlArguments = [String]()
        
        if let _ = queryString {
            let args = encodeByAddingPercentEscapes(queryString!)
            urlArguments.append(String(format: "q=%@", args))
        }
        
        if(CLLocationCoordinate2DIsValid(center!)) {
            
            let latitude = center!.latitude.description
            let longitude = center!.longitude.description
            urlArguments.append(String(format: "ll=%@,%@", latitude, longitude))
        }
        
        if let _ = zoomLevel {
            let zoomAsInt = Int(zoomLevel!)
            let zoom = "\(zoomAsInt)"
            
            urlArguments.append(String(format: "z=%@", zoom))
        }
        
            
        if viewOptions.contains(.Satellite) {
            urlArguments.append("t=h")
        }
            
        if viewOptions.contains(.Traffic) {
            urlArguments.append("layer=t")
        }
            
        if viewOptions.contains(.Transit) {
            urlArguments.append("lci=transit_comp")
        }
        
        return urlArguments
    }
}

class GoogleStreetViewDefinition : NSObject, GoogleMapsURLSchemable {
    
    var center : CLLocationCoordinate2D?
    
    override init() {
        super.init()
        center = kCLLocationCoordinate2DInvalid
    }
    
    // Potentially unsafe. Is there anywhere in app where center can become null?
    
    func anythingToSearchFor() -> Bool {
        return CLLocationCoordinate2DIsValid(center!)
    }
    
    func URLArgumentsForGoogleMaps() -> [String] {
        
        var urlArguments = [String]()
        
        // No check for validity in original SDK
        
        let latitude = center!.latitude.description
        let longitude = center!.longitude.description
        urlArguments.append(String(format: "center=%@,%@", latitude, longitude))
    urlArguments.append("mapmode=streetview")
        
        return urlArguments
    }
    
    func URLArgumentsForAppleMaps() -> [String] {
        var urlArguments = [String]()
        
        // No check for validity in original SDK
            
        let latitude = center!.latitude.description
        let longitude = center!.longitude.description
        urlArguments.append(String(format: "ll=%@,%@", latitude, longitude))
        urlArguments.append("z=19")
        urlArguments.append("t=k")
        
        return urlArguments
    }
    
    func URLArgumentsForWeb() -> [String] {
        return self.URLArgumentsForAppleMaps()
    }
}

class GoogleDirectionsWaypoint : NSObject {
    
    var queryString : String?
    var location : CLLocationCoordinate2D?
    
    override init() {
        super.init()
        location = kCLLocationCoordinate2DInvalid
    }
    
    convenience init(queryString : String) {
        self.init()
        self.queryString = queryString
    }
    
    convenience init(location : CLLocationCoordinate2D) {
        self.init()
        self.location = location
    }
    
    func anythingToSearchFor() -> Bool {
        
        if let _ = queryString {
            return true
        } else if CLLocationCoordinate2DIsValid(location!) {
            return true
        }
        
        return false
    }
    
    func URLArgumentsUsingKey(key : String) -> String {
        
        // Potentially unsafe. Is there anywhere in app where location can become null?
        
        if CLLocationCoordinate2DIsValid(location!) {
            let latitude = location?.latitude.description
            let longitude = location?.longitude.description
            return String(format: "%@=%@,%@", key, latitude!, longitude!)
        } else if let _ = queryString {
            
            let args = encodeByAddingPercentEscapes(queryString!)
            return String(format: "%@=%@", key, args)
        }
        
        return ""
    }
    
}

class GoogleDirectionsDefinition : NSObject, GoogleMapsURLSchemable {
    
    var startingPoint : GoogleDirectionsWaypoint?
    var destinationPoint : GoogleDirectionsWaypoint?
    var travelMode : GoogleMapsTravelMode?
    
    func anythingToSearchFor() -> Bool {
        
        if (self.startingPoint?.anythingToSearchFor() == true || self.destinationPoint?.anythingToSearchFor() == true) {
            return true
        }
        
        return false
    }
    
    func urlArgumentValueForTravelMode() -> String? {
        
        
        switch self.travelMode! {
            
        case .kGoogleMapsTravelModeBiking :
            return "bicycling"
        case .kGoogleMapsTravelModeDriving :
            return "driving"
        case .kGoogleMapsTravelModeTransit :
            return "transit"
        case .kGoogleMapsTravelModeWalking :
            return "walking"
        }
    }
    
    func urlArgumentForTravelModeWeb() -> String? {
        
        switch self.travelMode! {
            
        case .kGoogleMapsTravelModeBiking :
            return "b"
        case .kGoogleMapsTravelModeDriving :
            return "c"
        case .kGoogleMapsTravelModeTransit :
            return "r"
        case .kGoogleMapsTravelModeWalking :
            return "w"
        }
    }
    
    func waypointArguments() -> [String] {
        
        var args = [String]()
        
        if let _ = startingPoint {
            if (startingPoint?.anythingToSearchFor() == true) {
                args.append((self.startingPoint?.URLArgumentsUsingKey("saddr"))!)
            }
        }
        
        if let _ = destinationPoint {
            if (destinationPoint?.anythingToSearchFor() == true) {
                args.append((self.destinationPoint?.URLArgumentsUsingKey("daddr"))!)
            }
        }
        
        return args
    }
    
    
    func URLArgumentsForGoogleMaps() -> [String] {
        
        var urlArguments = waypointArguments()
        
        let travelMode : String? = urlArgumentValueForTravelMode()
        
        if let _ = travelMode {
            urlArguments.append(String(format: "directionsmode=%@", travelMode!))
        }
        
        return urlArguments
    }
    
    func URLArgumentsForAppleMaps() -> [String] {
        
        var urlArguments = waypointArguments()
        
        if let _ = travelMode {
            switch travelMode! {
                
        case .kGoogleMapsTravelModeDriving :
                urlArguments.append("dirflg=d")
                
        case .kGoogleMapsTravelModeWalking :
                urlArguments.append("dirflg=w")
                
        default :
                print("No valid travel mode")
            
            }
        }
        
        return urlArguments
    }
    
    func URLArgumentsForWeb() -> [String] {
        
        var urlArguments = waypointArguments()
        
        let travelMode : String? = urlArgumentValueForTravelMode()
        if let _ = travelMode {
            urlArguments.append(String(format: "dirflg=%@", travelMode!))
        }
        
        return urlArguments
        
    }
}

class OpenInGoogleMapsController : NSObject {
    
    var sharedApplication : UIApplication?
    
    override init() {
        super.init()
        sharedApplication = UIApplication.sharedApplication()
        //fallbackStrategy = GoogleMapsFallback.kGoogleMapsFallbackNone
    }
    
    class var sharedInstance : OpenInGoogleMapsController {
        return globalMapController
    }
    
    
    var callbackURL : NSURL?
    var fallbackStrategy : GoogleMapsFallback?
    
    func isGoogleMapsInstalled() -> Bool {
        
        let simpleURL = NSURL(string: kGoogleMapsScheme)
        let callbackURL = NSURL(string: kGoogleMapsCallbackScheme)
        if(sharedApplication?.canOpenURL(simpleURL!) == true || sharedApplication?.canOpenURL(callbackURL!) == true) {
            return true
        }
        
        return false
    }
    
    func fallBackToAppleMapsWithDefinition(definition : GoogleMapsURLSchemable) -> Bool {
        
        var mapURL = "https://maps.apple.com/"
        mapURL += String(format: "?%@", ("&".join(definition.URLArgumentsForAppleMaps())))
        
        let URLToOpen = NSURL(string: mapURL)
        
        // DEBUG logging omitted
        
        return (sharedApplication?.openURL(URLToOpen!))!
    }
    
    func fallbackToChromeFirstWithDefinition(definition : GoogleMapsURLSchemable) -> Bool {
        
        var mapURL = kGoogleChromeOpenLink
        
        let embedURL = "https://maps.google.com/maps/"
        let urlArgumentsAsString = String(format: "?%@", "&".join(definition.URLArgumentsForWeb()))
        let fullEmbedURL = embedURL + urlArgumentsAsString
        mapURL += encodeByAddingPercentEscapes(fullEmbedURL)
        
        // DEBUG logging omitted
        
        appendMapURLString(&mapURL, callbackURL: callbackURL)
        
        let URLToOpen = NSURL(string: mapURL)
        
        if(sharedApplication?.openURL(URLToOpen!) == true) {
            return true
        } else if (fallbackStrategy! == .kGoogleMapsFallbackChromeThenAppleMaps) {
            return fallBackToAppleMapsWithDefinition(definition)
        } else if (fallbackStrategy! == .kGoogleMapsFallbackChromeThenSafari) {
            return fallbackToSafariWithDefinition(definition)
        }
        
        return false
    }
    
    func fallbackToSafariWithDefinition(definition : GoogleMapsURLSchemable) -> Bool {
        
        var mapURL = "https://maps.google.com/maps"
        mapURL += String(format: "?%@", "&".join(definition.URLArgumentsForWeb()))
        
        // DEBUG logging omitted
        
        let URLToOpen = NSURL(string: mapURL)
        
        return (sharedApplication?.openURL(URLToOpen!))!
    }
    
    func openInGoogleMapsWithDefinition(definition : GoogleMapsURLSchemable) -> Bool {
        
        if(definition.anythingToSearchFor() == false) {
            return false
        }
        
        if(isGoogleMapsInstalled() == false) {
            
            if let _ = fallbackStrategy {
                
                switch fallbackStrategy! {
                    
                case .kGoogleMapsFallbackNone :
                    return false
                case .kGoogleMapsFallbackAppleMaps :
                    return fallBackToAppleMapsWithDefinition(definition)
                case .kGoogleMapsFallbackChromeThenSafari,
                .kGoogleMapsFallbackChromeThenAppleMaps :
                    return fallbackToChromeFirstWithDefinition(definition)
                case .kGoogleMapsFallbackSafari :
                    return fallbackToSafariWithDefinition(definition)
                }
            }
        }
        
        var mapURL = baseURLStringUsingCallback(callbackURL)
        
        mapURL += String(format: "?%@", "&".join(definition.URLArgumentsForGoogleMaps()))
        
        appendMapURLString(&mapURL, callbackURL: callbackURL)
        
        // DEBUG logging omitted
        
        let URLToOpen = NSURL(string: mapURL)
        return (sharedApplication?.openURL(URLToOpen!))!
    }
    
    func openMap(definition : GoogleMapDefinition) -> Bool {
        
        return openInGoogleMapsWithDefinition(definition)
    }
    
    func openStreetView(definition : GoogleStreetViewDefinition) -> Bool {
        
        return openInGoogleMapsWithDefinition(definition)
    }
    
    func openDirections(definition : GoogleDirectionsDefinition) -> Bool {
        
        return openInGoogleMapsWithDefinition(definition)
    }
    
    func baseURLStringUsingCallback(callbackURL : NSURL?) -> String {
        
        var usingCallback = false
        
        if let _ = callbackURL {
            usingCallback = (sharedApplication?.canOpenURL(callbackURL!))!
        }
        
        return (usingCallback) ? kGoogleMapsCallbackScheme : kGoogleMapsScheme
    }
    
    func appendMapURLString(inout mapURL : String, callbackURL : NSURL?) {
        
        var usingCallback = false
        
        if let _ = callbackURL {
            usingCallback = (sharedApplication?.canOpenURL(callbackURL!))!
        }
        
        if(usingCallback == true) {
            
            let postfix : String = String(format: "&x-success=%@", encodeByAddingPercentEscapes(callbackURL!.path!))
            
            mapURL += postfix
            mapURL += displayName
        }
    }
    
    // Swift, update your types so that this will not be necessary anymore
    
    var displayName : String {
        
        let mainBundle = NSBundle.mainBundle()
        let displayName = mainBundle.objectForInfoDictionaryKey("CFBundleDisplayName") as? String
        let dict = mainBundle.infoDictionary!
        let key = kCFBundleNameKey as String
        let name : String = dict[key] as! String
        let gotName : String = displayName ?? name ?? "" as String
        return gotName
    }
}