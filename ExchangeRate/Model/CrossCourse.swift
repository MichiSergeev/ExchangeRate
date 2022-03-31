//
//  CrossCourse.swift
//  ExchangeRate
//
//  Created by Mikhail Sergeev on 27.03.2022.
//

import Foundation

class CrossCourse {
    
    func calculateExchangeRateForDirectPairs(basePair: Double, quotePair: Double) -> Double? {
        guard quotePair != .zero else {
            return nil
        }
        
        return basePair / quotePair
    }
    
    func calculateExchangeRateForReversePairs(basePair: Double, quotePair: Double) -> Double? {
        guard basePair != .zero else {
            return nil
        }
        
        return quotePair / basePair
    }
    
    func calculateExchangeRate(baseDirectPair: Double, quoteReversePair: Double) -> Double {
        baseDirectPair * quoteReversePair
    }
    
    func calculateExchangeRate(baseReversePair: Double, quoteDirectPair: Double) -> Double? {
        guard baseReversePair * quoteDirectPair != .zero else {
            return nil
        }
        
        return 1 / (baseReversePair * quoteDirectPair)
    }
    
}
