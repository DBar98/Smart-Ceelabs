////
////  ProfileDataTableViewController.swift
////  SmartCeelabs
////
////  Created by Dávid Baľak on 06/04/2022.
////
//
//import UIKit
//import Charts
//import RxSwift
//import RxCocoa
//
//class ViewModel {
//    var users = BehaviorSubject(value: [Userko]())
//
//    func fetchUsers() {
//        let url = URL(string: "https://jsonplaceholder.typicode.com/posts")
//        let task = URLSession.shared.dataTask(with: url!) { (data,response, error) in
//            guard let data = data else {
//                return
//            }
//            do {
//                let responseData = try JSONDecoder().decode([Userko].self, from: data)
//                self.users.on(.next(responseData))
//            } catch {
//                print(error.localizedDescription)
//            }
//        }
//        task.resume()
//    }
//
//}
//
//struct Userko: Codable {
//    let userID, id: Int
//    let title, body: String
//
//    enum CodingKeys: String, CodingKey {
//        case userID = "userId"
//        case id, title, body
//    }
//}
//
//
//
//
//
//class ProfileDataTableViewController: UIViewController {
//
//    @IBOutlet weak var dataTableView: UITableView!
//    var chartData: [ProfileChartData] = []
//    var viewModel = ViewModel()
//
//    lazy var tableView : UITableView = {
//        let tv = UITableView(frame: self.view.frame, style: .insetGrouped)
//        tv.translatesAutoresizingMaskIntoConstraints = false
//        tv.register(ProfileDataTableCell.self, forCellReuseIdentifier: "ProfileDataTableCell")
//        return tv
//    }()
//
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        self.view.addSubview(tableView)
//        viewModel.fetchUsers()
//        bindTableView()
//    }
//
//
//    func bindTableView() {
//        var disposeBag = DisposeBag()
//
//        tableView.rx.setDelegate(self).disposed(by: disposeBag)
//
//        viewModel.users.bind(to: self.tableView.rx.items(cellIdentifier: "ProfileDataTableCell",cellType: ProfileDataTableCell.self)) { (row,item,cell) in
//            print(item)
//            cell.valueLabel.text = item.title
//            cell.valueDescLabel.text = "\(item.id)"
//        }.disposed(by: disposeBag)
//    }
//
//
//    //        viewModel.fetchData(phases:	 ["L1"], data: .current, cumulative: "false", timeFrom: "1648807245", timeTo: "1648807315", lineChart: lineChart)
//    //
//    //        self.viewModel.structs.bind(
//    //                to: self.dataTableView.rx.items(
//    //                    cellIdentifier: "ProfileDataTableCell", cellType: ProfileDataTableCell.self)) {
//    //                        row, model, cell in
//    //                        print(row)
//    //                        cell.valueLabel.text = model.surname
//    //                    }.disposed(by: disposeBag)
//    //
//
//
//    static func instantiate() -> Self {
//        return UIStoryboard(name: "ProfileDataTableView", bundle: nil).instantiateViewController(withIdentifier: "ProfileDataTableViewController") as! Self
//    }
//}
//
//extension ProfileDataTableViewController : UITableViewDelegate {}



//
//  ViewController.swift
//  MVVMApp
//
//  Created by CodeLib on 26/02/22.
//

import UIKit
//import RxSwift
//import RxCocoa

class ProfileDataTableViewController: UIViewController {
    @IBOutlet weak var dataTableView: UITableView!

    private var viewModel = ViewModel()
//    private var bag = DisposeBag()

    
    override func viewDidLoad() {
        super.viewDidLoad()
        dataTableView.register(cell: ProfileDataTableCell.self)

        viewModel.fetchData(data: .current, timeFrom: "1648807245", timeTo: "1648807315")
//        bindTableView()
        
    }
    
//    func bindTableView() {
////        dataTableView.rx.setDelegate(self).disposed(by: bag)
//        viewModel.values.bind(to: dataTableView.rx.items(cellIdentifier: "ProfileDataTableCell",cellType: ProfileDataTableCell.self)) { (row,item,cell) in
//            print(item)
//            cell.dateTimeLabel?.text = String(item.phase1?[row][0] ?? 0.0)
//            cell.valueLabel.text = String(item.phase1?[row][1] ?? 0.0)
//        }.disposed(by: bag)
//    }
    
    static func instantiate() -> Self {
            return UIStoryboard(name: "ProfileDataTableView", bundle: nil).instantiateViewController(withIdentifier: "ProfileDataTableViewController") as! Self
        }
}

extension ProfileDataTableViewController : UITableViewDelegate {}

class ViewModel {
//    var values = BehaviorSubject(value: [ProfileTableData]())
    let networking = Networking()

    func fetchData(data: ProfileDataEnum, timeFrom: String, timeTo: String){
        
        let request = ProfileRequest(token: "840D8E39905C|1649501382|b3fb5769792bdef4b3f2a8f54df55cea34c784b4e5cc5125eba8d160460d65e4",
                                     data: data.getDataShortuct,
                                     format: "H",
                                     phase: "L1, L2, L3",
                                     cumulative: "false",
                                     from: timeFrom,
                                     to: timeTo)
        
        networking.post(url: UrlEnum.profileDataUrl.rawValue,
                        jsonBody: request,
                        onCompletion: { [weak self] (response: Response) in
            guard let self = self else { return }
            
            switch response.status {
            case.ok:
                
                
                let dataUnitsTouple = self.getSpecificData(responseData: response, dataType: data)
                var tableData: [ProfileTableData] = []
                
//                if let energyData = dataUnitsTouple.0 {
//                    
//                    for energyData in energyData{
//                        tableData.append(ProfileTableData(phase1: energyData, phase2: <#T##[[Double]]?#>, phase3: <#T##[[Double]]?#>, timestamp: <#T##[Double]#>))
//                    }
//                }
//                
//                self.values.on(.next(profileData))
            case .fail:
                print("Failed to fetch data.")
            }
        }, onError: {
            print($0)
        })
    }
    
    private func getSpecificData(responseData: Response, dataType: ProfileDataEnum) -> (I?, String?){
        
        switch dataType {
        case .voltage:
            return (responseData.data.i, responseData.units.i)

        case .current:
            return (responseData.data.u, responseData.units.u)

        case .activePower:
            return (responseData.data.p, responseData.units.p)

        case .reactivePower:
            return (responseData.data.q, responseData.units.q)

        case .apparentPower:
            return (responseData.data.s, responseData.units.i)

        case .energyImport:
            return (responseData.data.e_i, responseData.units.i)

        case .energyExport:
            return (responseData.data.e_e, responseData.units.i)

        }
    }
}

struct ProfileTableData {
    var phase1: [[Double]]?
    var phase2: [[Double]]?
    var phase3: [[Double]]?
    var timestamp: [Double]
}


