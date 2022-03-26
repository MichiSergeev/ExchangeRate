//
//  Latest.swift
//  ExchangeRate
//
//  Created by Mikhail Sergeev on 27.03.2022.
//

import Foundation

struct Latest: Codable {
    var base: String
    var rates: [String: Double]
}
