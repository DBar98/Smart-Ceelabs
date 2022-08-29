//
//  OutputSettingsOverlayViewController.swift
//  SmartCeelabs
//
//  Created by Dávid Baľak on 09/04/2022.
//

import UIKit

protocol OutputSettingsOverlayViewDelegate: AnyObject {
    func onOutputNameChange(disconnector: DisconnectorTableModel)
}

class OutputSettingsOverlayViewController: BaseOverlayView {
    
    @IBOutlet weak var outputTableView: UITableView!
    @IBOutlet weak var saveButton: UIButton!

    var disconnector: DisconnectorModel?
    var device: Device?
    
    var viewModel: OutputSettingsViewModelType?
    weak var delegate: OutputSettingsOverlayViewDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
        super.isFromSearchView = false
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.isFromSearchView = true
    }
    
    private func setupTableView() {
        outputTableView.delegate = self
        outputTableView.dataSource = self
        outputTableView.separatorStyle = .none
        outputTableView.register(cell: OutputSettingsCell.self)
    }
    
    @IBAction func saveButtonPressed(_ sender: Any) {
        changeRelayOutputName()
        self.view.endEditing(true)
        self.dismiss(animated: true, completion: nil)
    }
    private func changeRelayOutputName() {
        let cells = self.outputTableView.visibleCells as! [OutputSettingsCell]
        print(cells.count)
        let disconnector = DisconnectorTableModel(relay1: cells[0].cellTextField.text ?? "",
                                                  relay2: cells[1].cellTextField.text ?? "",
                                                  relay3: cells[2].cellTextField.text ?? "",
                                                  relay4: cells[3].cellTextField.text ?? "")
        
        viewModel?.inputs.changeOutputName(disconnector: disconnector)
        delegate?.onOutputNameChange(disconnector: disconnector)
    }
}

extension OutputSettingsOverlayViewController: UITableViewDelegate {
}

extension OutputSettingsOverlayViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        "Output names"
    }
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 4
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "OutputSettingsCell", for: indexPath) as? OutputSettingsCell
        cell?.setupCell(relayName: disconnector?.getRelayByIndexNumber(index: indexPath.row).name ?? "")
        return cell ?? UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return tableView.frame.height / (4.8)
    }
}

