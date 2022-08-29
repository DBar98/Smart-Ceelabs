//
//  RealTimeDetailsViewController.swift
//  SmartCeelabs
//
//  Created by Dávid Baľak on 02/12/2021.
//

import UIKit
import Charts

class RealTimeDetailsViewController: ContainerViewController, URLSessionWebSocketDelegate, ChartViewDelegate {
    @IBOutlet weak var realTimeDetailsSubtitle: UILabel!
    @IBOutlet weak var realTimeDetailsTitle: UINavigationItem!
    @IBOutlet weak var realTimeDetailsChartView: UIView!
    @IBOutlet weak var realTimeDetailsPhaseCollection: UICollectionView!
    
    override var title: String? {
        didSet{
            navigationItem.title = title
        }
    }
    
    var viewModel: RealTimeViewModel?
    var phasesToDataDisplayArray: [String] = []
    weak var timer: Timer?
    
    var lineChart = LineChartView()
    var chartsModel = ChartsModel()
    var designatedChart: LineChartView?
    

    override func viewDidLoad() {
        setupUI()
        viewModel?.inputs.viewDidLoad()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(refreshRealTimeData), userInfo: nil, repeats: true)
        
        viewModel?.inputs.fetchDataFromWebSocket()

    }
    
    override func viewDidDisappear(_ animated: Bool) {
        viewModel?.stopFetchingDataFromWebSocket()
        timer?.invalidate()
    }
    
    override func viewDidLayoutSubviews() {
        self.lineChart.delegate = self
        self.lineChart.frame = CGRect(x: 0, y: 0, width: realTimeDetailsChartView.frame.size.width, height: realTimeDetailsChartView.frame.size.height)
        self.designatedChart = self.chartsModel.prepareRealTimeLineChartWithMultipleLines(lineChart: self.lineChart)
        self.realTimeDetailsChartView.addSubview(designatedChart!)
    }
    
    private func setupUI() {
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout.minimumInteritemSpacing = 15
        layout.minimumLineSpacing = 8
        layout.scrollDirection = .horizontal
        
        realTimeDetailsPhaseCollection.delegate = self
        realTimeDetailsPhaseCollection.dataSource = self
        realTimeDetailsPhaseCollection.allowsMultipleSelection = true
        realTimeDetailsPhaseCollection.collectionViewLayout = layout
        
        
        navigationController?.navigationBar.prefersLargeTitles = false
    }
    
    @objc private func refreshRealTimeData(){
        /*Chcek if view controller title is not nil*/
        guard let viewControllerTitle = self.realTimeDetailsTitle.title else {return}
        var webSocketDataType: RealTimeDetailsEnum
        /*Try convert title to RealTimeDetailsEnum and get its return type*/
        do {
            webSocketDataType = try RealTimeDetailsModel.getEnumTypeByGivenString(type: viewControllerTitle.uppercased(), webSocketArrayToParse: webSocketResponsesArray)
            viewModel?.inputs.updateRealTimeChart(data: webSocketDataType.arrayFromWebSocketResponese, phasesArray: self.phasesToDataDisplayArray, lineChart: self.lineChart, title: viewControllerTitle)
        } catch {
            print(RealTimeDetailsCustomExceptions.wrongEnumValue)
        }
    }
    
    static func instantiate() -> Self {
        UIStoryboard(name: "RealTimeView", bundle: nil).instantiateViewController(withIdentifier: "RealTimeDetailsViewController") as! Self
    }
}

extension RealTimeDetailsViewController: UICollectionViewDataSource{
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let realTimeDetailsCell: RealTimeDetailsCollectionViewCell = realTimeDetailsPhaseCollection.dequeueReusableCell(withReuseIdentifier: "RealTimeDetailsCollectionViewCell", for: indexPath) as! RealTimeDetailsCollectionViewCell
        //Set phases numbers depending on available phases of chosen device
        realTimeDetailsCell.setupCellUI(index: indexPath)
//        realTimeDetailsCell.realTimeDetailsCellLabel.text = chosenRealTimeDevice.getAvailablePhases()[indexPath.row]
//        realTimeDetailsCell.setupCellLabel(with: realTimeDetailsCell.realTimeDetailsCellLabel)
        //Set cell view color
//        realTimeDetailsCell.setupCellView(with: realTimeDetailsCell.realTimeDetailsCellView, uiColor: UIColor(red: 193, green: 207, blue: 192))
        
        realTimeDetailsCell.parentVC = self
        
        return realTimeDetailsCell
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel?.outputs.numerOfAvailablePhases ?? 1
    }
}

extension RealTimeDetailsViewController: UICollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        //get selected phases
        self.phasesToDataDisplayArray.removeAll()
        for indexPath in collectionView.indexPathsForSelectedItems!{
            let selectedCell = collectionView.cellForItem(at: indexPath) as! RealTimeDetailsCollectionViewCell
            //Parsing Phase num.
            guard let cellTextToWords = selectedCell.realTimeDetailsCellLabel.text else {return}
            let phaseNumber = String(cellTextToWords.byWords.last ?? "")
            //Fetch data by chosen time unit and display them
            phasesToDataDisplayArray.append(phaseNumber)
        }
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let screenViewWidth = UIScreen.main.bounds.width
        let collectionViewHeight = collectionView.frame.size.height
        
        return CGSize(width: screenViewWidth / CGFloat(viewModel?.outputs.numerOfAvailablePhases ?? 1), height: collectionViewHeight / 2)
    }
}
