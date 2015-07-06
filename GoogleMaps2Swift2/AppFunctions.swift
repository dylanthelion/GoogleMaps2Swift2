//
//  AppFunctions.swift
//  GoogleMaps2Swift2
//
//  Created by Dylan on 7/1/15.
//  Copyright © 2015 Dylan. All rights reserved.
//

import Foundation

func valuesSortedByKeys(dictionary : Dictionary<String, String>, sortParameter : Sorted) -> [String] {
    
    var keys = Array(dictionary.keys)
    
    switch sortParameter {
        
    case .Ascending :
        keys.sortInPlace({$0 < $1})
    case .Descending :
        keys.sortInPlace({$1 < $0})
    }
    
    var sortedValues = [String]()
    
    for key in keys {
        sortedValues.append(dictionary[key]!)
    }
    
    return sortedValues
}