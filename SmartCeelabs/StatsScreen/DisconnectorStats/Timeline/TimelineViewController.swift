//
//  TimelineViewController.swift
//  SmartCeelabs
//
//  Created by Dávid Baľak on 05/03/2022.
//

import UIKit
import Charts

class TimelineViewController: ContainerViewController {
    
    @IBOutlet weak var chartView: UIView!
    @IBOutlet weak var relaySegment: UISegmentedControl!
    @IBOutlet weak var timelineCollection: UICollectionView!
    
    var viewModel: TimelineViewModelType?
    var disconnector: DisconnectorModel?
    var barChart = BarChartView()
    
    var selectedTimelineCell: Int = 0 {
        didSet(previousIndex) {
            let previousSelected = timelineCollection.cellForItem(at: IndexPath.init(row: previousIndex, section: 0)) as? TimelineCollectionViewCell
            if previousIndex != selectedTimelineCell {
                previousSelected?.setupBackgroundAsDeselected(type: .disconnectorTimeline)
            }
        }
    }
    
    var timeFrom: String = TimeUnitsEnum.Today.getTimestamp
//        {
//            didSet {
//                viewModel?.inputs.fetchEnergyData(timeFrom: self.timeFrom, timeTo: self.timeTo, barChart: self.barChart, relayIndex: chosenRelayIdx)
//            }
//        }
    
    var timeTo: String = Date().currentTimeInTimeStampAsString
//    {
//        didSet{
//            viewModel?.inputs.fetchEnergyData(timeFrom: self.timeFrom, timeTo: self.timeTo, barChart: self.barChart, relayIndex: chosenRelayIdx)
//        }
//    }
    
    var chosenRelayIdx: Int = 0 {
        didSet {
            print(timeFrom)
            print(TimeUnitsEnum.Yesterday.getTimestamp)
            if timeFrom == TimeUnitsEnum.Yesterday.getTimestamp {
                viewModel?.inputs.fetchEnergyData(timeFrom: self.timeFrom, timeTo: TimeUnitsEnum.Today.getTimestamp, barChart: self.barChart, relayIndex: chosenRelayIdx)
            } else {
                viewModel?.inputs.fetchEnergyData(timeFrom: self.timeFrom, timeTo: Date().currentTimeInTimeStampAsString, barChart: self.barChart, relayIndex: chosenRelayIdx)
            }
        }
    }
    
    var timestampsArray: [Double] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupInputs()
        self.setupOutputs()
        self.setupUI()
    }
    
    private func setupInputs() {
        viewModel?.inputs.prepareChart(barChart: barChart)
        viewModel?.inputs.fetchDisconnector()
        viewModel?.inputs.fetchEnergyData(timeFrom: timeFrom, timeTo: timeTo, barChart: barChart, relayIndex: chosenRelayIdx)
    }
    
    private func setupOutputs() {
        viewModel?.outputs.onDisconnectorFetch = {[weak self] (disconnectorModel) in
            self?.disconnector = disconnectorModel
            self?.setupSegmentControl()
        }
        
        viewModel?.outputs.onTimeArrayFetch = { [weak self] timeArray in
            self?.timestampsArray = timeArray
        }
        
    }
    
    override func viewDidLayoutSubviews() {
        barChart.frame = CGRect(x: 0, y: 0, width: chartView.frame.width, height: chartView.frame.height)
        self.chartView.addSubview(self.barChart)
    }
    
    private func setupUI() {
        barChart.delegate = self
        setupTimelineCollection()
        setupSegmentControl()
    }
    
    private func setupSegmentControl() {
        relaySegment.removeAllSegments()
        guard let disconnector = disconnector else {
            return
        }
        
        for idx in 0...3 {
            self.relaySegment.insertSegment(withTitle:disconnector.getRelayByIndexNumber(index: idx).name, at: idx, animated: false)
        }
        relaySegment.selectedSegmentIndex = 0
    }
    
    private func setupTimelineCollection() {
        self.timelineCollection.delegate = self
        self.timelineCollection.dataSource = self
        self.timelineCollection.register(UINib(nibName: "TimelineCell", bundle: nil), forCellWithReuseIdentifier: "TimelineCollectionViewCell")
        self.timelineCollection.setCollectionHotizontalFlowLayoutWithSpacing()
        
        self.timelineCollection.showsHorizontalScrollIndicator = false
    }
    
    private func showDetailOverlay(value: String, time: Double, timeFormat: TimeFormat, unit: String) {
        let slideVC = DataDetailViewController()
        slideVC.time = time
        slideVC.value = value
        slideVC.timeFormat = timeFormat
        slideVC.unit = unit
                
        slideVC.modalPresentationStyle = .custom
        slideVC.transitioningDelegate = self
        self.present(slideVC, animated: true, completion: nil)
    }
    
    private func executeFetch() {
        viewModel?.inputs.fetchEnergyData(timeFrom: self.timeFrom, timeTo: self.timeTo, barChart: self.barChart, relayIndex: chosenRelayIdx)
    }

    
    static func instantiate() -> Self {
        return UIStoryboard(name: "Timeline", bundle: nil).instantiateViewController(withIdentifier: "TimelineViewController") as! Self
    }
    
    @IBAction func relaySegmentPressed(_ sender: UISegmentedControl) {
        chosenRelayIdx = sender.selectedSegmentIndex
    }
}

//MARK: - UICollectionViewDataSource
extension TimelineViewController: UICollectionViewDataSource{
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let collectionViewCell: TimelineCollectionViewCell = timelineCollection.dequeueReusableCell(withReuseIdentifier: "TimelineCollectionViewCell", for: indexPath) as! TimelineCollectionViewCell
        let cellText = AnalyticsTimelineEnum.hourlyActiveReport.timelineCells[indexPath.row].rawValue
        collectionViewCell.setupCellUI(cellText: cellText)
        
        if indexPath.row == selectedTimelineCell {
            collectionViewCell.setupBackgroundAsSelected(type: .disconnectorTimeline)
        }
        return collectionViewCell
        
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let timelineCells = AnalyticsTimelineEnum.hourlyActiveReport.timelineCells
        return timelineCells.count
    }
}

//MARK: - UICollectionViewDelegateFlowLayout
extension TimelineViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let screenViewWidth = UIScreen.main.bounds.width
        let collectionViewHeight = collectionView.frame.size.height
        return CGSize(width: screenViewWidth/3.0, height: collectionViewHeight)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let currentCell = timelineCollection.cellForItem(at: indexPath) as! TimelineCollectionViewCell
        selectedTimelineCell = indexPath.row
        
        guard let currentCellText = currentCell.timeIntervalLabel.text else { return }
        
        let chosenTimeInterval: TimeUnitsEnum = TimeUnitsEnum(rawValue: currentCellText) ?? .Today
        timeFrom = chosenTimeInterval.getTimestamp
        
        if currentCellText.elementsEqual("Yesterday") {
            timeTo = TimeUnitsEnum.Today.getTimestamp
            executeFetch()
        } else {
            timeTo = Date().currentTimeInTimeStampAsString
            executeFetch()
        }
        if chosenTimeInterval == .custom {
            let vc = UIStoryboard(name: "CalendarPickerModal", bundle: nil).instantiateViewController(withIdentifier: "CalendarPickerViewController") as? CalendarPickerViewController
            vc?.delegate = self
            vc?.modalPresentationStyle = .overCurrentContext
            self.navigationController?.present(vc ?? UIViewController(), animated: true, completion: nil)
        }
        /* Scroll cells when they are pressed*/
        timelineCollection.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
    }
}

//MARK: - CalendarPickerDelegate
extension TimelineViewController: CalendarPickerViewControllerDelegate {
    func submitButtonPressed(timeFrom: String, timeTo: String) {
        self.timeFrom = timeFrom
        self.timeTo = timeTo
        
        executeFetch()
    }
}

//MARK: - ChartDelegate/ ModalView
extension TimelineViewController: ChartViewDelegate {
    func chartValueSelected(_ chartView: ChartViewBase, entry: ChartDataEntry, highlight: Highlight) {
        let (h,m,s) = secondsToHoursMinutesSeconds( Int(entry.y) )
        
        if !timestampsArray.isEmpty {
            let hmsString = (h != 0) ?
                "\(h) Hours \(m) Min \(s) Sec" :  (m != 0) ?
                    "\(m) Min \(s) Sec" : "\(s) Sec"
            showDetailOverlay(value: hmsString, time: timestampsArray[ Int(entry.x) ] / 1000, timeFormat: .hoursMinutes, unit: "Spent Time")
        }
    }
}

// MARK: -Transition view settings
extension TimelineViewController: UIViewControllerTransitioningDelegate {
    
    func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        let presentationVC = PresentationController(presentedViewController: presented, presenting: presenting)
        presentationVC.presentationHeight = .low
        
        return presentationVC
    }
    
    func secondsToHoursMinutesSeconds(_ seconds: Int) -> (Int, Int, Int) {
        return (seconds / 3600, (seconds % 3600) / 60, (seconds % 3600) % 60)
    }
}
