//
//  ThumbnailView.swift
//  PhotoViewer
//
//  Created by shiyanjun on 2024/8/7.
//

import SwiftUI

// 照片缩略图
struct ThumbnailView: View {
    @Binding var selectedIndex: Int
    let photos: [Photo]
    
    var body: some View {
        ScrollViewReader { proxy in
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 1) {
                    ForEach(photos.indices, id: \.self) { index in
                        if let image = photos[index].image {
                            Image(uiImage: image)
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: 36, height: 36)
                                .clipped()
                                .border(.primary, width: selectedIndex == index ? 1 : 0)
                                .onTapGesture {
                                    withAnimation {
                                        selectedIndex = index
                                    }
                                }
                        }
                    }
                }
                .padding(.horizontal)
                .padding(.vertical, 0)
                .onAppear {
                    withAnimation() {
                        proxy.scrollTo(selectedIndex, anchor: .center)
                    }
                }
                .onChange(of: selectedIndex) { _, _ in
                    withAnimation() {
                        proxy.scrollTo(selectedIndex, anchor: .center)
                    }
                }
            }
        }
    }
}

#Preview {
    ThumbnailView(selectedIndex: .constant(0), photos: samplePhotos)
        .preferredColorScheme(.dark)
}
