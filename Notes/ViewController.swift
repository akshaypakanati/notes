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

let font = UIFont(name:"AvenirNext-Regular", size:20.0) ?? UIFont.systemFont(ofSize: 20.0)
let attributes : [NSAttributedStringKey:Any] = [.font:font, .foregroundColor: UIColor.black]

class ViewController: UIViewController {
    
    @IBOutlet var previewView : UIView?
    @IBOutlet var textView:UITextView?
    
    @IBOutlet var placeholderLabel : UILabel?
    @IBOutlet var previewButton : UIButton?

    @IBOutlet var toolbar:UIToolbar?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let textView = textView {
            textViewDidChange(textView)
        }
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

    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showPreview" {
            let shareOption = segue.destination as? ShareViewController
            shareOption?.previewImage = captureScreen()
        }
    }
    
    
}

extension ViewController: UITextViewDelegate {
    
    func textViewDidChange(_ textView: UITextView) {
        placeholderLabel?.isHidden = !textView.text.isEmpty
        previewButton?.isEnabled = !textView.text.isEmpty
        let attri = NSMutableAttributedString(attributedString:textView.attributedText)
        attri.addAttributes(attributes, range: NSMakeRange(0,attri.length))
        textView.attributedText = attri
    }
    
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
        let insets = UIEdgeInsetsMake(0.0, 0.0, height + 40.0, 0.0)
        textView?.contentInset = insets
    }
    
    @objc func keyBoardHidden(_ aNoti:Notification) {
        UIView.animate(withDuration: 0.3, animations: {
            self.textView?.contentInset = UIEdgeInsets.zero
        })
    }
}


//MARK: - Image Upload
extension ViewController:UIImagePickerControllerDelegate,UINavigationControllerDelegate,CropViewControllerDelegate {
    
    func openGallery() {
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
            
            let imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.sourceType = .photoLibrary
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
            UIApplication.shared.open(NSURL(string: UIApplicationOpenSettingsURLString)! as URL)
        }))
        present(alert, animated: true, completion: nil)
    }
    
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
            picker.dismiss(animated: false, completion: {
                let cropViewController = CropViewController(image: image)
                cropViewController.delegate = self
                self.present(cropViewController, animated: true, completion: nil)
            })
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    func cropViewController(_ cropViewController: CropViewController, didCropToImage image: UIImage, withRect cropRect: CGRect, angle: Int) {
        // 'image' is the newly cropped version of the original image
        if let correctImage = image.correctlyOrientedImage() {
            appendImage(with: correctImage)
        }
        
        cropViewController.dismiss(animated: true, completion: nil)
    }
}

extension ViewController {
    
    func appendImage(with image:UIImage) {
        let textAttachment = NSTextAttachment()
        textAttachment.image = image
        
        if let cgImage = textAttachment.image?.cgImage, let textView = textView {
            let image = UIImage(cgImage:cgImage, scale: 1, orientation: .up)
            let scale = image.size.width/(textView.frame.size.width - 20)
            var width : CGFloat =  image.size.width
            var height = image.size.height
            if scale > 1 {
                width = textView.frame.size.width - 20
                height = height/scale
            }
            
            textAttachment.bounds = CGRect(x: 0, y: 0, width: width, height: height)
        }

        let attri = NSAttributedString(attachment: textAttachment)
        if let range = textView?.selectedRange, let attriText = textView?.attributedText {
            let mutableAttriString = NSMutableAttributedString(attributedString:attriText)
            mutableAttriString.addAttributes(attributes, range: NSMakeRange(0, attriText.length))
            mutableAttriString.replaceCharacters(in: range, with: attri)
            textView?.attributedText = mutableAttriString
            textView?.resignFirstResponder()
        }
    }
    
    func captureScreen() -> UIImage? {
        textView?.resignFirstResponder()
        
        var image : UIImage? = nil
        if let bg = previewView {
            UIGraphicsBeginImageContextWithOptions(bg.bounds.size, false, 2.0)
            if let context = UIGraphicsGetCurrentContext() {
                bg.layer.render(in: context)
                image = UIGraphicsGetImageFromCurrentImageContext()
                UIGraphicsEndImageContext()
            }
        }
        
        return image
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
