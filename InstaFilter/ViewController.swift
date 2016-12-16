//
//  ViewController.swift
//  InstaFilter
//
//  Created by Noah Patterson on 12/15/16.
//  Copyright © 2016 noahpatterson. All rights reserved.
//

import UIKit
import CoreImage

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    @IBOutlet weak var imageView: UIImageView!
    
    @IBOutlet weak var intenstiyLabel: UILabel!
    @IBOutlet weak var intensity: UISlider!
    
    @IBOutlet weak var radiusLabel: UILabel!
    @IBOutlet weak var radius: UISlider!
    
    @IBOutlet weak var scaleLabel: UILabel!
    @IBOutlet weak var scale: UISlider!
    
    @IBOutlet weak var centerLabel: UILabel!
    @IBOutlet weak var center: UISlider!
    
    
    var currentImage: UIImage!
    var context: CIContext!
    var currentFilter: CIFilter! {
        didSet {
            title = currentFilter.name
        }
    }
    
    @IBAction func changeFilter() {
        let ac = UIAlertController(title: "Choose filter...", message: nil, preferredStyle: .actionSheet)
        ac.addAction(UIAlertAction(title: "CIBumpDistortion", style: .default, handler: setFilter))
        ac.addAction(UIAlertAction(title: "CIPixellate", style: .default, handler: setFilter))
        ac.addAction(UIAlertAction(title: "CISepiaTone", style: .default, handler: setFilter))
        ac.addAction(UIAlertAction(title: "CITwirlDistortion", style: .default, handler: setFilter))
        ac.addAction(UIAlertAction(title: "CIUnsharpMask", style: .default, handler: setFilter))
        ac.addAction(UIAlertAction(title: "CIVignette", style: .default, handler: setFilter))
        ac.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(ac, animated: true)
    }
    
    @IBAction func save() {
        guard currentImage != nil else { return }
        UIImageWriteToSavedPhotosAlbum(imageView.image!, self, #selector(image(_:didFinishSavingWithError:contextInfo:)), nil)
    }
    
    @IBAction func intensityChanged(_ sender: UISlider) {
        applyProcessing(sender)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        title = "YACIFP"
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(importPicture))
        context = CIContext()
        currentFilter = CIFilter(name: "CISepiaTone")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func image(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
        let ac: UIAlertController
        if let error = error {
            ac = UIAlertController(title: "Save error", message: error.localizedDescription, preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "OK", style: .cancel))
            
        } else {
            ac = UIAlertController(title: "Saved!", message: "Your altered image has been saved to your photos", preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "OK", style: .cancel))
        }
        present(ac, animated: true)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        guard let image = info[UIImagePickerControllerEditedImage] as? UIImage else { return }
        dismiss(animated: true)
        currentImage = image
        
        setFilter(nil)
    }

    func importPicture() {
        let picker = UIImagePickerController()
        picker.allowsEditing = true
        picker.delegate = self
        present(picker, animated: true)
    }
    
    func setFilter(_ action: UIAlertAction?) {
        guard currentImage != nil else { return }
        
        currentFilter = CIFilter(name: action?.title! ?? "CISepiaTone")
        
        let keyToSlider = [kCIInputIntensityKey: intensity, kCIInputRadiusKey: radius, kCIInputScaleKey: scale, kCIInputCenterKey: center]
        let possibleKeys: Set<String> = [kCIInputIntensityKey,kCIInputRadiusKey,kCIInputScaleKey,kCIInputCenterKey]
        let keys = checkFilterKeys()
        
        let keysNotUsed = possibleKeys.symmetricDifference(keys)
        
        for key in keysNotUsed {
            switch key {
            case kCIInputIntensityKey:
                intensity.isHidden = true
                intenstiyLabel.isHidden = true
            case kCIInputRadiusKey:
                radius.isHidden = true
                radiusLabel.isHidden = true
            case kCIInputScaleKey:
                scale.isHidden = true
                scaleLabel.isHidden = true
            case kCIInputCenterKey:
                center.isHidden = true
                centerLabel.isHidden = true
            default:
                break
            }

        }
        
        for key in keys {
            switch key {
            case kCIInputIntensityKey:
                intensity.isHidden = false
                intensity.value = 0.0
                intenstiyLabel.isHidden = false
            case kCIInputRadiusKey:
                radius.isHidden = false
                radius.value = 0.0
                radiusLabel.isHidden = false
            case kCIInputScaleKey:
                scale.isHidden = false
                scale.value = 0.0
                scaleLabel.isHidden = false
            case kCIInputCenterKey:
                center.isHidden = false
                center.value = 0.0
                centerLabel.isHidden = false
            default:
                break
            }
        }
        
        let beginImage = CIImage(image: currentImage)
        currentFilter.setValue(beginImage, forKey: kCIInputImageKey)
        
        applyProcessing(keyToSlider[keys.first!]!)
    }
    
    func checkFilterKeys() -> Set<String> {
        let inputKeys = currentFilter.inputKeys
        
        var foundKeys = Set<String>()
        if inputKeys.contains(kCIInputIntensityKey) {
            foundKeys.insert(kCIInputIntensityKey)
        }
        
        if inputKeys.contains(kCIInputRadiusKey) {
            foundKeys.insert(kCIInputRadiusKey)
        }
        
        if inputKeys.contains(kCIInputScaleKey) {
            foundKeys.insert(kCIInputScaleKey)
        }
        
        if inputKeys.contains(kCIInputCenterKey) {
            foundKeys.insert(kCIInputCenterKey)
        }
        return foundKeys
    }
    
    func applyProcessing(_ slider: UISlider?) {
        //not all filters have the same keys, we need to figure out which to assing
        //let inputKeys = currentFilter.inputKeys
        let keyToTag = [0: kCIInputIntensityKey, 1: kCIInputRadiusKey, 2: kCIInputScaleKey, 3: kCIInputCenterKey]
        let keyToValue: [String:Any] = [kCIInputIntensityKey: intensity.value, kCIInputRadiusKey: radius.value * 200, kCIInputScaleKey: scale.value * 10, kCIInputCenterKey: CIVector(x: currentImage.size.width * CGFloat(center.value), y: currentImage.size.height * CGFloat(center.value))]

        
        
         if let sliderKey = slider?.tag, let key = keyToTag[sliderKey] {
            currentFilter.setValue(keyToValue[key], forKey: key)
        }
        /*
        if inputKeys.contains(kCIInputIntensityKey) {
            currentFilter.setValue(intensity.value, forKey: kCIInputIntensityKey)
        }
        
        if inputKeys.contains(kCIInputRadiusKey) {
            currentFilter.setValue(intensity.value * 200, forKey: kCIInputRadiusKey)
        }
        
        if inputKeys.contains(kCIInputScaleKey) {
            currentFilter.setValue(intensity.value * 10, forKey: kCIInputScaleKey)
        }
        
        if inputKeys.contains(kCIInputCenterKey) {
            currentFilter.setValue(CIVector(x: currentImage.size.width / 2, y: currentImage.size.height / 2), forKey: kCIInputCenterKey)
        }
         */
        // `currentFilter.outputImage!.extent` -- means render all of it
            //-- until this method is called no actual processing is done
        if let cgimg = context.createCGImage(currentFilter.outputImage!, from: currentFilter.outputImage!.extent) {
            let processedImage = UIImage(cgImage: cgimg)
            imageView.image = processedImage
        }
        
    }
}

