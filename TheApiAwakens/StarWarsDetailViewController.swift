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
    @IBOutlet weak var charactersVehicleStarshipValueLabel: UILabel!
    @IBOutlet weak var makeLabel: UILabel!
    @IBOutlet weak var costLabel: UILabel!
    @IBOutlet weak var lengthLabel: UILabel!
    @IBOutlet weak var classLabel: UILabel!
    @IBOutlet weak var crewLabel: UILabel!
    @IBOutlet weak var charactersVehicleStarshipLabel: UILabel!
    @IBOutlet weak var largestLabel: UILabel!
    @IBOutlet weak var smallestLabel: UILabel!
    @IBOutlet weak var smallestLabelValue: UILabel!
    @IBOutlet weak var largestLabelValue: UILabel!
    @IBOutlet weak var usdButton: UIButton!
    @IBOutlet weak var creditButton: UIButton!
    @IBOutlet weak var englishButton: UIButton!
    @IBOutlet weak var metricButton: UIButton!
    @IBOutlet weak var exchangeLabel: UILabel!
    @IBOutlet weak var exchangeTextField: UITextField!
    @IBOutlet weak var pickerView: UIPickerView!


    var didCharacterStarshipFinished = false
    var totalValueToEnglish = 0.0
    var totalValueToMetric = 0.0
    var objectQuantity = 0
    var pickerData = [String]()
    var nextPageNumber = 1
    var type = ResourceType.none
    var swAPIClient: SWApiClient = SWApiClient()
    var starships = [Starship]()
    var vehicles = [Vehicle]()
    var characters = [Character]()
    var valueSelectedAllTypes: Measurable!
    var valueSelectedTransportCraft: TransportCraft!
    var isApiFirstCall = true
    var characterSelected: Character!
    var charactersVehicleAndStarship = ""
    var starshipsIDs = [String]()
    var vehiclesIDs = [String]()
    var hasFinishedRequest = false

    var planets = [Planet]() {
        didSet {
            setCharactersPlanetLabel()
        }
    }
    var charactersVehicles = [Vehicle]() {
        didSet {
            setCharacterVehicleAndStarshipLabel()
        }
    }
    var characterStarships = [Starship]() {
        didSet {
            setCharacterVehicleAndStarshipLabel()
        }
    }
    var hasNextPage = false {
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

    func hideCharacterLabels() {
        charactersVehicleStarshipLabel.isHidden = true
        charactersVehicleStarshipValueLabel.isHidden = true
    }

    func fetchForStarship(with page: Int) {
        swAPIClient.fetchForStarship(nextPage: page, completion: { [weak self] (result) in
            switch result {
                case .failure(let error):
                    print(error)
                case .success(let result):
                    self?.hasFinishedRequest = true
                    
                    // Update pickerView with data
                    self?.pickerData = [String]()
                    self?.starships += result.resource
                    self?.objectQuantity = (self?.starships.count)!
                    self?.hasNextPage = result.hasPage
                    for starship in (self?.starships)! {
                        self?.pickerData.append(starship.name)
                    }
                    self?.pickerView.reloadAllComponents()
                    
                    //Set labels with first element of the array since the user has not selected any row of the pickerView yet
                    if (self?.isApiFirstCall)! {
                        self?.setLabels(with: (self?.starships.first!)!)
                        self?.isApiFirstCall = false
                    }
            }
        })
    }

    func fetchForVehicle(with page: Int) {
        swAPIClient.fetchForVehicle(nextPage: page, completion: { [weak self] (result) in
            switch result {
                case .failure(let error):
                    print(error)
                case .success(let result):
                    self?.hasFinishedRequest = true
                    
                    // Update pickerView with data
                    self?.pickerData = [String]()
                    self?.vehicles += result.resource
                    self?.objectQuantity = (self?.vehicles.count)!
                    self?.hasNextPage = result.hasPage

                    for vehicle in (self?.vehicles)! {
                    self?.pickerData.append(vehicle.name)
                }
                self?.pickerView.reloadAllComponents()
                
                //Set labels with first element of the array since the user has not selected any row on the pickerView yet
                if (self?.isApiFirstCall)! {
                    self?.setLabels(with: (self?.vehicles.first!)!)
                    self?.isApiFirstCall = false
                }
            }
        })
    }
    //Set labels only for Vehcile and Starship (Character is not a TransportCraft)
    func setLabels(with valueSelected: TransportCraft) {
        
        switch type {
        case .starship:
            let starships = getSmallestAndlargest(from: self.starships)
            smallestLabelValue.text = starships.smallest.name
            largestLabelValue.text = starships.largest.name
        case .vehicle:
            let vehicle = getSmallestAndlargest(from: vehicles)
            smallestLabelValue.text = vehicle.smallest.name
            largestLabelValue.text = vehicle.largest.name
        case .character, .none: break
        }
        
        // Only transportCraft(Vehcile and Starship have costLabel)
        self.valueSelectedTransportCraft = valueSelected
        // All the types have sizeLabel
        self.valueSelectedAllTypes = valueSelected
        
        nameValueLabel.text = valueSelected.name
        makeValueLabel.text = valueSelected.make
        costValueLabel.text = String(valueSelected.cost.cleanValue)
        crewValueLabel.text = valueSelected.crew
        classValueLabel.text = valueSelected.swClass
        
        if valueSelected.size == 0 {
            lengthValueLabel.text = "Unknown"
        } else {
            lengthValueLabel.text = String(valueSelected.size.cleanValue)
        }
    }

    // Defines who is the smallest and largest
    func getSmallestAndlargest<T: Measurable>(from resource: [T]) -> (smallest: T, largest: T) {
        // DOn't use sizes which the value is = 0. 0 means that the size is unknown
        let resourceFiltered = resource.filter { (Measurable) -> Bool in
            if Measurable.size != 0 {
                return true
            } else {
                return false
            }
        }
        
        let largest = resourceFiltered.max { a, b in a.size < b.size }
        let smallest = resourceFiltered.min { a, b in a.size < b.size }
        return (smallest: smallest!, largest: largest!)
    }

    func fetchForCharacter(with page: Int) {
        swAPIClient.fetchForCharacter(nextPage: page, completion: { [weak self] (result) in
            switch result {
            case .failure(let error):
                print(error)
            case .success(let result):
                self?.hasFinishedRequest = true
                
                // Update pickerView with data
                self?.pickerData = [String]()
                self?.characters += result.resource
                self?.objectQuantity = (self?.characters.count)!
                self?.hasNextPage = result.hasPage

                for character in (self?.characters)! {
                    self?.pickerData.append(character.name)
                }
                self?.pickerView.reloadAllComponents()
                
                //Set labels with first element of the array since the user has not selected any row on the pickerView yet
                let firstCharacter = self?.characters.first!
                if (self?.isApiFirstCall)! {
                    // Check if character has any vehicle and fetch for it
                    if (self?.characters.first?.vehiclesID.first) != nil {
                        self?.vehiclesIDs = (firstCharacter!.vehiclesID)
                        self?.fetchForCharacterVehicle(with: (self?.vehiclesIDs)!)
                    } else {
                        self?.charactersVehicleStarshipValueLabel.text = "None"
                    }
                    // Check if character has any starship and fetch for it
                    if (self?.characters.first?.starshipsID.first) != nil {
                        self?.starshipsIDs = (firstCharacter!.starshipsID)
                        self?.fetchForCharacterStarship(with: (self?.starshipsIDs)!)
                    } else {
                        self?.charactersVehicleStarshipValueLabel.text = "None"
                    }
                
                    self?.fetchForPlanet(with: (firstCharacter!.homeworldID))
                    self?.setLabels(with: (firstCharacter)!)
                    self?.isApiFirstCall = false
                }
            }
        })
    }

    func fetchForCharacterVehicle(with vehiclesID: [String]) {
        for id in vehiclesID {
            swAPIClient.fetchForCharacterVehicle(with: id) { (result) in
                switch result {
                case .failure(let error):
                    print(error)
                case .success(let result):
                    self.charactersVehicles.append(result.resource)
                }
            }
        }
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

    func fetchForPlanet(with id: String) {
        swAPIClient.fetchForCharacterPlanet(with: id) { (result) in
            switch result {
            case .success(let result):
                self.planets.append(result.resource)
            case .failure(let error):
                print(error)
            }
        }
    }

    func setLabels(with valueSelected: Character) {
        
        hideTransportCraftViews()
        
        let characters = getSmallestAndlargest(from: self.characters)
        smallestLabelValue.text = characters.smallest.name
        largestLabelValue.text = characters.largest.name
        

        self.valueSelectedAllTypes = valueSelected
        
        //Change label's text, so character can use the same UI and Starship and Vehicle
        makeLabel.text = "Born"
        costLabel.text = "Home"
        lengthLabel.text = "Height"
        classLabel.text = "Eyes"
        crewLabel.text = "Hair"
        smallestLabel.text = "Shortest"
        largestLabel.text = "Tallest"
        
        nameValueLabel.text = valueSelected.name
        makeValueLabel.text = valueSelected.born
        classValueLabel.text = valueSelected.eyes
        crewValueLabel.text = valueSelected.hair
        
        if valueSelected.size == 0 {
            lengthValueLabel.text = "Unknown"
        } else {
            lengthValueLabel.text = String(valueSelected.size.cleanValue)
        }
        
        setCharactersPlanetLabel()
    }

    func hideTransportCraftViews() {
        usdButton.isHidden = true
        creditButton.isHidden = true
    }

    func setCharactersPlanetLabel() {
        
        // first time, no character was selected yet on pickerView
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
        var vehiclesNamesFormatted = ""
        var starshipNamesFormatted = ""
        // Update UI with character's vehicles only when all the vehicles were fetched
        if vehiclesIDs.count == charactersVehicles.count {
            didCharacterStarshipFinished = true
            vehiclesIDs = [String]()
            var vehicleNames = [String]()
            for vehicle in charactersVehicles {
                vehicleNames.append(vehicle.name)
            }
            
            if charactersVehicleStarshipValueLabel.text == "" {
                    vehiclesNamesFormatted += vehicleNames.joined(separator: ", ")
                    vehiclesNamesFormatted += ", "
                    charactersVehicleStarshipValueLabel.text = vehiclesNamesFormatted
            } else {
                vehiclesNamesFormatted += vehicleNames.joined(separator: ", ")
                if charactersVehicleStarshipValueLabel.text == "none" {
                    if vehicleNames.count > 0 {
                        charactersVehicleStarshipValueLabel.text = vehiclesNamesFormatted
                    }
                } else {
                    charactersVehicleStarshipValueLabel.text = "\(charactersVehicleStarshipValueLabel.text!)\(vehiclesNamesFormatted)"
                }
            }
        }
        
        // Update UI with character's starships only when all the vehicles were fetched
        if starshipsIDs.count == characterStarships.count {
            starshipsIDs = [String]()
            var starshipNames = [String]()
            for starship in characterStarships {
                starshipNames.append(starship.name)
            }
            
            if charactersVehicleStarshipValueLabel.text == "" {
                    starshipNamesFormatted += starshipNames.joined(separator: ", ")
                if charactersVehicleStarshipValueLabel.text != "none" {
                    starshipNamesFormatted += ","
                }
                charactersVehicleStarshipValueLabel.text = starshipNamesFormatted
            } else {
                starshipNamesFormatted += starshipNames.joined(separator: ", ")
                if charactersVehicleStarshipValueLabel.text == "none" {
                    if starshipNames.count > 0 {
                        charactersVehicleStarshipValueLabel.text = starshipNamesFormatted
                    }
                } else {
                    charactersVehicleStarshipValueLabel.text = "\(charactersVehicleStarshipValueLabel.text!)\(starshipNamesFormatted)"
                }
            }
        }
    }

    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return pickerData.count
    }

    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
            if (objectQuantity - row == 3) && hasNextPage && hasFinishedRequest {
                hasFinishedRequest = false
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
            vehiclesIDs = characterSelected.vehiclesID
            starshipsIDs = characterSelected.starshipsID
            
            cleanCharactersValues()

            if characterSelected.vehiclesID.first != nil {
                fetchForCharacterVehicle(with: vehiclesIDs)
            } else {
                charactersVehicleStarshipValueLabel.text = ResourceType.none.rawValue
            }
            
            if characterSelected.starshipsID.first != nil {
                fetchForCharacterStarship(with: starshipsIDs)
            } else {
                charactersVehicleStarshipValueLabel.text = ResourceType.none.rawValue
            }
            fetchForPlanet(with: characterSelected.homeworldID)
            setLabels(with: characterSelected)
        default: break
        }
    }

    func cleanCharactersValues() {
        charactersVehicleStarshipValueLabel.text = ""
        charactersVehicleAndStarship = ""
        charactersVehicles = [Vehicle]()
        characterStarships = [Starship]()
    }

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
        lengthValueLabel.text = (valueSelectedAllTypes.size / 0.9144).cleanValue
    }

    @IBAction func convertLengthToMetric(_ sender: Any) {
        exchangeTextField.isHidden = true
        exchangeLabel.isHidden = true

        if metricButton.isSelected {
            return
        }
        metricButton.isSelected = true
        englishButton.isSelected = false
        lengthValueLabel.text = valueSelectedAllTypes.size.cleanValue
    }

    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let textFieldText = NSString(string: textField.text!).replacingCharacters(in: range, with: string)
        
        //MARK: error handling - if the value for exchange is <= 0 show an alert
        if textFieldText != "" {
            if let text = Int(textFieldText) {
                if text <= 0 {
                    showAlert()
                    return false
                }
            }
        }
        return true
    }

    func showAlert() {
        let alert = UIAlertController(title: "Alert", message: "Exchange value must be higher than zero", preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
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
}
