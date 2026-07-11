//
//  CompactModeSheetView.swift
//  Abstrakt
//
//  Created by Daffa Yuranizar Arrifi on 09/07/26.
//

import SwiftUI

struct CompactModeSheetView: View {
    @Environment(LiveActivityViewModel.self) var viewModel
    var animationNamespace: Namespace.ID

    private let columns = [
        GridItem(.flexible()),
        GridItem(.flexible()),
        GridItem(.flexible()),
        GridItem(.flexible())
    ]

    var body: some View {
        VStack(spacing: 0) {
            

            // MARK: - Widget Grid Content
            VStack(spacing: 0) {
                HStack(spacing: 8) {
                    Image(systemName: "rectangle.topthird.inset.filled")
                    Text("Compact Mode")
                        .font(.system(size: 16, weight: .semibold, design: .rounded))
                }
                .foregroundStyle(.primary)
                .padding(.top, 16)
                .frame(maxWidth: .infinity)
                .contentShape(Rectangle())
                .onTapGesture {
                    viewModel.isExpanded.toggle()
                }
                .gesture(
                    DragGesture(minimumDistance: 10)
                        .onEnded { value in
                            if value.translation.height < -30 {
                                viewModel.isExpanded = true
                            } else if value.translation.height > 30 {
                                viewModel.isExpanded = false
                            }
                        }
                )
                if viewModel.isExpanded {
                    // Expanded: items are scrollable inside the container
                    ScrollView(showsIndicators: false) {
                        GeometryReader { proxy -> Color in
                            let minY = proxy.frame(in: .named("SCROLL")).minY
                            DispatchQueue.main.async {
                                // If the user pulls down significantly past the top (overscroll)
                                if minY > 30 {
                                    viewModel.isExpanded = false
                                }
                            }
                            return Color.clear
                        }
                        .frame(height: 0)

                        widgetGrid(items: viewModel.currentWidgets)
                            .padding(.horizontal, 24)
                            .padding(.vertical, 24)
                    }
                    .coordinateSpace(name: "SCROLL")
                    .transition(.identity)
                } else {
                    // Collapsed: show all items, scroll attempt expands the container
                    widgetGrid(items: viewModel.currentWidgets)
                        .padding(.horizontal, 24)
                        .padding(.vertical, 24)
                        .frame(maxHeight: .infinity, alignment: .top)
                        .contentShape(Rectangle())
                        .simultaneousGesture(
                            DragGesture(minimumDistance: 10)
                                .onEnded { value in
                                    if value.translation.height < -15 {
                                        viewModel.isExpanded = true
                                    }
                                }
                        )
                        .transition(.identity)
                }
            }
            .background(Color(UIColor.systemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
        }
        .frame(width: 352)
    }

    @State private var isJiggling = false

    private func widgetGrid(items: [CompactWidgetModel]) -> some View {
        LazyVGrid(columns: columns, spacing: 24) {
            ForEach(items) { item in
                let isLeading = viewModel.selectedLeadingWidget?.id == item.id
                let isTrailing = viewModel.selectedTrailingWidget?.id == item.id
                let isExpandedSelected = viewModel.selectedExpandedWidget?.id == item.id
                let isLockScreenSelected = viewModel.selectedLockScreenWidget?.id == item.id
                
                let isSelected: Bool = {
                    switch viewModel.selectedPreviewMode {
                    case .compact:
                        return isLeading || isTrailing
                    case .expanded:
                        return isExpandedSelected
                    case .lockScreen:
                        return isLockScreenSelected
                    }
                }()
                
                VStack(spacing: 8) {
                    Button {
                        withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                            viewModel.handleWidgetTap(item)
                        }
                    } label: {
                        ZStack {
                            RoundedRectangle(cornerRadius: 12, style: .continuous)
                                .fill(Color.black)
                                .frame(width: 52, height: 52)

                            // Render using shared component
                            CompactWidgetView(item: item, isLiveActivity: false)
                                .fixedSize()
                                .scaleEffect(0.65) // Scale down to fit well as a pill/circle
                                .frame(width: 52, height: 52)
                            
                            // Visual indicator for selection
                            if isSelected {
                                RoundedRectangle(cornerRadius: 12, style: .continuous)
                                    .stroke(Color.white.opacity(0.3), lineWidth: 2)
                                
                                VStack {
                                    HStack {
                                        if viewModel.selectedPreviewMode == .compact {
                                            if isLeading {
                                                Text("L")
                                                    .font(.system(size: 10, weight: .bold, design: .rounded))
                                                    .foregroundStyle(.black)
                                                    .frame(width: 18, height: 18)
                                                    .background(Color.white)
                                                    .clipShape(Circle())
                                                    .padding(4)
                                            }
                                            Spacer()
                                            if isTrailing {
                                                Text("R")
                                                    .font(.system(size: 10, weight: .bold, design: .rounded))
                                                    .foregroundStyle(.black)
                                                    .frame(width: 18, height: 18)
                                                    .background(Color.white)
                                                    .clipShape(Circle())
                                                    .padding(4)
                                            }
                                        } else {
                                            Image(systemName: "checkmark")
                                                .font(.system(size: 10, weight: .bold))
                                                .foregroundStyle(.black)
                                                .frame(width: 18, height: 18)
                                                .background(Color.white)
                                                .clipShape(Circle())
                                                .padding(4)
                                            Spacer()
                                        }
                                    }
                                    Spacer()
                                }
                            }
                        }
                    }
                    .buttonStyle(.plain)
                    // Jiggle animation
                    .rotationEffect(.degrees(viewModel.activeSelectionSlot != .none ? (isJiggling ? 2 : -2) : 0))
                    .animation(
                        viewModel.activeSelectionSlot != .none 
                            ? .easeInOut(duration: 0.12).repeatForever(autoreverses: true) 
                            : .default, 
                        value: isJiggling
                    )
                    .onChange(of: viewModel.activeSelectionSlot) { _, newValue in
                        if newValue != .none {
                            isJiggling.toggle()
                        }
                    }

                    Text(item.name)
                        .font(.system(size: 10, weight: .medium, design: .rounded))
                        .foregroundStyle(.primary) // Keep text visible
                        .lineLimit(1)
                        .minimumScaleFactor(0.7)
                        .multilineTextAlignment(.center)
                }
            }
        }
        .onAppear {
            if viewModel.activeSelectionSlot != .none {
                isJiggling.toggle()
            }
        }
    }
}
