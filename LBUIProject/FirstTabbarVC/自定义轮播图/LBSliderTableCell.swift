//
//  LBSliderTableCell.swift
//  LBUIProject
//
//  Created by liu bin on 2022/7/26.
//

import UIKit

class LBSliderTableCell: UITableViewCell {

    var valueChanged: ((_ progress: CGFloat, _ sliderView: UISlider) -> Void)?
    
    lazy var sliderView: UISlider = {
        let view = UISlider()
//        view.thumbTintColor = UIColor.blue
        view.addTarget(self, action: #selector(sliderValueChanged(sliderView:)), for: .valueChanged)
        return view
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.selectionStyle = .none
        contentView.addSubview(sliderView)
        sliderView.snp.makeConstraints { make in
            make.left.equalTo(15)
            make.right.equalTo(-15)
            make.centerY.equalToSuperview()
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    
    @objc func sliderValueChanged(sliderView: UISlider) {
        let progress = sliderView.value / sliderView.maximumValue
        valueChanged?(CGFloat(progress), sliderView)
    }

}
