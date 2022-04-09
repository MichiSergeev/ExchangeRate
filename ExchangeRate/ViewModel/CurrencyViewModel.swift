//
//  CurrencyViewModel.swift
//  ExchangeRate
//
//  Created by Mikhail Sergeev on 04.04.2022.
//

import RxSwift
import RxRelay
import RxDataSources

class CurrencyViewModel {
    
    private let basePath = "https://openexchangerates.org/api/"
    private let latest = "latest.json"
    private let appID = "app_id"
    private let id = "4502a35230eb4319987a07d2fba726b1"
    private var disposeBag = DisposeBag()
    
    let storage = UserDefaults.standard
    let titles = Settings.Table.SettingDisplayTitles.self
    var all: [Currency] = []
    var favorites: [Currency] = []
    var other: [Currency] = []
    var isCurrencyLoaded = PublishSubject<Bool>()
    
    func getLatestExchangeRate() {
        guard let url = URL(string: basePath + latest + "?" + appID + "=" + id) else {
            print("url isn't correct")
            return
        }
        
        let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
            guard let httpResponse = response as? HTTPURLResponse,
                  httpResponse.statusCode == 200 else {
                      print("statusCode != 200")
                      return
                  }
            
            guard let data = data else {
                print(error.debugDescription)
                return
            }
            
            do {
                let latest = try JSONDecoder().decode(Latest.self, from: data)
                self.setAllCurrencies(from: latest.rates)
                self.setFavoritesAndOther()
                self.isCurrencyLoaded.onNext(true)
            } catch {
                print(error.localizedDescription)
            }
        }
        task.resume()
    }
}


// MARK: - Currency properties setting methods
extension CurrencyViewModel {
    func setAllCurrencies(from dictionary: [String: Double]) {
        all = dictionary.map { ($0.key, $0.value) }
    }
    
    func setFavoritesAndOther() {
        let codes = readFromStorage()

        all.forEach { code, rate in
            if codes.contains(code) {
                favorites.append((code, rate))
            } else {
                other.append((code, rate))
            }
        }

        favorites.sort { $0.0 < $1.0 }
        other.sort { $0.0 < $1.0 }
    }
}

// MARK: - Data storage methods
extension CurrencyViewModel {
    func readFromStorage() -> [String] {
        let key = Settings.UserDefaultKeys.favorites.rawValue
        
        if let favorites = storage.array(forKey: key) as? [String],
           !favorites.isEmpty {
            return favorites
        } else {
            let defaultCurrencies = Settings.DefaultCurrency.allCases.map { $0.rawValue }
            storage.setValue(defaultCurrencies, forKey: key)
            return readFromStorage()
        }
    }
    
    func writeToStorage(_ currencies: [String]) {
        let key = Settings.UserDefaultKeys.favorites.rawValue
        storage.setValue(currencies, forKey: key)
    }
}
