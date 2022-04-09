//
//  CurrencyDataSource.swift
//  ExchangeRate
//
//  Created by Mikhail Sergeev on 09.04.2022.
//

import UIKit

class CurrencyListDataSource: NSObject, UITableViewDataSource {
    
    private let viewModel: CurrencyViewModel!
    
    init(viewModel: CurrencyViewModel) {
        self.viewModel = viewModel
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        viewModel.titles.allCases.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return viewModel.favorites.count
        case 1:
            return viewModel.other.count
        default:
            return 0
        }
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        viewModel.titles.allCases[section].rawValue
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard var cell = tableView.dequeueReusableCell(withIdentifier: "currencyCell") else {
            return UITableViewCell()
        }

        cell = UITableViewCell(style: .subtitle, reuseIdentifier: "currenciesCell")

        switch indexPath.section {
        case 0:
            cell.textLabel?.text = viewModel.favorites[indexPath.row].0
            cell.detailTextLabel?.text = String(viewModel.favorites[indexPath.row].1)
        default:
            cell.textLabel?.text = viewModel.other[indexPath.row].0
            cell.detailTextLabel?.text = String(viewModel.other[indexPath.row].1)
        }

        return cell
    }
}
