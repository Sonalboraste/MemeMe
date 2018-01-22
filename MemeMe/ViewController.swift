//
//  ViewController.swift
//  MemeMe
//
//  Created by Mrunal Bhatt on 1/19/18.
//  Copyright © 2018 Sonal. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate, UITextFieldDelegate
{
    
    @IBOutlet weak var imageViewPhoto: UIImageView!

    @IBOutlet weak var buttonCamera: UIButton!
    
    @IBOutlet weak var buttonGallery: UIButton!
    
    @IBOutlet weak var textFieldTop: UITextField!
    
    @IBOutlet weak var textFieldBottom: UITextField!
    
    var defaultTopText = "TOP"
    
    var defaultBottomText = "BOTTOM"
    
    struct MemeStruct
    {
        var stringTopText = ""
        var stringBottomText = ""
        var imageOriginal = UIImage()
        var imageMemed = UIImage()
    }
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.

        textFieldTop.text = defaultTopText
        
        textFieldBottom.text = defaultBottomText
        
        let memeTextAttributes:[String:Any] = [
            NSStrokeColorAttributeName: UIColor.black,
            NSForegroundColorAttributeName: UIColor.white,
            NSFontAttributeName: UIFont(name: "HelveticaNeue-CondensedBlack", size: 25)!,
            NSStrokeWidthAttributeName: 12]
        
        textFieldTop.defaultTextAttributes = memeTextAttributes
        textFieldBottom.defaultTextAttributes = memeTextAttributes
        
        textFieldTop.textAlignment = .center
        textFieldBottom.textAlignment = .center
        
        textFieldTop.delegate = self
        textFieldBottom.delegate = self
        
    }
    
    override func viewWillAppear(_ animated: Bool)
    {
        buttonCamera.isEnabled = UIImagePickerController.isSourceTypeAvailable(.camera)
        
    }
    
    override func viewWillDisappear(_ animated: Bool)
    {
        super.viewWillDisappear(animated)
        unsubscribeFromKeyboardNotifications()
    }
    
    @IBAction func pickImage(_ sender: Any)
    {
        let imagePickerController = UIImagePickerController()
        
        imagePickerController.delegate = self
        
        let clickedButton = sender as! UIButton
        
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
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController)
    {
        print("Did Cancel")
        
       picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any])
    {
        print("imagePickerController")
     
        imageViewPhoto.contentMode = .scaleAspectFit
        
        
        if (info[UIImagePickerControllerOriginalImage] as? UIImage) != nil
        {
            imageViewPhoto.image = info[UIImagePickerControllerOriginalImage] as? UIImage
        }
        
        picker.dismiss(animated: true, completion: nil)
        
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool
    {
        print("Test the return key")
        
        
        if textField.tag == 1
        {
            print("BOTTOM")
            
            
            subscribeToKeyboardNotifications(isKeyBoardReturn: true)
        }
        
        textField.resignFirstResponder()
        
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField)
    {
        print("Start...")

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
        //let meme = MemeStruct(stringTopText: textFieldTop.text! , stringBottomText: textFieldBottom.text!, imageOriginal: imageViewPhoto.image!, imageMemed: generateMemedImage())
        
    }
    
    func generateMemedImage() -> UIImage {
        
        // TODO: Hide toolbar and navbar
        
        // Render view to an image
        UIGraphicsBeginImageContext(self.view.frame.size)
        view.drawHierarchy(in: self.view.frame, afterScreenUpdates: true)
        let memedImage:UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        
        // TODO: Show toolbar and navbar
        
        return memedImage
    }
}

