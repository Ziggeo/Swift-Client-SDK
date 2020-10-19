//
//  AppDelegate.swift
//  TestApplication
//
//  Created by alex on 18/08/16.
//  Copyright © 2016 Ziggeo Inc. All rights reserved.
//

import UIKit
import AVFoundation
import ZiggeoSwiftFramework

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    internal func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        do {
            try AVAudioSession.sharedInstance().setCategory(AVAudioSession.Category.playAndRecord, options: [AVAudioSession.CategoryOptions.duckOthers, AVAudioSession.CategoryOptions.defaultToSpeaker]);
            setupFileWatcher()
        }
        catch {}
        return true
    }

    var eventSource: DispatchSourceFileSystemObject?
    
    func setupFileWatcher() {
        guard let screenRecorderVideoDirectory = Self.getSharedDirectory() else {
            print("Failed to get shared directory")
            return
        }

        guard FileManager.default.fileExists(atPath: screenRecorderVideoDirectory.path) else {
            print("Shared directory doesn't exist")
            return
        }

        let descriptor = open(screenRecorderVideoDirectory.path, O_EVTONLY)
        if descriptor == -1 {
            return
        }

        self.eventSource = DispatchSource.makeFileSystemObjectSource(fileDescriptor: descriptor, eventMask: .write, queue: DispatchQueue.main)

        self.eventSource?.setEventHandler {
            self.processNewScreenRecordings()
        }

        self.eventSource?.setCancelHandler() {
            close(descriptor)
        }
        
        self.eventSource?.resume()
    }

    func processNewScreenRecordings() {
        guard let screenRecorderVideoDirectory = Self.getSharedDirectory() else {
            print("Failed to get shared directory")
            return
        }

        let files = (try? FileManager.default.contentsOfDirectory(at: screenRecorderVideoDirectory, includingPropertiesForKeys: nil, options: [])) ?? []

        let documentsDirectory = getDocumentsDirectory()

        print("Processing screen recordings:")

        for file in files {
            print("* \(file)")
            moveFile(file, to: documentsDirectory)
        }
    }

    func moveFile(_ source: URL, to destinationDirectory: URL) {
        let fileName = source.lastPathComponent

        let destination = destinationDirectory.appendingPathComponent(fileName)
        print("Moving file \(source) to \(destination)...")
        do {
            try FileManager.default.moveItem(at: source, to: destination)
            print("OK")
            // todo upload file with path stored in `destination`
        } catch {
            print("Unexpected error: \(error).")
        }
    }

    func getDocumentsDirectory() -> URL {
        // find all possible documents directories for this user
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)

        // just send back the first one, which ought to be the only one
        return paths[0]
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }

    func application(_ application: UIApplication, handleEventsForBackgroundURLSession identifier: String, completionHandler: @escaping () -> Void) {
        let ziggeo = Ziggeo(token: "ZIGGEO_APP_TOKEN");
        ziggeo.connect.postWithPath(identifier, data: nil) { (data, response, error) in
            completionHandler();
        }
    }

    static func getSharedDirectory() -> URL? {
        // path in the url variable is read only. only the Library/Caches subdirectory is writable
        let url = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: "group.Ziggeo.TestApplication.Group")
        let writableUrl = url?.appendingPathComponent("Library/Caches")
        return writableUrl
    }


}

