//
//  ViewController.swift
//  Snapchat
//
//  Created by Divyesh B Chudasama on 02/11/2014.
//  Copyright (c) 2014 DChudasama. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet var Username: UITextField!
    
    @IBAction func SignIn(sender: AnyObject) {
        
        //Block code from Parse documentation that handles logIn of users
        PFUser.logInWithUsernameInBackground(Username.text, password:"mypass") {
            (user: PFUser!, error: NSError!) -> Void in
            if user != nil {
                // Do stuff after successful login.
                
                println("Logged In")
                
                //This will segue to the showUsers TableViewController, showing users after logging in
                self.performSegueWithIdentifier("showUsers", sender: self)
                
            } else {
                
                var user = PFUser()
                user.username = self.Username.text
                user.password = "mypass"
                
                user.signUpInBackgroundWithBlock {
                    (succeeded: Bool!, error: NSError!) -> Void in
                    if error == nil {
                        // Hooray! Let them use the app now.
                        println("Signed Up")
                        
                        self.performSegueWithIdentifier("showUsers", sender: self)
                        
                    } else {
                        
                        println(error)
                    }
                }
            }
        }
        
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.

        
    }

    override func viewDidAppear(animated: Bool) {
        
        //If the user is already logged in then...
        if PFUser.currentUser() != nil {
            
            //Load the user table straight away
            self.performSegueWithIdentifier("showUsers", sender: self)
            
        }
    }
    
 
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

