//
//  AppDelegate.swift
//  Timerity
//
//  Created by Curt Clifton on 12/6/14.
//  Copyright (c) 2014–2015 curtclifton.net. All rights reserved.
//

import UIKit
import TimerityData

// TODO: This is just a bare skeleton iPhone app for demo purposes.

private let groupURL = NSFileManager.defaultManager().containerURLForSecurityApplicationGroupIdentifier("group.net.curtclifton.Timerity")
private let timerDatabaseURL = groupURL!.URLByAppendingPathComponent("data.json", isDirectory: false)

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    private let timerDataPresenter = TimerDataPresenter(fileURL: timerDatabaseURL)
    var timerDB: TimerData {
        return timerDataPresenter.timerData
    }
    
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        let settings = UIUserNotificationSettings(forTypes: .Alert | .Badge | .Sound, categories: nil)
        application.registerUserNotificationSettings(settings)
        // Override point for customization after application launch.
        
        updateNotifications()
        NSLog("In application did finish launching, timers: %@", timerDB.timers.description)
        
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

        // TODO: remove file coordination demo code:
        // dyecb.invalidate()
        
        timerDataPresenter.invalidate()
    }

    func application(application: UIApplication, handleWatchKitExtensionRequest userInfo: [NSObject : AnyObject]?, reply: (([NSObject : AnyObject]!) -> Void)!) {
        // TODO: remove file coordination demo code:
        //        dyecb.text = "Here I come to save the day!"
        //        dyecb.write()
        // If you are using openParentApplication:reply:, make sure you create a background task immediately upon entering application:handleWatchKitExtensionRequest:reply:. This will make sure that the iPhone app gets time in the background instead of being suspended again. Additionally, wrap the call to endBackgroundTask: in a dispatch_after of 2 seconds to ensure that the iPhone app has time to send the reply before being suspended again. https://devforums.apple.com/thread/264473?tstart=0
        var didEndBackgroundTask = false
        var watchHandshakeBackgroundTaskIdentifier : UIBackgroundTaskIdentifier? = nil
        let taskEnder = { () -> Void in
            if !didEndBackgroundTask {
                // We need to end the background task immediately or we'll be terminated. We hope to never reach this code, since the background work below should be fast.
                UIApplication.sharedApplication().endBackgroundTask(watchHandshakeBackgroundTaskIdentifier!)
            }
        }
        watchHandshakeBackgroundTaskIdentifier = UIApplication.sharedApplication().beginBackgroundTaskWithExpirationHandler(taskEnder)
        
        NSLog("handling extension request with timers: %@", timerDB.timers.description)
        NSLog("request: %@", userInfo ?? "no user info")
        if let rawJSONData = userInfo as? [String: AnyObject] {
            let maybeCommand = TimerCommand.decodeJSONData(rawJSONData)
            switch maybeCommand {
            case .Left(let commandBox):
                let command = commandBox.contents
                switch command.commandType {
                case .Local:
                    assert(false, "shouldn't send local command to the iPhone app")
                case .Delete:
                    timerDB.deleteTimer(command.timer, commandType: .Local)
                default:
                    timerDB.updateTimer(command.timer, commandType: .Local)
                    updateNotificationsForTimer(command.timer)
                }

                timerDataPresenter.write()
                NSLog("updated iPhone database %@", timerDB.description)
                
                // TODO: Our data set is small enough to just send it all back in the reply. For a larger data set, we might want to tell the watch extension to re-read from the file.
                let updatedDB = timerDB.encodeToJSONData()
                let result = updatedDB as [NSObject: AnyObject]
                reply(result)
            case .Right(let errorBox):
                NSLog("error decoding command from watch extension: %@", errorBox.contents.description)
                // TODO: communicate error back to watch app
                reply([:])
            }
        } else {
            NSLog("userInfo from watch extension wasn't expected type [String: AnyObject]: %@", userInfo ?? "was nil");
            // TODO: communicate error back to watch app
            reply([:])
        }
        
        let endTime = dispatch_time(DISPATCH_TIME_NOW, Int64(2 * NSEC_PER_SEC))
        dispatch_after(endTime, dispatch_get_main_queue(), taskEnder)
    }
    
    private func updateNotificationsForTimer(timer: Timer) {
        // CCC, 1/5/2015. implement
        //        let notification = UILocalNotification()
        //        let oneMinuteHence = NSDate().dateByAddingTimeInterval(60.0)
        //        notification.fireDate = oneMinuteHence
        //        notification.alertTitle = "Fire!"
        //        notification.alertBody = "Release all zigs"
        //        application.scheduleLocalNotification(notification)
    }
    
    private func updateNotifications() {
        // CCC, 12/10/2014. implement
    }
    
    // CCC, 1/5/2015. Handle the case where the app is foregrounded when a notification expires.
}

