//
//  ViewModelBindings.swift
//  textPreviwer
//
//  Created by joseewu on 2019/3/1.
//  Copyright © 2019 com. All rights reserved.
//

import Foundation


protocol ViewModelBindings {
    associatedtype Inputs
    associatedtype Outputs
    var inputs:Inputs {get}
    var outputs:Outputs {get}
}
