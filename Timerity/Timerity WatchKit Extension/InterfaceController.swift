//
//  InterfaceController.swift
//  Timerity WatchKit Extension
//
//  Created by Curt Clifton on 12/6/14.
//  Copyright (c) 2014 curtclifton.net. All rights reserved.
//

import WatchKit
import Foundation


class InterfaceController: WKInterfaceController {

    override init() {
        // Initialize variables here.
        super.init()
        
        // Configure interface objects here.
        NSLog("%@ init", self)
    }

    override func awakeWithContext(context: AnyObject!) {
        // CCC, 12/10/2014.
    }
    
    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
        NSLog("%@ will activate", self)
    }

    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        NSLog("%@ did deactivate", self)
        super.didDeactivate()
    }

    // MARK: Actions
    
    // CCC, 12/10/2014. Testing:
    @IBAction func buttonTapped() {
        NSLog("tapping");
        InterfaceController.openParentApplication([:]) { result, error in
            if let fireDate = result["fireDate"] as? NSDate {
                NSLog("got call back with payload: %@", fireDate);
            } else {
                NSLog("got call back sans payload");
            }
        }
        NSLog("waiting for call back");
    }
    
}
