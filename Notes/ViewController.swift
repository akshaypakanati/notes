//
//  ViewController.swift
//  Notes
//
//  Created by Ganesh Potnuru on 1/9/18.
//  Copyright © 2018 Ganesh Potnuru. All rights reserved.
//

import UIKit
import AVFoundation
import Photos

let font = UIFont.systemFont(ofSize: 19.0)
let attributes : [NSAttributedStringKey:Any] = [.font:font, .foregroundColor: UIColor.white]

class ViewController: UIViewController {

    @IBOutlet var textView:UITextView?
    @IBOutlet var toolbar:UIToolbar?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        textView?.inputAccessoryView = toolbar
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func selectImage(_ sender:UIBarButtonItem) {
        openGallery()
    }
    @IBAction func done(_ sender:UIBarButtonItem) {
        textView?.resignFirstResponder()
    }

}

extension ViewController: UITextViewDelegate {
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        NotificationCenter.default.addObserver(self, selector: #selector(keyBoardShown), name: NSNotification.Name.UIKeyboardDidShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyBoardHidden), name: NSNotification.Name.UIKeyboardDidHide, object: nil)
    }
    
    override func viewWillDisappear(_ animated : Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardDidHide, object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardDidShow, object: nil)
    }
    
    @objc func keyBoardShown(_ aNotification:Notification) {
        let info = aNotification.userInfo
        let kbSize = (info?[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue.size
        let height =  kbSize?.height ?? 0.0
        let insets = UIEdgeInsetsMake(0.0, 0.0, height, 0.0)
        textView?.contentInset = insets
    }
    
    @objc func keyBoardHidden(_ aNoti:Notification) {
        UIView.animate(withDuration: 0.3, animations: {
            self.textView?.contentInset = UIEdgeInsets.zero
        })
    }
}


//MARK: - Image Upload
extension ViewController:UIImagePickerControllerDelegate,UINavigationControllerDelegate {
    
    func openGallery() {
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
            
            let imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.sourceType = .photoLibrary
            imagePicker.allowsEditing = true
            self.navigationController?.present(imagePicker, animated: true, completion: nil)
        }
    }
    
    func checkGallery() {
        PHPhotoLibrary.requestAuthorization { status in
            switch status {
            case .authorized:
                self.openGallery()
                break
            case .restricted:
                self.alertToEncourageGalleryAccessInitially()
                break
            case .denied:
                self.alertToEncourageGalleryAccessInitially()
                break
            default:
                // place for .notDetermined - in this callback status is already determined so should never get here
                break
            }
        }
    }
    
    //"Please go to Settings > Unidos to enable enable gallery access
    func alertToEncourageGalleryAccessInitially() {
        let alert = UIAlertController(
            title: nil,
            message: "Please go to Settings > Tweet",
            preferredStyle: UIAlertControllerStyle.alert
        )
        alert.addAction(UIAlertAction(title: "Cancel", style: .default, handler: nil))
        alert.addAction(UIAlertAction(title: "Settings", style: .cancel, handler: { (alert) -> Void in
            UIApplication.shared.openURL(NSURL(string: UIApplicationOpenSettingsURLString)! as URL)
        }))
        present(alert, animated: true, completion: nil)
    }
    
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        
        if let image = info[UIImagePickerControllerEditedImage] as? UIImage, let correctImage = image.correctlyOrientedImage() {
                appendImage(with: correctImage)
            }
        picker.dismiss(animated: true, completion: nil)
        
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
}

extension ViewController {
    
    func appendImage(with image:UIImage) {
        let textAttachment = NSTextAttachment()
        textAttachment.image = image
        let oldWidth = textAttachment.image!.size.width
        let width : CGFloat =  300.0
        let scaleFactor = oldWidth / (width - 10)
        if let cgImage = textAttachment.image?.cgImage {
            textAttachment.image = UIImage(cgImage:cgImage, scale: scaleFactor, orientation: .up)
            
            textAttachment.bounds = CGRect(x: (self.view.frame.size.width - width)/2, y: 0, width: width, height: width)
        }

        let attri = NSAttributedString(attachment: textAttachment)
        if let range = textView?.selectedRange, let attriText = textView?.attributedText {
            let mutableAttriString = NSMutableAttributedString(attributedString:attriText)
            mutableAttriString.addAttributes(attributes, range: NSRange(loc:0 ,len:attriText.length))
            mutableAttriString.replaceCharacters(in: range, with: attri)
            textView?.attributedText = mutableAttriString
            textView?.resignFirstResponder()
        }
    }
    
}

extension UIImage {
    func correctlyOrientedImage() -> UIImage? {
        if self.imageOrientation == .up {
            return self
        }
        
        UIGraphicsBeginImageContextWithOptions(self.size, false, self.scale)
        self.draw(in: CGRect(x: 0, y: 0, width: self.size.width, height: self.size.height))
        
        let normalizedImage = UIGraphicsGetImageFromCurrentImageContext()
        
        UIGraphicsEndImageContext()
        return normalizedImage
    }
}
