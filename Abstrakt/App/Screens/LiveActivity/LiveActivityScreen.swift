//
//  LiveActivityScreen.swift
//  Abstrakt
//
//  Created by Daffa Yuranizar Arrifi on 09/07/26.
//

import SwiftUI

struct LiveActivityScreen: View {
    private let collapsedOffset: CGFloat = 250
    private let expandedOffset: CGFloat = 150

    @State private var viewModel = LiveActivityViewModel()
    @Namespace private var animationNamespace

    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .top) {
                // Background
                AppColors.appBackground
                    .ignoresSafeArea()

                // Top Area
                DynamicIslandPreviewView(
                    animationNamespace: animationNamespace
                )
                
                // Bottom Container Sheet
                CompactModeSheetView(
                    animationNamespace: animationNamespace
                )
                .frame(height: geometry.size.height + 200) // Large enough to always bleed off the bottom
                .padding(.top, viewModel.isExpanded ? expandedOffset : collapsedOffset)
                .ignoresSafeArea(edges: .bottom)
                .animation(.spring(response: 0.4, dampingFraction: 0.8), value: viewModel.isExpanded)
            }
            .environment(viewModel)
            .task {
                await viewModel.loadData()
            }
        }
    }
}

#Preview {
    LiveActivityScreen()
}
