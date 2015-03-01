//
//  DeviceIdViewController.swift
//  Wee Greenhouse Monitor
//
//  Created by Jason Kusnier on 2/28/15.
//  Copyright (c) 2015 Jason Kusnier. All rights reserved.
//

import UIKit

class DeviceIdViewController: UIViewController {

    @IBOutlet weak var deviceIdText: UITextField!
    @IBOutlet weak var saveButton: UIButton!
    
    var delegateViewController:UIViewController?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    @IBAction func deviceIdChanged(sender: AnyObject) {
        self.saveButton.enabled = !self.deviceIdText.text.isEmpty
    }

    @IBAction func savePressed(sender: AnyObject) {
        let defaults = NSUserDefaults.standardUserDefaults()
        defaults.setValue(self.deviceIdText.text, forKey: "deviceId")
        defaults.synchronize()
        
        if let vc = self.delegateViewController as? ViewController {
            vc.closeModal()
        }
    }
    
}
