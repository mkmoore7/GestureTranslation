//
//  ViewController.swift
//  Myo
//
//  Created by Dionisio Nunes on 23/06/16.
//  Copyright © 2016 Dionisio Nunes. All rights reserved.
//

import UIKit


private var myo: TLMMyo? {
    return TLMHub.sharedHub().myoDevices().first as? TLMMyo
}

class ViewController: UIViewController {
    
    @IBOutlet weak var accel: UILabel!
    @IBOutlet weak var gyro: UILabel!
    @IBOutlet weak var orient: UILabel!
    @IBOutlet weak var emgLabel: UILabel!
    @IBOutlet weak var status: UILabel!
 
    @IBAction func Connect(sender: AnyObject) {
        let controller = TLMSettingsViewController.settingsInNavigationController()
        presentViewController(controller, animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let notifer = NSNotificationCenter.defaultCenter()
        notifer.addObserverForName(TLMHubDidConnectDeviceNotification, object: nil, queue: nil) {
            (notification: NSNotification!) -> Void in
            myo!.setStreamEmg(.Enabled)
        }
        
        notifer.addObserver(
            self,
            selector: #selector(ViewController.didConnectDevice(_:)),
            name: TLMHubDidConnectDeviceNotification,
            object: nil)
        notifer.addObserver(
            self,
            selector: #selector(ViewController.didDisconnectDevice(_:)),
            name: TLMHubDidDisconnectDeviceNotification,
            object: nil)
        notifer.addObserver(
            self,
            selector: #selector(ViewController.didRecieveAccelerationEvent(_:)),
            name: TLMMyoDidReceiveAccelerometerEventNotification,
            object: nil)
        notifer.addObserver(
            self,
            selector: #selector(ViewController.onEmg(_:)),
            name: TLMMyoDidReceiveEmgEventNotification,
            object: nil)
        notifer.addObserver(
            self,
            selector:#selector(ViewController.didReceiveOrientationEvent(_:)),
            name: TLMMyoDidReceiveOrientationEventNotification,
            object: nil)
        
        notifer.addObserver(
            self,
            selector:#selector(ViewController.didReceiveGyroscopeEvent(_:)),
            name: TLMMyoDidReceiveGyroscopeEventNotification,
            object: nil)
        
        // Do any additional setup after loading the view, typically from a nib.
    }
    

    func didReceiveOrientationEvent(notification:NSNotification){
        let eventData = notification.userInfo as! Dictionary<NSString, TLMOrientationEvent>
        let orientationEvent = eventData[kTLMKeyOrientationEvent]
        
        let angles = GLKitPolyfill.getOrientation(orientationEvent)
        let pitch = CGFloat(angles.pitch.radians)
        let yaw = CGFloat(angles.yaw.radians)
        let roll = CGFloat(angles.roll.radians)
        orient.text = "Orientation: pitch(\(pitch)), yaw(\(yaw)), roll(\(roll))"
        
    }
    func didReceiveGyroscopeEvent(notification:NSNotification){
        let eventData = notification.userInfo as! Dictionary<NSString, TLMGyroscopeEvent>
        let gyroscopeEvent = eventData[kTLMKeyGyroscopeEvent]!
        
        let gyroData = GLKitPolyfill.getGyro(gyroscopeEvent);
        let x = gyroData.x
        let y = gyroData.y
        let z = gyroData.z
        gyro.text = "Gryo: x(\(x)), y(\(y)), z(\(z))"
        
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func didConnectDevice(notification: NSNotification) {
        status.text = "Status: Connected!"
    }
    func didDisconnectDevice(notification: NSNotification) {
        status.text = "Status: Disconnected :("
    }
    func didRecieveAccelerationEvent(notification: NSNotification) {
        let eventData = notification.userInfo as! Dictionary<NSString, TLMAccelerometerEvent>
        let accelerometerEvent = eventData[kTLMKeyAccelerometerEvent]!
        
        let acceleration = GLKitPolyfill.getAcceleration(accelerometerEvent);
        let x = acceleration.x
        let y = acceleration.y
        let z = acceleration.z
        
        accel.text = "Accel: x(\(x)), y(\(y)), z(\(z))"
        
    }
    
    
    func onEmg(notification: NSNotification) {
        if let emg = notification.userInfo?[kTLMKeyEMGEvent] as? TLMEmgEvent {
            print(emg.rawData)
            emgLabel.text = "\(emg.rawData)"
        }
    }
}

