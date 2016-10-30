//
//  OCRViewController.swift
//  SimpleScanner
//
//  Created by Ronen Lahat on 26/09/2016.
//  Copyright © 2016 Ronen Lahat. All rights reserved.
//

import UIKit
import TesseractOCR
import Parsimmon

class OCRViewController: UIViewController, UINavigationControllerDelegate {
    
    // MARK: - Properties

    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var syntaxSwitch: UISwitch!
    @IBOutlet weak var organizeBarButton: UIBarButtonItem!
    
    var activityIndicator: UIActivityIndicatorView!
    var originalTopMargin: CGFloat!
    var capturedImage : UIImage?
    var recognizedText : String?
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        navigationController?.isNavigationBarHidden = false
        
        if let imageToScan = capturedImage {
            scan(image: imageToScan)
        } else {
            print("no image to scan")
        }
        
    }
    
    // MARK: - Methods
    
    func scan(image: UIImage) {
        
        // disable user interaction and display an activity indicator to the user while Tesseract does its work.
        addActivityIndicator()
        
        guard let tesseract = G8Tesseract(language:"eng") else {
            print("Tesseract not available")
            return
        }
        tesseract.delegate = self
        
        tesseract.engineMode = .tesseractOnly
//        tesseract.pageSegmentationMode = .auto
//        tesseract.maximumRecognitionTime = 60.0
        tesseract.image = scaleImage(image, maxDimension: 640)
        tesseract.recognize()
        
        recognizedText = tesseract.recognizedText
        
        updateTextField()
        
        removeActivityIndicator()
        print("finished reading")
    }
    
    func updateTextField() {
        if syntaxSwitch.isOn {
            let tagger = ParsimmonTagger()
            let taggedTokens : Array = (tagger?.tagWords(inText: recognizedText))!
            print (taggedTokens)
            
            let attributedString = NSMutableAttributedString(string: "")
            
            for taggedToken : ParsimmonTaggedToken in taggedTokens as! [ParsimmonTaggedToken] {
                let attributes = getAttributes(from: taggedToken.tag)
                attributedString.append(NSMutableAttributedString(string: taggedToken.token + " ",
                                                                  attributes: attributes))
            }
            
            
            textView.attributedText = attributedString
        } else {
            textView.text = recognizedText
        }
        textView.isEditable = true
    }
    
    func getAttributes(from tag: String) -> [String : Any] {
        
        switch(tag) {
        case "PersonalName":
            return [NSStrokeWidthAttributeName : -2, NSForegroundColorAttributeName : UIColor.black]
//        case "Verb":
//            return [NSForegroundColorAttributeName : UIColor.red]
//        case "Adjective":
//            return [NSForegroundColorAttributeName : UIColor.blue]
//        case "Preposition":
//            return [NSForegroundColorAttributeName : UIColor.purple]
//        case "Pronoun":
//            return [NSForegroundColorAttributeName : UIColor.magenta]
        default:
            return [NSForegroundColorAttributeName : UIColor.black]
        }
    }
    
    // MARK: - Helper Methods
    
    func scaleImage(_ image: UIImage, maxDimension: CGFloat) -> UIImage {
        var scaledSize = CGSize(width: maxDimension, height: maxDimension)
        var scaleFactor: CGFloat
        
        if image.size.width > image.size.height {
            scaleFactor = image.size.height / image.size.width
            scaledSize.width = maxDimension
            scaledSize.height = scaledSize.width * scaleFactor
        } else {
            scaleFactor = image.size.width / image.size.height
            scaledSize.width = scaledSize.height * scaleFactor
            scaledSize.height = maxDimension
        }
        
        UIGraphicsBeginImageContext(scaledSize)
        image.draw(in: CGRect(x: 0,y: 0, width: scaledSize.width, height: scaledSize.height))
        let scaledImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return scaledImage!
    }
    
    // MARK: - Activity indicator methods
    
    func addActivityIndicator() {
        activityIndicator = UIActivityIndicatorView(frame: view.bounds)
        activityIndicator.activityIndicatorViewStyle = .gray
        activityIndicator.backgroundColor = UIColor.red
        activityIndicator.startAnimating()
        view.addSubview(activityIndicator)
    }
    
    func removeActivityIndicator() {
        activityIndicator.removeFromSuperview()
        activityIndicator = nil
    }
    
    // MARK: - IBActions
    
    @IBAction func switchChanged(_ sender: UISwitch) {
        updateTextField()
    }
    
    /*
    @IBAction func takePhoto(_ sender: AnyObject) {
        view.endEditing(true)
        
        let imagePickerActionSheet = UIAlertController(title: "Snap/Upload Photo", message: nil, preferredStyle: .actionSheet)
        
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            let cameraButton = UIAlertAction(title: "Take Photo", style: .default) { (alert) -> Void in
                let imagePicker = UIImagePickerController()
                imagePicker.delegate = self
                imagePicker.sourceType = .camera
                self.present(imagePicker, animated: true, completion: nil)
            }
            imagePickerActionSheet.addAction(cameraButton)
        }
        
        let libraryButton = UIAlertAction(title: "Choose Existing", style: .default) { (alert) -> Void in
            let imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.sourceType = .photoLibrary
            self.present(imagePicker, animated: true, completion: nil)
        }
        
        imagePickerActionSheet.addAction(libraryButton)
        
        let cancelButton = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        imagePickerActionSheet.addAction(cancelButton)
        
        present(imagePickerActionSheet, animated: true, completion: nil)
    }
    */
    
    @IBAction func share(_ sender: AnyObject) {
        if textView.text.isEmpty {
            return
        }
        let activityViewController = UIActivityViewController(activityItems: [textView.text], applicationActivities: nil)
        let excludeActivities : [UIActivityType] = [
            .assignToContact,
            .saveToCameraRoll,
            .addToReadingList,
            .postToFlickr,
            .postToVimeo]
        activityViewController.excludedActivityTypes = excludeActivities
        
        present(activityViewController, animated: true, completion: nil)
    }
    
    @IBAction func dismissKeyboard(_ sender: AnyObject) {
        textView.resignFirstResponder()
    }

    @IBAction func returnToCamera(_ sender: AnyObject) {
        let _ = navigationController?.popViewController(animated: true)
    }
    
    var previewIsClosed = true
    
    @IBAction func viewOriginal(_ sender: AnyObject) {
        let dismissTap = UITapGestureRecognizer(target: self, action: #selector(self.dismissPreview(_:)))
        
        if previewIsClosed {
            openPreview(dismissTap)
            previewIsClosed = false
        }
    }
    
    func openPreview(_ dismissTap: UITapGestureRecognizer) {
        let captureImageView = UIImageView(image: capturedImage) // UIImageView(image: UIImage(contentsOfFile: imageFilePath as! String))
        captureImageView.backgroundColor = UIColor(white: 0.0, alpha: 0.7)
        captureImageView.frame = self.view.bounds.offsetBy(dx: 0, dy: -self.view.bounds.size.height)
        captureImageView.alpha = 1.0
        captureImageView.contentMode = .scaleAspectFit
        captureImageView.isUserInteractionEnabled = true
        self.view.addSubview(captureImageView)
        
        captureImageView.addGestureRecognizer(dismissTap)
        UIView.animate(withDuration: 0.7, animations: { captureImageView.frame = self.view.bounds})
    }
    
    func dismissPreview(_ dismissTap: UITapGestureRecognizer) {

        UIView.animate(withDuration: 0.7, animations: {
            dismissTap.view?.frame = self.view.bounds.offsetBy(dx: 0, dy: self.view.bounds.size.height) }, completion:{ (finished) in
                                dismissTap.view?.removeFromSuperview() })
        previewIsClosed = true
    }
    
    @IBAction func save(_ sender: AnyObject) {
        let alert = UIAlertController(title: "Save Item",
                                      message: "Add a title",
                                      preferredStyle: .alert)
        
        let text = textView.text
        
        let saveAction = UIAlertAction(title: "Save",
                                       style: .default,
                                       handler: { (action:UIAlertAction) -> Void in
                                        
                                        let textField = alert.textFields!.first
                                        SnippetStore.shared.saveSnippet(title: textField!.text!, text: text!)
                                        
                                        self.performSegue(withIdentifier: "history", sender: self)
        })
        
        let cancelAction = UIAlertAction(title: "Cancel",
                                         style: .default) { (action: UIAlertAction) -> Void in
        }
        
        alert.addTextField {
            (textField: UITextField) -> Void in
        }
        
        alert.addAction(saveAction)
        alert.addAction(cancelAction)
        
        present(alert,
                animated: true,
                completion: nil)
    }


    
}

// MARK: - Extensions / Delegates

extension OCRViewController: UITextViewDelegate {
    func textViewShouldEndEditing(_ textView: UITextView) -> Bool {
        textView.resignFirstResponder()
        return true
    }
}

extension OCRViewController: G8TesseractDelegate {
    func shouldCancelImageRecognition(for tesseract: G8Tesseract!) -> Bool {
        // TODO: implement a cancel button
        return false; // return true if you need to interrupt tesseract before it finishes
    }
    
    func progressImageRecognitionForTesseract(for tesseract : G8Tesseract!) {
        // TODO: implement a progress bar
        print("progress...")
    }
}

extension OCRViewController: UIImagePickerControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        // a UIImagePickerDelegate method that returns the selected image information in an info dictionary object.
        
        let selectedPhoto = info[UIImagePickerControllerOriginalImage] as! UIImage
        let scaledImage = scaleImage(selectedPhoto, maxDimension: 640)
        
        
        // dismiss your UIImagePicker
        dismiss(animated: true) {
            // pass the image to scan()
            self.scan(image: scaledImage)
        }
        
    }
    
}
