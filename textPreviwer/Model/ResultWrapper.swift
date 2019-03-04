//
//  ResultWrapper.swift
//  textPreviwer
//
//  Created by joseewu on 2019/3/2.
//  Copyright © 2019 com. All rights reserved.
//

import Foundation

struct ResultWrapper<T:Codable>:Codable {
    private enum CodingKeys:String, CodingKey {
        case items
    }
    let items:[T]?
}
extension ResultWrapper {
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        items = try? container.decode([T].self, forKey: .items)
    }
    func encode(to encoder: Encoder) throws {

    }
}
