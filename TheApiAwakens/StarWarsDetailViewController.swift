    //
    //  DetailViewController.swift
    //  TheApiAwakens
    //
    //  Created by Tassia Serrao on 13/01/2017.
    //  Copyright © 2017 Tassia Serrao. All rights reserved.
    //

import UIKit

class StarWarsDetailViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource, UIScrollViewDelegate, UITextFieldDelegate {

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
    var swAPIClient = SWApiClient()
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
    var indicator = UIActivityIndicatorView()

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
    var hasNextPage = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        hideSubviews()
        loadData()
        pickerView.delegate = self
        pickerView.dataSource = self
        exchangeTextField.delegate = self
        self.addDoneButtonOnKeyboard()
        self.navigationItem.title = type.rawValue
    }
    //Hide all subviews but indicator
    func hideSubviews() {
        for view in self.view.subviews {
            if view != indicator {
                view.isHidden = true
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        createIndicator()
        indicator.startAnimating()
    }
    
    func createIndicator() {
        indicator = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.white)
        indicator.frame = CGRect(x: 0.0, y: 0.0, width: 40.0, height: 40.0)
        indicator.center = self.view.center
        self.view.addSubview(indicator)
        indicator.bringSubview(toFront: view)
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
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

    func hideCharacterLabels() {
        charactersVehicleStarshipLabel.isHidden = true
        charactersVehicleStarshipValueLabel.isHidden = true
    }

    func fetchForStarship(with page: Int) {
        swAPIClient.fetchForStarship(nextPage: page, completion: { [weak self] (result) in
            self?.indicator.stopAnimating()
            switch result {
                case .failure(let error):
                    if page == 1 {
                        self?.showAlert(title: "Something failed", message: "Couldn't load Starship - try again later", actionTitle: "Ok")
                    }
                    
                    print(error)
                case .success(let result):
                    self?.hasFinishedRequest = true
                    
                    // Update pickerView with data
                    self?.pickerData = [String]()
                    self?.starships += result.resource
                    self?.objectQuantity = (self?.starships.count)!
                    self?.hasNextPage = result.hasPage
                    self?.shouldIncreaseNextPageNumber(with: (self?.hasNextPage)!)
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
    
    func shouldIncreaseNextPageNumber(with hasNextPage: Bool) {
        if hasNextPage {
            nextPageNumber += 1
        }
    }

    func fetchForVehicle(with page: Int) {
        swAPIClient.fetchForVehicle(nextPage: page, completion: { [weak self] (result) in
            switch result {
                case .failure(let error):
                    if page == 1 {
                        self?.showAlert(title: "Something failed", message: "Couldn't load Vehicle - try again later", actionTitle: "Ok")
                    }

                    print(error)
                case .success(let result):
                    self?.hasFinishedRequest = true
                    
                    // Update pickerView with data
                    self?.pickerData = [String]()
                    self?.vehicles += result.resource
                    self?.objectQuantity = (self?.vehicles.count)!
                    self?.hasNextPage = result.hasPage
                    self?.shouldIncreaseNextPageNumber(with: (self?.hasNextPage)!)

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
        stopShowingIndicator()
        
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
            lengthValueLabel.text = valueSelected.size.cleanValue
        }
    }
    
    func stopShowingIndicator() {
        showSubviews()
        indicator.stopAnimating()
    }
    
    //Show all subviews but indicator
    func showSubviews() {
        for view in self.view.subviews {
            if view != indicator {
                view.isHidden = false
            }
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
                if page == 1 {
                    self?.showAlert(title: "Something failed", message: "Couldn't load Character - try again later", actionTitle: "Ok")
                }

                print(error)
            case .success(let result):
                self?.hasFinishedRequest = true
                
                // Update pickerView with data
                self?.pickerData = [String]()
                self?.characters += result.resource
                self?.objectQuantity = (self?.characters.count)!
                self?.hasNextPage = result.hasPage
                self?.shouldIncreaseNextPageNumber(with: (self?.hasNextPage)!)

                for character in (self?.characters)! {
                    self?.pickerData.append(character.name)
                }
                self?.pickerView.reloadAllComponents()
                
                //Set labels with first element of the array since the user has not selected any row on the pickerView yet
                let firstCharacter = self?.characters.first!
                
                if (self?.isApiFirstCall)! {
                    // Check if character has any vehicle and fetch for it
                    if !(firstCharacter?.vehiclesID.isEmpty)! {
                        self?.vehiclesIDs = (firstCharacter!.vehiclesID)
                        self?.fetchForCharacterVehicle(with: (self?.vehiclesIDs)!)
                    } else {
                        self?.charactersVehicleStarshipValueLabel.text = "None"
                    }
                    // Check if character has any starship and fetch for it
                    if !(firstCharacter?.starshipsID.isEmpty)! {
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
        stopShowingIndicator()
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
        
        // If planets is equal to 1, this means that so far only the planet of one character was fetched. This character is automatically fetched so the lablels can show some values before the user selects any other character.
        // if/else is needed to guarantee that characterSelected is not nil
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
        let pickerViewRowsQuantity = pickerView.numberOfRows(inComponent: component)
        
        if (pickerViewRowsQuantity - row == 3) && hasNextPage && hasFinishedRequest {
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

            if !characterSelected.vehiclesID.isEmpty {
                fetchForCharacterVehicle(with: vehiclesIDs)
            } else {
                charactersVehicleStarshipValueLabel.text = ResourceType.none.rawValue
            }
            
            if !characterSelected.starshipsID.isEmpty {
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
        costValueLabel.text = valueSelectedTransportCraft.cost.cleanValue
        usdButton.isSelected = false
        creditButton.isSelected = true
    }
    
    @IBAction func showUsdCost(_ sender: Any) {
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
                    showAlert(title: "Alert", message: "Exchange value must be higher than zero", actionTitle: "Ok")
                    return false
                }
            }
        }
        return true
    }

    func showAlert(title: String, message: String, actionTitle: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: actionTitle, style: UIAlertActionStyle.default, handler: nil))
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
            let newValue = valueSelectedTransportCraft.cost * Double(exchangeRateValue)
            costValueLabel.text = String(newValue.cleanValue)
        }
    }
}
