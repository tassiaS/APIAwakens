//
//  ViewController.swift
//  TheApiAwakens
//
//  Created by Tassia Serrao on 12/01/2017.
//  Copyright © 2017 Tassia Serrao. All rights reserved.
//

import UIKit

class StarWarsViewController: UIViewController, UIGestureRecognizerDelegate {

    @IBOutlet weak var vehicleStackView: UIStackView!
    @IBOutlet weak var characterStackview: UIStackView!
    @IBOutlet weak var starshipStackview: UIStackView!
    var type: ResourceType!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let stackViews: [UIStackView] = [characterStackview, vehicleStackView, starshipStackview]
        
        for stackView in stackViews {
            let recognizer = UITapGestureRecognizer(target: self, action: #selector(didClickStackview(_:)))
            stackView.addGestureRecognizer(recognizer)
        }
    }

    func didClickStackview(_ gestureRecognizer: UITapGestureRecognizer) {
        type = ResourceType.getType(with: (gestureRecognizer.view?.tag)!)
        
        if Reachability.isConnectedToNetwork() {
            showSWDetailViewController()
        } else {
            showOfflineError()
        }
    }
    
    func showSWDetailViewController() {
        let detailVC = storyboard?.instantiateViewController(withIdentifier: "StarWarsDetailViewController") as! StarWarsDetailViewController
        detailVC.type = self.type
        navigationController?.pushViewController(detailVC, animated: true)
    }
    
    func showOfflineError() {
        let alert = UIAlertController(title: "You're offline", message: "Please connect to the internet and try again", preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
}

