//
//  ViewController.swift
//  textPreviwer
//
//  Created by joseewu on 2019/3/1.
//  Copyright © 2019 com. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class ViewController: UIViewController {

    @IBOutlet weak var cardView: UIView!
    let viewModel:FontsViewModel = FontsViewModel()
    let tapGesture:UITapGestureRecognizer = UITapGestureRecognizer()
    let fontPicker:UIPickerView = UIPickerView()
    var textFieldStack:[UITextField] = [UITextField]()
    var activeTextField:UITextField?
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        viewModel.inputs.viewDidAppear.onNext(())
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        setUp()
    }
    func setUp(){
        view.backgroundColor = UIColor.lightGray
        cardView.layer.borderWidth = 1.0
        cardView.layer.borderColor = UIColor.lightGray.cgColor
        cardView.clipsToBounds = true
        tapGesture.addTarget(self, action: #selector(addLabel(_:)))
        cardView.addGestureRecognizer(tapGesture)
        fontPicker.dataSource = self
        fontPicker.delegate = self
    }
    @objc func addLabel(_ sender:UITapGestureRecognizer){
        sender.view?.endEditing(true)
        let location = sender.location(in: cardView)
        let newTextfiled:UITextField = UITextField(frame: CGRect(origin: location, size: CGSize(width: 100, height: 50)))
        newTextfiled.text = "Hello!"
        newTextfiled.minimumFontSize = 20
        newTextfiled.inputView = fontPicker
        newTextfiled.tag = textFieldStack.count + 1
        newTextfiled.delegate = self
        sender.view?.addSubview(newTextfiled)
        textFieldStack.append(newTextfiled)
    }
}
extension ViewController:UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        activeTextField = textField
    }
}
extension ViewController:UIPickerViewDelegate,UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return viewModel.outputs.fonts.count
    }
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        let titleString = viewModel.outputs.fonts[row]
        return titleString
    }
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        let titleString = viewModel.outputs.fonts[row]
        if let activeTextField = activeTextField {
            activeTextField.font = UIFont(name: titleString, size: 20)
        }
    }
}

