//
//  AnalyticsViewController.swift
//  SmartCeelabs
//
//  Created by Dávid Baľak on 25/02/2022.
//

import UIKit
import Charts

enum AnalyticsTimelineEnum: String, CaseIterable {    
    
    case hourlyActiveReport = "Hourly Active Report"
    case dailyActiveReport = "Daily Active Report"
    case monthlyActiveReport = "Monthly Active Report"
    case dailyReactiveReport = "Daily Reactive Report"
    
    typealias type = TimeUnitsTypesEnum
    
    var timePeriod: PeriodType {
        get {
            switch self {
            case .hourlyActiveReport:
                return .hour
            case .dailyActiveReport:
                return .day
            case .monthlyActiveReport:
                return .month
            case .dailyReactiveReport:
                return .day
            }
        }
    }
    
    var timelineCells: [TimeUnitsEnum] {
        get {
            switch self {
            case .hourlyActiveReport:
                return type.daily.timeUnits
            case .dailyActiveReport:
                return type.weekly.timeUnits
            case .monthlyActiveReport:
                return type.monthly.timeUnits
            case .dailyReactiveReport:
                return type.weekly.timeUnits
            }
        }
    }
    
    var segments: [String] {
        get {
            var array: [String] = []
            typealias active = EnergyDataOutputsEnum.ActiveEnergy
        
            switch self {
            case .hourlyActiveReport:
                array = active.allCases.map { $0.rawValue }
            case .dailyActiveReport:
                array = active.allCases.map { $0.rawValue }
            case .monthlyActiveReport:
                array = active.allCases.map { $0.rawValue }
            case .dailyReactiveReport:
                array = EnergyDataOutputsEnum.ReactiveEnergy.allCases.map { $0.rawValue }
            }
            return array
        }
    }
    
    var chartDetailTimeFormat: TimeFormat {
        get {
            switch self {
            case .hourlyActiveReport:
                return .hoursMinutes
            case .dailyActiveReport:
                return .daysMonths
            case .monthlyActiveReport:
                return .months
            case .dailyReactiveReport:
                return .daysMonths
            }
        }
    }
}

class AnalyticsDataViewController: DetailedChartViewController {

    @IBOutlet weak var timelineCollection: UICollectionView!
    @IBOutlet weak var chartView: UIView!
    @IBOutlet weak var dataTableView: UITableView!
    @IBOutlet weak var outputSegmentControl: UISegmentedControl!
    
    var viewModel: AnalyticsViewModelType?
    
    var lineChart = LineChartView()
    var barChart = BarChartView()
    var timestampsArray: [Double] = []
    var units: String = ""
    
    var selectedTimelineCellIdx: Int = 0 {
        didSet(previousIndex) {
            let previousSelected = timelineCollection.cellForItem(at: IndexPath.init(row: previousIndex, section: 0)) as? AnalyticsTimelineCell
            if previousIndex != selectedTimelineCellIdx {
                previousSelected?.setupBackgroundAsDeselected(type: .analyticsTimeline)
            }
        }
    }
    
    override var title: String? {
        didSet {
            navigationItem.title = title
            analyticsTimeline = AnalyticsTimelineEnum(rawValue: title ?? "")
        }
    }
    
    var analyticsTimeline: AnalyticsTimelineEnum?
    {
        didSet {
            energyDataType = (analyticsTimeline == .monthlyActiveReport || analyticsTimeline == .dailyActiveReport || analyticsTimeline == .hourlyActiveReport) ? "Energy Import" : "Quadrant 1"
            
            let data: String = EnergyDataOutputsEnum(rawValue: energyDataType)?.energyShortcut ?? ""
            viewModel?.inputs.fetchEnergyData(energyDataType: data,
                                              timeline: analyticsTimeline ?? .dailyActiveReport,
                                              timeFrom: timeFrom,
                                              timeTo: timeTo,
                                              barChart: barChart,
                                              selectedDataType: EnergyDataOutputsEnum(rawValue: energyDataType) ?? .energyImport,
            currentController: self)
        }
    }
    
    var energyDataType: String = "Energy Import"{
        didSet {
            let data: String = EnergyDataOutputsEnum(rawValue: energyDataType)?.energyShortcut ?? ""
            viewModel?.inputs.fetchEnergyData(energyDataType: data,
                                              timeline: analyticsTimeline ?? .dailyActiveReport,
                                              timeFrom: timeFrom,
                                              timeTo: timeTo,
                                              barChart: barChart,
                                              selectedDataType: EnergyDataOutputsEnum(rawValue: energyDataType) ?? .energyImport,
                                              currentController: self)
        }
    }
    
    var timeFrom: String = TimeUnitsEnum.Today.getTimestamp {
        didSet {
            self.showSpinner(onView: barChart)

            let data: String = EnergyDataOutputsEnum(rawValue: energyDataType)?.energyShortcut ?? ""
            viewModel?.inputs.fetchEnergyData(energyDataType: data,
                                              timeline: analyticsTimeline ?? .dailyActiveReport,
                                              timeFrom: timeFrom,
                                              timeTo: timeTo,
                                              barChart: barChart,
                                              selectedDataType: EnergyDataOutputsEnum(rawValue: energyDataType) ?? .energyImport,
                                              currentController: self)
        }
    }
    
    var timeTo: String = Date().currentTimeInTimeStampAsString
    
    var totalValue: [(String, String)] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupUI()
        self.prepareInputs()
        self.prepareOutputs()
    }
    
    private func setupUI() {
        //setup  chosen timeline by analytics type
        timeFrom = (analyticsTimeline == .hourlyActiveReport) ? TimeUnitsEnum.Today.getTimestamp : (analyticsTimeline == .monthlyActiveReport) ? TimeUnitsEnum.thisYear.getTimestamp : TimeUnitsEnum.Last7Days.getTimestamp
        
        dataTableView.register(cell: AnalyticsTableViewCell.self)
        dataTableView.dataSource = self
        dataTableView.delegate = self
        
        timelineCollection.dataSource = self
        timelineCollection.delegate = self
        timelineCollection.showsHorizontalScrollIndicator = false
        timelineCollection.setCollectionHotizontalFlowLayoutWithSpacing()
        
        barChart.delegate = self
        
        self.navigationItem.largeTitleDisplayMode = .never
        self.setupSegmentControl()
        
        guard let title = title else {
            return
        }
        analyticsTimeline = AnalyticsTimelineEnum(rawValue: title)
    }
    
    private func prepareInputs() {
        viewModel?.inputs.prepareChart(barChart: self.barChart)
    }
    
    private func prepareOutputs() {
        self.barChart = viewModel?.outputs.barChart ?? BarChartView()
        viewModel?.outputs.totalValue = { (totalValue) in
            DispatchQueue.main.async {
                self.totalValue = totalValue
                self.dataTableView.reloadData()
            }
        }
        self.dataTableView.reloadData()
        
        viewModel?.outputs.timestampsUnitsFetched = { [weak self] (timestamps, unit) in
            //get timestamps from touple
            self?.timestampsArray = timestamps
            //get unit from touple
            self?.units = unit
        }
    }
    
    override func viewDidLayoutSubviews() {
        barChart.frame = CGRect(x: 0, y: 0, width: chartView.frame.width, height: chartView.frame.height)
        self.chartView.addSubview(self.barChart)
//        self.timelineCollection.selectItem(at: IndexPath(row: 0, section: 0), animated: true, scrollPosition: .left)
    }
    
    
    private func setupSegmentControl() {
        guard let title = title else {
            return
        }
        let currentCategory = AnalyticsTimelineEnum(rawValue: title)
        guard let segments = currentCategory?.segments else { return }
        
        outputSegmentControl.removeAllSegments()
        for (index, segment) in segments.enumerated() {
            self.outputSegmentControl.insertSegment(withTitle: segment, at: index, animated: false)
        }
        outputSegmentControl.selectedSegmentIndex = 0
    }
    
    //MARK: Overriden functions
    override func showDetailOverlay(value: String, time: Double, timeFormat: TimeFormat, unit: String) {
        super.showDetailOverlay(value: value, time: time, timeFormat: timeFormat, unit: unit)
    }
    
    //MARK: IBA actions
    @IBAction func energyOutputSegmentPressed(_ sender: UISegmentedControl) {
        let segmentValue = sender.titleForSegment(at: sender.selectedSegmentIndex)
        guard let segmentValue = segmentValue else {return}
        
//        self.removeSpinner()
        self.showSpinner(onView: barChart)

        self.energyDataType = segmentValue
    }
    
    //MARK: Instantiation
    static func instantiate() -> Self{
        let vc =  UIStoryboard(name: "AnalyticsDataView", bundle: nil).instantiateViewController(withIdentifier: "AnalyticsDataViewController") as! Self
        return vc
    }
}

extension AnalyticsDataViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        guard let segmentCount = analyticsTimeline?.segments else { return 0 }
        
        return (tableView.frame.height / CGFloat(segmentCount.count + 1))
    }
}

extension AnalyticsDataViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        "Outputs info"
    }
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return analyticsTimeline?.segments.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "AnalyticsTableViewCell", for: indexPath) as? AnalyticsTableViewCell
        cell?.mainLabel.text = analyticsTimeline?.segments[indexPath.row]
        cell?.setupCellUI(cellText: cell?.mainLabel.text ?? "")
        if totalValue.count != 0{
            if cell?.mainLabel.text == totalValue[indexPath.row].0{
                cell?.valueLabel.text = String(totalValue[indexPath.row].1)
            }
        }
        return cell ?? UITableViewCell()
    }
}


extension AnalyticsDataViewController: UICollectionViewDataSource{

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let title = title else { return UICollectionViewCell() }
        let cellText = AnalyticsTimelineEnum(rawValue: title)?.timelineCells[indexPath.row].rawValue
        
        let collectionViewCell: AnalyticsTimelineCell = timelineCollection.dequeueReusableCell(withReuseIdentifier: "AnalyticsTimelineCell", for: indexPath) as! AnalyticsTimelineCell
        collectionViewCell.setupCellUI(cellText: cellText ?? "")
        
        if indexPath.row == selectedTimelineCellIdx {
            collectionViewCell.setupBackgroundAsSelected(type: .analyticsTimeline)
        }
        
        return collectionViewCell
     
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard let title = title else { return 0 }

        let timelineCells = AnalyticsTimelineEnum(rawValue: title)?.timelineCells
        return timelineCells?.count ?? 0
    }
}

extension AnalyticsDataViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let screenViewWidth = UIScreen.main.bounds.width
        let collectionViewHeight = collectionView.frame.size.height
        return CGSize(width: screenViewWidth/3.0, height: collectionViewHeight)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        selectedTimelineCellIdx = indexPath.row
        
        let currentCell = timelineCollection.cellForItem(at: indexPath) as! AnalyticsTimelineCell
        guard let currentCellText = currentCell.cellLabel.text else { return }
        
        let chosenTimeInterval: TimeUnitsEnum = TimeUnitsEnum(rawValue: currentCellText) ?? .Today
        
        if chosenTimeInterval == .Yesterday {
            timeTo = TimeUnitsEnum.Today.getTimestamp
        } else if chosenTimeInterval == .lastYear {
            timeTo = TimeUnitsEnum.thisYear.getTimestamp
        } else {
            timeTo = Date().currentTimeInTimeStampAsString
        }
        
//        timeTo = (chosenTimeInterval == .Yesterday) ? TimeUnitsEnum.Today.getTimestamp : Date().currentTimeInTimeStampAsString
        

        if chosenTimeInterval == .custom {
            let vc = UIStoryboard(name: "CalendarPickerModal", bundle: nil).instantiateViewController(withIdentifier: "CalendarPickerViewController") as? CalendarPickerViewController
            vc?.delegate = self
            vc?.modalPresentationStyle = .overCurrentContext
            self.navigationController?.present(vc ?? UIViewController(), animated: true, completion: nil)
        } else {
            timeFrom = chosenTimeInterval.getTimestamp
        }
    }
}

extension AnalyticsDataViewController: CalendarPickerViewControllerDelegate {
    func submitButtonPressed(timeFrom: String, timeTo: String) {
        self.timeFrom = timeFrom
    }
}
//MARK: Chart view Delegate
extension AnalyticsDataViewController: ChartViewDelegate {
    func chartValueSelected(_ chartView: ChartViewBase, entry: ChartDataEntry, highlight: Highlight) {
        
        if !timestampsArray.isEmpty, units != ""{
            showDetailOverlay(value: String(entry.y),
                             time: timestampsArray[Int(entry.x)] / 1000,
                             timeFormat: analyticsTimeline?.chartDetailTimeFormat ?? .daysMonths,
                             unit: units)
        }
    }
}


