//
//  Photo.swift
//  PhotoViewer
//
//  Created by shiyanjun on 2024/8/7.
//

import Foundation
import SwiftUI

struct Photo: Identifiable, Hashable {
    var id: UUID = .init()
    var image: UIImage?
}
