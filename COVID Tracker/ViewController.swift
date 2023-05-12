//
//  ViewController.swift
//  COVID Tracker
//
//  Created by Nazar Kopeyka on 13.04.2023.
//

import Charts /* 170 */
import UIKit


/// Data of covid cases
class ViewController: UIViewController, UITableViewDataSource { /* 142 add UITableViewDataSource */
    
    static let numberFormatter: NumberFormatter = { /* 159 */
        let formatter = NumberFormatter() /* 160 */
        formatter.usesGroupingSeparator = true /* 166 */
        formatter.groupingSeparator = "," /* 167 */
        formatter.formatterBehavior = .default /* 165 */
        formatter.locale = .current /* 161 */
        return formatter /* 162 */
    }()
    
    private let tableView: UITableView = { /* 133 */
        let table = UITableView(frame: .zero) /* 134 */
        table.register(UITableViewCell.self,
                       forCellReuseIdentifier: "cell") /* 135 */
        return table /* 136 */
    }()
    
    private var dayData: [DayData] = [] { /* 130 */
        didSet { /* 131 */
            DispatchQueue.main.async { /* 132 */
                self.tableView.reloadData() /* 137 */
                self.createGraph() /* 168 */
            }
        }
    }
    
    private var scope: APICaller.DataScope = .national /* 29 */
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Covid Cases" /* 1 */
        configureTable() /* 138 */
        createFilterButton() /* 30 */
        fetchData() /* 97 */
    }
    
    override func viewDidLayoutSubviews() { /* 156 viewDidLayout */
        super.viewDidLayoutSubviews() /* 157 */
        tableView.frame = view.bounds /* 158 */
    }
    
    private func createGraph() { /* 169 */
        
    }
    
    private func configureTable() { /* 139 */
        view.addSubview(tableView) /* 140 */
        tableView.dataSource = self /* 141 */
    }
    
    private func fetchData() { /* 81 */
        APICaller.shared.getCovidData(for: scope) { [weak self] result in /* 93 */ /* 155 add weak self */
            switch result { /* 94 */
            case .success(let dayData): /* 95 */
//                break /* 96 */
                self?.dayData = dayData /* 129 */
            case .failure(let error): /* 95 */
                print(error) /* 96 */
            }
        }
    }
    
    private func createFilterButton() { /* 28 */
        let buttonTitle: String = { /* 33 */
            switch scope { /* 34 */
            case .national: return "National" /* 35 */
            case .state(let state): return state.name /* 36 */
            }
        }()
        
        navigationItem.rightBarButtonItem = UIBarButtonItem( /* 31 */
            title: buttonTitle,
            style: .done,
            target: self,
            action: #selector(didTapFilter)
        )
    }
    
    @objc private func didTapFilter() { /* 32 */
        let vc = FilterViewController() /* 37 */
        vc.completion = { [weak self] state in /* 79 */
            self?.scope = .state(state) /* 80 */
            self?.fetchData() /* 82 */
            self?.createFilterButton() /* 83 */
        }
        let navVC = UINavigationController(rootViewController: vc) /* 38 */
        present(navVC, animated: true) /* 39 */
    }
    
    
    //MARK: - Table
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int { /* 143 numberOfRows */
        return dayData.count /* 144 */
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell { /* 145 */
        let data = dayData[indexPath.row] /* 146 */
        let cell: UITableViewCell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) /* 147 */
        cell.textLabel?.text = createText(with: data) /* 148 */
        return cell /* 149 */
    }
    
    private func createText(with data: DayData) -> String? { /* 150 */
        let dateString = DateFormatter.prettyFormatter.string(from: data.date) /* 153 */
        let total = Self.numberFormatter.string(from: NSNumber(value: data.count)) /* 163 */
        return "\(dateString): \(total ?? "\(data.count)")" /* 154 */ /* 164 change data.count */
    }
}
