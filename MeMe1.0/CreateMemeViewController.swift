//
//  ViewController.swift
//  MeMe1.0
//
//  Created by Kaustubh on 02/05/2020.
//  Copyright © 2020 Kaustubh. All rights reserved.
//

import UIKit
import Foundation

class CreateMemeViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    
    let textFieldDelegate = MemeTextFieldDelegate()
    
    //MARK: outlets
    
    @IBOutlet weak var shareButton: UIBarButtonItem!
    
    @IBOutlet weak var imagePickerView: UIImageView!
    
    @IBOutlet weak var cameraButton: UIBarButtonItem!
    
    @IBOutlet weak var pickImageButton: UIBarButtonItem!
    
    @IBOutlet weak var imageToolbar: UIToolbar!
    
    @IBOutlet weak var topTextField: UITextField!
    
    @IBOutlet weak var bottomTextField: UITextField!
    
    @IBOutlet weak var topToolbar: UIToolbar!
    var memeImage: UIImage!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        prepareView()
        cameraButton.isEnabled =  UIImagePickerController.isSourceTypeAvailable(.camera)
        // Do any additional setup after loading the view.
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true, completion: nil)
        imagePickerView.image = info[.originalImage] as? UIImage
        if let _ = imagePickerView.image {
            self.shareButton.isEnabled = true
        } else {
            self.shareButton.isEnabled = false
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
        self.shareButton.isEnabled = false
        imagePickerView.image = nil
    }
    
    override func viewWillAppear(_ animated: Bool) {
        subscribeToKeyBoardNotifications()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        unsubscribeToKeyBoardNotifications()
    }
    
    fileprivate func setTextFieldProps(_ textField: UITextField) {
        let textAttributes : [NSAttributedString.Key : Any] = [
            .strokeColor: UIColor.black,
            .foregroundColor: UIColor.white,
            .strikethroughColor: UIColor.white,
            .font: UIFont(name: "HelveticaNeue-CondensedBlack", size: 40)!,
            .strokeWidth: -4.0
        ]
        textField.defaultTextAttributes = textAttributes
        textField.adjustsFontSizeToFitWidth = true
        textField.textAlignment = .center
        textField.allowsEditingTextAttributes = true
    }
    
    @objc fileprivate func keyboardWillShow(_ notification: Notification) {
        if bottomTextField.isEditing {
            view.frame.origin.y = -getKeyboardHeight(notification)
            
        }
    }
    
    @objc fileprivate func keyboardWillHide(_ notification: Notification) {
        if bottomTextField.isEditing {
            view.frame.origin.y = 0
        }
    }
    
    fileprivate func getKeyboardHeight(_ notification: Notification) -> CGFloat {
        let userInfo = notification.userInfo
        let keyboardSize = userInfo![UIResponder.keyboardFrameEndUserInfoKey] as! NSValue
        return keyboardSize.cgRectValue.height
    }
    
    fileprivate func subscribeToKeyBoardNotifications(){
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        
    }
    
    fileprivate func unsubscribeToKeyBoardNotifications(){
        NotificationCenter.default.removeObserver(self)
    }
    
    fileprivate func generateImage() -> UIImage {
        
        hideToolbars(true)
        
        // Render view to an image
        UIGraphicsBeginImageContext(self.view.frame.size)
        view.drawHierarchy(in: self.view.frame, afterScreenUpdates: true)
        let memedImage:UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        
        hideToolbars(false)
        
        return memedImage
    }
    
    fileprivate func prepareView() {
        
        //Prepare Text fields within image view
        self.topTextField.delegate = self.textFieldDelegate
        self.bottomTextField.delegate = self.textFieldDelegate
        
        self.setTextFieldProps(self.topTextField)
        self.setTextFieldProps(self.bottomTextField)
        
        //share button settings
        self.shareButton.isEnabled = false
        
    }
    
    //pick image from photo library
    @IBAction func pickAnImageFromCamera(_ sender: Any) {
        pickAnImage(.camera)
    }
    
    //pick image by camera roll button
    @IBAction func pickAnImageFromAlbum(_ sender: Any) {
        pickAnImage(.photoLibrary)
    }
    
    fileprivate func pickAnImage(_ source : UIImagePickerController.SourceType) {
        let pickerController = UIImagePickerController()
        pickerController.delegate = self
        pickerController.sourceType = source
        present(pickerController, animated: true, completion: nil)
    }
    
    //share image action
    @IBAction func share() {
        memeImage = generateImage()
        let activity = UIActivityViewController(activityItems: [memeImage!], applicationActivities: nil)
        show(activity, sender: self)
        activity.completionWithItemsHandler = {(activity, completed, items, error) in
            if (completed){
                self.save()
                return
            }
        }
    }
    
    fileprivate func save() {
        let _ = Meme(
            topText:self.topTextField.text!,
            bottomText: self.bottomTextField.text!,
            image: self.imagePickerView.image!,
            memedImage: memeImage)
    }
    
    fileprivate func hideToolbars(_ hide: Bool) {
        topToolbar.isHidden = hide
        imageToolbar.isHidden = hide
    }
    
    
}



