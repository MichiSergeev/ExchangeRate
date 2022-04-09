//
//  ViewController.swift
//  ExchangeRate
//
//  Created by Mikhail Sergeev on 26.03.2022.
//

import UIKit
import RxSwift
import RxCocoa
import RxDataSources

class CurrencyListViewController: UIViewController {
    
    // MARK: - Private properties
    private var tableView: UITableView!
    private let disposeBag = DisposeBag()
    private var viewModel = CurrencyViewModel()
    
    // MARK: - Lifecycle methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Курсы валют к USD"
        view.backgroundColor = .white
        setUpTableView()
        loadCurrencies()
    }
    
    // MARK: - Private methods
    private func setUpTableView() {
        tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "currencyCell")
        
        view.addSubview(tableView)
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.readableContentGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.readableContentGuide.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.readableContentGuide.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.readableContentGuide.bottomAnchor)
        ])
    }
    
    private func loadCurrencies() {
        viewModel.getLatestExchangeRate()
        viewModel.isCurrencyLoaded
            .subscribe(onNext: { isLoaded in
                guard isLoaded else { return }
                
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            }).disposed(by: disposeBag)
    }
    
}

// MARK: - Table view data source methods
extension CurrencyListViewController: UITableViewDataSource {
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

// MARK: - Table view delegate methods
extension CurrencyListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        let currency: Currency
        let currenciesForCalculation: [Currency]

        switch indexPath.section {
        case 0:
            currency = viewModel.favorites[indexPath.row]
            currenciesForCalculation = viewModel.other
        case 1:
            currency = viewModel.other[indexPath.row]
            currenciesForCalculation = viewModel.favorites
        default:
            return
        }

        let currencyRatioVC = CurrencyRatioViewController()
        currencyRatioVC.currency = currency
        currencyRatioVC.currenciesForCalculation = currenciesForCalculation

        navigationController?.pushViewController(currencyRatioVC, animated: true)
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let section = indexPath.section

        let deleteFromFavorites = UIContextualAction(style: .destructive, title: "Удалить") { _, _, completionHandler in
            let deletedFromFavorites = self.viewModel.favorites.remove(at: indexPath.row)
            let newFavorites = self.viewModel.favorites.map({$0.0})
            self.viewModel.writeToStorage(newFavorites)
            tableView.deleteRows(at: [indexPath], with: .automatic)
            self.viewModel.other.append(deletedFromFavorites)
            self.viewModel.other.sort(by: { $0.0 < $1.0 })
            let index = self.viewModel.other.firstIndex { $0.0 == deletedFromFavorites.0 } ?? 0
            let newIndexPath = IndexPath(row: index, section: 1)
            tableView.insertRows(at: [newIndexPath], with: .automatic)
            completionHandler(true)
        }

        let addToFavorites = UIContextualAction(style: .normal, title: "В избранное") { (_, _, completionHandler) in
            let deletedFromOther = self.viewModel.other.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .automatic)
            self.viewModel.favorites.append(deletedFromOther)
            let newFavorites = self.viewModel.favorites.map({$0.0})
            self.viewModel.writeToStorage(newFavorites)
            self.viewModel.favorites.sort { $0.0 < $1.0 }
            let index = self.viewModel.favorites.firstIndex { $0.0 == deletedFromOther.0 } ?? 0
            let newIndexPath = IndexPath(row: index, section: 0)
            tableView.insertRows(at: [newIndexPath], with: .automatic)
            completionHandler(true)
        }

        addToFavorites.backgroundColor = .orange

        switch section {
        case 0:
            if viewModel.favorites.count > Settings.Favourites.min.rawValue {
                return UISwipeActionsConfiguration(actions: [deleteFromFavorites])
            } else {
                return UISwipeActionsConfiguration(actions: [])
            }
        default:
            if viewModel.favorites.count < Settings.Favourites.max.rawValue {
                return UISwipeActionsConfiguration(actions: [addToFavorites])
            } else {
                return UISwipeActionsConfiguration(actions: [])
            }
        }
    }
}
