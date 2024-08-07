//
//  PhotoCardView2.swift
//  PhotoViewer
//
//  Created by shiyanjun on 2024/8/7.
//

import SwiftUI

// 照片卡片
struct PhotoCardView2: View {
    @Binding var selectedIndex: Int
    @Binding var direction: Direction
    let photos: [Photo]
    
    var body: some View {
        AxisScrollView(list: photos,
                       currentIndex: $selectedIndex,
                       direction: $direction) { photo in
            if let image = photo.image {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .padding(5)
                    .clipped()
            }
        }
    }
}

#Preview {
    PhotoDetailView()
        .environmentObject(PhotoViewModel())
        .preferredColorScheme(.dark)
}
