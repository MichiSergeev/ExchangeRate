//
//  CurrencyRatioViewController.swift
//  ExchangeRate
//
//  Created by Mikhail Sergeev on 02.04.2022.
//

import UIKit

class CurrencyRatioViewController: UITableViewController {
    
    // MARK: - Public properties
    var currency: Currency!
    var currenciesForCalculation: [Currency] = []
    
    // MARK: - Private properties
    private var calculatedCurrencies: [Currency] = []
    
    // MARK: - Lifecycle methods
    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.title = Settings.CurrencyRationScreen.title.rawValue + currency.0
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        calculateRatio()
    }
    
    // MARK: - Private methods
    private func calculateRatio() {
        let model = CrossCourse()
        calculatedCurrencies = currenciesForCalculation.map { code, rate in
            let newRate = model.calculateExchangeRateForDirectPairs(basePair: rate, quotePair: currency.1) ?? -1
            return (code, newRate)
        }
    }

    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return calculatedCurrencies.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard var cell = tableView.dequeueReusableCell(withIdentifier: "cell") else {
            return UITableViewCell()
        }
        
        cell = UITableViewCell(style: .subtitle, reuseIdentifier: "cell")
        cell.textLabel?.text = calculatedCurrencies[indexPath.row].0
        
        let value = calculatedCurrencies[indexPath.row].1
        let stringValue = value == -1 ? "n/d" : "\(value)"
        cell.detailTextLabel?.text = stringValue
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        currency.0
    }

}
