//
//  ViewController.swift
//  GoogleMaps2Swift2
//
//  Created by Dylan on 6/9/15.
//  Copyright © 2015 Dylan. All rights reserved.
//

import UIKit
import CoreLocation

class ViewController: UIViewController, PickLocationDelegate, UIAlertViewDelegate, CLLocationManagerDelegate {
    
    @IBOutlet weak var satelliteLabel: UILabel!
    @IBOutlet weak var transitLabel: UILabel!
    @IBOutlet weak var trafficLabel: UILabel!
    @IBOutlet weak var travelModeLabel: UILabel!
    
    @IBOutlet weak var editLocationButton: UIButton!

    @IBOutlet weak var startLabel: UILabel!
    
    @IBOutlet weak var endLabel: UILabel!
    
    @IBOutlet weak var pickMapTypeSC: UISegmentedControl!
    
    @IBOutlet weak var satelliteSwitch: UISwitch!
    
    @IBOutlet weak var trafficSwitch: UISwitch!
    
    @IBOutlet weak var transitSwitch: UISwitch!
    
    @IBOutlet weak var startLocationDescription: UILabel!
    
    @IBOutlet weak var endLocationDescription: UILabel!
    
    @IBOutlet weak var endLocationButton: UIButton!
    
    @IBOutlet weak var travelMethodButton: UIButton!
    
    var model : MapRequestModel?
    var pendingLocationGroup : LocationGroup?
    let locationManager = GlobalLocationManager.appLocationManager
    
    // UIActionSheet has been deprecated. These notifications are now handled with UIAlertController
    var travelModeAlertView : UIAlertController?
    
    let kOpenInMapsSampleURLScheme : String = "OpenInGoogleMapsSample://"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        locationManager.startLocating(self)
        model = MapRequestModel()
        pickLocationController(nil, query: "1600 Amphitheatre Parkway, Mountain View, CA 94043", group: LocationGroup.Start)
        OpenInGoogleMapsController.sharedInstance.callbackURL = NSURL(string: kOpenInMapsSampleURLScheme)
        OpenInGoogleMapsController.sharedInstance.fallbackStrategy = GoogleMapsFallback.kGoogleMapsFallbackChromeThenAppleMaps
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func openInGoogleMaps() {
        
        let mapDefinition = GoogleMapDefinition()
        if let _ = model {
            
            mapDefinition.queryString = model?.startQueryString
            mapDefinition.center = model?.startLocation
            
            // OptionsSetType does not work with bitwise operators, and Bools are no longer Integer convertible. Fixing this would be a lot of work, potentially unsafe, so I've decided to work with the methods that come with OptionSetType. the code below is the best pattern I've been able to come up with.
            
            if (satelliteSwitch.on) {
                mapDefinition.viewOptions.union(GoogleMapsViewOptions.Satellite)
            }
            
            if (trafficSwitch.on) {
                mapDefinition.viewOptions.union(GoogleMapsViewOptions.Traffic)
            }
            
            if(transitSwitch.on) {
                mapDefinition.viewOptions.union(GoogleMapsViewOptions.Transit)
            }
        }
        
        if let _ = mapDefinition.queryString {
            
            if CLLocationCoordinate2DIsValid(mapDefinition.center!) {
                mapDefinition.zoomLevel = 15.0
            }
        }
        
        OpenInGoogleMapsController.sharedInstance.openMap(mapDefinition)
    }
    
    func openDirectionsInGoogleMaps() {
        
        let directionsDefinition = GoogleDirectionsDefinition()
        
        if let _ = model {
            
            if let _ = model?.startLocation {
                directionsDefinition.startingPoint = nil
            } else {
                let startingPoint = GoogleDirectionsWaypoint()
                startingPoint.queryString = model?.startQueryString
                startingPoint.location = model?.startLocation
                directionsDefinition.startingPoint = startingPoint
            }
            
            if((model?.destinationCurrentLocation) != nil) {
                directionsDefinition.destinationPoint = nil
            } else {
                let destination = GoogleDirectionsWaypoint()
                destination.queryString = model?.destinationQueryString
                destination.location = model?.destinationLocation
                directionsDefinition.destinationPoint = destination
            }
            
            directionsDefinition.travelMode = travelModeAsGoogleMapsEnum(model!.travelMode!)
        }
        
        OpenInGoogleMapsController.sharedInstance.openDirections(directionsDefinition)
    }
    
    func openStreetViewInGoogleMaps() {
        
        let streetViewDefinition = GoogleStreetViewDefinition()
        
        if let _ = model {
            if let _ = model?.startLocation {
                if(CLLocationCoordinate2DIsValid(model!.startLocation!)) {
                    streetViewDefinition.center = model?.startLocation
                    OpenInGoogleMapsController.sharedInstance.openStreetView(streetViewDefinition)
                } else {
                    showSimpleAlertWithTitle("Please select a lat/long", description: "To display a Street View location, you must define it by a lat / long")
                }
            }
        }
    }

    @IBAction func openInMapsWasClicked(sender: AnyObject) {
        
        if pickMapTypeSC.selectedSegmentIndex == 0 {
            openInGoogleMaps()
        } else if pickMapTypeSC.selectedSegmentIndex == 1 {
            openDirectionsInGoogleMaps()
        } else if pickMapTypeSC.selectedSegmentIndex == 2 {
            openStreetViewInGoogleMaps()
        }
    }

    @IBAction func typeOfMapChanged(sender: UISegmentedControl) {
        
        if sender.selectedSegmentIndex == 0 {
            startLabel.text = "Location"
            endLocationDescription.hidden = true
            endLocationButton.hidden = true
            endLabel.hidden = true
            trafficLabel.hidden = false
            trafficSwitch.hidden = false
            transitLabel.hidden = false
            transitSwitch.hidden = false
            satelliteLabel.hidden = false
            satelliteSwitch.hidden = false
            travelModeLabel.hidden = true
            travelMethodButton.hidden = true
        } else if sender.selectedSegmentIndex == 1 {
            startLabel.text = "Start location"
            endLocationDescription.hidden = false
            endLocationButton.hidden = false
            endLabel.hidden = false
            trafficLabel.hidden = true
            trafficSwitch.hidden = true
            transitLabel.hidden = true
            transitSwitch.hidden = true
            satelliteLabel.hidden = true
            satelliteSwitch.hidden = true
            travelModeLabel.hidden = false
            travelMethodButton.hidden = false
        } else if sender.selectedSegmentIndex == 2 {
            startLabel.text = "Location"
            endLocationDescription.hidden = true
            endLocationButton.hidden = true
            endLabel.hidden = true
            trafficLabel.hidden = true
            trafficSwitch.hidden = true
            transitLabel.hidden = true
            transitSwitch.hidden = true
            satelliteLabel.hidden = true
            satelliteSwitch.hidden = true
            travelModeLabel.hidden = true
            travelMethodButton.hidden = true
        }
    }
    
    func updateTextStrings() {
        if let _ = model {
            startLocationDescription.text = model?.descriptionForGroup(LocationGroup.Start)
            endLocationDescription.text = model?.descriptionForGroup(LocationGroup.End)
            travelMethodButton.setTitle(model?.travelModeDescription(), forState: .Normal)
        }
    }
    
    @IBAction func editLocationWasPressed(sender: AnyObject) {
        if let _ = sender as? UIButton {
            pendingLocationGroup = LocationGroup(rawValue: (sender as! UIButton).tag)!
            // Using an IBAction and segue to present a view controller will result in the view being presented before it is in the window hierarchy. I've never known this to cause any bugs, but it will raise a warning in the console.
    
            performSegueWithIdentifier("segueToPickLocation", sender: self)
        }
    }
    
    @IBAction func travelMethodButtonWasPressed(sender: AnyObject) {
        let alertController = UIAlertController(title: "Please", message: "Select travel mode", preferredStyle: .Alert)
        
        if let _ = model {
            let travelModeStrings = (model?.sortedTravelModeDescriptions())!
            
            // This bit of code can be more dynamic. For now, the options are "sorted" in the MapRequestModel class, and the enum is built such that the sorted order corresponds to the order of enums, so that the array index can be used to do what action sheets and sorted NSDictionaries used to do. This should be updated to use Swift's capabilities.
            
            for (index, element) in travelModeStrings.enumerate() {
                let choice = UIAlertAction(title: element, style: .Default){(action) in
                    self.model?.travelMode = TravelMode(rawValue: index)
                }
                alertController.addAction(choice)
            }
        }
        
        presentViewController(alertController, animated: true, completion: nil)
    }
    
    func pickLocationController(controller: PickLocationViewController, query: String, location: CLLocationCoordinate2D, group: LocationGroup) {
        if let _ = model {
            model?.setQueryString(query, center: location, group: group)
        }
        updateTextStrings()
    }
    
    func pickLocationController(controller: PickLocationViewController, location: CLLocationCoordinate2D, group: LocationGroup) {
        if let _ = model {
            model?.setQueryString(nil, center: location, group: group)
        }
        updateTextStrings()
    }
    
    func pickLocationController(controller: PickLocationViewController?, query: String, group: LocationGroup) {
        if let _ = model {
            model?.setQueryString(query, group: group)
        }
        updateTextStrings()
    }
    
    func pickLocationController(controller: PickLocationViewController, group: LocationGroup) {
        if let _ = model {
            model?.useCurrentLocationForGroup(group)
        }
        updateTextStrings()
    }
    
    func noLocationPickedByPickLocationController(controller: PickLocationViewController) {
        // Do nothing
    }
    
    func showSimpleAlertWithTitle(title : String, description: String) {
        
        let alertController = UIAlertController(title: title, message: description, preferredStyle: .Alert)
        
        let okayAction = UIAlertAction(title: "Okay", style: .Cancel, handler: nil)
        alertController.addAction(okayAction)
        
        presentViewController(alertController, animated: true, completion: nil)
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        view.endEditing(true)
    }
    
    func travelModeAsGoogleMapsEnum(appTravelMode : TravelMode) -> GoogleMapsTravelMode {
        switch appTravelMode {
        case .Bicycling :
            return GoogleMapsTravelMode.kGoogleMapsTravelModeBiking
        case .Driving :
            return GoogleMapsTravelMode.kGoogleMapsTravelModeDriving
        case .PublicTransit :
            return GoogleMapsTravelMode.kGoogleMapsTravelModeTransit
        case .Walking :
            return GoogleMapsTravelMode.kGoogleMapsTravelModeWalking
        case .NotSpecified :
            return GoogleMapsTravelMode(rawValue: 0)!
        }
    }
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if let destinationVC = segue.destinationViewController as? PickLocationViewController {
            destinationVC.allowCurrentLocation = (pickMapTypeSC.selectedSegmentIndex == 1)
            destinationVC.group = pendingLocationGroup
            destinationVC.delegate = self
        }
    }
    
}

