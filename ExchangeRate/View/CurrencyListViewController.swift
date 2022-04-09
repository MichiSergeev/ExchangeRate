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
    private var dataSource: CurrencyListDataSource!
    
    // MARK: - Lifecycle methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        dataSource = CurrencyListDataSource(viewModel: viewModel)
        title = "Курсы валют к USD"
        view.backgroundColor = .white
        setUpTableView()
        loadCurrencies()
    }
    
    // MARK: - Private methods
    private func setUpTableView() {
        tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.dataSource = dataSource
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
        let deleteFromFavorites = makeDeleteSwipeAvtion(tableView: tableView, indexPath: indexPath)
        let addToFavorites = makeAddToFavoritesSwipeAction(tableView: tableView, indexPath: indexPath)
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
    
    private func makeDeleteSwipeAvtion(tableView: UITableView, indexPath: IndexPath) -> UIContextualAction {
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
        
        return deleteFromFavorites
    }
    
    private func makeAddToFavoritesSwipeAction(tableView: UITableView, indexPath: IndexPath) -> UIContextualAction {
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
        
        return addToFavorites
    }
}
