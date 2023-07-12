//
//  BLTSwiftTaskViewController.swift
//  LBUIProject
//
//  Created by liu bin on 2023/6/2.
//

import Foundation



class BLTSwiftTaskViewController: UIViewController {
    
    lazy var chainManager = BLTTaskChainManager<LLContractDetailSignBeforeModel, LLContractDetailBeforeSignCheckTask>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        navigationItem.title = "责任链模式"
        testTaskChain()
    }
    
    func testTaskChain() {
        let chanquanTask = LLContractDetailChanQuanCheckTask.init(self)
        let mutiContractTask = LLContractDetailMutiContractCheckTask.init(self)
        mutiContractTask.lookOtherContractBlock = {
            [weak self] in
            self?.chainManager.removeAllTask()
            self?.pushContractListOfHouse()
        }
        self.chainManager.addData(LLContractDetailSignBeforeModel()).addTaskChain(chanquanTask).addTaskChain(mutiContractTask)
        self.chainManager.startTask({[weak self] error in
            self?.signContractFlow()
        })
    }
    
    func pushContractListOfHouse() {
        
    }
    
    func signContractFlow() {
    
    }
}
