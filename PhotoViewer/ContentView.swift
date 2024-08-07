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

#Preview {
    ContentView()
        .preferredColorScheme(.dark)
}
