//
//  ViewController.swift
//  SimpleScanner
//
//  Created by Ronen Lahat on 25/09/2016.
//  Copyright © 2016 Ronen Lahat. All rights reserved.
//

import UIKit

import IPDFCameraViewController

class ViewController: UIViewController {

    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var cameraViewController: IPDFCameraViewController!
    @IBOutlet weak var focusIndicator: UIImageView!

    
    // MARK: - View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.cameraViewController.setupCameraView()
        self.cameraViewController.isBorderDetectionEnabled = true
        updateTitleLabel()
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
    
    
    @IBAction func borderDetectToggle(_ sender: AnyObject) {
        let enabled = !cameraViewController.isBorderDetectionEnabled
        changeButton(sender as! UIBarButtonItem, targetTitle: (enabled) ? "CROP On" : "CROP Off", toStateEnabled: enabled)
        cameraViewController.isBorderDetectionEnabled = enabled
        updateTitleLabel()
    }
    
    @IBAction func filterToggle(_ sender: AnyObject) {
        cameraViewController.cameraViewType = (cameraViewController.cameraViewType == .blackAndWhite) ? .normal : .blackAndWhite
    }
    
    @IBAction func torchToggle(_ sender: AnyObject) {
        let enabled = !cameraViewController.isTorchEnabled
        changeButton(sender as! UIBarButtonItem, targetTitle: (enabled) ? "FLASH On" : "FLASH Off", toStateEnabled: enabled)
        cameraViewController.isTorchEnabled = enabled
    }
    
    func updateTitleLabel(){
        let animation = CATransition()
        animation.timingFunction = CAMediaTimingFunction.init(name: kCAMediaTimingFunctionEaseOut)
        animation.type = kCATransitionPush
        animation.subtype = kCATransitionFromBottom
        animation.duration = 0.35
        titleLabel.layer.add(animation, forKey: "kCATransitionFade")
        
        let filterMode = (cameraViewController.cameraViewType == .blackAndWhite) ? "TEXT FILTER" : "COLOR FILTER"
        titleLabel.text = filterMode.appendingFormat(" | ",
                                                     (cameraViewController.isBorderDetectionEnabled) ? "TEXT FILTER" : "COLOR FILTER")
    }
    
    func changeButton(_ button: UIBarButtonItem, targetTitle title: String, toStateEnabled enabled: Bool) {
        button.title = title // for: .normal
        button.tintColor = (enabled) ? UIColor(red: 1, green: 0.81, blue: 0, alpha: 1) : UIColor.white // for: .normal
    }
    
    // MARK: - CameraVC Capture Image
    
    func dismissPreview(_ dismissTap: UITapGestureRecognizer) {
        UIView.animate(withDuration: 0.7,
                       delay: 0.0,
                       usingSpringWithDamping: 0.8,
                       initialSpringVelocity: 0.7,
                       options: .allowUserInteraction,
                       animations: {
                        dismissTap.view?.frame = self.view.bounds.offsetBy(dx: 0, dy: self.view.bounds.size.height) },
                       completion: { (finished) in
                        dismissTap.view?.removeFromSuperview() })
    }

    
    @IBAction func captureButton(_ sender: AnyObject) {
        cameraViewController.captureImage(completionHander: { [unowned self] (imageFilePath) in
            let captureImageView = UIImageView(image: imageFilePath as? UIImage) // UIImageView(image: UIImage(contentsOfFile: imageFilePath as! String))
            captureImageView.backgroundColor = UIColor(white: 0.0, alpha: 0.7)
            captureImageView.frame = self.view.bounds.offsetBy(dx: 0, dy: -self.view.bounds.size.height)
            captureImageView.alpha = 1.0
            captureImageView.contentMode = .scaleAspectFit
            captureImageView.isUserInteractionEnabled = true
            self.view.addSubview(captureImageView)
            
            let dismissTap = UITapGestureRecognizer(target: self, action: #selector(self.dismissPreview(_:)))
            captureImageView.addGestureRecognizer(dismissTap)
            
            UIView.animate(withDuration: 0.7,
                           delay: 0.0,
                           usingSpringWithDamping: 0.0,
                           initialSpringVelocity: 0.7,
                           options: .allowUserInteraction,
                           animations: {
                            captureImageView.frame = self.view.bounds },
                           completion: nil)
        
        })
    }
}


// MARK: - extensions

extension UIColor {
    convenience init(red: Int, green: Int, blue: Int) {
        assert(red >= 0 && red <= 255, "Invalid red component")
        assert(green >= 0 && green <= 255, "Invalid green component")
        assert(blue >= 0 && blue <= 255, "Invalid blue component")
        
        self.init(red: CGFloat(red) / 255.0, green: CGFloat(green) / 255.0, blue: CGFloat(blue) / 255.0, alpha: 1.0)
    }
    
    convenience init(netHex:Int) {
        self.init(red:(netHex >> 16) & 0xff, green:(netHex >> 8) & 0xff, blue:netHex & 0xff)
    }
}

