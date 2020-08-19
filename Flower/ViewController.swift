//
//  ViewController.swift
//  Flowers
//
//  Created by Jamie on 2020/08/18.
//  Copyright © 2020 Jamie. All rights reserved.
//

import UIKit
import CoreML
import Vision
import Alamofire
import SwiftyJSON

class ViewController: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    
    
    let wikiURL = "https://en.wikipedia.org/w/api.php"
    
    @IBOutlet weak var photoView: UIImageView!
    
    let imagePicker = UIImagePickerController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        imagePicker.delegate = self
        imagePicker.sourceType = .camera
        imagePicker.allowsEditing = true
        
        
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        if let userPickedImage = info[UIImagePickerController.InfoKey.editedImage] as? UIImage {
            
            photoView.image = userPickedImage
            
            guard let convertedCiImage = CIImage(image: userPickedImage) else {
                fatalError("can't convert to CIImage")
            }
            
            detect(image: convertedCiImage)
            
            imagePicker.dismiss(animated: true, completion: nil)
        }
        
    }
    
    func detect(image: CIImage) {
        
        guard let model = try? VNCoreMLModel(for: FlowerClassifier().model) else {
            fatalError()
        }
        
        let request = VNCoreMLRequest(model: model) { (request, error) in
            
            guard let classification = request.results?.first as? VNClassificationObservation else {
                fatalError()
            }
           
            self.navigationItem.title = classification.identifier
            self.requestInfo(flowerName: classification.identifier)

        }
        
        let handler = VNImageRequestHandler(ciImage: image)
        
        do {
            try handler.perform([request])
            
        } catch {
            print("error")
        }
        
    }
    
    
    func requestInfo(flowerName: String) {
        
        let parameters : [String:String] = [
            "format" : "json",
            "action" : "query",
            "prop" : "extracts",
            "exintro" : "",
            "explaintext" : "",
            "titles" : flowerName,
            "indexpageids" : "",
            "redirects" : "1",
        ]
        
        Alamofire.request(wikiURL, method: .get, parameters: parameters).responseJSON { (response) in
            if response.result.isSuccess {
                print("got the wiki info")
                print(response)
            }
        }
        
        
        
        
        
    }
    
    
    @IBAction func cameraButton(_ sender: UIBarButtonItem) {
        
        present(imagePicker, animated: true, completion: nil)
        
    }
    
}

