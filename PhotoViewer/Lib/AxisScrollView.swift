// The Swift Programming Language
// https://docs.swift.org/swift-book

import SwiftUI

/// - 手势方向
enum Direction {
    case h, v, none
}

/// - 双向滚动视图
struct AxisScrollView<Content: View, T: Identifiable>: View {
    let list: [T]
    @Binding var currentIndex: Int
    @Binding var direction: Direction
    @State private var offset: CGSize = .zero
    
    var content: (T) -> Content
    
    init(list: [T], currentIndex: Binding<Int>, direction: Binding<Direction>, @ViewBuilder content: @escaping (T) -> Content) {
        self.list = list
        self._currentIndex = currentIndex
        self._direction = direction
        self.content = content
    }
    
    var body: some View {
        GeometryReader {
            let size = $0.size
            AxisCurrentPageView(list: list, currentIndex: $currentIndex, content: content)
                .offset(x: offset.width, y: offset.height)
                .gesture(
                    DragGesture()
                        .onChanged({ value in
                            let trans = value.translation
                            if direction == .none {
                                direction = abs(trans.width) > abs(trans.height) ? .h : .v
                            }
                            
                            if direction == .h {
                                offset = CGSize(width: trans.width, height: 0)
                            } else if direction == .v {
                                offset = CGSize(width: 0, height: trans.height * 0.8)
                            }
                        })
                        .onEnded({ value in
                            let pageSize = direction == .h ? size.width : size.height
                            let translation = direction == .h ? value.translation.width : value.translation.height
                            
                            /// - 值为负数时表示向上或向左滑动，值为正数时表示向下或向右滑动
                            let dir = Int(translation / abs(translation))
                            
                            if abs(translation) > pageSize * 0.3 && !isAtBoundary(dir: dir) {
                                let newOffset = CGSize(
                                    width: direction == .h ? CGFloat(dir) * pageSize : 0,
                                    height: direction == .v ? CGFloat(dir) * pageSize : 0
                                )
                                
                                withAnimation(.interactiveSpring) {
                                    if direction == .h {
                                        offset = newOffset
                                    } else {
                                        offset = .zero
                                    }
                                } completion: {
                                    if direction == .h {
                                        if translation < 0 {
                                            currentIndex = max(min(currentIndex + 1, list.count - 1), 0)
                                        } else {
                                            currentIndex = max(min(currentIndex - 1, list.count - 1), 0)
                                        }
                                    } else {
//                                        if translation < 0 {
//                                            currentIndex = max(min(currentIndex + 1, list.count - 1), 0)
//                                        } else {
//                                            currentIndex = max(min(currentIndex - 1, list.count - 1), 0)
//                                        }
                                    }
                                    direction = .none
                                }
                            } else {
                                withAnimation(.interactiveSpring()) {
                                    offset = .zero
                                    direction = .none
                                }
                            }
                        })
                )
                .onChange(of: currentIndex) {
                    offset = .zero
                }
        }
    }
    
    /// - 是否到达边界 (第一页或最后一页)
    private func isAtBoundary(dir: Int) -> Bool {
        /// - 第一页向下或向右滑 || 最后一页向上或向左滑
        return (currentIndex == 0 && dir > 0) || (currentIndex == list.count - 1 && dir < 0)
    }
}

/// - 当前页
struct AxisCurrentPageView<Content: View, T: Identifiable>: View {
    let list: [T]
    @Binding var currentIndex: Int
    
    var content: (T) -> Content
    
    init(list: [T], currentIndex: Binding<Int>, content: @escaping (T) -> Content) {
        self.list = list
        self._currentIndex = currentIndex
        self.content = content
    }
    
    var body: some View {
        Color.clear
            .overlay(alignment: .center) {
                getPage(pageIndex: currentIndex)
            }
        /**
         .overlay(alignment: .top) {
         getPage(pageIndex: currentIndex - 1)
         .alignmentGuide(.top) { $0[.bottom]}
         }
         .overlay(alignment: .bottom) {
         getPage(pageIndex: currentIndex + 1)
         .alignmentGuide(.bottom) { $0[.top]}
         }
         */
            .overlay(alignment: .leading) {
                getPage(pageIndex: currentIndex - 1)
                    .alignmentGuide(.leading) { $0[.trailing]}
            }
            .overlay(alignment: .trailing) {
                getPage(pageIndex: currentIndex + 1)
                    .alignmentGuide(.trailing) { $0[.leading]}
            }
            .contentShape(Rectangle())
    }
    
    /// - 根据索引获取页面
    private func getPage(pageIndex: Int) -> some View {
        Group {
            if (0 ..< list.count).contains(pageIndex)  {
                Color.clear
                    .overlay {
                        content(list[pageIndex])
                    }
            }
        }
    }
}
