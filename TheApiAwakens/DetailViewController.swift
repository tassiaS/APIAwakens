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
    @IBOutlet weak var englishButton: UIButton!
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
    var planets = [Planet]() {
        didSet {
            setCharactersPlanetLabel()
        }
    }
    var characterSelected: Character!
    var charactersVehicles = [Vehicle]() {
        didSet {
            setCharacterVehicleAndStarshipLabel()
        }
    }
    var vehiclesID = [String]()
    var charactersVehicleAndStarship = ""
    var starshipsID = [String]()
    var characterStarships = [Starship]() {
        didSet {
            setCharacterVehicleAndStarshipLabel()
        }
    }

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
                self.navigationItem.title = ResourceType.starship.rawValue
                hideCharacterLabels()
                fetchForStarship(with: nextPageNumber)
            case .vehicle :
                self.navigationItem.title = ResourceType.vehicle.rawValue
                hideCharacterLabels()
                fetchForVehicle(with: nextPageNumber)
            case .character :
                self.navigationItem.title = ResourceType.character.rawValue
                fetchForCharacter(with: nextPageNumber)
            default: break
        }
    }
    
    func fetchForStarship(with page: Int) {
        swAPIClient.fetchForStarship(nextPage: nextPageNumber, completion: { [weak self] (result) in
            switch result {
                case .failure(let error):
                    print(error)
                case .success(let result):
                    // Update the pickerView with the result(array of starship)
                    self?.pickerData = [String]()
                    self?.starships += result.resource
                    self?.objectQuantity = (self?.starships.count)!
                    self?.hasNextPage = result.hasPage
                    for starship in (self?.starships)! {
                        self?.pickerData.append(starship.name)
                    }
                    self?.pickerView.reloadAllComponents()
                    
                    //Set the labels with the info of the first Starship since the user has not selected any row on the pickerView yet
                    if (self?.isApiFirstCall)! {
                        self?.setLabels(with: (self?.starships.first!)!)
                        self?.isApiFirstCall = false
                    }
            }
        })
    }
    func fetchForVehicle(with page: Int) {
        swAPIClient.fetchForVehicle(nextPage: nextPageNumber, completion: { [weak self] (result) in
            switch result {
                case .failure(let error):
                    print(error)
                // Update the pickerView with the result(array of starship)
                case .success(let result):
                    self?.pickerData = [String]()
                    self?.vehicles += result.resource
                    self?.objectQuantity = (self?.vehicles.count)!
                    self?.hasNextPage = result.hasPage
                    for vehicle in (self?.vehicles)! {
                    self?.pickerData.append(vehicle.name)
                }
                self?.pickerView.reloadAllComponents()
                
                //Set the labels with the info of the first Vehicle since the user has not selected any row on the pickerView yet
                if (self?.isApiFirstCall)! {
                    self?.setLabels(with: (self?.vehicles.first!)!)
                    self?.isApiFirstCall = false
                }
            }
        })
    }

    func fetchForCharacter(with page: Int) {
        swAPIClient.fetchForCharacter(nextPage: nextPageNumber, completion: { [weak self] (result) in
            switch result {
            case .failure(let error):
                print(error)
            case .success(let result):
                // Update the pickerView with the result(array of starship)
                self?.pickerData = [String]()
                self?.characters += result.resource
                self?.objectQuantity = (self?.characters.count)!
                self?.hasNextPage = result.hasPage
                for character in (self?.characters)! {
                    self?.pickerData.append(character.name)
                }
                self?.pickerView.reloadAllComponents()
                
                let firstCharacter = self?.characters.first!
                
                // Check if the character has any vehicle and fetch for it
                if (self?.isApiFirstCall)! {
                    if (self?.characters.first?.vehiclesID.first) != nil {
                        self?.vehiclesID = (firstCharacter!.vehiclesID)
                        self?.fetchForCharacterVehicle(with: (self?.vehiclesID)!)
                    } else {
                        self?.vehicleStarshipValueLabel.text = "None"
                    }
                // Check if the character has any starship and fetch for it
                if (self?.characters.first?.starshipsID.first) != nil {
                        self?.starshipsID = (firstCharacter!.starshipsID)
                        self?.fetchForCharacterStarship(with: (self?.starshipsID)!)
                    } else {
                        self?.vehicleStarshipValueLabel.text = "None"
                    }
                
                self?.fetchForPlanet(with: (firstCharacter!.homeworldID))
                self?.setLabels(with: (firstCharacter)!)
                self?.isApiFirstCall = false
                }
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
                    self.charactersVehicles.append(result.resource)                }
            }
        }
    }

    func fetchForPlanet(with id: String) {
        swAPIClient.fetchForPlanet(with: id) { (result) in
            switch result {
            case .success(let result):
                self.planets.append(result.resource)
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
        case .character, .none: break
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
        
        //Change label's text, so character can use the same UI and Starship and Vehicle
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
        
        setCharactersPlanetLabel()
    }
    
    func setCharactersPlanetLabel() {
        
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
    
    func setCharacterVehicleAndStarshipLabel() {
        if vehiclesID.count == charactersVehicles.count {
            vehiclesID = [String]()
            var vehicleNames = [String]()
            for vehicle in charactersVehicles {
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
        englishButton.isSelected = false
        metricButton.isSelected = true
        switch type {
        case .starship:
            setLabels(with: starships[row])
        case .vehicle:
            setLabels(with: vehicles[row])
        case .character:
            characterSelected = characters[row]
            vehicleStarshipValueLabel.text = ""
            charactersVehicleAndStarship = ""
            charactersVehicles = [Vehicle]()
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

        englishButton.isSelected = true
        metricButton.isSelected = false
        totalValueToEnglish = valueSelectedAllTypes.size / 0.9144
        lengthValueLabel.text = String(format:"%.01f", valueSelectedAllTypes.size / 0.9144)
    }
    @IBAction func convertLengthToMetric(_ sender: Any) {
        exchangeTextField.isHidden = true
        exchangeLabel.isHidden = true

        if metricButton.isSelected {
            return
        }
        metricButton.isSelected = true
        englishButton.isSelected = false
        lengthValueLabel.text = (totalValueToEnglish * 0.9144).cleanValue
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let textFieldText = NSString(string: textField.text!).replacingCharacters(in: range, with: string)
        
        if textFieldText != "" {
            // I think I dont need it
            if let text = Int(textFieldText) {
                if text <= 0 {
                    showAlert()
                    return false
                }
            }
        }
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
            costValueLabel.text = String(newValue.cleanValue)
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
    
    func showAlert() {
        let alert = UIAlertController(title: "Alert", message: "Exchange value must be higher than zero", preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
}
