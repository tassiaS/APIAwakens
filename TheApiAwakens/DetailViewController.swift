//
//  DetailViewController.swift
//  TheApiAwakens
//
//  Created by Tassia Serrao on 13/01/2017.
//  Copyright © 2017 Tassia Serrao. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource, UIScrollViewDelegate, UITextFieldDelegate {
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var makeLabel: UILabel!
    @IBOutlet weak var costLabel: UILabel!
    @IBOutlet weak var lengthLabel: UILabel!
    @IBOutlet weak var classLabel: UILabel!
    @IBOutlet weak var crewLabel: UILabel!
    @IBOutlet weak var pickerView: UIPickerView!
    @IBOutlet weak var smallestLabel: UILabel!
    @IBOutlet weak var largestLabel: UILabel!
    @IBOutlet weak var usdButton: UIButton!
    @IBOutlet weak var creditButton: UIButton!
    @IBOutlet weak var EnglishButton: UIButton!
    @IBOutlet weak var metricButton: UIButton!
    @IBOutlet weak var exchangeLabel: UILabel!
    @IBOutlet weak var exchangeTextField: UITextField!
    
    
    var totalValueToEnglish = 0.0
    var totalValueToMetric = 0.0
    var objectQuantity = 0
    var lastPickerViewIndex = 0
    var pickerData = [String]()
    var nextPageNumber = 1
    var type = ResourceType.none
    var swAPIClient: SWApiClient = SWApiClient()
    var starships = [Starship]()
    var valueSelectedAllTypes: Measurable!
    var valueSelectedTransportCraft: TransportCraft!
    var exchangeRateValue = 0

    var hasNextPage = true {
        didSet {
            if hasNextPage { nextPageNumber += 1 }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        loadData()
        pickerView.delegate = self
        pickerView.dataSource = self
        exchangeTextField.delegate = self
        self.addDoneButtonOnKeyboard()
    }

    func loadData() {
        switch type {
            case .starship : fetchForStarship(with: nextPageNumber)
            default: break
        }
    }
    
    func fetchForStarship(with page: Int) {
        swAPIClient.fetchForStarship(nextPage: nextPageNumber, completion: { [weak self] (result) in
            switch result {
                case .success(let result):
                    self?.pickerData = [String]()
                    self?.starships += result.resource
                    self?.objectQuantity = (self?.starships.count)!
                    self?.hasNextPage = result.hasPage
                    for starship in (self?.starships)! {
                        self?.pickerData.append(starship.name)
                    }
                    self?.pickerView.reloadAllComponents()
                    //set the first value since the user has not selected any row on the pickerView yet
                    self?.setLabels(with: (self?.starships.first!)!)
                case .failuere(let error):
                    print(error)
            }
        })
    }
    
    func setLabels(with valueSelected: TransportCraft) {
        let value = getSize(from: starships)
        self.valueSelectedTransportCraft = valueSelected
        self.valueSelectedAllTypes = valueSelected

        smallestLabel.text = value.smallest.name
        largestLabel.text = value.largest.name

        nameLabel.text = valueSelected.name
        makeLabel.text = valueSelected.make
        costLabel.text = String(valueSelected.cost)
        lengthLabel.text = String(valueSelected.size)
        classLabel.text = valueSelected.swClass
        crewLabel.text = valueSelected.crew
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return pickerData.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if row > lastPickerViewIndex {
            lastPickerViewIndex = row
            if (objectQuantity - lastPickerViewIndex == 3) && hasNextPage {
                print("lasIndex\(lastPickerViewIndex)")
                print(hasNextPage)
                print(nextPageNumber)
                switch type {
                case .starship:
                    fetchForStarship(with: nextPageNumber)
                default:
                    break
                }
            }
        }
        return pickerData[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        switch type {
            case .starship:
                setLabels(with: starships[row])
            default: break
        }
    }
    
    func getSize<T: Measurable>(from resource: [T]) -> (smallest: T, largest: T) {
        let largest = resource.max { a, b in a.size < b.size }
        let smallest = resource.min { a, b in a.size < b.size }
        return (smallest: smallest!, largest: largest!)
    }
    
    @IBAction func convertCostToCredit(_ sender: Any) {
        exchangeTextField.isHidden = true
        exchangeLabel.isHidden = true
        costLabel.text = String(valueSelectedTransportCraft.cost)
        usdButton.isHighlighted = true
    }
    @IBAction func convertCostToUSD(_ sender: Any) {
        exchangeTextField.isHidden = false
        exchangeLabel.isHidden = false
        creditButton.isHighlighted = true
    }
    @IBAction func convertLengthToEnglish(_ sender: Any) {
        metricButton.isHighlighted = true
        totalValueToEnglish = valueSelectedAllTypes.size / 0.9144
        lengthLabel.text = String(format:"%.01f", valueSelectedAllTypes.size / 0.9144)
    }
    @IBAction func convertLengthToMetric(_ sender: Any) {
        EnglishButton.isHighlighted = true
        lengthLabel.text = String(format:"%.01f", totalValueToEnglish * 0.9144)
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        costLabel.text = String(valueSelectedTransportCraft.cost)
        return true
    }
    
    //Add done button to numpad
    func addDoneButtonOnKeyboard() {
        let doneToolbar: UIToolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: 320, height: 50))
        doneToolbar.barStyle = UIBarStyle.default
        let flexSpace = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: nil, action: nil)
        let done: UIBarButtonItem  = UIBarButtonItem(title: "Done", style: UIBarButtonItemStyle.done, target: self, action: #selector(self.doneButtonAction))
        
        var items = [UIBarButtonItem]()
        items.append(flexSpace)
        items.append(done)
        
        doneToolbar.items = items
        doneToolbar.sizeToFit()
        
        self.exchangeTextField.inputAccessoryView = doneToolbar
    }
    
    func doneButtonAction() {
        self.exchangeTextField.resignFirstResponder()
        if let exchangeRateValue = Int(exchangeTextField.text!) {
            let newValue = Double(costLabel.text!)! * Double(exchangeRateValue)
            costLabel.text = String(newValue)
        }
    }
}
