//
//  FontsViewModel.swift
//  textPreviwer
//
//  Created by joseewu on 2019/3/1.
//  Copyright © 2019 com. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

protocol FontsViewModelInputs {
    var viewDidAppear:PublishSubject<Void> {get}
}
protocol FontsViewModelOutputs {
    var fonts:[String] {get}
}
class FontsViewModel:ViewModelBindings,FontsViewModelInputs,FontsViewModelOutputs {
    var inputs:FontsViewModelInputs {return self}
    var outputs:FontsViewModelOutputs {return self}

    var viewDidAppear: PublishSubject<Void> = PublishSubject.init()

    var fonts: [String] = [String]()

    var service:FontServiceSpec!
    let disposeBag:DisposeBag = DisposeBag()
    init() {
        service = TRFontsService()
        loadFont()
    }
    func loadFont() {

        viewDidAppear.asObservable().flatMapLatest { _ -> Observable<ResultWrapper<FontsModel>> in
            return self.service.getGoogleFonts()
            }.flatMapLatest { (result) -> Observable<[(String,String)]> in
                var temp = [(String,String)]()
                if let items = result.items {
                    for item in items {
                        guard let family = item.family else {return Observable.empty()}
                        guard let files =  item.files  else {return Observable.empty()}
                        for (key,value) in files {
                            let fileName = "\(family)-\(key)"
                            temp.append((value, fileName))
                        }
                    }
                }
                return Observable.just(temp)
            }.flatMapLatest { (result) -> Observable<String> in
                let all = result.compactMap({ (item) -> Observable<String> in
                    return self.service.getFont(with: item.0, name: item.1).debug()

                })
                let singleObservable: Observable<String> = Observable.from(all).merge().catchErrorJustReturn("")
                return singleObservable
            }.subscribe(onNext: { results in
                print(results)
                self.listAllFonts()
                self.fonts.append(results)
            }, onCompleted: {
                print("onCompleted")
            }).disposed(by: disposeBag)
    }
    private func listAllFonts() {
        let allFamilies = UIFont.familyNames
        for item in allFamilies {
            print(item)
        }
    }
}
