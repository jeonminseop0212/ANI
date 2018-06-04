//
//  ANIPopupPickerView.swift
//  Ani
//
//  Created by jeonminseop on 2018/05/15.
//  Copyright © 2018年 JeonMinseop. All rights reserved.
//

import UIKit

protocol ANIPopupPickerViewDelegate {
  func cancelButtonTapped()
}

class ANIPopupPickerView: UIView {
  
  private weak var pickerAreaBG: UIView?
  private weak var pickerView: UIPickerView?
  
  private let CENCEL_BUTTON_HEIGHT: CGFloat = 50.0
  private weak var cancelButton: UIButton?
  
  var pickerItem: [String]? {
    didSet {
      setupPickerView()
    }
  }
  
  var delegate: ANIPopupPickerViewDelegate?

  override init(frame: CGRect) {
    super.init(frame: frame)
    
    setup()
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  private func setup() {
    //cancelButton
    let cancelButton = UIButton()
    cancelButton.setTitle("キャンセル", for: .normal)
    cancelButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 17.0)
    cancelButton.setTitleColor(ANIColor.dark, for: .normal)
    cancelButton.backgroundColor = .white
    cancelButton.layer.cornerRadius = 7.0
    cancelButton.layer.masksToBounds = true
    cancelButton.addTarget(self, action: #selector(cancel), for: .touchUpInside)
    addSubview(cancelButton)
    cancelButton.edgesToSuperview(excluding: .top)
    cancelButton.height(CENCEL_BUTTON_HEIGHT)
    self.cancelButton = cancelButton
    
    //pickerAreaBG
    let pickerAreaBG = UIView()
    pickerAreaBG.backgroundColor = .white
    pickerAreaBG.layer.cornerRadius = 7.0
    pickerAreaBG.layer.masksToBounds = true
    addSubview(pickerAreaBG)
    pickerAreaBG.edgesToSuperview(excluding: .bottom)
    pickerAreaBG.bottomToTop(of: cancelButton, offset: -10.0)
    self.pickerAreaBG = pickerAreaBG
  }
  
  private func setupPickerView() {
    guard let pickerAreaBG = self.pickerAreaBG,
          let pickerItem = self.pickerItem else { return }
    
    let pickerView = UIPickerView()
    pickerView.dataSource = self
    pickerView.delegate = self
    pickerAreaBG.addSubview(pickerView)
    pickerView.edgesToSuperview()
    self.pickerView = pickerView
    
    if !pickerItem.isEmpty {
      ANINotificationManager.postPickerViewDidSelect(pickItem: pickerItem[0])
    }
  }
  
  //MARK: action
  @objc private func cancel() {
    self.delegate?.cancelButtonTapped()
  }
}

extension ANIPopupPickerView: UIPickerViewDataSource {
  func numberOfComponents(in pickerView: UIPickerView) -> Int {
    return 1
  }
  
  func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
    guard let pickerItem = self.pickerItem else { return 0 }
    return pickerItem.count
  }
  
  func pickerView(_ pickerView: UIPickerView, attributedTitleForRow row: Int, forComponent component: Int) -> NSAttributedString? {
    guard let pickerItem = self.pickerItem else { return nil }
    
    let title = pickerItem[row]
    return NSAttributedString(string: title, attributes: [.foregroundColor: ANIColor.dark])
  }
  
  func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
    return 30.0
  }
}

extension ANIPopupPickerView: UIPickerViewDelegate {
  func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
    guard let pickerItem = self.pickerItem else { return "" }

    return pickerItem[row]
  }
  
  func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
    guard let pickerItem = self.pickerItem else { return }

    ANINotificationManager.postPickerViewDidSelect(pickItem: pickerItem[row])
  }
}
