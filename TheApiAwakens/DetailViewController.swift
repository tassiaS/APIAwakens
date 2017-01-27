//
//  DetailViewController.swift
//  TheApiAwakens
//
//  Created by Tassia Serrao on 13/01/2017.
//  Copyright © 2017 Tassia Serrao. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource, UIScrollViewDelegate, UITextFieldDelegate {
    
    @IBOutlet weak var nameValueLabel: UILabel!
    @IBOutlet weak var makeValueLabel: UILabel!
    @IBOutlet weak var costValueLabel: UILabel!
    @IBOutlet weak var lengthValueLabel: UILabel!
    @IBOutlet weak var classValueLabel: UILabel!
    @IBOutlet weak var crewValueLabel: UILabel!
    
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
    var vehicles = [Vehicle]()
    var characters = [Character]()
    var valueSelectedAllTypes: Measurable!
    var valueSelectedTransportCraft: TransportCraft!
    var exchangeRateValue = 0
    var isApiFirstCall = true

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
            case .vehicle : fetchForVehicle(with: nextPageNumber)
            case .character : fetchForCharacter(with: nextPageNumber)
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
                    if (self?.isApiFirstCall)! {
                        self?.setLabels(with: (self?.starships.first!)!)
                        self?.isApiFirstCall = false
                    }
                case .failuere(let error):
                    print(error)
            }
        })
    }
    
    func fetchForVehicle(with page: Int) {
        swAPIClient.fetchForVehicle(nextPage: nextPageNumber, completion: { [weak self] (result) in
            switch result {
            case .success(let result):
                self?.pickerData = [String]()
                self?.vehicles += result.resource
                self?.objectQuantity = (self?.vehicles.count)!
                self?.hasNextPage = result.hasPage
                for vehicle in (self?.vehicles)! {
                    self?.pickerData.append(vehicle.name)
                }
                self?.pickerView.reloadAllComponents()
                //set the first value since the user has not selected any row on the pickerView yet
                if (self?.isApiFirstCall)! {
                    self?.setLabels(with: (self?.vehicles.first!)!)
                    self?.isApiFirstCall = false
                }
            case .failuere(let error):
                print(error)
            }
        })
    }

    func fetchForCharacter(with page: Int) {
        swAPIClient.fetchForCharacter(nextPage: nextPageNumber, completion: { [weak self] (result) in
            switch result {
            case .success(let result):
                self?.pickerData = [String]()
                self?.characters += result.resource
                self?.objectQuantity = (self?.characters.count)!
                self?.hasNextPage = result.hasPage
                for character in (self?.characters)! {
                    self?.pickerData.append(character.name)
                }
                self?.pickerView.reloadAllComponents()
                //set the first value since the user has not selected any row on the pickerView yet
                if (self?.isApiFirstCall)! {
                    self?.setLabels(with: (self?.characters.first!)!)
                    self?.isApiFirstCall = false
                }
            case .failuere(let error):
                print(error)
            }
        })
    }

    
    func setLabels(with valueSelected: TransportCraft) {
      switch type {
        case .starship:
              let starship = getSize(from: starships)
              smallestLabel.text = starship.smallest.name
              largestLabel.text = starship.largest.name
        case .vehicle:
            let vehicle = getSize(from: vehicles)
            smallestLabel.text = vehicle.smallest.name
            largestLabel.text = vehicle.largest.name
        case .character: break
        case .none: break
        }
        
        self.valueSelectedTransportCraft = valueSelected
        self.valueSelectedAllTypes = valueSelected

        nameValueLabel.text = valueSelected.name
        makeValueLabel.text = valueSelected.make
        costValueLabel.text = String(valueSelected.cost)
        lengthValueLabel.text = String(valueSelected.size)
        classValueLabel.text = valueSelected.swClass
        crewValueLabel.text = valueSelected.crew
    }
    
    func setLabels(with valueSelected: Character) {
        
        hideTransportCraftViews()
        
        let character = getSize(from: characters)
        smallestLabel.text = character.smallest.name
        largestLabel.text = character.largest.name
        

        self.valueSelectedAllTypes = valueSelected
        
        // Update label's text for character
        makeLabel.text = "Born"
        costLabel.text = "Home"
        lengthLabel.text = "Height"
        classLabel.text = "Eyes"
        crewLabel.text = "Hair"
        
        nameValueLabel.text = valueSelected.name
        makeValueLabel.text = valueSelected.born
        costValueLabel.text = "home"
        lengthValueLabel.text = String(valueSelected.size)
        classValueLabel.text = valueSelected.eyes
        crewValueLabel.text = valueSelected.hair
    }

    func hideTransportCraftViews() {
        usdButton.isHidden = true
        creditButton.isHidden = true
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
                case .vehicle:
                    fetchForVehicle(with: nextPageNumber)
                case .character:
                    fetchForCharacter(with: nextPageNumber)
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
        case .vehicle:
            setLabels(with: vehicles[row])
        case .character:
            setLabels(with: characters[row])
        default: break
        }
    }
    
    // Defines who is the smallest and largest
    func getSize<T: Measurable>(from resource: [T]) -> (smallest: T, largest: T) {
        let largest = resource.max { a, b in a.size < b.size }
        let smallest = resource.min { a, b in a.size < b.size }
        return (smallest: smallest!, largest: largest!)
    }
    
    // Convert credit-USD / English-Metric
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
        exchangeTextField.isHidden = true
        exchangeLabel.isHidden = true

        metricButton.isHighlighted = true
        totalValueToEnglish = valueSelectedAllTypes.size / 0.9144
        lengthValueLabel.text = String(format:"%.01f", valueSelectedAllTypes.size / 0.9144)
    }
    @IBAction func convertLengthToMetric(_ sender: Any) {
        exchangeTextField.isHidden = true
        exchangeLabel.isHidden = true

        EnglishButton.isHighlighted = true
        lengthValueLabel.text = String(format:"%.01f", totalValueToEnglish * 0.9144)
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        costLabel.text = String(valueSelectedTransportCraft.cost)
        return true
    }
    
    // Add done button to numpad
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
