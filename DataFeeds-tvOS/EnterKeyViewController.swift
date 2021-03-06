//
//  EnterKeyViewController.swift
//  DataFeeds
//
//  Created by Paula Petcu on 9/11/16.
//  Copyright © 2016 monohelixlabs. All rights reserved.
//

import UIKit

class EnterKeyViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet var codeTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.codeTextField.delegate = self
        
        UserDefaultsManager.sharedInstance.setShownKeyScreen(true)
    }

    override func viewWillAppear(_ animated: Bool) {
        codeTextField.text = UserDefaultsManager.sharedInstance.getAIOkey()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        let aiokey = codeTextField.text! as String
        codeTextField.endEditing(true)
        
        UserDefaultsManager.sharedInstance.setAIOkey(aiokey)
        
        return false
    }

    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        // guard against anything but alphanumeric characters
        let set = NSCharacterSet.alphanumerics.inverted
        return string.rangeOfCharacter(from: set) == nil
        
    }
    
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
