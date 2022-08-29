//
//  ProfileDetailViewController.swift
//  SmartCeelabs
//
//  Created by Dávid Baľak on 02/11/2021.
//

import UIKit
import Charts
import CryptoKit

class ProfileDetailViewController: UIViewController, UICollectionViewDelegate, ChartViewDelegate {

    @IBOutlet weak var profileChartView: UIView!
    @IBOutlet weak var profilePhaseCollection: UICollectionView!
    @IBOutlet weak var profileTimeLineCollection: UICollectionView!
    
    //MARK: - Properties
    var lineChart = LineChartView()
    var chartsModel = ChartsModel()
    var valueUnit: String = ""
    var responseArray : [[Double]] = []
    var resultArrayOfEachPhase: [[Double]] = []
    var profileResponseForChart: [[[Double]]] = []
    var chartDataFromProfile: [ProfileChartDataStruct] = []
    
    var selectedPhaseCellIdx: Int?
    
    var chartData: [ProfileChartData] = []

    var viewModel: ProfileDetailViewModelType?
    let tableDataVC = ProfileDataTableViewController.instantiate()

    var timeIntervalFrom: String = TimeUnitsEnum.Today.getTimestamp
    var timeIntervalTo: String = Date().currentTimeInTimeStampAsString
    
    var phaseNumberForFetching: [String] = [] {
        didSet {
            fetchData()
        }
    }
    
    var selectedTimelineCellIdx: Int = 0 {
        didSet(previousIndex) {
            let previousSelected = profileTimeLineCollection.cellForItem(at: IndexPath.init(row: previousIndex, section: 0)) as? ProfileTimeLineCell
            if previousIndex != selectedTimelineCellIdx {
                previousSelected?.setupBackgroundAsDeselected(type: .timeline)
            }
        }
    }
    
    override var title: String? {
        didSet {
            navigationItem.title = title
        }
    }
        
    var phaseNumber: String = "L1"
    
    //MARK: - View Controller initialization
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupUI()

        lineChart = chartsModel.prepareLineChart(lineChart: self.lineChart, usedPercents: false)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        fetchData()
        self.navigationItem.largeTitleDisplayMode = .never
        
    }

    override func viewDidLayoutSubviews() {
        lineChart.frame = CGRect(x: 0, y: 0, width: profileChartView.frame.width, height: profileChartView.frame.height)
    }
    
    //MARK: - View Controller UI Setup
    func setupUI() {
        profileTimeLineCollection.delegate = self
        profileTimeLineCollection.dataSource = self
        profileTimeLineCollection.showsHorizontalScrollIndicator = false
        profileTimeLineCollection.setCollectionHotizontalFlowLayoutWithSpacing()
        
        profilePhaseCollection.delegate = self
        profilePhaseCollection.dataSource = self
        if let profilePhaseCollectionLayout = profilePhaseCollection.collectionViewLayout as? UICollectionViewFlowLayout {
            profilePhaseCollectionLayout.scrollDirection = .horizontal
        }
        profilePhaseCollection.allowsMultipleSelection = true
        
        self.lineChart.delegate = self
        self.profileChartView.addSubview(lineChart)
        
        setupOutputs()
//        setupNavBar()
    }
    
    private func setupOutputs() {
        viewModel?.outputs.onDataFetch = { [weak self] data in
            self?.chartData = data
        }
    }
    
    private func setupNavBar() {
        //setup settings image
        let gearShapeImg =  UIImage(systemName: "gearshape.fill")
        let gaershapeBarButton = UIBarButtonItem(image: gearShapeImg, style: .done, target: self, action: #selector(gearshapeButtonTapped))
        
        //create buttons in navigation bar
        self.navigationItem.rightBarButtonItem = gaershapeBarButton
    }
    
    @objc func gearshapeButtonTapped() {
        self.navigationController?.present(tableDataVC, animated: true, completion: nil)
    }
    
    //MARK: - Data Fetch
    private func fetchData() {
        viewModel?.inputs.fetchData(phases: Array(Set(phaseNumberForFetching)),
                                    data: ProfileDataEnum(rawValue: title ?? "") ?? .voltage,
                                    cumulative: "false",
                                    timeFrom: timeIntervalFrom,
                                    timeTo: timeIntervalTo,
                                    lineChart: self.lineChart,
                                    currentController: self)
    }
    
    
    static func instantiate() -> Self {
        return UIStoryboard(name: "ProfileDataView", bundle: nil).instantiateViewController(withIdentifier: "ProfileDetailViewController") as! Self
    }
}

//MARK: - Collection View Delegates
extension ProfileDetailViewController: UICollectionViewDataSource{
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        //MARK: - Timeline Collection View
        if collectionView == profileTimeLineCollection{
            let collectionViewCell: ProfileTimeLineCell = profileTimeLineCollection.dequeueReusableCell(withReuseIdentifier: "ProfileTimeLineCell", for: indexPath) as! ProfileTimeLineCell
            
            collectionViewCell.setupCellUI(cellText: TimeUnitsTypesEnum.daily.timeUnits[indexPath.row].rawValue )
//            collectionViewCell.setupCellUI(cellText: TimeUnitsEnum.allCases[indexPath.row].rawValue )
            
            if indexPath.row == selectedTimelineCellIdx {
                collectionViewCell.setupBackgroundAsSelected(type: .timeline)
            }
            return collectionViewCell
        }
        
        //MARK: - Phase Collection View
        else if collectionView == profilePhaseCollection {
            let collectionViewCell: ProfileDetailPhaseCell = profilePhaseCollection.dequeueReusableCell(withReuseIdentifier: "ProfileDetailPhaseCell", for: indexPath) as! ProfileDetailPhaseCell
            
            collectionViewCell.parentVC = self
            collectionViewCell.setupCellUI(cellText: profilePhasesCells[indexPath.row].phaseName)
            
            if indexPath.row == selectedPhaseCellIdx {
                collectionViewCell.setupBackgroundAsSelected(type: .phase)
            }
            
            return collectionViewCell
        }
        return UICollectionViewCell()
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == profileTimeLineCollection {
            return TimeUnitsTypesEnum.daily.timeUnits.count
        }
        else if collectionView == profilePhaseCollection {
            return viewModel?.outputs.devicePhases ?? 3
        }
        return 0
    }
}

extension ProfileDetailViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let screenViewWidth = UIScreen.main.bounds.width
        let collectionViewHeight = collectionView.frame.size.height
        
        if collectionView == profileTimeLineCollection {
            return CGSize(width: screenViewWidth/3.0, height: collectionViewHeight)
        }
        else if collectionView == profilePhaseCollection {
            let numberOfPhases = viewModel?.outputs.devicePhases ?? 3
            return CGSize(width: screenViewWidth / CGFloat(numberOfPhases), height: collectionViewHeight)
        }
        return .zero
    }
    
    //MARK: - Cell selection
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        //MARK: - Phase Cell selection
        if collectionView == profilePhaseCollection{
            selectedPhaseCellIdx = indexPath.row
            
            let selectedCell = collectionView.cellForItem(at: indexPath) as! ProfileDetailPhaseCell
            //Parsing Phase num.
            guard let cellTextToWords = selectedCell.profilePhaseLabel.text else {return}
            phaseNumber = String(cellTextToWords.byWords.last ?? "")
            //Fetch data by chosen time unit and display them
            phaseNumberForFetching.append(phaseNumber)
        }
        
        //MARK: - Timeline Cell selection
        else if collectionView == profileTimeLineCollection{
            selectedTimelineCellIdx = indexPath.row
            
            let currentCell = profileTimeLineCollection.cellForItem(at: indexPath) as! ProfileTimeLineCell
            
            guard let currentCellText = currentCell.timeLineCellLabel.text else { return }
            let chosenTimeInterval: TimeUnitsEnum = TimeUnitsEnum(rawValue: currentCellText) ?? .Today
            
            timeIntervalFrom = chosenTimeInterval.getTimestamp
            timeIntervalTo = Date().currentTimeInTimeStampAsString

            if currentCellText.elementsEqual("Yesterday"){
                timeIntervalTo = TimeUnitsEnum.Today.getTimestamp

                self.viewModel?.inputs.fetchData(phases: self.phaseNumberForFetching, data: ProfileDataEnum(rawValue: title ?? "") ?? .voltage, cumulative: "false", timeFrom: TimeUnitsEnum.Yesterday.getTimestamp, timeTo: timeIntervalTo, lineChart: self.lineChart, currentController: self)
            } else if chosenTimeInterval == .custom {
                let vc = UIStoryboard(name: "CalendarPickerModal", bundle: nil).instantiateViewController(withIdentifier: "CalendarPickerViewController") as? CalendarPickerViewController
                vc?.delegate = self
                vc?.modalPresentationStyle = .overCurrentContext
                self.navigationController?.present(vc ?? UIViewController(), animated: true, completion: nil)
            }
            else {
                self.viewModel?.inputs.fetchData(phases: self.phaseNumberForFetching, data: ProfileDataEnum(rawValue: title ?? "") ?? .voltage, cumulative: "false", timeFrom: timeIntervalFrom, timeTo: timeIntervalTo, lineChart: self.lineChart, currentController: self)
            }
        }
    }
}

//MARK: - Calendar View Delegate
extension ProfileDetailViewController: CalendarPickerViewControllerDelegate {
    func submitButtonPressed(timeFrom: String, timeTo: String) {
        viewModel?.inputs.fetchData(phases: phaseNumberForFetching, data: ProfileDataEnum(rawValue: title ?? "") ?? .voltage, cumulative: "false", timeFrom: timeFrom, timeTo: timeTo, lineChart: self.lineChart, currentController: self)
    }
}

extension Array where Element: Equatable {
    var unique: [Element] {
        var uniqueValues: [Element] = []
        forEach { item in
            guard !uniqueValues.contains(item) else { return }
            uniqueValues.append(item)
        }
        return uniqueValues
    }
}
