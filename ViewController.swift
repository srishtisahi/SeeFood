//
//  ViewController.swift
//  SeeFood
//
//  Created by Srishti Sahi on 10/08/24.
//

import UIKit
import CoreML
import Vision

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var imageView: UIImageView!
    
    let imagePicker = UIImagePickerController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        imagePicker.delegate = self
        //imagePicker.sourceType = .camera
        imagePicker.sourceType = .photoLibrary
        imagePicker.allowsEditing = false
        // Do any additional setup after loading the view.
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {

        if let userPickedImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {

            imageView.image = userPickedImage
            
            guard let ciimage = CIImage(image: userPickedImage) else {
                fatalError("Couldn't convert UIImage to CIImage")
            }
            
            detect(image: ciimage)
            
        }
        imagePicker.dismiss(animated: true, completion: nil)
    }
    
    func detect(image: CIImage) {
        let config = MLModelConfiguration()
        guard let model = try? VNCoreMLModel(for: Inceptionv3(configuration: config).model) else {
            fatalError("Loading CoreML Model Failed")
        }
        
        let request = VNCoreMLRequest(model: model) { (request, error) in
            guard let results = request.results as? [VNClassificationObservation] else {
                fatalError("Model failed to process image")
            }
            print(results)
            
            if let firstResult = results.first {
                if firstResult.identifier.contains("hotdog") {
                    self.navigationItem.title = "Hotdog!"
                } else {
                    self.navigationItem.title = "Not Hotdog!"
                }
            }
        }
        let handler = VNImageRequestHandler(ciImage: image)
        
        do {
            try handler.perform([request])
        }
        catch {
            print(error)
        }
    }

    @IBAction func cameraTapped(_ sender: UIBarButtonItem) {
        
        present(imagePicker, animated: true, completion: nil)
        
    }
    
}

