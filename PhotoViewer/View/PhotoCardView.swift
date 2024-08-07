//
//  PhotoCardView.swift
//  PhotoViewer
//
//  Created by shiyanjun on 2024/8/7.
//

import SwiftUI

// 照片卡片
struct PhotoCardView: View {
    @Binding var selectedIndex: Int
    let photos: [Photo]
    
    var body: some View {
        TabView(selection: $selectedIndex) {
            ForEach(photos.indices, id: \.self) { index in
                GeometryReader {
                    let size = $0.size
                    if let image = photos[index].image {
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFit()
                            .padding(.horizontal, 2)
                            .frame(width: size.width, height: size.height)
                    } else {
                        Rectangle()
                            .fill(.clear)
                            .frame(width: size.width, height: size.height)
                            .overlay {
                                Text("图片加载失败")
                                    .font(.headline)
                                    .foregroundColor(.primary)
                            }
                    }
                }
                .background(.black.opacity(0.0000001))
                .transition(.scale.combined(with: .opacity))
            }
        }
        .tabViewStyle(.page(indexDisplayMode: .never))
    }
}

#Preview {
    PhotoCardView(selectedIndex: .constant(0), photos: samplePhotos)
        .preferredColorScheme(.dark)
}
