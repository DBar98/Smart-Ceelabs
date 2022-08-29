//
//  MonitoringViewController.swift
//  SmartCeelabs
//
//  Created by Dávid Baľak on 08/03/2022.
//

import UIKit
import Charts

enum Pages: CaseIterable {
    case pageZero
    case pageOne
    case pageTwo
    
    var name: String {
        switch self {
        case .pageZero:
            return "Percentage availability"
        case .pageOne:
            return "Availability per 24 hours"
        case .pageTwo:
            return "Uptime"
    }
}
    
    var index: Int {
        switch self {
        case .pageZero:
            return 0
        case .pageOne:
            return 1
        case .pageTwo:
            return 2
        }
    }
    
    var timePeriod: String {
        switch self {
        case .pageZero:
            return "DAY"
        case .pageOne:
            return "HOUR"
        case .pageTwo:
            return "DAY"
        }
    }
    
    typealias type = TimeUnitsTypesEnum
    var timeInterval: [TimeUnitsEnum] {
        switch self {
        case .pageZero:
            return type.weekly.timeUnits
        case .pageOne:
            return type.oneDay.timeUnits
        case .pageTwo:
            return type.weekly.timeUnits
        }
    }
}

class MonitoringViewController: ContainerViewController {
    
    private var pageController: UIPageViewController?
    var viewModel: MonitoringViewModelType?

    private var pages: [Pages] = Pages.allCases
    private var currentIndex: Int = 0
    private var vcs: [UIViewController] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupInputs()

        self.view.backgroundColor = .lightGray
        self.setupPageViews()

        self.setupPageController()
    }
    
    private func setupInputs() {
        viewModel?.inputs.viewDidLoad()
    }
    
    private func setupPageViews() {
        Pages.allCases.map {
            let vc: MonitoringPageViewController = MonitoringPageViewController.instantiate()
            vc.viewModel = viewModel?.outputs.pageViewModel
            vc.page = pages[$0.index]
            
            vcs.append(vc)
        }
    }
    
    private func setupPageController() {
        
        self.pageController = UIPageViewController(transitionStyle: .scroll, navigationOrientation: .horizontal, options: nil)
        self.pageController?.dataSource = self
        self.pageController?.delegate = self
        self.pageController?.view.backgroundColor = .systemBackground
        self.pageController?.view.frame = CGRect(x: 0,y: 0,width: self.view.frame.width,height: self.view.frame.height)
        self.addChild(self.pageController!)
        self.view.addSubview(self.pageController!.view)
        
        self.pageController?.setViewControllers([vcs[0]], direction: .forward, animated: true, completion: nil)
        self.pageController?.didMove(toParent: self)
    }
    
    static func instantiate() -> Self {
        return UIStoryboard(name: "MonitoringView", bundle: nil).instantiateViewController(withIdentifier: "MonitoringViewController") as! Self
    }
}

extension MonitoringViewController: UIPageViewControllerDataSource, UIPageViewControllerDelegate {
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let currentVC = viewController as? MonitoringPageViewController else {
            return nil
        }
        
        var index = currentVC.page?.index ?? 0
        
        if index == 0 {
            return nil
        }
        
        index -= 1
        return vcs[index]
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {

        guard let currentVC = viewController as? MonitoringPageViewController else {
            return nil
        }
        
        var index = currentVC.page?.index ?? 0
        
        if index >= self.pages.count - 1 {
            return nil
        }
        
        index += 1
        return vcs[index]
    }
    
    func presentationCount(for pageViewController: UIPageViewController) -> Int {
        return self.pages.count
    }
    
    func presentationIndex(for pageViewController: UIPageViewController) -> Int {
        return self.currentIndex
    }
}

