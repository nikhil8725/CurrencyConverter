
import UIKit

class ViewController: UIViewController , UIPickerViewDelegate, UIPickerViewDataSource , ServiceDelegate {

    @IBOutlet weak var sourcePickerView: UIPickerView!
    @IBOutlet weak var destinationPickerView: UIPickerView!
    @IBOutlet weak var inputTextView: UITextField!
    @IBOutlet weak var slider: UISlider!
    @IBOutlet weak var resultLabel: UILabel!
    
    var pickerData : [String] = [String]()
    let webService = WebService()
    let model = CurrencyModel.self
    
    var baseCurrency = "USD"
    var sourceCurrency = ""
    var destinationCurrency = ""
    var keyboardSize: CGRect?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.inputTextView.addTarget(self, action: #selector(self.textFieldDidChange), for: .editingChanged)
        inputTextView.text = "0"
        webService.delegate = self
        webService.CallService(url:model.baseUrl + baseCurrency)
        self.hideKeyboardWhenTappedAround()
        
        NotificationCenter.default.addObserver(self, selector: #selector(ViewController.keyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(ViewController.keyboardWillHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    @objc func keyboardWillShow(notification:NSNotification) {
        if let size = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            keyboardSize = size
        }
        moveUp()

    }
    
    @objc func keyboardWillHide(notification:NSNotification) {
        moveDown()
    
    }
    
    func moveUp(){
        if view.frame.origin.y == 0 {
            let textFeldOriginBottom = inputTextView!.frame.origin.y + inputTextView.frame.height
            let position = view.frame.height - textFeldOriginBottom
            let offset = position - keyboardSize!.height
            if offset < 0 {
                var frame = view.frame
                frame.origin.y = offset - 8
                UIView.animate(withDuration: 0.28, animations: { () -> Void in
                    self.view.frame = frame
                })
            }
        }
    }
    
    func moveDown(){
        if view.frame.origin.y != 0 {
            var frame = self.view.frame
            frame.origin.y = 0
            UIView.animate(withDuration: 0.28, animations: { () -> Void in
                self.view.frame = frame
            })
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        //removing observer 
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    //text field value change event 
    @objc func textFieldDidChange(textField: UITextField) {
        let inputValue = textField.text
        convertCurrency(inputValue: inputValue!)
    }
    
    //delegate method
    func responseDelegateFunc(response : NSDictionary)  {
        self.sourcePickerView.delegate = self
        self.destinationPickerView.delegate = self
        self.sourcePickerView.dataSource = self
        self.destinationPickerView.dataSource = self 
        
        CurrencyModel.baseCurrencyDict = response
        sourcePickerView.reloadAllComponents()
        destinationPickerView.reloadAllComponents()

        sourcePickerView.selectRow(CurrencyModel.availableCurrencies.index(of: baseCurrency)!, inComponent: 0, animated: true)
        
        sourceCurrency = (Array(model.availableCurrencies)[sourcePickerView.selectedRow(inComponent: 0)])
        destinationCurrency = (Array(model.baseCurrencyDict!)[destinationPickerView.selectedRow(inComponent: 0)].key as? String)!
        
        convertCurrency(inputValue: inputTextView.text!)
    }
    
    //slider value change event
    @IBAction func sliderValueChanged(_ sender: UISlider) {
        self.inputTextView.text = String(Int(round(slider.value)))
        print(inputTextView.text!)
        convertCurrency(inputValue: inputTextView.text!)
    }
    
    //Picker view delegate methods 
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if pickerView.tag == 10 {
            return (model.availableCurrencies.count)
        }else{
            return (model.baseCurrencyDict!.count)
        }
        
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if pickerView.tag == 10 {
            return  model.availableCurrencies[row]
        }else{
            return Array(model.baseCurrencyDict!)[row].key as? String
        }
        
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if pickerView.tag == 10 {
            sourceCurrency = (model.availableCurrencies[sourcePickerView.selectedRow(inComponent: 0)])
                baseCurrency = sourceCurrency
                webService.CallService(url: model.baseUrl + baseCurrency)
        }
        sourceCurrency = (Array(model.availableCurrencies)[sourcePickerView.selectedRow(inComponent: 0)])
        destinationCurrency = (Array(model.baseCurrencyDict!)[destinationPickerView.selectedRow(inComponent: 0)].key as? String)!
        
        print(sourceCurrency + "   " + destinationCurrency)
        
        let inputValue = self.inputTextView.text
        convertCurrency(inputValue: inputValue!)
        
    }
    
    func convertCurrency(inputValue : String){
        let getValue = inputValue
        var myNumber : NSNumber = 0
        if let integer = Float(getValue) {
             myNumber = NSNumber(value: integer)
        }
        
        let conversionRate =  model.baseCurrencyDict![destinationCurrency] as! NSNumber
        let result = ((myNumber.floatValue ) * (conversionRate.floatValue  ))
        
        self.resultLabel.text =  (inputValue) + " " + sourceCurrency + "  =  " +  String(format: "%.2f", result) + " " + destinationCurrency
    }
}

//hide keyboard in extension
extension UIViewController {
    func hideKeyboardWhenTappedAround() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
}
