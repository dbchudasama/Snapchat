//
//  UserViewController.swift
//  Snapchat
//
//  Created by Divyesh B Chudasama on 04/11/2014.
//  Copyright (c) 2014 DChudasama. All rights reserved.
//

import UIKit

class UserViewController: UITableViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate {

    //Array to store users
    var userArray: [String] = []
    
    var activeRecipient = 0
    
    //Creating a timer variable
    var timer = NSTimer()
    
    func imagePickerController(picker: UIImagePickerController!, didFinishPickingImage image: UIImage!, editingInfo: [NSObject : AnyObject]!) {
        self.dismissViewControllerAnimated(true, completion: nil)
        
        //Upload to Parse using standard given code by Parse
        var imageToSend = PFObject(className:"image")
        //Fetching Image that needs to be uploaded to Parse
        imageToSend["photo"] = PFFile(name: "image.jpg", data: UIImageJPEGRepresentation(image, 0.5))//Value needs to be between 0 and 1, 1 being highest quality
        //Setting the username of the sender
        imageToSend["senderUsername"] = PFUser.currentUser().username
        //Setting the sender to that the image needs to be sent to
        imageToSend["recipientUsername"] = userArray[activeRecipient]
        imageToSend.save()
    }
    
    
    //Function that will allow the user to select their image
    @IBAction func pickImage(sender: AnyObject) {
        
        //Setting the image to the method Image Picker
        var image = UIImagePickerController()
        //Setting the image delegate to self
        image.delegate = self
        //As in simulator the camera can't be accessed, here setting the image source to be photo library
        image.sourceType = UIImagePickerControllerSourceType.Camera
        //Not allowing editing
        image.allowsEditing = false
        
        //Then setting the current view controller to be the image
        self.presentViewController(image, animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        var query = PFUser.query()
        //This will return all the users except the current one ie. the user himself/herself
        query.whereKey("username", notEqualTo: PFUser.currentUser().username)
        //Find all Users (contacts) who have added you as a contact. FindObjects() will ensure that no other action (for statement) is executed UNTIL ALL other users have been found. Synchronous call. IF we wanted to for statment to complete whilst finding users then would have to use findObjectsInBackgroundWithBlock, known as Asynchronous.
        var users = query.findObjects()
        
        for user in users {
            
            //For all users objects found append them to the userArray array so they display in the table
            userArray.append(user.username)
            
            //Refreshing the table of users incase new users have been added
            tableView.reloadData()
        }
        
        //Timer checking every 5 secs for a message
        timer = NSTimer.scheduledTimerWithTimeInterval(5, target: self, selector:("checkForMessage"), userInfo: nil, repeats: true)
        
    }
    
    func checkForMessage(){
        
        println("Checking for message...")
        
        //Query to check class 'image'
        var query = PFQuery(className: "image")
        
        //Here the recipient is being set for whom the query must search images
        query.whereKey("recipientUsername", equalTo: PFUser.currentUser().username)
       
        //Images variable to query and find objects
        var images = query.findObjects()
        
        //Initially setting to false i.e. query hasn't yet checked for updates
        var done = false
        
        //Looping through array of images
        for image in images {
            
            //If the check hasn't been completed then..
            if done == false {
                
                //This will create an image from the image file that the user sends
                var imageView:PFImageView = PFImageView()
                
                //Setting the imageView to the image file
                imageView.file = image["photo"] as PFFile
                
                //Instruction to download the image
                imageView.loadInBackground({ (photo, error) -> Void in
                    
                    //To make sure that an image has been successfully downloaded
                    if error == nil {
                        
                        //Passing this variable through in the below method
                        var senderUsername = ""
                        
                        //If sender name is from list of contacts then display the username
                        if image["senderUsername"] != nil {
                            
                            senderUsername = image["senderUsername"]! as NSString
                        
                        //Or else
                        } else {
                            
                            //Unkown User
                            senderUsername = "unkown user"
                            
                        }
        

                        
                        //Alert to inform the user who the sender is - Creating a UIAlertController
                        var alert = UIAlertController(title: "You have a message", message: "Message from \(senderUsername)", preferredStyle: UIAlertControllerStyle.Alert)
                        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: {(action) -> Void in
                        
                    /*
                        //Setting up a background view to avoid users from seeing the table of contacts as the image is being placed on top of the table and if the image that is sent is small then the chances of this are likely.
                        var backgroundView = UIImageView(frame: CGRectMake(0, 0, self.view.frame.width, self.view.frame.height))
                        
                        //Setting that backgroundView to be solid black
                        backgroundView.backgroundColor = UIColor.blackColor()
                        
                        //Giving a tint of see throughness, throught the black
                        backgroundView.alpha = 0.5
                        
                        //Now adding the backgroundView
                        self.view.addSubview(backgroundView)
                        
                    */
                        //Creating a UIImage and then putting on top of the Table. Here creating the image so that it is the full size of the screen frame
                        var displayedImage = UIImageView(frame: CGRectMake(0, 0, self.view.frame.width, self.view.frame.height))
                        
                        //Setting the image to be the image sent
                        displayedImage.image = photo
                        
                        //Setting a tag for the imageView to be used later when wanting to hide the images
                        displayedImage.tag = 3
                        
                        //Making sure the image is not stretched when displaying
                        displayedImage.contentMode = UIViewContentMode.ScaleAspectFit
                        //Now placing this image in the view
                        self.view.addSubview(displayedImage)
                        
                        //Delete image after one view and then do not replay
                        image.delete()
                        
                        //Here setting a timer to hide the image after five seconds, using the function hideMessage
                        self.timer = NSTimer.scheduledTimerWithTimeInterval(5, target: self, selector:("hideMessage"), userInfo: nil, repeats: false)
                        
                        }))
                        
                        self.presentViewController(alert, animated: true, completion: nil)
                    }
                    
                })
                
                
                done == true
            }
        }

    }
    
    //Function that will handle the image hiding
    func hideMessage() {
        
        //Looping through subviews
        for subview in self.view.subviews {
            
            //If a subview has the tag '3'
            if subview.tag == 3 {
                
                //Remove that subview from the screen
                subview.removeFromSuperview()
            }
        }
    }
    
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
       
        // Return the number of sections.
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
      
        // Return the number of users found
        return userArray.count
    }

    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath) as UITableViewCell

        // Configure the cell...
        // Setting the text of each cell to the name of each user
        cell.textLabel.text = userArray[indexPath.row]

        return cell
    }

    //This method will cater for sending a selected user from the table the image taken/chosen by calling
    //the pickImag method
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        //Here selecting the user to which the image needs to be sent
        activeRecipient = indexPath.row
        
        //Calling method pickImage
        pickImage(self)
    }
    
    //Function to handle user logout
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        //If user selects the 'logout' button then...
        if segue.identifier == "logout" {
            //Log the user out
            PFUser.logOut()
        }
    }
    
    
    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return NO if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return NO if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
    }
    */

}
