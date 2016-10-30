//
//  ScanViewController.swift
//  SimpleScanner
//
//  Created by Ronen Lahat on 25/09/2016.
//  Copyright © 2016 Ronen Lahat. All rights reserved.
//

import UIKit

import IPDFCameraViewController
import TOCropViewController

class ScanViewController: UIViewController, TOCropViewControllerDelegate {
    
    
    @IBOutlet weak var cameraViewController: IPDFCameraViewController!
    @IBOutlet weak var focusIndicator: UIImageView!

    // MARK: - View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.cameraViewController.setupCameraView()
        self.cameraViewController.isBorderDetectionEnabled = false
    }
    
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.setNavigationBarHidden(true, animated: animated)
        super.viewWillAppear(animated)
        
//        navigationController?.isNavigationBarHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        navigationController?.setNavigationBarHidden(false, animated: animated)
        super.viewWillDisappear(animated)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.cameraViewController.start()
    }
    
    //    func preferredStatusBarStyle() -> UIStatusBarStyle {
    //        return .lightContent
    //    }
    
    // MARK: - CameraVC Actions
    
    @IBAction func focusGesture(_ sender: AnyObject) {
        if (sender.state == .recognized) {
            let location = sender.location(in: self.cameraViewController)
            focusIndicatorAnimate(toPoint: location)
            cameraViewController.focus(at: location) {
                self.focusIndicatorAnimate(toPoint: location)
            }
        }
    }
    
    func focusIndicatorAnimate(toPoint targetPoint: CGPoint) {
        focusIndicator.center = targetPoint
        focusIndicator.alpha = 0.0
        focusIndicator.isHidden = false
        
        UIView.animate(withDuration: 0.4,
                       animations: { self.focusIndicator.alpha = 1.0 },
                       completion: { (finished) -> Void in
                        UIView.animate(withDuration: 0.4,
                                       animations: { self.focusIndicator.alpha = 0.0 })
        })
    }
    
    
    @IBAction func borderDetectToggle(_ sender: UIBarButtonItem) {
        let isBorderDetectionEnabled = !cameraViewController.isBorderDetectionEnabled
        
        let tagetImage = isBorderDetectionEnabled ?
            UIImage(named:"focusIndicator") :
            UIImage(named:"ic_crop_free_white")
        
        sender.image = tagetImage
        
        cameraViewController.isBorderDetectionEnabled = isBorderDetectionEnabled
            }
    
    @IBAction func filterToggle(_ sender: UIBarButtonItem) {
        let isCameraBlackAndWhite = cameraViewController.cameraViewType == .blackAndWhite
        
        cameraViewController.cameraViewType = isCameraBlackAndWhite ? .normal : .blackAndWhite
        
        let tagetImage = isCameraBlackAndWhite ? UIImage(named:"ic_invert_colors_white") :
            UIImage(named:"ic_invert_colors_off_white")
        
        sender.image = tagetImage
            }
    
    @IBAction func torchToggle(_ sender: UIBarButtonItem) {
        let isTorchEnabled = !cameraViewController.isTorchEnabled
        let tagetImage = isTorchEnabled ?
            UIImage(named:"ic_flash_on_white") :
            UIImage(named:"ic_flash_off_white")
        sender.image = tagetImage
        cameraViewController.isTorchEnabled = isTorchEnabled
            }
    
    
    func changeButton(_ button: UIBarButtonItem, targetTitle title: String, toStateEnabled enabled: Bool) {
        button.title = title // for: .normal
        button.tintColor = (enabled) ? UIColor(red: 1, green: 0.81, blue: 0, alpha: 1) : UIColor.white // for: .normal
    }
    
    // MARK: - CameraVC Capture Image
    
    @IBAction func captureButton(_ sender: AnyObject) {
        cameraViewController.captureImage(completionHander: { [unowned self] (imageFilePath) in
            guard let image = imageFilePath as? UIImage else {
                return
            }
            
            let isBorderDetectionEnabled = self.cameraViewController.isBorderDetectionEnabled
            
            if isBorderDetectionEnabled {
                // skip CropViewController
                self.performSegue(withIdentifier: "OCRSegue", sender: image)
            } else {
                self.presentCropViewController(image: image)
            }
            
        })
    }
    
    func presentCropViewController(image : UIImage) {
        
//        let imageView = UIImageView(image: image)
//        let frame : CGRect = self.view.convert(imageView.frame, to: self.view)
        
        let cropViewController = TOCropViewController(image: image)
        cropViewController?.aspectRatioPickerButtonHidden = true
        cropViewController?.delegate = self
        self.present(cropViewController!, animated:true, completion: nil)
//        cropViewController?.presentAnimated(fromParentViewController: self, from: imageView, fromFrame: frame, setup: nil, completion: nil)
    }
    
    func cropViewController(_ cropViewController : TOCropViewController, didCropTo image : UIImage, with cropRect: CGRect, angle:NSInteger) {
        // 'image' is the newly cropped version of the original image
        self.dismiss(animated: true) {
            self.performSegue(withIdentifier: "OCRSegue", sender: image)
        }
//        cropViewController.dismiss(animated: true) {
//            self.performSegue(withIdentifier: "OCRSegue", sender: self)
//        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "OCRSegue" {
            if let ocrViewController = segue.destination as? OCRViewController, let capturedImage = sender as? UIImage {
                ocrViewController.capturedImage = capturedImage
                //print("image \(capturedImage.description) prepared")
                //print("size of the cropped image: \(capturedImage.size.width) by \(capturedImage.size.height)")
                //print("size of the original image: \(image?.size.width) by \(image?.size.height)")

            }
        }
    }
}


