//
//  RelayActionView.swift
//  SmartCeelabs
//
//  Created by Dávid Baľak on 18/03/2022.
//


import UIKit
import KeychainSwift

protocol RelayActionViewDelegate: AnyObject {
    func saveButtonPressed(deviceName: String)
}

class RelayActionView: UIViewController {

    @IBOutlet weak var dateTimeView: UIView!
    @IBOutlet weak var stateButton: UIButton!
    @IBOutlet weak var editButton: UIButton!
    @IBOutlet weak var outputsActionsTable: UITableView!
    
    var hasSetPointOrigin = false
    var relayIdx: Int = 0
    var pointOrigin: CGPoint?
    var deviceToken: String?

    var viewModel: RelayActionViewModel?
    var relayActions: [RelayAction]?
    weak var overlayDelegate: OverlayViewDelegate?
    var keychain = KeychainSwift()
    var defaults = UserDefaults.standard
    
    let datePicker = UIDatePicker()

    override func viewDidLoad() {
        super.viewDidLoad()
//        self.viewModel = OverlayViewModel()
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(panGestureRecognizerAction))
        view.addGestureRecognizer(panGesture)
        setupUI()
    }
    
    private func setupUI(){
        //minimum date 
        datePicker.minimumDate = Date()
        self.dateTimeView.insertSubview(datePicker, at: 0)
        self.setupStateButton()
        self.setupActionsTable()
        
        self.setupOutputs()
    }
    
    private func setupOutputs() {
        self.viewModel?.onRelayActionsFetch = { [weak self] (actions) in
            self?.relayActions = actions
            DispatchQueue.main.async {
                self?.outputsActionsTable.reloadData()
            }
        }
    }
    
    private func setupActionsTable() {
        self.outputsActionsTable.delegate = self
        self.outputsActionsTable.dataSource = self
        self.outputsActionsTable.register(cell: RelayActionTableViewCell.self)
        
        viewModel?.getRelayActions(relayIdx: self.relayIdx)
    }
    
    private func setupStateButton() {
        let actions: [UIAction] = [
            UIAction(title: "Switch On", image: nil) {_ in },
            UIAction(title: "Switch Off", image: nil) {_ in }
        ]
        
        self.stateButton.menu = UIMenu(title: "Choose output state", options: .displayInline, children: actions)
    }
    
    override func viewDidLayoutSubviews() {
        if !hasSetPointOrigin {
            hasSetPointOrigin = true
            pointOrigin = self.view.frame.origin
        }
    }
    
    @IBAction func editButtonPressed(_ sender: UIButton) {
        self.outputsActionsTable.isEditing = !self.outputsActionsTable.isEditing
        let title: String = (self.outputsActionsTable.isEditing) ? "Done" : "Edit"
        editButton.setTitle(title, for: .normal)
    }
    
    @IBAction func submitButtonPressed(_ sender: Any) {
        
        guard let auth = defaults.string(forKey: "auth") else { return }
        
        if auth == "local"{
            guard let pass = keychain.get("userPassword"), let title = stateButton.titleLabel?.text else { return }
//            guard let refreshToken = self.keychain.get("refreshToken"), let title = stateButton.titleLabel?.text else { return }
            let action = RelayAction(password: pass,
                                     relayIdx: self.relayIdx,
                                     relayState: title,
                                     timestamp: String(datePicker.date.timeIntervalSince1970))
            viewModel?.inputs.pushNewRelayAction(relayAction: action)

        } else {
            guard let refreshToken = self.keychain.get("refreshToken"), let title = stateButton.titleLabel?.text else { return }
            let action = RelayAction(refreshToken: refreshToken,
                                    relayIdx: self.relayIdx,
                                    relayState: title,
                                    timestamp: String(datePicker.date.timeIntervalSince1970))
        
            viewModel?.inputs.pushNewRelayAction(relayAction: action)
        }
    }
    
    @objc func panGestureRecognizerAction(sender: UIPanGestureRecognizer) {
        let translation = sender.translation(in: view)
        
        // Not allowing the user to drag the view upward
        guard translation.y >= 0 else { return }
        
        // setting x as 0 because we don't want users to move the frame side ways!! Only want straight up or down
        view.frame.origin = CGPoint(x: 0, y: self.pointOrigin!.y + translation.y)
        
        if sender.state == .ended {
            let dragVelocity = sender.velocity(in: view)
            if dragVelocity.y >= 1300 {
                self.dismiss(animated: true, completion: nil)
            } else {
                // Set back to original position of the view controller
                UIView.animate(withDuration: 0.3) {
                    self.view.frame.origin = self.pointOrigin ?? CGPoint(x: 0, y: 400)
                }
            }
        }
    }
}

extension RelayActionView: UITableViewDelegate {
}

extension RelayActionView: UITableViewDataSource {
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        "Scheduled actions"
    }
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return relayActions?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "RelayActionTableViewCell", for: indexPath) as? RelayActionTableViewCell
        if let relayActions = relayActions {
            cell?.setupCellUI(relayAction: relayActions[indexPath.row])
        }
        
        return cell ?? UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return .delete
    }
    
//    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
//        if var relayActions = relayActions {
//            let movedAction = relayActions[sourceIndexPath.item]
//            relayActions.remove(at: sourceIndexPath.item)
//            relayActions.insert(movedAction, at: sourceIndexPath.item)
//        }
//    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            tableView.beginUpdates()
            
            if let relayActions = relayActions {
                viewModel?.inputs.deleteRelayAction(relayAction: relayActions[indexPath.row])
            }
            relayActions?.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)

            tableView.endUpdates()
        }
    }
}
