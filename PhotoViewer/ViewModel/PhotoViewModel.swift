//
//  PhotoViewModel.swift
//  PhotoViewer
//
//  Created by shiyanjun on 2024/8/7.
//

import SwiftUI

class PhotoViewModel: ObservableObject {
    @Published var photos: [Photo] = samplePhotos
    @Published var showDetail: Bool = false
    @Published var hideStatusBar: Bool = false
    @Published var selectedIndex: Int = 0
}

var samplePhotos: [Photo] = (1...44).map({ Photo(image: UIImage(named: "Pic-\($0)"))})
