//
//  PhotoDetailView.swift
//  PhotoViewer
//
//  Created by shiyanjun on 2024/8/7.
//

import SwiftUI

// 照片详情
struct PhotoDetailView: View {
    @EnvironmentObject var vm: PhotoViewModel
    @State private var direction: Direction = .none
    @State private var showButton: Bool = false
    
    var body: some View {
        VStack(spacing: 0) {
            HeaderView(selectedIndex: $vm.selectedIndex, photoCount: vm.photos.count) {
                withAnimation(.easeInOut(duration: 0.3)) {
                    vm.showDetail = false
                    vm.hideStatusBar = false
                }
            }
            .opacity(showButton ? 1 : 0)
            .opacity(direction != .v ? 1 : 0)
            
            Spacer(minLength: 3)
            
            PhotoCardView2(selectedIndex: $vm.selectedIndex, direction: $direction, photos: vm.photos)
                .onTapGesture {
                    withAnimation {
                        showButton.toggle()
                    }
                }
                .onAppear {
                    showButton = true
                }
            
            Spacer(minLength: 3)
            
            ThumbnailView(selectedIndex: $vm.selectedIndex, photos: vm.photos)
                .opacity(showButton ? 1 : 0)
                .opacity(direction != .v ? 1 : 0)
        }
        .statusBar(hidden: vm.hideStatusBar)
    }
}

// 照片详情头部
struct HeaderView: View {
    @Binding var selectedIndex: Int
    let photoCount: Int
    
    var action: () -> Void
    
    var body: some View {
        HStack {
            VStack {
                Text("照片")
                    .font(.system(size: 20, weight: .bold))
                
                Spacer(minLength: 0)
                
                Text("\(selectedIndex + 1)/\(photoCount)")
                    .font(.system(size: 12))
                    .foregroundColor(.primary.opacity(0.5))
            }
            
            Spacer(minLength: 0)
            
            HStack(spacing: 24) {
                Button(action: {
                    /// - action
                }, label: {
                    Image(systemName: "ellipsis")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 24)
                        .foregroundColor(Color.primary)
                })
                
                Button(action: {
                    action()
                }, label: {
                    Circle()
                        .fill(.white.opacity(0.06))
                        .frame(width: 40, height: 40)
                        .overlay {
                            Image(systemName: "xmark")
                                .resizable()
                                .scaledToFill()
                                .frame(width: 14, height: 14)
                                .foregroundColor(Color.primary)
                        }
                })
            }
        }
        .padding(.horizontal)
        .frame(height: 44)
    }
}

#Preview {
    PhotoDetailView()
        .environmentObject(PhotoViewModel())
        .preferredColorScheme(.dark)
}
