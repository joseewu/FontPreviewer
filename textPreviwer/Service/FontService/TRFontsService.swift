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
                    if let fontModel = try? decoder.decode(ResultWrapper<FontsModel>.self, from: data) {
                        observer.onNext(fontModel)
                    }
                }
            })
            downloadTask.resume()
            return Disposables.create()
        }
    }
    func getFont(with urlStr:String,name fileName:String) ->  Observable<URL> {
        let documents = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        guard let url = URL(string: urlStr) else {
            return Observable.empty()
        }
        let filePath = documents.appendingPathComponent("\(fileName).ttf")

        return Observable<URL>.create { (observer) -> Disposable in
                var request = URLRequest(url: url, cachePolicy: URLRequest.CachePolicy.reloadIgnoringCacheData, timeoutInterval: 30)
                request.allHTTPHeaderFields = ["Content-Type":"application/json"]
            let downloadTask = URLSession.shared.dataTask(with: request, completionHandler: { (data, response, error) in
                if let error = error {
                    observer.onError(error)
                    observer.onCompleted()
                }
                if let data = data {
                    do {
                        try data.write(to: filePath)
                        observer.onNext(filePath)
                        observer.onCompleted()
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
}
