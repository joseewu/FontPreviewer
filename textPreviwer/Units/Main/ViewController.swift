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

    private let viewModel:FontsViewModel = FontsViewModel()
    let tapGesture:UITapGestureRecognizer = UITapGestureRecognizer()
    let fontPicker:UIPickerView = UIPickerView()
    private var textFieldStack:[UITextField] = [UITextField]()
    private var activeTextField:UITextField?
    private let loadingIndicator:UIActivityIndicatorView = UIActivityIndicatorView()
    private let disposeBag:DisposeBag = DisposeBag()

    @IBOutlet weak var collectionView: UICollectionView!

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        viewModel.inputs.viewDidAppear.onNext(())
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setUp()
        bindViewModel()
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
        loadingIndicator.style = .whiteLarge
        loadingIndicator.startAnimating()
        loadingIndicator.frame.size = CGSize(width: 100, height: 100)
        loadingIndicator.layer.cornerRadius = 4
        loadingIndicator.backgroundColor = UIColor.black.withAlphaComponent(0.7)
        view.addSubview(loadingIndicator)

        collectionView.register(UINib(nibName: "TextPreviewCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "TextPreviewCollectionViewCell")
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.isPagingEnabled = true

    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        loadingIndicator.center = CGPoint(x: view.frame.maxX/2, y: view.frame.maxY/2)
    }

    func bindViewModel() {
        viewModel.outputs.update.drive(onNext: { [weak self] _ in
            self?.loadingIndicator.stopAnimating()
            self?.collectionView.reloadData()
        }).disposed(by: disposeBag)
        viewModel.outputs.registeredFontName.drive(onNext: { [weak self] fontName in
            if let activeTextField = self?.activeTextField, let fontName = fontName {
                activeTextField.font = UIFont(name: fontName, size: 20)
            }
        }).disposed(by: disposeBag)
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
        return viewModel.outputs.fontRegisteredName.count
    }

    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        let titleString = viewModel.outputs.fontRegisteredName[row]
        return titleString
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        loadingIndicator.startAnimating()
        viewModel.inputs.selectedFont.onNext(row)
    }
}

extension ViewController:UICollectionViewDataSource, UICollectionViewDelegate,UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.outputs.fontRegisteredName.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "TextPreviewCollectionViewCell", for: indexPath) as? TextPreviewCollectionViewCell
        cell?.lbTextPreview.text = viewModel.outputs.fontRegisteredName[indexPath.row]
        let arg = viewModel.fonts[indexPath.row]
        cell?.fetchFont(with: arg.0, name: arg.1)
        return cell!
    }
    func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        (cell as? TextPreviewCollectionViewCell)?.cancel()
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let preferWidth = (view.frame.width)/2
        let preferHeight = (collectionView.frame.size.height - 20)/3
        return CGSize(width: preferWidth, height: preferHeight)
    }
}
