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
    @IBOutlet weak var intensity: UISlider!
    
    var currentImage: UIImage!
    var context: CIContext!
    var currentFilter: CIFilter!

    @IBAction func changeFilter() {
    }
    
    @IBAction func save() {
    }
    
    @IBAction func intensityChanged(_ sender: UISlider) {
        applyProcessing()
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
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        guard let image = info[UIImagePickerControllerEditedImage] as? UIImage else { return }
        dismiss(animated: true)
        currentImage = image
        
        let beginImage = CIImage(image: currentImage)
        currentFilter.setValue(beginImage, forKey: kCIInputImageKey)
        
        applyProcessing()
    }

    func importPicture() {
        let picker = UIImagePickerController()
        picker.allowsEditing = true
        picker.delegate = self
        present(picker, animated: true)
    }
    
    func applyProcessing() {
        currentFilter.setValue(intensity.value, forKey: kCIInputIntensityKey)
        // `currentFilter.outputImage!.extent` -- means render all of it 
            //-- until this method is called no actual processing is done
        if let cgimg = context.createCGImage(currentFilter.outputImage!, from: currentFilter.outputImage!.extent) {
            let processedImage = UIImage(cgImage: cgimg)
            imageView.image = processedImage
        }
        
    }
}

