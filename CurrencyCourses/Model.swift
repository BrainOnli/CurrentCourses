//
//  Model.swift
//  CurrencyCourses
//
//  Created by Mac on 22.01.2021.
//

import UIKit

/*
 <StartDate>22.01.2021</StartDate>
 <TimeSign>0000</TimeSign>
 <CurrencyCode>944</CurrencyCode>
 <CurrencyCodeL>AZN</CurrencyCodeL>
 <Units>1</Units>
 <Amount>16.633</Amount>
 */
class Currency {
    var NumCode: String?
    var CharCode: String?
    
    var Nominal: String?
    var nominalDouble: Double?
    
    var Name: String?
    
    var Value: String?
    var valueDouble: Double?
}

class Model: NSObject, XMLParserDelegate {
    static let shared = Model()
    
    var currencies: [Currency] = []
    var currentDate: Date = Date()
    
    var pathForXML: String {

        let path = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.libraryDirectory, FileManager.SearchPathDomainMask.userDomainMask, true)[0] + "/data.xml"
        
        if FileManager.default.fileExists(atPath: path) {
            return path
        }
        
         return Bundle.main.path(forResource: "data", ofType: "xml")!
        
    }
    
    var urlForXML: URL {
        return URL(fileURLWithPath: pathForXML)
    }
    
    /* загрузка XML с bank.gov.ua и сохранание его в каталоге приложения*/
    /* http://www.cbr.ru/scripts/XML_daily.asp?date_req=02/03/2002*/
    func loadXMLFile(date: Date?)  {
        
        var strUrl = "http://www.cbr.ru/scripts/XML_daily.asp?date_req="
        
        if date != nil {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "dd/mm/yyyy"
            strUrl = strUrl+dateFormatter.string(from: date!)
        }
        
        let url = URL(string: strUrl)
        
        let task = URLSession.shared.dataTask(with: url!) { (date, responce, error) in
            if error == nil {
                let path = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.libraryDirectory, FileManager.SearchPathDomainMask.userDomainMask, true)[0] + "/data.xml"
                let urlForSave = URL(fileURLWithPath: path)
                
                do {
                    try date?.write(to: urlForSave)
                    print(path)
                } catch {
                    print("Error when save data:\(error.localizedDescription)")
                }
                
            } else {
                print("Error when loadXMLFile"+error!.localizedDescription)
            }
        }
        
        task.resume()
    }
    
    // распарсить XML и положить его в curreincies [Currency], отправить уведомление приложению о том что данные обновились
    func parseXML()  {
        currencies = []
        
        let parser = XMLParser(contentsOf: urlForXML)
        parser?.delegate = self
        parser?.parse()
        
        print(currencies)
    }
    
    var currentCurrency: Currency?
    
    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String] = [:]) {
        if elementName == "ValCurs" {
            
            if let currentDateString = attributeDict["Date"] {
            let df = DateFormatter()
            df.dateFormat = "dd.MM.yyyy"
            currentDate = df.date(from: currentDateString)!
            }
        }
    
        if elementName == "Valute" {
            currentCurrency = Currency()
        }
        
    }
    
    var currentCharacters: String = ""
    func parser(_ parser: XMLParser, foundCharacters string: String) {
        currentCharacters = string
    }

    func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        
        /* <NumCode>036</NumCode>
         <CharCode>AUD</CharCode>
         <Nominal>1</Nominal>
         <Name>¿‚ÒÚ‡ÎËÈÒÍËÈ ‰ÓÎÎ‡</Name>
         <Value>16,0102</Value> */
        
        if elementName == "NumCode" {
            currentCurrency?.NumCode = currentCharacters
        }
        if elementName == "CharCode" {
            currentCurrency?.CharCode = currentCharacters
        }
        if elementName == "Nominal" {
            currentCurrency?.Nominal = currentCharacters
            currentCurrency?.nominalDouble = Double(currentCharacters.replacingOccurrences(of: ",", with: "."))
        }
        if elementName == "Name" {
            currentCurrency?.Name = currentCharacters
        }
        if elementName == "Value" {
            currentCurrency?.Value = currentCharacters
            currentCurrency?.valueDouble = Double(currentCharacters)
        }
        
        if elementName == "Valute" {
            currencies.append(currentCurrency!)
        }
    }
}



