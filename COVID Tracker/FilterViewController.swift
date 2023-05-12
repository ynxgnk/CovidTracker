//
//  FilterViewController.swift
//  COVID Tracker
//
//  Created by Nazar Kopeyka on 13.04.2023.
//

import UIKit

class FilterViewController: UIViewController, UITableViewDelegate, UITableViewDataSource { /* 49 add 2 protocols */

    public var completion: ((State) -> Void)? /* 41 */
    
    private let tableView: UITableView = { /* 42 */
        let table = UITableView(frame: .zero, style: .grouped) /* 43 */
        table.register(UITableViewCell.self, forCellReuseIdentifier: "cell") /* 44 */
        return table /* 45 */
    }()
    
    private var states: [State] = [] { /* 66 */
        didSet { /* 67 */
            DispatchQueue.main.async { /* 78 */
                self.tableView.reloadData() /* 68 */
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground /* 40 */
        title = "Select State" /* 2 */
        view.addSubview(tableView) /* 46 */
        tableView.dataSource = self /* 47 */
        tableView.delegate = self /* 48 */
        fetchStates() /* 65 */
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .close,
                                                           target: self,
                                                           action: #selector(didTapClose)) /* 75 */
    }
    
    override func viewDidLayoutSubviews() { /* 50 viewDidLayoutSubwiews */
        super.viewDidLayoutSubviews() /* 51 */
        tableView.frame = view.bounds /* 52 */
    }
    
    @objc private func didTapClose() { /* 76 */
        dismiss(animated: true, completion: nil) /* 77 */
    }
    
    private func fetchStates() { /* 60 */
        APICaller.shared.getStateList { [weak self] result in /* 61 */
            switch result { /* 62 */
            case .success(let states): /* 63 */
                self?.states = states /* 64 */
            case .failure(let error): /* 63 */
                print(error) /* 64 */
            }
        }
    }
    
    //MARK: - Table
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int { /* 53 */
        return states.count /* 53 */ /* 70 change 0 */
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell { /* 54 */
        let state = states[indexPath.row] /* 69 */
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell",
                                                 for:  indexPath) /* 55 */
        cell.textLabel?.text = state.name /* 56 */ /* 71 change "Hello" */
        return cell /* 57 */
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) { /* 58 */
        tableView.deselectRow(at: indexPath, animated: true) /* 59 */
        let state = states[indexPath.row] /* 72 */
        completion?(state) /* 73 */
        dismiss(animated: true, completion: nil) /* 74 */
    }
    
}
