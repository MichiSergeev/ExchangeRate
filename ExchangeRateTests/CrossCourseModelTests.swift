//
//  CrossCourseModelTests.swift
//  ExchangeRateTests
//
//  Created by Mikhail Sergeev on 29.03.2022.
//

import XCTest
@testable import ExchangeRate

class CrossCourseModelTests: XCTestCase {

    func testDirectPairsExchangeRate_WhenExist_ShouldBeEqual() {
        // Arrange
        let model = CrossCourse()
        let basePair = 87.500012
        let quotePair = 0.901915
        let expectedResult = 97.015807
        
        // Act
        let exchangeRate = model.calculateExchangeRateForDirectPairs(basePair: basePair, quotePair: quotePair)
        
        // Assert
        XCTAssertEqual(exchangeRate!, expectedResult, accuracy: 0.000002)
    }
    
    func testDirectPairsExchangeRate_WhenBasePair_IsZero() {
        // Arrange
        let model = CrossCourse()
        let basePair = 0.0
        let quotePair = 0.901915
        let expectedResult = 0.0
        
        // Act
        let exchangeRate = model.calculateExchangeRateForDirectPairs(basePair: basePair, quotePair: quotePair)
        
        // Assert
        XCTAssertEqual(exchangeRate!, expectedResult, accuracy: 0.000002)
    }
    
    func testDirectPairsExchangeRate_WhenQuotePair_IsZero() {
        // Arrange
        let model = CrossCourse()
        let basePair = 87.500012
        let quotePair = 0.0
        
        // Act
        let exchangeRate = model.calculateExchangeRateForDirectPairs(basePair: basePair, quotePair: quotePair)
        
        // Assert
        XCTAssertNil(exchangeRate)
    }
    
    func testReversePairsExchangeRate_WhenExist_ShouldBeEqual() {
        // Arrange
        let model = CrossCourse()
        let basePair: Double = 1 / 7
        let quotePair = 2.0
        let expectedResult = 14.0
        
        // Act
        let exchangeRate = model.calculateExchangeRateForReversePairs(basePair: basePair, quotePair: quotePair)
        
        // Assert
        XCTAssertEqual(exchangeRate!, expectedResult, accuracy: 0.000002)
    }

    func testReversePairsExchangeRate_WhenBasePair_IsZero() {
        // Arrange
        let model = CrossCourse()
        let basePair = 0.0
        let quotePair = 0.901915
        
        // Act
        let exchangeRate = model.calculateExchangeRateForReversePairs(basePair: basePair, quotePair: quotePair)
        
        // Assert
        XCTAssertNil(exchangeRate)
    }
    
    func testReversePairsExchangeRate_WhenQuotePair_IsZero() {
        // Arrange
        let model = CrossCourse()
        let basePair: Double = 3 / 7
        let quotePair = 0.0
        
        // Act
        let exchangeRate = model.calculateExchangeRateForReversePairs(basePair: basePair, quotePair: quotePair)
        
        // Assert
        XCTAssertEqual(exchangeRate!, 0.0, accuracy: 0.000002)
    }
    
    func testCombainePairsExchangeRate_WhenBasePair_IsZero() {
        // Arrange
        let model = CrossCourse()
        let basePair = 0.0
        let quotePair = 0.90
        
        // Act
        let exchangeRate = model.calculateExchangeRate(baseReversePair: basePair, quoteDirectPair: quotePair)
        
        // Assert
        XCTAssertNil(exchangeRate)
    }
    
    func testCombainePairsExchangeRate_WhenQuotePair_IsZero() {
        // Arrange
        let model = CrossCourse()
        let basePair = 0.9
        let quotePair = 0.0
        
        // Act
        let exchangeRate = model.calculateExchangeRate(baseReversePair: basePair, quoteDirectPair: quotePair)
        
        // Assert
        XCTAssertNil(exchangeRate)
    }
    
    func testCombainePairsExchangeRate_WhenExist_ShouldBeEqual() {
        // Arrange
        let model = CrossCourse()
        let baseReversePair: Double = 1 / 70
        let quoteDirecPair = 0.8
        let expectedResult = 87.5
        
        // Act
        let exchangeRate = model.calculateExchangeRate(baseReversePair: baseReversePair, quoteDirectPair: quoteDirecPair)
        
        // Assert
        XCTAssertEqual(exchangeRate!, expectedResult, accuracy: 0.000002)
    }
    
}
