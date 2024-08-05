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
        ScrollViewReader { proxy in
            ScrollView(.vertical) {
                LazyVGrid(columns: Array(repeating: GridItem(spacing: 2), count: 3), spacing: 2) {
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
                        .frame(height: (UIScreen.main.bounds.width-4)/3)
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
        .statusBar(hidden: vm.hideStatusBar)
        .opacity(vm.showDetail ? 0 : 1)
        .overlay {
            DetailView()
                .environmentObject(vm)
        }
    }
}

struct DetailView: View {
    @EnvironmentObject var vm: PhotoViewModel
    @State private var showButton: Bool = false
    
    var body: some View {
        if vm.showDetail {
            GeometryReader {
                let size = $0.size
                
                VStack {
                    HeaderView()
                        .environmentObject(vm)
                        .opacity(showButton ? 1 : 0)
                    
                    Spacer()
                    
                    CardView()
                        .environmentObject(vm)
                        .onTapGesture {
                            withAnimation {
                                showButton.toggle()
                            }
                        }
                        .onAppear {
                            showButton = false
                        }
                    
                    Spacer()
                    
                    ThumbnailView()
                        .environmentObject(vm)
                        .opacity(showButton ? 1 : 0)
                }
                .frame(width: size.width, height: size.height)
            }
            .opacity(vm.showDetail ? 1 : 0)
            .transition(.scale.combined(with: .opacity))
        }
    }
}

struct HeaderView: View {
    @EnvironmentObject var vm: PhotoViewModel
    
    var body: some View {
        HStack {
            VStack {
                Text("照片")
                    .font(.system(size: 20, weight: .bold))
                
                Text("\(vm.selectedIndex + 1)/\(vm.photos.count)")
                    .font(.system(size: 12))
                    .foregroundColor(.primary.opacity(0.5))
            }
            .frame(height: 43)
            
            Spacer()
            
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
                    withAnimation(.easeInOut(duration: 0.3)) {
                        vm.showDetail = false
                        vm.hideStatusBar = false
                    }
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

struct CardView: View {
    @EnvironmentObject var vm: PhotoViewModel
    
    var body: some View {
        TabView(selection: $vm.selectedIndex) {
            ForEach(vm.photos.indices, id: \.self) { index in
                if let image = vm.photos[index].image {
                    GeometryReader {
                        let size = $0.size
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFit()
                            .padding(.horizontal, 10)
                            .frame(width: size.width, height: size.height)
                    }
                    .tag(index)
                    .background(.black.opacity(0.0000001))
                    .transition(.scale.combined(with: .opacity))
                }
            }
        }
        .tabViewStyle(.page(indexDisplayMode: .never))
    }
}

struct ThumbnailView: View {
    @EnvironmentObject var vm: PhotoViewModel
    
    var body: some View {
        ScrollViewReader { proxy in
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 1) {
                    ForEach(vm.photos.indices, id: \.self) { index in
                        if let image = vm.photos[index].image {
                            Image(uiImage: image)
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: 36, height: 36)
                                .clipped()
                                .border(.primary, width: vm.selectedIndex == index ? 1 : 0)
                                .onTapGesture {
                                    withAnimation {
                                        vm.selectedIndex = index
                                    }
                                }
                        }
                    }
                }
                .padding(.horizontal)
                .onAppear {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        proxy.scrollTo(vm.selectedIndex, anchor: .center)
                    }
                }
                .onChange(of: vm.selectedIndex) { _, _ in
                    withAnimation(.easeInOut(duration: 0.2)) {
                        proxy.scrollTo(vm.selectedIndex, anchor: .center)
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
