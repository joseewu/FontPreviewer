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
    var selectedFont:PublishSubject<Int> {get}
}
protocol FontsViewModelOutputs {
    var fontRegisteredName:[String] {get}
    var registeredFontName:Driver<String?> {get}
    var update:Driver<Void> {get}
}
class FontsViewModel:ViewModelBindings,FontsViewModelInputs,FontsViewModelOutputs {
    var registeredFontName: Driver<String?>

    var update: Driver<Void>
    var selectedFont: PublishSubject<Int> = PublishSubject.init()

    var inputs:FontsViewModelInputs {return self}
    var outputs:FontsViewModelOutputs {return self}

    var viewDidAppear: PublishSubject<Void> = PublishSubject.init()

    var fontRegisteredName: [String] = [String]()
    var fonts: [(String,String)] = [(String,String)]()

    var service:FontServiceSpec!
    let disposeBag:DisposeBag = DisposeBag()
    private let updateSubject: PublishSubject<Void> = PublishSubject.init()
    private let registeredFontNameSubject: PublishSubject<String?> = PublishSubject.init()
    init() {
        service = TRFontsService()
        update = updateSubject.asDriver(onErrorJustReturn: ())
        registeredFontName = registeredFontNameSubject.asDriver(onErrorJustReturn: nil)
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
            }.subscribe(onNext: { [weak self] result in
                self?.fonts = result
                for item in result {
                    self?.fontRegisteredName.append(item.1)
                }
                self?.updateSubject.onNext(())
            }).disposed(by: disposeBag)

        selectedFont.asObservable().flatMapLatest { [weak self] selectedFontIndex -> Observable<URL> in
            guard let strongSelf = self else {return Observable.empty()}
            let selectedFont = strongSelf.fonts[selectedFontIndex]
            return strongSelf.service.getFont(with: selectedFont.0, name: selectedFont.1)
            }.subscribe(onNext: { [weak self] results in
                if let name = self?.loadFont(results) {
                    self?.registeredFontNameSubject.onNext(name)
                    self?.updateSubject.onNext(())
                }
                }, onCompleted: {
            }).disposed(by: disposeBag)
    }

    private func loadFont(_ path: URL) -> String? {

        guard let data = try? Data(contentsOf: path, options: Data.ReadingOptions.init(rawValue: 0)) else {
            return nil

        }
        guard let provider = CGDataProvider(data: data as CFData) else {
            return nil
            
        }

        guard let font = CGFont(provider) else {return nil}
        var error: Unmanaged<CFError>?
        let success = CTFontManagerRegisterGraphicsFont(font, &error)
        if !success {
            return String(font.postScriptName ?? "")
        }
        if let name = font.postScriptName {
            return String(name)
        } else {
            return nil
        }
    }
}
