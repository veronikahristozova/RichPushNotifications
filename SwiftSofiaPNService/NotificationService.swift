//
//  NotificationService.swift
//  SwiftSofiaPNService
//
//  Created by Veronika Hristozova on 4/19/17.
//  Copyright © 2017 Centroida. All rights reserved.
//

import UserNotifications
import UIKit

class NotificationService: UNNotificationServiceExtension {
    
    var contentHandler: ((UNNotificationContent) -> Void)?
    var bestAttemptContent: UNMutableNotificationContent?
    
    override func didReceive(_ request: UNNotificationRequest, withContentHandler contentHandler: @escaping (UNNotificationContent) -> Void) {
        self.contentHandler = contentHandler
        bestAttemptContent = (request.content.mutableCopy() as? UNMutableNotificationContent)
        
        //Media
        func failEarly() {
            contentHandler(request.content)
        }
        
        guard let content = (request.content.mutableCopy() as? UNMutableNotificationContent) else {
            return failEarly()
        }
        
        guard let apnsData = content.userInfo["data"] as? [String: Any] else {
            return failEarly()
        }
        
        guard let attachmentURL = apnsData["attachment-url"] as? String else {
            return failEarly()
        }
        
        guard let imageData = NSData(contentsOf:NSURL(string: attachmentURL)! as URL) else { return failEarly() }
        guard let attachment = UNNotificationAttachment.create(imageFileIdentifier: "image.gif", data: imageData, options: nil) else { return failEarly() }
        
        
        //Actions
        let likeAction = UNNotificationAction(identifier: "meow", title: "Meow", options: [])
        
        let addToCartAction = UNNotificationAction(identifier: "pizza", title: "Pizza?", options: [])
        
        let category = UNNotificationCategory(identifier: "myCategory", actions: [likeAction, addToCartAction], intentIdentifiers: [], options: [])
        
        UNUserNotificationCenter.current().setNotificationCategories([category])
        
        content.attachments = [attachment]
        contentHandler(content.copy() as! UNNotificationContent)
    }
    
    override func serviceExtensionTimeWillExpire() {
        // Called just before the extension will be terminated by the system.
        // Use this as an opportunity to deliver your "best attempt" at modified content, otherwise the original push payload will be used.
        if let contentHandler = contentHandler, let bestAttemptContent =  bestAttemptContent {
            contentHandler(bestAttemptContent)
        }
    }
    
}
extension UNNotificationAttachment {
    
    /// Save the image to disk
    static func create(imageFileIdentifier: String, data: NSData, options: [NSObject : AnyObject]?)
        -> UNNotificationAttachment? {
            
            let fileManager = FileManager.default
            let tmpSubFolderName = ProcessInfo.processInfo.globallyUniqueString
            let fileURLPath      = NSURL(fileURLWithPath: NSTemporaryDirectory())
            let tmpSubFolderURL  = fileURLPath.appendingPathComponent(tmpSubFolderName, isDirectory: true)
            
            do {
                try fileManager.createDirectory(at: tmpSubFolderURL!,
                                                withIntermediateDirectories: true,
                                                attributes: nil)
                let fileURL = tmpSubFolderURL?.appendingPathComponent(imageFileIdentifier)
                try data.write(to: fileURL!, options: [])
                let imageAttachment = try UNNotificationAttachment.init(identifier: imageFileIdentifier,
                                                                        url: fileURL!,
                                                                        options: options)
                return imageAttachment
            } catch let error {
                print("error \(error)")
            }
            
        return nil
    }
}










