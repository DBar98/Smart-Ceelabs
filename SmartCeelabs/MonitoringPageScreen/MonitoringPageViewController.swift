//
//  PageVC.swift
//  PageControllerTutorial
//
//  Created by Chris Larsen on 5/30/19.
//  Copyright © 2019 Tiger Bomb. All rights reserved.
//

import UIKit
import Charts

class MonitoringPageViewController: DetailedChartViewController {
    @IBOutlet weak var popupButton: UIButton!
    
    var viewModel: MonitoringPageViewModelType?
    
    var barChart = BarChartView()
    var lineChart = LineChartView()
    var pieChart = PieChartView()
    
    @IBOutlet weak var chartView: UIView!
    
    @IBOutlet weak var pageTitle: UILabel!
    var page: Pages?
    
    var timeFrom: String = ""
    {
        didSet {
            viewModel?.inputs.getPercentageAvailability(timeFrom: timeFrom,
                                                        timeTo: (timeFrom == TimeUnitsEnum.Yesterday.getTimestamp) ? TimeUnitsEnum.Today.getTimestamp : Date().currentTimeInTimeStampAsString,
                                                        pages: page ?? .pageTwo,
                                                        lineChart: lineChart,
                                                        barChart: barChart,
                                                        pieChart: pieChart)
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        pageTitle.text = page?.name
        self.setupInputs()
        self.setupUI()
        self.setupButton(page: self.page ?? .pageOne)
        
        self.lineChart.delegate = self
    }
    
    private func setupInputs() {
        viewModel?.inputs.prepareLineChart(chart: lineChart)
        viewModel?.inputs.prepareBarChart(chart: barChart)
        viewModel?.inputs.preparePieChart(chart: pieChart)
        
        self.timeFrom = (page?.index == 1) ? TimeUnitsEnum.Today.getTimestamp : TimeUnitsEnum.Last7Days.getTimestamp
        
        viewModel?.inputs.getPercentageAvailability(timeFrom: self.timeFrom,
                                                    timeTo: (timeFrom == TimeUnitsEnum.Yesterday.getTimestamp) ? TimeUnitsEnum.Today.getTimestamp : Date().currentTimeInTimeStampAsString,
                                                    pages: page ?? .pageTwo,
                                                    lineChart: lineChart,
                                                    barChart: barChart,
                                                    pieChart: pieChart)
    }
    
    private func setupUI() {
        barChart.delegate = self
        pieChart.delegate = self
    }
    
    func setupButton(page: Pages) {
        
        let actions: [UIAction] = page.timeInterval.map { (interval) in
            UIAction(title: interval.rawValue, image: nil) { _ in
                if interval.rawValue == "Custom Interval" {
                    let vc = UIStoryboard(name: "CalendarPickerModal", bundle: nil).instantiateViewController(withIdentifier: "CalendarPickerViewController") as? CalendarPickerViewController
                    vc?.delegate = self
                    vc?.modalPresentationStyle = .overCurrentContext
                    self.navigationController?.present(vc ?? UIViewController(), animated: true, completion: nil)
                } else {
                    self.timeFrom = interval.getTimestamp
                }
            }
        }

        let menu = UIMenu(title: "Select time", options: .displayInline, children: actions)
        
        popupButton.menu = menu
        popupButton.setTitle("", for: .selected)
    }
    
    
    override func viewDidLayoutSubviews() {
        barChart.frame = CGRect(x: 0, y: 0, width: chartView.frame.width, height: chartView.frame.height)
        lineChart.frame = CGRect(x: 0, y: 0, width: chartView.frame.width, height: chartView.frame.height)
        pieChart.frame = CGRect(x: 0, y: 0, width: chartView.frame.width, height: chartView.frame.height)

        switch page {
        case.pageZero :
            self.chartView.addSubview(self.barChart)
        case .none:
            self.chartView.addSubview(self.barChart)
        case .pageOne:
            self.chartView.addSubview(self.pieChart)
        case .pageTwo:
            self.chartView.addSubview(self.lineChart)
        }

    }
    
    //MARK: Overriden functions
    override func showDetailOverlay(value: String, time: Double, timeFormat: TimeFormat, unit: String) {
        super.showDetailOverlay(value: value, time: time, timeFormat: timeFormat, unit: unit)
    }
    
    static func instantiate() -> Self {
        return UIStoryboard(name: "MonitoringPageView", bundle: nil).instantiateViewController(withIdentifier: "MonitoringPageViewController") as! Self
    }
}

extension MonitoringPageViewController: ChartViewDelegate {
    func chartValueSelected(_ chartView: ChartViewBase, entry: ChartDataEntry, highlight: Highlight) {
        if chartView == pieChart {
//            let date = Date(timeIntervalSince1970: entry.x)
            showDetailOverlay(value: String(format: "%.1f", entry.y), time: entry.x, timeFormat: .hoursMinutes, unit: "%")
        }
    }
}

extension MonitoringPageViewController: CalendarPickerViewControllerDelegate {
    func submitButtonPressed(timeFrom: String, timeTo: String) {
//        when pie chart showed, use just one day difference
        if page == .pageOne {
            let timeToDate = Date(timeIntervalSince1970: Double(timeFrom) ?? 0.0).startOfDay
            let tommorow = Calendar.current.date(byAdding: .day, value: 1, to: timeToDate)

            if let tommorow = tommorow {
                var customTimeTo = String(tommorow.timeIntervalSince1970)

                viewModel?.inputs.getPercentageAvailability(timeFrom: timeFrom,
                                                            timeTo: customTimeTo,
                                                            pages: page ?? .pageTwo,
                                                            lineChart: lineChart,
                                                            barChart: barChart,
                                                            pieChart: pieChart)
            }
        } else {
            let startOfDay = Date(timeIntervalSince1970: Double(timeFrom) ?? 0.0).startOfDay
            self.timeFrom = String(startOfDay.timeIntervalSince1970)
        }
    }
}
