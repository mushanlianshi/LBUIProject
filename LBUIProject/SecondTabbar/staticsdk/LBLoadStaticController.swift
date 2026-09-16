//
//  LBLoadStaticController.swift
//  LBUIProject
//
//  Created by liu bin on 2026/9/14.
//

import UIKit
import SnapKit
import LBSDK

class LBLoadStaticController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        let person = LBPerson()
        person.testSwiftPrint()
        
        let OCAI = LBSDKOCAPI();
        let name = OCAI.getSwiftName()
        print("LBLOg name is \(name)")
        OCAI.printSwiftMethod()
        
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
            [weak self] in
            guard let self else { return }
            person.pushTestVC(self)
        }
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
