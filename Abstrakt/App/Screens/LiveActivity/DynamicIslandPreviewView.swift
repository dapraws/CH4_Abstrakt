//
//  DynamicIslandPreviewView.swift
//  Abstrakt
//
//  Created by Daffa Yuranizar Arrifi on 09/07/26.
//

import ActivityKit
import SwiftUI

struct DynamicIslandPreviewView: View {
    @Environment(LiveActivityViewModel.self) var viewModel
    var animationNamespace: Namespace.ID

    var body: some View {
        @Bindable var vm = viewModel
        
        VStack(spacing: 16) {
            Text(viewModel.selectedPreviewMode.title)
                .font(.system(size: 20, weight: .semibold, design: .rounded))
                .foregroundStyle(.primary)
                .animation(.easeInOut(duration: 0.2), value: viewModel.selectedPreviewMode)

            TabView(selection: $vm.selectedPreviewMode) {
                ForEach(LiveActivityPreviewMode.allCases) { mode in
                    previewPage(for: mode)
                        .frame(maxHeight: .infinity, alignment: .top)
                        .tag(mode)
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .always))
            .frame(height: 280)
        }
    }
    
    // MARK: - Page Router
    
    @ViewBuilder
    private func previewPage(for mode: LiveActivityPreviewMode) -> some View {
        switch mode {
        case .compact:
            compactModePreview()
        case .expanded:
            placeholderPreview(mode: mode)
        case .lockScreen:
            placeholderPreview(mode: mode)
        }
    }

    // MARK: - Compact Mode (Existing)

    private func compactModePreview() -> some View {
        ZStack(alignment: .top) {
            // iPhone + Pill Background Image
            Image("iphone-live-activity")
                .resizable()
                .scaledToFill()
                .frame(width: 350, height: 196)
                .clipShape(RoundedRectangle(cornerRadius: 40, style: .continuous))
            
            VStack(spacing: 0) {
                // Transparent interactive slots over the image's pill
                HStack {
                    // Leading Slot
                    Button {
                        withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                            viewModel.toggleLeadingSelection()
                        }
                    } label: {
                        if let widget = viewModel.selectedLeadingWidget {
                            CompactWidgetView(item: widget, isLiveActivity: false)
                                .fixedSize()
                                .scaleEffect(0.40)
                                .frame(width: 48, height: 48)
                                .transition(.scale.combined(with: .opacity))
                                .offset(x: 24, y: -15)
                        } else {
                            Image(systemName: "plus")
                                .frame(width: 48, height: 48)
                                .background(viewModel.activeSelectionSlot == .leading ? Color.gray.opacity(0.3) : Color.clear)
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundStyle(.gray)
                                .transition(.scale.combined(with: .opacity))
                                .offset(x: 24, y: -15)
                        }
                    }
                    .buttonStyle(.plain)

                    Spacer()

                    // Trailing Slot
                    Button {
                        withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                            viewModel.toggleTrailingSelection()
                        }
                    } label: {
                        if let widget = viewModel.selectedTrailingWidget {
                            CompactWidgetView(item: widget, isLiveActivity: false)
                                .fixedSize()
                                .scaleEffect(0.65)
                                .frame(width: 48, height: 48)
                                .transition(.scale.combined(with: .opacity))
                                .offset(x: -24, y: -15)
                        } else {
                            Image(systemName: "plus")
                                .frame(width: 48, height: 48)
                                .background(viewModel.activeSelectionSlot == .trailing ? Color.gray.opacity(0.3) : Color.clear)
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundStyle(.gray)
                                .transition(.scale.combined(with: .opacity))
                                .offset(x: -24, y: -15)
                        }
                    }
                    .buttonStyle(.plain)
                }
                .padding(.horizontal, 24)
                .padding(.vertical, 8)
                .frame(width: 280, height: 64)
                .background(Color.clear)
                .clipShape(Capsule())
                .padding(.top, 16)

                // Edit / Start / Stop / Clear Buttons
                HStack(spacing: 8) {
                    Button("Start") {
                        startLiveActivity()
                    }
                    Text("|").foregroundStyle(.gray)
                    Button("Stop") {
                        stopLiveActivity()
                    }
                    Text("|").foregroundStyle(.gray)
                    Button("Clear") { 
                        withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                            viewModel.selectedLeadingWidget = nil
                            viewModel.selectedTrailingWidget = nil
                            viewModel.activeSelectionSlot = .none
                        }
                    }
                }
                .font(.system(size: 12, weight: .medium))
                .foregroundStyle(.white)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(Color.black)
                .clipShape(Capsule())
                .offset(x: 0, y: -20)
                
                
                Text("􀖓 Swipe to navigate between modes.")
                    .padding(.top, 40)
            }
        }
        .padding(.horizontal, 16)
    }

    private func placeholderPreview(mode: LiveActivityPreviewMode) -> some View {
        let isSelectedSlot: Bool = {
            switch mode {
            case .expanded: return viewModel.activeSelectionSlot == .expanded
            case .lockScreen: return viewModel.activeSelectionSlot == .lockScreen
            default: return false
            }
        }()
        
        let selectedWidget: CompactWidgetModel? = {
            switch mode {
            case .expanded: return viewModel.selectedExpandedWidget
            case .lockScreen: return viewModel.selectedLockScreenWidget
            default: return nil
            }
        }()
        
        return ZStack(alignment: .top) {
            Image(mode.assetName)
                .resizable()
                .scaledToFill()
                .frame(width: 350, height: 196)
                .clipShape(RoundedRectangle(cornerRadius: 40, style: .continuous))
            
            VStack(spacing: 0) {
                // Single interactive slot centered
                Button {
                    withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                        if mode == .expanded {
                            viewModel.toggleExpandedSelection()
                        } else if mode == .lockScreen {
                            viewModel.toggleLockScreenSelection()
                        }
                    }
                } label: {
                    if let widget = selectedWidget {
                        CompactWidgetView(item: widget, isLiveActivity: false)
                            .fixedSize()
                            .scaleEffect(0.65)
                            .frame(width: 48, height: 48)
                            .transition(.scale.combined(with: .opacity))
                    } else {
                        Image(systemName: "plus")
                            .frame(width: 48, height: 48)
                            .background(isSelectedSlot ? Color.gray.opacity(0.3) : Color.gray.opacity(0.15))
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundStyle(.gray)
                            .transition(.scale.combined(with: .opacity))
                    }
                }
                .buttonStyle(.plain)
                .padding(.top, 80)
                
                Text(selectedWidget == nil ? "Tap to add widget" : "Tap to change/remove")
                    .font(.system(size: 12, weight: .medium, design: .rounded))
                    .foregroundStyle(.secondary)
                    .padding(.top, 8)
            }
        }
        .padding(.horizontal, 16)
    }
    
    // MARK: - Live Activity Actions
    
    private func startLiveActivity() {
        let attributes = CompactModeAttributes(
            leadingWidget: viewModel.selectedLeadingWidget,
            trailingWidget: viewModel.selectedTrailingWidget
        )
        
        let contentState = CompactModeAttributes.ContentState()
        
        do {
            let activity = try Activity.request(
                attributes: attributes,
                content: .init(state: contentState, staleDate: nil),
                pushType: nil
            )
            print("Successfully started Live Activity: \(activity.id)")
        } catch {
            print("Error starting Live Activity: \(error.localizedDescription)")
        }
    }

    private func stopLiveActivity() {
        Task {
            for activity in Activity<CompactModeAttributes>.activities {
                await activity.end(nil, dismissalPolicy: .immediate)
            }
            print("Successfully stopped all Compact Mode Live Activities")
        }
    }
}
