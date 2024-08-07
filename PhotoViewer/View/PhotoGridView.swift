//
//  PhotoGridView.swift
//  PhotoViewer
//
//  Created by shiyanjun on 2024/8/7.
//

import SwiftUI

// 照片网格
struct PhotoGridView: View {
    @EnvironmentObject var vm: PhotoViewModel
    private let screenWidth = UIScreen.main.bounds.width
    private let gridSpacing: CGFloat = 2
    
    var body: some View {
        ScrollViewReader { proxy in
            ScrollView(.vertical) {
                LazyVGrid(columns: Array(repeating: GridItem(spacing: gridSpacing), count: 3), spacing: gridSpacing) {
                    ForEach(vm.photos.indices, id: \.self) { index in
                        GeometryReader {
                            let size = $0.size
                            
                            if let image = vm.photos[index].image {
                                Image(uiImage: image)
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .frame(width: size.width, height: size.height)
                                    .clipped()
                            }
                        }
                        .clipShape(.rect)
                        .contentShape(.rect)
                        .frame(height: (screenWidth - (gridSpacing * 2)) / 3)
                        .onTapGesture {
                            vm.selectedIndex = index
                            withAnimation(.easeInOut(duration: 0.3)) {
                                vm.showDetail = true
                                vm.hideStatusBar = true
                            }
                        }
                    }
                }
            }
            .onChange(of: vm.selectedIndex) { _, _ in
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        proxy.scrollTo(vm.selectedIndex, anchor: .center)
                    }
                }
            }
        }
    }
}

#Preview {
    PhotoGridView()
        .environmentObject(PhotoViewModel())
        .preferredColorScheme(.dark)
}
