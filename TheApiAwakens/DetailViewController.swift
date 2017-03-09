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
    @IBOutlet weak var vehicleStarshipValueLabel: UILabel!
    
    @IBOutlet weak var makeLabel: UILabel!
    @IBOutlet weak var costLabel: UILabel!
    @IBOutlet weak var lengthLabel: UILabel!
    @IBOutlet weak var classLabel: UILabel!
    @IBOutlet weak var crewLabel: UILabel!
    @IBOutlet weak var vehicleStarshipLabel: UILabel!
    
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
    var planets = [Planet]()
    var characterSelected: Character!
    var characterVehicles = [Vehicle]()
    var vehiclesID = [String]()
    var charactersVehicleAndStarship = ""
    var starshipsID = [String]()
    var characterStarships = [Starship]()

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
            case .starship :
                hideCharacterLabels()
                fetchForStarship(with: nextPageNumber)
            case .vehicle :
                hideCharacterLabels()
                fetchForVehicle(with: nextPageNumber)
            case .character :
                fetchForCharacter(with: nextPageNumber)
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
                case .failure(let error):
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
            case .failure(let error):
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
                    if (self?.characters.first?.vehiclesID.first) != nil {
                        self?.vehiclesID = (self?.characters.first?.vehiclesID)!
                        self?.fetchForCharacterVehicle(with: (self?.vehiclesID)!)
                    } else {
                        self?.vehicleStarshipValueLabel.text = "None"
                    }
                    
                    if (self?.characters.first?.starshipsID.first) != nil {
                        self?.starshipsID = (self?.characters.first?.starshipsID)!
                        self?.fetchForCharacterStarship(with: (self?.starshipsID)!)
                    } else {
                        self?.vehicleStarshipValueLabel.text = "None"
                    }

                    self?.fetchForPlanet(with: (self?.characters.first?.homeworldID)!)
                    self?.setLabels(with: (self?.characters.first!)!)
                    self?.isApiFirstCall = false
                }
            case .failure(let error):
                print(error)
            }
        })
    }
    
    func fetchForCharacterStarship(with starshipsID: [String]) {
        for id in starshipsID {
            swAPIClient.fetchForCharacterStarship(with: id) { (result) in
                switch result {
                case .failure(let error):
                    print(error)
                case .success(let result):
                    self.characterStarships.append(result.resource)
                    self.setVehicleStarshipLabel()
                }
            }
        }
    }
    
    func fetchForCharacterVehicle(with vehiclesID: [String]) {
        for id in vehiclesID {
            swAPIClient.fetchForCharacterVehicle(with: id) { (result) in
                switch result {
                case .failure(let error):
                    print(error)
                case .success(let result):
                    self.characterVehicles.append(result.resource)
                    self.setVehicleStarshipLabel()
                }
            }
        }
    }

    func fetchForPlanet(with id: String) {
        swAPIClient.fetchForPlanet(with: id) { (result) in
            switch result {
            case .success(let result):
                self.planets.append(result.resource)
                self.setPlanetLabel()
            case .failure(let error):
                print(error)
            }
        }
    }

    
    func setLabels(with valueSelected: TransportCraft) {
      switch type {
        case .starship:
              let starship = getSmallestAndlargest(from: starships)
              smallestLabel.text = starship.smallest.name
              largestLabel.text = starship.largest.name
        case .vehicle:
            let vehicle = getSmallestAndlargest(from: vehicles)
            smallestLabel.text = vehicle.smallest.name
            largestLabel.text = vehicle.largest.name
        case .character: break
        case .none: break
    }
        
        self.valueSelectedTransportCraft = valueSelected
        self.valueSelectedAllTypes = valueSelected

        nameValueLabel.text = valueSelected.name
        makeValueLabel.text = valueSelected.make
        costValueLabel.text = String(valueSelected.cost.cleanValue)
        lengthValueLabel.text = String(valueSelected.size.cleanValue)
        classValueLabel.text = valueSelected.swClass
        crewValueLabel.text = valueSelected.crew
    }
    
    func setLabels(with valueSelected: Character) {
        
        hideTransportCraftViews()
        
        let size = getSmallestAndlargest(from: characters)
        smallestLabel.text = size.smallest.name
        largestLabel.text = size.largest.name
        

        self.valueSelectedAllTypes = valueSelected
        
        // Update label's text for character
        makeLabel.text = "Born"
        costLabel.text = "Home"
        lengthLabel.text = "Height"
        classLabel.text = "Eyes"
        crewLabel.text = "Hair"
        
        nameValueLabel.text = valueSelected.name
        makeValueLabel.text = valueSelected.born
        lengthValueLabel.text = String(valueSelected.size.cleanValue)
        classValueLabel.text = valueSelected.eyes
        crewValueLabel.text = valueSelected.hair
        
        setPlanetLabel()
    }
    
    func setPlanetLabel() {
        
        // first time, no character was selected yet
        if planets.count == 1 {
            costValueLabel.text = planets.first?.name
        } else {
            for planet in planets {
                if characterSelected.homeworldID == planet.id {
                    costValueLabel.text = planet.name
                }
            }
        }
    }
    
    func setVehicleStarshipLabel() {
        if vehiclesID.count == characterVehicles.count {
            vehiclesID = [String]()
            var vehicleNames = [String]()
            for vehicle in characterVehicles {
                vehicleNames.append(vehicle.name)
            }
            charactersVehicleAndStarship += vehicleNames.joined(separator: ", ")
            vehicleStarshipValueLabel.text = charactersVehicleAndStarship
        }
        
        if starshipsID.count == characterStarships.count {
            starshipsID = [String]()
            var starshipNames = [String]()
            for starship in characterStarships {
                starshipNames.append(starship.name)
            }
            charactersVehicleAndStarship += starshipNames.joined(separator: ", ")
            vehicleStarshipValueLabel.text = charactersVehicleAndStarship
        }
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
        exchangeTextField.text = ""
        costValueLabel.text = "     "
        switch type {
        case .starship:
            setLabels(with: starships[row])
        case .vehicle:
            setLabels(with: vehicles[row])
        case .character:
            characterSelected = characters[row]
            vehicleStarshipValueLabel.text = ""
            charactersVehicleAndStarship = ""
            characterVehicles = [Vehicle]()
            vehiclesID = characterSelected.vehiclesID
            
            characterStarships = [Starship]()
            starshipsID = characterSelected.starshipsID

            if characterSelected.vehiclesID.first != nil {
                fetchForCharacterVehicle(with: vehiclesID)
            } else {
                vehicleStarshipValueLabel.text = "None"
            }
            
            if characterSelected.starshipsID.first != nil {
                fetchForCharacterStarship(with: starshipsID)
            } else {
                vehicleStarshipValueLabel.text = "None"
            }
            fetchForPlanet(with: characterSelected.homeworldID)
            setLabels(with: characterSelected)
        default: break
        }
    }
    
    // Defines who is the smallest and largest
    func getSmallestAndlargest<T: Measurable>(from resource: [T]) -> (smallest: T, largest: T) {
        let largest = resource.max { a, b in a.size < b.size }
        let smallest = resource.min { a, b in a.size < b.size }
        return (smallest: smallest!, largest: largest!)
    }
    
    // Convert credit-USD / English-Metric
    @IBAction func convertCostToCredit(_ sender: Any) {
        exchangeTextField.isHidden = true
        exchangeLabel.isHidden = true
        costValueLabel.text = String(valueSelectedTransportCraft.cost.cleanValue)
        usdButton.isSelected = false
        creditButton.isSelected = true
    }
    @IBAction func convertCostToUSD(_ sender: Any) {
        exchangeTextField.isHidden = false
        exchangeLabel.isHidden = false
        usdButton.isSelected = true
        creditButton.isSelected = false
    }
    @IBAction func convertLengthToEnglish(_ sender: Any) {
        exchangeTextField.isHidden = true
        exchangeLabel.isHidden = true

        EnglishButton.isSelected = true
        metricButton.isSelected = false
        totalValueToEnglish = valueSelectedAllTypes.size / 0.9144
        lengthValueLabel.text = String(format:"%.01f", valueSelectedAllTypes.size / 0.9144)
    }
    @IBAction func convertLengthToMetric(_ sender: Any) {
        exchangeTextField.isHidden = true
        exchangeLabel.isHidden = true

        metricButton.isSelected = true
        EnglishButton.isSelected = false
        lengthValueLabel.text = (totalValueToEnglish * 0.9144).cleanValue
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        costValueLabel.text = String(valueSelectedTransportCraft.cost)
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
            let newValue = Double(costValueLabel.text!)! * Double(exchangeRateValue)
            costValueLabel.text = String(newValue)
        }
    }
    
    func hideCharacterLabels() {
        vehicleStarshipLabel.isHidden = true
        vehicleStarshipValueLabel.isHidden = true
    }
    
    func showCharacterLabels() {
        vehicleStarshipLabel.isHidden = true
        vehicleStarshipValueLabel.isHidden = true
    }
}
