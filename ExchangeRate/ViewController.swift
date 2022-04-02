//
//  ViewController.swift
//  ExchangeRate
//
//  Created by Mikhail Sergeev on 26.03.2022.
//

import UIKit

class ViewController: UIViewController {
    
    let basePath = "https://openexchangerates.org/api/"
    let latest = "latest.json"
    let appID = "app_id"
    let id = "4502a35230eb4319987a07d2fba726b1"
    let storage = UserDefaults.standard
    let titles = Settings.Table.SettingDisplayTitles.self
    var all: [Currency] = []
    var favorites: [Currency] = []
    var other: [Currency] = []
    var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Курсы валют к USD"
        view.backgroundColor = .white
        getLatestExchangeRate()
        setUpTableView()
    }
    
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
                
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            } catch {
                print(error.localizedDescription)
            }
        }
        task.resume()
    }
    
    func setUpTableView() {
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
    
}

extension ViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        titles.allCases.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return favorites.count
        case 1:
            return other.count
        default:
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        titles.allCases[section].rawValue
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard var cell = tableView.dequeueReusableCell(withIdentifier: "currencyCell") else {
            return UITableViewCell()
        }
        
        cell = UITableViewCell(style: .subtitle, reuseIdentifier: "currenciesCell")
        
        switch indexPath.section {
        case 0:
            cell.textLabel?.text = favorites[indexPath.row].0
            cell.detailTextLabel?.text = String(favorites[indexPath.row].1)
        default:
            cell.textLabel?.text = other[indexPath.row].0
            cell.detailTextLabel?.text = String(other[indexPath.row].1)
        }
        
        return cell
    }
}

extension ViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let baseCurrency: Currency
        let currenciesForCalculation: [Currency]
        
        switch indexPath.section {
        case 0:
            baseCurrency = favorites[indexPath.row]
            currenciesForCalculation = other
        case 1:
            baseCurrency = other[indexPath.row]
            currenciesForCalculation = favorites
        default:
            return
        }
        
        let currencyRatioVC = CurrencyRatioViewController()
        currencyRatioVC.baseCurrency = baseCurrency
        currencyRatioVC.currenciesForCalculation = currenciesForCalculation

        navigationController?.pushViewController(currencyRatioVC, animated: true)
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let section = indexPath.section
        
        let deleteFromFavorites = UIContextualAction(style: .destructive, title: "Удалить") { _, _, completionHandler in
            let deletedFromFavorites = self.favorites.remove(at: indexPath.row)
            let newFavorites = self.favorites.map({$0.0})
            self.writeToStorage(newFavorites)
            tableView.deleteRows(at: [indexPath], with: .automatic)
            self.other.append(deletedFromFavorites)
            self.other.sort(by: { $0.0 < $1.0 })
            let index = self.other.firstIndex { $0.0 == deletedFromFavorites.0 } ?? 0
            let newIndexPath = IndexPath(row: index, section: 1)
            tableView.insertRows(at: [newIndexPath], with: .automatic)
            completionHandler(true)
        }
        
        let addToFavorites = UIContextualAction(style: .normal, title: "В избранное") { (_, _, completionHandler) in
            let deletedFromOther = self.other.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .automatic)
            self.favorites.append(deletedFromOther)
            let newFavorites = self.favorites.map({$0.0})
            self.writeToStorage(newFavorites)
            self.favorites.sort { $0.0 < $1.0 }
            let index = self.favorites.firstIndex { $0.0 == deletedFromOther.0 } ?? 0
            let newIndexPath = IndexPath(row: index, section: 0)
            tableView.insertRows(at: [newIndexPath], with: .automatic)
            completionHandler(true)
        }
        
        addToFavorites.backgroundColor = .orange
        
        switch section {
        case 0:
            if favorites.count > Settings.Favourites.min.rawValue {
                return UISwipeActionsConfiguration(actions: [deleteFromFavorites])
            } else {
                return UISwipeActionsConfiguration(actions: [])
            }
        default:
            if favorites.count < Settings.Favourites.max.rawValue {
                return UISwipeActionsConfiguration(actions: [addToFavorites])
            } else {
                return UISwipeActionsConfiguration(actions: [])
            }
        }
    }
}

private extension ViewController {
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
