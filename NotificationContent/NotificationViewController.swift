//
//  NotificationViewController.swift
//  NotificationContent
//
//  Created by Veronika Hristozova on 4/19/17.
//  Copyright © 2017 Centroida. All rights reserved.
//

import UIKit
import UserNotifications
import UserNotificationsUI
import CoreMotion

class NotificationViewController: UIViewController, UNNotificationContentExtension {
    
    @IBOutlet weak var imageView: UIImageView!
    
    var manager = CMMotionManager()
    
    func accelometerUpdate() {
        if manager.isGyroAvailable {
            manager.gyroUpdateInterval = 0.1
            manager.startGyroUpdates()
        }
        
        if manager.isDeviceMotionAvailable {
            manager.deviceMotionUpdateInterval = 0.01
            manager.startDeviceMotionUpdates(to: .main) {
                [weak self] (data: CMDeviceMotion?, error: Error?) in
                if let gravity = data?.gravity {
                    let rotation = atan2(gravity.x, gravity.y) - M_PI
                    self?.imageView.transform = CGAffineTransform(rotationAngle: CGFloat(rotation))
                }
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        accelometerUpdate()
        
        let size = view.bounds.size
        preferredContentSize = CGSize(width: size.width, height: size.height / 2)
    }
    
    func didReceive(_ notification: UNNotification) {
        if let notificationData = notification.request.content.userInfo["data"] as? [String: Any] {
            
            // Grab the attachment
            if let urlString = notificationData["attachment-url"], let fileUrl = URL(string: urlString as! String) {
                
                let imageData = NSData(contentsOf: fileUrl)
                let image = UIImage(data: imageData! as Data)!
                
                imageView.image = image
                accelometerUpdate()
            }
        }
    }
}
