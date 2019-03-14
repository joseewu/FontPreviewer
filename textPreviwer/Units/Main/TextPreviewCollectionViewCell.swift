//
//  TextPreviewCollectionViewCell.swift
//  textPreviwer
//
//  Created by joseewu on 2019/3/14.
//  Copyright © 2019 com. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift

class TextPreviewCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var lbTextPreview: UILabel!
    private let service:TRFontsService = TRFontsService()
    private let taskQueue:OperationQueue = OperationQueue()
    private var disposeble:Disposable?
    override func awakeFromNib() {
        super.awakeFromNib()
        renderUI()
    }
    
    func renderUI() {
        layer.borderColor = UIColor.black.cgColor
        layer.borderWidth = 1
    }
    func cancel() {
        taskQueue.cancelAllOperations()
    }
    func fetchFont(with urlStr:String,name fileName:String) {
        disposeble?.dispose()
        let block = BlockOperation { [weak self] in
            self?.disposeble = self?.service.getFont2(with: urlStr, name: fileName).subscribe(onNext: { (nameString) in
                DispatchQueue.main.async {
                    self?.lbTextPreview.font = UIFont(name: nameString, size: 20)
                }
            })
        }
        taskQueue.addOperation(block)
    }
    override func prepareForReuse() {
        super.prepareForReuse()
        taskQueue.cancelAllOperations()
        disposeble?.dispose()
        lbTextPreview.font = nil
    }
}
