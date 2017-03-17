//
//  ViewController.swift
//  TheApiAwakens
//
//  Created by Tassia Serrao on 12/01/2017.
//  Copyright © 2017 Tassia Serrao. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UIGestureRecognizerDelegate{
    
    @IBOutlet weak var vehicleStackView: UIStackView!
    @IBOutlet weak var characterStackview: UIStackView!
    @IBOutlet weak var starshipStackview: UIStackView!
    var type: ResourceType!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Add tapGestureRecognizer to imageViews
        let stackViews = [characterStackview, vehicleStackView, starshipStackview]
        for stackView in stackViews {
            let recognizer = UITapGestureRecognizer(target: self, action: #selector(showDetailViewController(_:)))
            recognizer.delegate = self
            stackView?.addGestureRecognizer(recognizer)
        }
    }

    func showDetailViewController(_ gestureRecognizer: UITapGestureRecognizer) {
        type = ResourceType.getType(with: (gestureRecognizer.view?.tag)!)
        if isConnectedToNetwork() {
            let detailVC = storyboard?.instantiateViewController(withIdentifier: "detailViewController") as! DetailViewController
            detailVC.type = self.type
            navigationController?.pushViewController(detailVC, animated: true)
        }
    }
    
    func isConnectedToNetwork() -> Bool{
        if Network.isConnectedToNetwork() == true {
            print("Internet connection OK")
            return true
        } else {
            let alert = UIAlertController(title: "Alert", message: "The Internet connection appears to be offline", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "Click", style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
            print("Internet connection FAILED")
            return false
        }
    }

}

