
import UIKit

class ViewController: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate {
    @IBOutlet weak var pickerFrom: UIPickerView!
    @IBOutlet weak var pickerTo: UIPickerView!
    @IBOutlet weak var labelCur: UILabel!

    
    
    let currincies = ["RON", "EUR", "MYR", "CAD", "DKK", "GBP", "PHP", "CZK", "PLN", "RUB", "JPY", "SGD", "BRL", "SEK", "USD", "HRK", "NZD", "HKD", "BGN", "TRY", "MXN", "HUF", "KRW", "NOK", "INR", "ILS", "IDR", "CHF", "THB", "CNY", "ZAR", "AUD"]
    
    var diff: [Int] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        pickerFrom.dataSource = self
        pickerTo.dataSource = self
        

        pickerFrom.delegate = self
        pickerTo.delegate = self
        
        self.activity.hidesWhenStopped = true
        self.requestCurrentCurrencyRate()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBOutlet weak var activity: UIActivityIndicatorView!

    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if pickerView === pickerTo{
            return self.currencyExceptBase().count
        }
        return currincies.count
    }
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    //MARK: UIPickerViewDelegate
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if pickerView === pickerTo{
            return self.currencyExceptBase()[row]
        }
        return currincies[row]
    }

    func currencyExceptBase() -> [String]{
        var currenciesExceptBase = currincies
        currenciesExceptBase.remove(at: pickerFrom.selectedRow(inComponent: 0))
        diff = self.getDiff(a: currenciesExceptBase.first ?? "", a1: "")
        
        return currenciesExceptBase
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if pickerView === pickerFrom{
            self.pickerTo.reloadAllComponents()
        }
        self.requestCurrentCurrencyRate()
    }
    
    func requestCurrentCurrencyRate(){
        let baseCurrencyIndex = self.pickerFrom.selectedRow(inComponent: 0)
        let toCurrencyIndex = self.pickerTo.selectedRow(inComponent: 0)
        var currinciesEx = currincies
        currinciesEx.remove(at: baseCurrencyIndex)
        
        
        let baseCurrency = self.currincies[baseCurrencyIndex]
        let toCurrency = currinciesEx[toCurrencyIndex]
        self.activity.startAnimating()
        
        self.retrieveCurrencyRate(baseCurrency: baseCurrency, toCurrency: toCurrency){ [weak self] (value) in
            DispatchQueue.main.async(execute: {
                if let strongSelf = self{

                    strongSelf.labelCur.text = value
                    strongSelf.activity.stopAnimating()
                }
            })
        }
    }
    
    func getDiff(a: String, a1: String) -> [Int] {
        return CurrencyVM().getMinimumDifference(a: [a], b: [a1])
    }
    
    func retrieveCurrencyRate (baseCurrency: String, toCurrency: String, completion: @escaping(String) -> Void){
        requestCurrencyRates(baseCurrency: baseCurrency){ [weak self] (data, error) in
            var string = "No currency retrieved!"
            if let currenError = error {
                string = currenError.localizedDescription
            } else{
                if let strongSelf = self {
                    string = strongSelf.parceCurrencyRatesData(data: data, toCurrency: toCurrency)
                }
            }
            completion(string)
        }
    }

    
    
    func requestCurrencyRates(baseCurrency: String, parseHandler: @escaping (Data?, Error?) -> Void) {
        let url = URL(string: "https://api.fixer.io/latest?base=" + baseCurrency)!
        
        let dataTask = URLSession.shared.dataTask(with: url){
            (dataRecieved, responce, error) in
            parseHandler(dataRecieved, error)
        }
        
        dataTask.resume()
    }
    
    
    
    
    func parceCurrencyRatesData(data: Data?, toCurrency: String) -> String{
        var value: String = ""
        
        
        do {
            let json = try JSONSerialization.jsonObject(with: data!, options: []) as? Dictionary<String, Any>

            if let parsedJSON = json {
                if let rates = parsedJSON["rates"] as? Dictionary<String,Double>{
                    if let rate = rates[toCurrency] {
                        value = "\(rate)"
                    } else {
                        
                        value = "No rate for currency \"\(toCurrency)\" found"
                        
                    }
                } else {
                    value = "No \"rates\" field found"
                }
            }
            
        }
        catch {
            value = error.localizedDescription
        }
        return value
    }

    
    
    
    
    
}

