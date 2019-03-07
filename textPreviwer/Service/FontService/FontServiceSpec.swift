//
//  FontServiceSpec.swift
//  textPreviwer
//
//  Created by joseewu on 2019/3/1.
//  Copyright © 2019 com. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

//define spec of FontService
protocol FontServiceSpec {
    var apiKey:String {get}
    var mainDomain:String{get}
    func getGoogleFonts() -> Observable<ResultWrapper<FontsModel>>
    func getFont(with urlStr:String,name fileName:String) ->  Observable<URL>
}

extension FontServiceSpec {
    var apiKey: String {
        
        return ""
    }
    var mainDomain:String {
        return "https://www.googleapis.com/webfonts/v1/webfonts"
    }
}
