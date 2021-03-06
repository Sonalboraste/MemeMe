//
//  MemeEditorViewController.swift
//  MemeMe
//
//  Created by Mrunal Bhatt on 1/19/18.
//  Copyright © 2018 Sonal. All rights reserved.
//

import UIKit



class MemeEditorViewController: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate, UITextFieldDelegate
{
    
    
    @IBOutlet weak var navbarTop: UINavigationBar!
    
    
    @IBOutlet weak var buttonShare: UIBarButtonItem!
    
    
    @IBOutlet weak var imageViewPhoto: UIImageView!
    
    
    @IBOutlet weak var buttonGallery: UIBarButtonItem!
    
    
    @IBOutlet weak var buttonCamera: UIBarButtonItem!
    
    
    @IBOutlet weak var textFieldTop: UITextField!
    
    
    @IBOutlet weak var textFieldBottom: UITextField!
    
    
    @IBOutlet weak var toolbarBottom: UIToolbar!
    
    
    var defaultTopText = "TOP"
    
    var defaultBottomText = "BOTTOM"
    
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
       
        configure(textField: textFieldTop, withText: defaultTopText)
        
        configure(textField: textFieldBottom, withText: defaultBottomText)
        
        buttonShare.isEnabled = false
        
    }
    
    override func viewWillAppear(_ animated: Bool)
    {
        buttonCamera.isEnabled = UIImagePickerController.isSourceTypeAvailable(.camera)
        
        hideNavigationBar(true)
    }
    
    override func viewWillDisappear(_ animated: Bool)
    {
        super.viewWillDisappear(animated)
        unsubscribeFromKeyboardNotifications()
        
        hideNavigationBar(false)
    }
    
    @IBAction func pickImage(_ sender: Any)
    {
    
        let imagePickerController = UIImagePickerController()
        
        imagePickerController.delegate = self
        
        let clickedButton = sender as! UIBarButtonItem
        
        if(clickedButton.tag == 0)//pick Button
        {
            imagePickerController.sourceType = .photoLibrary
        }
        if(clickedButton.tag == 1) //camera button
        {
            
            imagePickerController.sourceType = .camera
        }
        
        present(imagePickerController, animated: true, completion: nil)
        
    }
    
    @IBAction func shareMemedImage(_ sender: Any)
    {
        
        // memed image to share
        let image = generateMemedImage()
        
        let imageToShare = [ image ]
        
        // set up activity view controller
        let activityController = UIActivityViewController(activityItems: imageToShare, applicationActivities: nil)
        
        activityController.completionWithItemsHandler = {(activityType: UIActivityType?, completed: Bool, returnedItems: [Any]?, error: Error?) in
            if !completed
            {
                // User canceled
                return
            }
            // User completed activity
            self.save()
            
            self.dismiss(animated: true, completion: nil)            
            
        }
        
        // present the view controller
        self.present(activityController, animated: true, completion: nil)   
        
    }
    
    @IBAction func cancelMemeCreation(_ sender: Any)
    {
        
        navigationController?.popToRootViewController(animated: true)
    }
    
    func configure(textField: UITextField, withText text: String)
    {
        
        textField.text = text
        
        let memeTextAttributes:[String:Any] = [
            NSStrokeColorAttributeName: UIColor.black,
            NSForegroundColorAttributeName: UIColor.white,
            NSFontAttributeName: UIFont(name: "HelveticaNeue-CondensedBlack", size: 25)!,
            NSStrokeWidthAttributeName: -5]
        
        textField.defaultTextAttributes = memeTextAttributes
        
        textField.textAlignment = .center
        
        textField.delegate = self
        
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController)
    {
        
       picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any])
    {
        
        //Enable the share button once image has beeen selected
        buttonShare.isEnabled = true
        
     
        imageViewPhoto.contentMode = .scaleAspectFit
        
        
        if (info[UIImagePickerControllerOriginalImage] as? UIImage) != nil
        {
            imageViewPhoto.image = info[UIImagePickerControllerOriginalImage] as? UIImage
        }
        
        picker.dismiss(animated: true, completion: nil)
        
        
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool
    {
        
        if textField.tag == 1
        {
            
            subscribeToKeyboardNotifications(isKeyBoardReturn: true)
        }
        
        textField.resignFirstResponder()
        
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField)
    {
        
        if textField.tag == 0
        {
            unsubscribeFromKeyboardNotifications()
            
            if textField.text == defaultTopText
            {
                textField.text = ""
            }
        }
        else if textField.tag == 1
        {
            
            subscribeToKeyboardNotifications(isKeyBoardReturn: false)
            
            if  textField.text == defaultBottomText
            {
                textField.text = ""
            }
        }
    }
    
    func keyboardWillShow(_ notification:Notification)
    {
        
        view.frame.origin.y = 0 - getKeyboardHeight(notification)
    }
    
    func keyboardWillHide(_ notification:Notification)
    {
        view.frame.origin.y = 0
    }

    
    func getKeyboardHeight(_ notification:Notification) -> CGFloat
    {
        
        let userInfo = notification.userInfo
        let keyboardSize = userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue // of CGRect
        return keyboardSize.cgRectValue.height
    }
    
    func subscribeToKeyboardNotifications(isKeyBoardReturn : Bool)
    {
        if isKeyBoardReturn
        {
            NotificationCenter.default.removeObserver(self, name: .UIKeyboardWillShow, object: nil)
            
            NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: .UIKeyboardWillHide, object: nil)
        }
        else
        {
            NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: .UIKeyboardWillShow, object: nil)
        }
    }
    
    func unsubscribeFromKeyboardNotifications()
    {
     
        NotificationCenter.default.removeObserver(self, name: .UIKeyboardWillHide, object: nil)
        
        NotificationCenter.default.removeObserver(self, name: .UIKeyboardWillShow, object: nil)
        
    }

    func save()
    {
        //Hide toolbar and navbar
        hideToolbarAndNavbar(isHide: true)
        
        let meme = Meme(stringTopText: textFieldTop.text! , stringBottomText: textFieldBottom.text!, imageOriginal: imageViewPhoto.image!, imageMemed: generateMemedImage())
        
        
        //Add meme to AppDelegate's memes array
                
        if let appDelegate = UIApplication.shared.delegate as? AppDelegate
        {
            appDelegate.memes.append(meme)
        }
        
        //Show toolbar and navbar
        hideToolbarAndNavbar(isHide: false)
        
    }
    
    func generateMemedImage() -> UIImage
    {
        
        
        
        // Render view to an image
        UIGraphicsBeginImageContext(self.view.frame.size)
        view.drawHierarchy(in: self.view.frame, afterScreenUpdates: true)
        let memedImage:UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        
       
        
        return memedImage
    }
    
    func hideToolbarAndNavbar(isHide : Bool)
    {
        navbarTop.isHidden = isHide
        toolbarBottom.isHidden = isHide
    }
    
    func hideNavigationBar(_ isHidden: Bool)
    {
        navigationController?.navigationBar.isHidden = isHidden
    }
    
}

