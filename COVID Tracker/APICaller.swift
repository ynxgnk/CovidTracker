//
//  APICaller.swift
//  COVID Tracker
//
//  Created by Nazar Kopeyka on 13.04.2023.
//

import Foundation

extension DateFormatter { /* 116 */
    static let dayFormatter: DateFormatter = { /* 117 */
        let formatter = DateFormatter() /* 118 */
        formatter.dateFormat = "YYY-MM-dd" /* 119 */
        formatter.timeZone = .current /* 121 */
        formatter.locale = .current /* 122 */
        return formatter /* 120 */
    }()
    
    static let prettyFormatter: DateFormatter = { /* 151 copy from 117 and paste */
        let formatter = DateFormatter() /* 151 */
        formatter.dateStyle = .medium /* 152 */
        formatter.timeZone = .current /* 151 */
        formatter.locale = .current /* 151 */
        return formatter /* 151 */
    }()
}

class APICaller { /* 3 */
    static let shared = APICaller() /* 4 */
    
    private init() {} /* 5 */
    
    
    private struct Constants { /* 13 */
        static let allStatesUrl = URL(string: "https://api.covidtracking.com/v2/states.json") /* 14 */
    }
    
    enum DataScope { /* 9 */
        case national /* 10 */
        case state(State) /* 10 */
    }
    
    public func getCovidData(
        for scope: DataScope, /* 11 */
        completion: @escaping (Result<[DayData], Error>) -> Void /* 12 */ /* 112 change String to DayData */
    ) { /* 6 */
        let urlString: String /* 85 */
        switch scope { /* 86 */
        case .national: urlString = "https://api.covidtracking.com/v2/us/daily.json" /* 87 */
        case .state(let state): /* 88 */
            urlString = "https://api.covidtracking.com/v2/states/\(state.state_code.lowercased())/daily.json" /* 89 */
        }
        
        guard let url = URL(string: urlString) else { return } /* 84 copy from 18 and paste */ /* 90 change Constants.allStatesUrl */
        
        let task = URLSession.shared.dataTask(with: url) { data, _, error in /* 84 */
            guard let data = data, error == nil else { return } /* 84 */
            
            do { /* 84 */
//                let result = try JSONSerialization.jsonObject(with: data, options: .allowFragments) /* 91 */
//                print(result) /* 92 */
                let result = try JSONDecoder().decode(CovidDataResponse.self, from: data) /* 106 */
//                print(result.data.count) /* 111 */
//                result.data.forEach { model in /* 113 */
//                    print(model.date) /* 114 */
//                }
                let models: [DayData] = result.data.compactMap { /* 123 */
                    guard let value = $0.cases.total.value, /* 128 */
                          let date = DateFormatter.dayFormatter.date(from: $0.date) else { /* 125 */
                       return nil /* 126 */
                   }
                    return DayData(
                        date: date,
                        count: value
                    ) /* 124 */
                }
                
                completion(.success(models)) /* 127 */
            }
            catch { /* 84 */
                completion(.failure(error)) /* 84 */
            }
        }
        task.resume() /* 84 */
    }
        
    
    public func getStateList(
        completion: @escaping (Result<[State], Error>) -> Void) { /* 7 completion handler is going to be escaping, its gonna return a Result, in success case we will have an array of States, else will have error */
            guard let url = Constants.allStatesUrl else { return } /* 18 */
            let task = URLSession.shared.dataTask(with: url) { data, _, error in /* 19 */
                guard let data = data, error == nil else { return } /* 20 */
                
                do { /* 21 */
                    let result = try JSONDecoder().decode(StateListResponse.self, from: data) /* 22 */
                    let states = result.data /* 23 */
                    completion(.success(states)) /* 24 */
                }
                catch { /* 25 */
                    completion(.failure(error)) /* 26 */
                }
            }
            task.resume() /* 27 */
        }
    }


//MARK: - Models

struct StateListResponse: Codable { /* 16 */
    let data: [State] /* 17 */
}

struct State: Codable { /* 8 */
    let name: String /* 15 */
    let state_code: String /* 15 */
}

struct CovidDataResponse: Codable { /* 98 */
    let data: [CovidDayData] /* 99 */
}

struct CovidDayData: Codable { /* 100 */
    let cases: CovidCases /* 101 */
    let date: String /* 107 */
}

struct CovidCases: Codable { /* 102 */
    let total: TotalCases /* 103 */
}

struct TotalCases: Codable { /* 104 */
    let value: Int? /* 105 */
}

struct DayData { /* 108 */
    let date: Date /* 109 */
    let count: Int /* 110 */
}




/* 7 completion handler is going to be escaping, its gonna return a Result, in success case we will have an array of States, else will have error */
