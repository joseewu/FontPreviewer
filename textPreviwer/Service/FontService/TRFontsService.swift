//
//  TRFontsService.swift
//  textPreviwer
//
//  Created by joseewu on 2019/3/1.
//  Copyright © 2019 com. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
class TRFontsService: FontServiceSpec {
    init() {

    }
    func getGoogleFonts() -> Observable<ResultWrapper<FontsModel>> {
        return Observable<ResultWrapper<FontsModel>>.create { (observer) -> Disposable in
            var url = URLComponents(string: self.mainDomain)!

            url.queryItems = [
                URLQueryItem(name: "key", value: self.apiKey)
            ]
            var request = URLRequest(url: url.url!, cachePolicy: URLRequest.CachePolicy.reloadIgnoringCacheData, timeoutInterval: 10)
            request.allHTTPHeaderFields = ["Content-Type":"application/json"]
            let downloadTask = URLSession.shared.dataTask(with: request, completionHandler: { (data, response, error) in
                if let data = data {
                    let decoder = JSONDecoder.init()
                    if let jj = try? decoder.decode(ResultWrapper<FontsModel>.self, from: data) {
                        observer.onNext(jj)
                    }
                }
            })
            downloadTask.resume()
            return Disposables.create()
        }
    }
    func getFont(with urlStr:String,name fileName:String) ->  Observable<String> {
        let documents = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        guard let url = URL(string: urlStr) else {
            return Observable.empty()
        }
        let filePath = documents.appendingPathComponent("\(fileName).ttf")

        return Observable<String>.create { (observer) -> Disposable in
                var request = URLRequest(url: url, cachePolicy: URLRequest.CachePolicy.reloadIgnoringCacheData, timeoutInterval: 2)
                request.allHTTPHeaderFields = ["Content-Type":"application/json"]
            let downloadTask = URLSession.shared.dataTask(with: request, completionHandler: { (data, response, error) in
                if let error = error {
                    observer.onError(error)
                    observer.onCompleted()
                }
                if let data = data {
                    do {
                        try data.write(to: filePath)
                        if let name = self.loadFont(filePath) {
                            observer.onNext(name)
                            observer.onCompleted()
                        } else {
                            observer.onCompleted()
                        }
                    } catch {
                        observer.onError(error)
                        observer.onCompleted()
                    }
                }
            })
                downloadTask.resume()
            return Disposables.create()
        }
    }

    func loadFont(_ path: URL) -> String? {

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
            print("Error loading font. Font is possibly already registered.")
            return nil
        }

        if let name = font.postScriptName {
            return String(name)
        } else {
            return nil
        }
    }
}
