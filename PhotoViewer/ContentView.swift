//
//  ContentView.swift
//  PhotoViewer
//
//  Created by shiyanjun on 2024/8/5.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var vm = PhotoViewModel()
    
    var body: some View {
        if vm.showDetail {
            PhotoDetailView()
                .environmentObject(vm)
                .transition(.scale.combined(with: .opacity))
        } else {
            PhotoGridView()
                .environmentObject(vm)
        }
    }
}

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

// 照片详情
struct PhotoDetailView: View {
    @EnvironmentObject var vm: PhotoViewModel
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
            
            Spacer(minLength: 3)
            
            PhotoCardView(selectedIndex: $vm.selectedIndex, photos: vm.photos)
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

class PhotoViewModel: ObservableObject {
    @Published var photos: [Photo] = samplePhotos
    @Published var showDetail: Bool = false
    @Published var hideStatusBar: Bool = false
    @Published var selectedIndex: Int = 0
}

struct Photo: Identifiable, Hashable {
    var id: UUID = .init()
    var image: UIImage?
}

var samplePhotos: [Photo] = (1...44).map({ Photo(image: UIImage(named: "Pic-\($0)"))})

#Preview {
    ContentView()
        .preferredColorScheme(.dark)
}
