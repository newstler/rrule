//
//  FilerProtocol.swift
//  
//
//  Created by Yuri Sidorov on 09.03.2024.
//

import Foundation

protocol Filter {
    func reject(index: Int) -> Bool
}
