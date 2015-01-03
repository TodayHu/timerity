//
//  AppDelegate.swift
//  Timerity
//
//  Created by Curt Clifton on 12/6/14.
//  Copyright (c) 2014 curtclifton.net. All rights reserved.
//

import UIKit
import TimerityData

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        let settings = UIUserNotificationSettings(forTypes: .Alert | .Badge | .Sound, categories: nil)
        application.registerUserNotificationSettings(settings)
        // Override point for customization after application launch.
        
        // NOTE: We can get a WKInterfaceDevice instance, but if we try to use it we crash:
        //        let device = WKInterfaceDevice.currentDevice()
        //        println(device.description)
        //        if let plusImage = UIImage(named: "Plus") {
        //            println("image: \(plusImage)")
        //            let isCached = device.addCachedImage(plusImage, name: "Plus")
        //            println("cached: \(isCached)")
        //        }
        
        return true
    }

    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }

    func application(application: UIApplication!, handleWatchKitExtensionRequest userInfo: [NSObject : AnyObject]!, reply: (([NSObject : AnyObject]!) -> Void)!) {
        // CCC, 12/30/2014. See TimerCommand for userInfo values
        // CCC, 12/10/2014. This schedules a notification, but we also have to handle the case where the app is foregrounded when the notification expires.
        let notification = UILocalNotification()
        let oneMinuteHence = NSDate().dateByAddingTimeInterval(60.0)
        notification.fireDate = oneMinuteHence
        notification.alertTitle = "Fire!"
        notification.alertBody = "Release all zigs"
        application.scheduleLocalNotification(notification)
        
        let result: [NSObject: AnyObject] = ["fireDate": oneMinuteHence]
        reply(result)
    }
}

