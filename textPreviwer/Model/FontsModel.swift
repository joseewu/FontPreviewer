//
//  FontsModel.swift
//  textPreviwer
//
//  Created by joseewu on 2019/3/1.
//  Copyright © 2019 com. All rights reserved.
//

import Foundation

struct FontsModel:Codable {
    private enum CodingKeys:String, CodingKey {
        case kind
        case family
        case variants
        case subsets
        case files
    }
    let kind:String?
    let family:String?
    let variants:[String]?
    let files:[String:String]?
}

extension FontsModel {
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        kind = try? container.decode(String.self, forKey: .kind)
        family = try? container.decode(String.self, forKey: .family)
        variants = try? container.decode([String].self, forKey: .variants)
        files = try? container.decode([String:String].self, forKey: .files)
    }
    func encode(to encoder: Encoder) throws {

    }
}

