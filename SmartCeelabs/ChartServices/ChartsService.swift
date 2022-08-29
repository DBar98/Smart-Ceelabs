//
//  ChartModels.swift
//  SmartCeelabs
//
//  Created by Dávid Baľak on 14/07/2021.
//

import Foundation
import Charts
import UIKit

struct ChartsModel {

    func prepareLineChart(lineChart: LineChartView, usedPercents: Bool) -> LineChartView {
        
        lineChart.drawGridBackgroundEnabled = false
        lineChart.legend.enabled = false
        lineChart.rightAxis.drawLabelsEnabled = false
        lineChart.xAxis.drawGridLinesEnabled = false
        lineChart.leftAxis.drawGridLinesEnabled = true
        lineChart.rightAxis.axisLineWidth = 0
        lineChart.leftAxis.axisLineWidth = 0
        lineChart.xAxis.granularityEnabled = true
        lineChart.xAxis.labelPosition = .bottom
        lineChart.xAxis.axisLineWidth = 2
        
        if usedPercents {
            lineChart.leftAxis.axisMaximum = 100
        }
        
        return lineChart
    }
    
    func updateLineChartWithMultipleLines(arrayOfProfileChartDataStructs: [ProfileChartData], lineChart: LineChartView, units: String, usingEpoch: Bool) {
        //Definition of axis formmaters
       
        if arrayOfProfileChartDataStructs.count == 0 {
            lineChart.data = .none
            lineChart.noDataText = "No data to show"
            return
        }
        
        let yAxisFormatter = YAxisValueFormatter(unit: units)
        
        let xAxisFormatter = ChartXAxisFormatter()
        xAxisFormatter.useEpochTimestamp = usingEpoch
        
        let xAxisFormatterForHours = ChartXAxisFormatterForHours()
        xAxisFormatterForHours.useEpochTimestamp = usingEpoch
        
        var arrayOfDataSets: [LineChartDataSet] = []
                
        for doubleArray in arrayOfProfileChartDataStructs{
            var entries = [ChartDataEntry]()
            
            for ( _,row) in doubleArray.arrayOfValues.enumerated(){
                for (_, _) in row.enumerated() {
                    entries.append(ChartDataEntry(x: Double(row[0]), y: Double(row[1].rounded(toPlaces: 1))))
                }
            }
            arrayOfDataSets.append(LineChartDataSet(entries: entries, label: doubleArray.phaseName))
            entries.removeAll()
        }
        
        self.designLinesInChart(dataSets: arrayOfDataSets)
        
//        Compare earliest date from incomming data and yesterday 00:00 to adjust xAxis intervals
        if arrayOfDataSets.count != 0 {
            if arrayOfDataSets[0].xMin > Calendar.current.date(byAdding: .hour, value: -48, to: Date())!.timeIntervalSince1970*1000 {
                lineChart.xAxis.valueFormatter = xAxisFormatterForHours
                } else {
                lineChart.xAxis.valueFormatter = xAxisFormatter
            }
        }
        
        lineChart.leftAxis.valueFormatter = yAxisFormatter
        lineChart.data = LineChartData(dataSets: arrayOfDataSets)
    }
    
    /**
            LINE CHART FOR REAL TIME DATA PURPOSES
     */
    func prepareRealTimeLineChartWithMultipleLines(lineChart: LineChartView) -> LineChartView{
        lineChart.drawGridBackgroundEnabled = false
        lineChart.legend.enabled = false
        lineChart.rightAxis.drawLabelsEnabled = false
        lineChart.xAxis.drawGridLinesEnabled = false
        lineChart.leftAxis.drawGridLinesEnabled = true
        lineChart.rightAxis.axisLineWidth = 0
        lineChart.leftAxis.axisLineWidth = 0
        lineChart.xAxis.granularityEnabled = true
        lineChart.xAxis.labelPosition = .bottom
        lineChart.xAxis.axisLineWidth = 2
        
        return lineChart
    }
    
    //MARK: - UPDATE REAL TIME CHARTS
    func updateRealTimeChartEntries(realTimeDetailsChartResponse: RealTimeDetailsEnumResponse, arrayOfChosenPhases: [String], lineChart: LineChartView, units: String){
        //Definition of axis formmaters
        let yAxisFormatter = YAxisValueFormatter(unit: units)
        let xAxisFormatterHMS = ChartXAxisFormatterHoursMinutesSeconds()
        
        var arrayOfDataSets: [LineChartDataSet] = []
        
        if arrayOfChosenPhases.count == 0 {
            lineChart.data = .none
            lineChart.noDataText = "No data to show"
        }
        
        for phaseName in arrayOfChosenPhases {
            var entries = [ChartDataEntry]()
            var phaseDataStruct: RealTimeDetailsChartResponse
            
            do {
                phaseDataStruct = try realTimeDetailsChartResponse.getRealTimeDataByPhaseName(phaseName: phaseName)
                for (_, phaseStructTimeAndData) in phaseDataStruct.timestampAndDataDoubleAray.enumerated() {
                    for (_,_) in phaseStructTimeAndData.enumerated() {
                        entries.append(ChartDataEntry(x: phaseStructTimeAndData[0], y: phaseStructTimeAndData[1]))
                    }
                }
                arrayOfDataSets.append(LineChartDataSet(entries: entries, label: phaseDataStruct.phaseName))
                entries.removeAll()
            } catch {
                print(error.localizedDescription)
            }
        }
        
        self.designLinesInChart(dataSets: arrayOfDataSets)
        
        if !arrayOfDataSets.isEmpty{
            lineChart.xAxis.valueFormatter = xAxisFormatterHMS
        }
        
        lineChart.leftAxis.valueFormatter = yAxisFormatter
        lineChart.data = LineChartData(dataSets: arrayOfDataSets)
    }
    
    private func designLinesInChart(dataSets: [LineChartDataSet]){
        
        for dataSet in dataSets{
            
            dataSet.drawCirclesEnabled = false
            dataSet.drawValuesEnabled = false
            
            guard dataSet.label != nil else {return}
            if (dataSet.label == "L1"){
                dataSet.setColor(UIColor(red: 0, green: 188, blue: 212))
            } else if (dataSet.label == "L2"){
                dataSet.setColor(UIColor(red: 244, green: 67, blue: 54))
            } else if (dataSet.label == "L3"){
                dataSet.setColor(UIColor(red: 76, green: 175, blue: 80))
            } else {
                dataSet.setColor(UIColor(red: 0, green: 188, blue: 212))
                dataSet.fillColor = (UIColor(red: 0, green: 188, blue: 212))
                dataSet.drawFilledEnabled = true
                dataSet.drawCirclesEnabled = true
                dataSet.drawValuesEnabled = true
            }
        }
    }
    
    func prepareBarChart(barChart: BarChartView) -> BarChartView{
        barChart.data = .none
        barChart.noDataText = "No data to display"
        barChart.xAxis.drawGridLinesEnabled = false
//        barChart.setVisibleXRangeMaximum(30)
        barChart.leftAxis.axisMinimum = 0
        barChart.rightAxis.drawLabelsEnabled = false
        barChart.barData?.barWidth = 0.3
        barChart.leftAxis.drawGridLinesEnabled = false
        barChart.rightAxis.drawGridLinesEnabled = false
        barChart.drawGridBackgroundEnabled = false
        barChart.xAxis.drawGridLinesBehindDataEnabled = false
        barChart.xAxis.labelPosition = .bottom
        barChart.rightAxis.axisLineWidth = 0
        barChart.xAxis.drawLabelsEnabled = false
        barChart.legend.enabled = false
        
        return barChart
    }
   
    func prepareBarChartData(fetchedData: [ChartDatasetStruct]) -> BarChartData? {
        var dataSet: BarChartDataSet
        var dataSets: [BarChartDataSet] = []
        var entries = [BarChartDataEntry]()
        
        for (idx1, energyArray) in fetchedData.enumerated() {
            
//            guard let energyArrayData = energyArray.energyData else {return nil}
            guard let energyArrayData = energyArray.consumptionData else { return nil }
            
            for ( index ,row) in energyArrayData.enumerated(){
                entries.append(BarChartDataEntry(x: Double(index), y: Double(row[1])))
            }
            dataSet = BarChartDataSet(entries: entries)
            dataSet.drawValuesEnabled = false
            
            switch energyArray.labelName {
            case .energyImport:
                dataSet.setColor(UIColor(red: 43, green: 134, blue: 33))
            case .none:
                dataSet.setColor(UIColor(red: 77, green: 134, blue: 33))
            case .energyExport:
                dataSet.setColor(UIColor(red: 9, green: 66, blue: 56))
            case .Q1:
                dataSet.setColor(UIColor(red: 11, green: 134, blue: 211))
            case .Q2:
                dataSet.setColor(UIColor(red: 111, green: 134, blue: 155))
            case .Q3:
                dataSet.setColor(UIColor(red: 123, green: 2, blue: 4))
            case .Q4:
                dataSet.setColor(UIColor(red: 220, green: 134, blue: 9))
            }
            
            dataSets.append(dataSet)
        
        }
        return BarChartData(dataSets: dataSets)
    }
    
    //MARK: - UPDATE BAR CHARTS
    func updateBarChartData(fetchedData: [ChartDatasetStruct], chart: BarChartView, units: String, stacked: Bool) {
        var dataSet: BarChartDataSet
        var dataSets: [BarChartDataSet] = []
        var entries = [BarChartDataEntry]()
        let yAxisFormatter = YAxisValueFormatter(unit: units)
        let xAxisFormatter = BarChartXAxisFormatter()
        
        //check if data available
        if fetchedData.count == 0 {
            chart.data = .none
            chart.noDataText = "No data to show"
            return
        }
        
        if stacked {
                for (idx1, energyArray) in fetchedData.enumerated() {
                    
                    guard let energyArrayData = energyArray.consumptionData else { return }
                    
                    let time: Double = Date(timeIntervalSince1970: energyArray.consumptionData?[0][0] ?? 0).timeIntervalSince1970
                    xAxisFormatter.values.append(time)
                    entries.append(BarChartDataEntry(x: Double(idx1), yValues:[energyArray.consumptionData?[0][1] ?? 0, energyArray.consumptionData?[1][1] ?? 0]))
            
                    dataSet = BarChartDataSet(entries: entries)
                    dataSet.drawValuesEnabled = false
                    dataSet.colors =  [UIColor(red: 76, green: 175, blue: 80), UIColor(red: 255, green: 87, blue: 34)]
                    
                    dataSets.append(dataSet)
                }
        } else {
        
        for (idx1, energyArray) in fetchedData.enumerated() {
            
            guard let energyArrayData = energyArray.consumptionData else { return }
            
            for ( index ,row) in energyArrayData.enumerated() {
                let time: Double = Date(timeIntervalSince1970: row[0]).timeIntervalSince1970/1000
                xAxisFormatter.values.append(time)
                entries.append(BarChartDataEntry(x: Double(index), y: Double(row[1])))
            }
            
            dataSet = BarChartDataSet(entries: entries)
            dataSet.drawValuesEnabled = false
            
            switch energyArray.labelName {
            case .energyImport:
                dataSet.setColor(UIColor(red: 43, green: 134, blue: 33))
            case .none:
                dataSet.setColor(UIColor(red: 77, green: 134, blue: 33))
            case .energyExport:
                dataSet.setColor(UIColor(red: 9, green: 66, blue: 56))
            case .Q1:
                dataSet.setColor(UIColor(red: 11, green: 134, blue: 211))
            case .Q2:
                dataSet.setColor(UIColor(red: 111, green: 134, blue: 155))
            case .Q3:
                dataSet.setColor(UIColor(red: 123, green: 2, blue: 4))
            case .Q4:
                dataSet.setColor(UIColor(red: 220, green: 134, blue: 9))
            }
            
            dataSets.append(dataSet)
        }
        }
        chart.leftAxis.valueFormatter = yAxisFormatter
        
        if !dataSets.isEmpty {
            chart.xAxis.valueFormatter = xAxisFormatter

        }
        chart.data = BarChartData(dataSets: dataSets)
        chart.xAxis.drawLabelsEnabled = true

    }

    //MARK: - UPDATE TIMELINE CHARTS
    func updateTimeLineCharts(timelineArray: [[Double]], chart: BarChartView){
        var dataSet: BarChartDataSet
        var dataSets: [BarChartDataSet] = []
        var entries = [BarChartDataEntry]()
        let xAxisFormmater = BarChartXAxisFormatter()
        let yForm = TimelineYAxisFormatter(unit: "min")

        
        //check if data available
        if timelineArray.count == 0 {
            chart.data = .none
            chart.noDataText = "No data to show"
            return
        }

        for (idx,timeInterval) in timelineArray.enumerated() {
            entries = []
            
            if timeInterval[2] == 1.0 {
                xAxisFormmater.values.append(timeInterval[0]/1000)
                entries.append(BarChartDataEntry(x: Double(idx/2), y: Double((timeInterval[1] - timeInterval[0]) / 1000)))
            }
           
            dataSet = BarChartDataSet(entries: entries, label: String(timeInterval[2]))
            dataSet.colors = [UIColor(red: 76, green: 175, blue: 80)]
            dataSets.append(dataSet)
        }
        
        if !dataSets.isEmpty {
//            chart.xAxis.valueFormatter = xAxisFormmater
            chart.leftAxis.valueFormatter = yForm
            chart.data = BarChartData(dataSets: dataSets)
            chart.xAxis.drawLabelsEnabled = true
            chart.barData?.setDrawValues(false)
            chart.leftAxis.granularity = 10
        }

//
//        let yForm = TimelineYAxisFormatter(unit: "s")
//
//        var dataEntries1: [BarChartDataEntry] = []
//        var indexes:[Double] = []
////            for i in 0..<timelineArray.count {
//        for (idx,i) in timelineArray.enumerated() {
//            yForm.values.append((i[1] - i[0])/1000)
//            indexes.append(Double(idx))
//        }
//                let dataEntry1 = BarChartDataEntry(x: Double(1),yValues: indexes, data: "Points")
//                   dataEntries1.append(dataEntry1)
////               }
//
//               let chartDataSet1 = BarChartDataSet(entries: dataEntries1, label: "Points")
//               chartDataSet1.barBorderColor = .red
//               chartDataSet1.stackLabels = ["Points", "Scans","d","e"]
//        chartDataSet1.colors =  [UIColor.darkGray, UIColor.lightGray, .blue, .red]
//
//               let chartData = BarChartData(dataSets: [chartDataSet1])
//
////               let chartFormatter = BarChartFormatter(labels: xValues)
////               let xAxis = XAxis()
////               xAxis.valueFormatter = chartFormatter
////               self.xAxis.valueFormatter = xAxis.valueFormatter
//        chart.data = chartData
////        chart.leftAxis.valueFormatter = yForm
    }
    
    //MARK: - UPDATE PIE CHART
    func updatePieChart(chart: PieChartView, data: [ProfileChartData]) {
        
        var colorArray: [UIColor] = []
        var entries = [PieChartDataEntry]()
        
        for chartData in data {
            for value in chartData.arrayOfValues {
                
                let entry = PieChartDataEntry()
                let date = Date(timeIntervalSince1970: value[0])
                entry.label = date.getFormattedDate(format: "HH:mm")
                entry.x = value[0]
                entry.y = value[1]
                colorArray.append(setColor(value: value[1]))
                entries.append( entry)
            }
        }

        // 3. chart setup
        let set = PieChartDataSet( entries: entries, label: "Pie Chart")
        
        // this is custom extension method. Download the code for more details.
        let colors: [UIColor] = colorArray

        set.colors = colors
        let data = PieChartData(dataSet: set)
        chart.data = data
        chart.noDataText = "No data available"
        // user interaction
        chart.isUserInteractionEnabled = true
        chart.legend.enabled = false
        chart.holeRadiusPercent = 0.1
        chart.transparentCircleColor = UIColor.clear
        set.drawValuesEnabled = false
        set.sliceSpace = 1
        set.entryLabelFont = UIFont(name: "HelveticaNeue-Light", size: 10)

    }
    
    func setColor(value: Double) -> UIColor{

        if(value < 100){
            return UIColor.red
        }
        else
        {
            return UIColor(red: 43, green: 134, blue: 33)
        }
    }
    
}
