//
//  PickLocationViewController.swift
//  GoogleMaps2Swift2
//
//  Created by Dylan on 7/1/15.
//  Copyright © 2015 Dylan. All rights reserved.
//

import UIKit
import CoreLocation

class PickLocationViewController: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate {
    
    var group : LocationGroup?
    var delegate : PickLocationDelegate?
    var allowCurrentLocation : Bool = true
    var someNiceDefaults : [Dictionary<String, AnyObject?>]?
    
    @IBOutlet weak var searchStringTextField: UITextField!

    @IBOutlet weak var latTextField: UITextField!
    
    @IBOutlet weak var longTextField: UITextField!
    
    @IBOutlet weak var instructionLabel: UILabel!
    
    @IBOutlet weak var locationPicker: UIPickerView!
    
    @IBOutlet weak var currentLocationSwitch: UISwitch!
    
    @IBOutlet weak var currentLocationLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        someNiceDefaults = [Dictionary<String, AnyObject?>]()
        
        someNiceDefaults = [["search" : "1600 Amphitheatre Parkway, Mountain View, CA",
            "description" : "1600 Amphitheatre Parkway"],
        ["search" : "345 Spear Street, San Francisco, CA",
        "description" : "345 Spear Street, SF"],
        ["loc": [48.8536629,2.3479513],
        "description": "(48.854, 2.347) -- Notre Dame" ],
        ["search" : "pizza",
        "loc": [40.758895,-73.985131],
        "description": "Pizza near Times Square"],
        ["search" : "ramen",
        "loc": [35.680066,139.767813],
        "description": "Ramen near Tokyo Station"],
        ["search" : "ice cream",
        "loc": [37.7579691,-122.3880665],
        "description": "Ice cream in Dogpatch"],
        ["loc" : [1.2792354,103.8517178],
        "description": "(1.279, 103.852) - Singapore towers"],
        ["search" : "Roppongi Hills Mori Tower Tokyo Japan",
        "description" : "Mori Tower, Tokyo Japan"]]
        
        locationPicker.dataSource = self
        locationPicker.delegate = self
        
        if let _ = group {
            if group! == .Start {
                instructionLabel.text = "Pick a starting location"
            } else {
                instructionLabel.text = "Pick a destination"
            }
        }
        
        currentLocationSwitch.on = false
        currentLocationSwitch.hidden = allowCurrentLocation
        currentLocationLabel.hidden = allowCurrentLocation

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    

    @IBAction func doneButtonPressed(sender: AnyObject) {
        
        let searchStringText = searchStringTextField.text!
        var latValue = latTextField.text?.floatValue
        var longValue = longTextField.text?.floatValue
        
        if currentLocationSwitch.on {
            delegate?.pickLocationController(self, group: group!)
        } else if let _ = latValue, _ = longValue {
            
            if(latValue! > 90.0 || latValue! < -90.0) {
                latValue = 0
            }
            
            if(longValue! > 180.0 || longValue! < -180.0) {
                longValue = 0
            }
            
            let location : CLLocationCoordinate2D
            
            if(latValue! == 0 && longValue! == 0) {
                location = kCLLocationCoordinate2DInvalid
            } else {
                let lat : CLLocationDegrees = CLLocationDegrees(latValue!)
                let long : CLLocationDegrees = CLLocationDegrees(longValue!)
                location = CLLocationCoordinate2DMake(lat, long)
            }
            
            let validLocation = CLLocationCoordinate2DIsValid(location)
            
            if searchStringText == "" {
                if(validLocation) {
                    delegate?.pickLocationController(self, location: location, group: group!)
                } else {
                    delegate?.noLocationPickedByPickLocationController(self)
                }
            } else {
                if(validLocation) {
                    delegate?.pickLocationController(self, query: searchStringText, location: location, group: group!)
                } else {
                    delegate?.pickLocationController(self, query: searchStringText, group: group!)
                }
            }
        } else {
            
            let alertController = UIAlertController(title: "No Location", message: "Please select a location", preferredStyle: .Alert)
            
            let okayAction = UIAlertAction(title: "OK", style: .Cancel, handler: nil)
            alertController.addAction(okayAction)
            presentViewController(alertController, animated: true, completion: nil)
        }
        
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func useCurrentLocationSwitchChanged(sender: UISwitch) {
        
        searchStringTextField.enabled = sender.on
        latTextField.enabled = sender.on
        longTextField.enabled = sender.on
        locationPicker.hidden = sender.on
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        view.endEditing(true)
    }
    
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return someNiceDefaults!.count
    }
    
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        let entry = someNiceDefaults![row]
        return entry["description"]! as? String
    }
    
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        let entry = someNiceDefaults![row]
        if let _ = entry["search"] {
            searchStringTextField.text = entry["search"]! as? String
        } else {
            searchStringTextField.text = ""
        }
        
        if let _ = entry["loc"] {
            let location = entry["loc"] as! [Float]
            latTextField.text = location[0].description
            longTextField.text = location[1].description
        } else {
            latTextField.text = "0.0"
            longTextField.text = "0.0"
        }
    }

}

protocol PickLocationDelegate {
    
    func pickLocationController(controller : PickLocationViewController?, query : String, group : LocationGroup)
    func pickLocationController(controller : PickLocationViewController, location : CLLocationCoordinate2D, group : LocationGroup)
    func pickLocationController(controller : PickLocationViewController, query : String, location : CLLocationCoordinate2D, group : LocationGroup)
    func pickLocationController(controller : PickLocationViewController,group : LocationGroup)
    func noLocationPickedByPickLocationController(controller : PickLocationViewController)
}
