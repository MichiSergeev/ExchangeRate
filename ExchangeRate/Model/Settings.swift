//
//  Settings.swift
//  ExchangeRate
//
//  Created by Mikhail Sergeev on 02.04.2022.
//

import Foundation

class Settings {
    enum Table {
        enum SettingDisplayTitles: String, CaseIterable {
            case favourites = "Избранные валюты"
            case other = "Другие валюты"
        }
    }
    
    enum CurrencyRationScreen: String, CaseIterable {
        case title = "Курс к выбранной валюте"
    }
    
    enum Favourites: Int {
        case min = 1
        case max = 5
    }
    
    enum DefaultCurrency: String, CaseIterable {
        case usd = "USD"
    }
    
    enum UserDefaultKeys: String, CaseIterable {
        case favorites
    }
}


