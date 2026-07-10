//
//  CompactModeActivity.swift
//  Abstrakt
//

import ActivityKit
import SwiftUI
import WidgetKit

// MARK: - Shared Widget Models

enum WidgetColor: String, Codable, Hashable {
    case red, blue, green, yellow, purple, cyan, indigo, pink, white, clear
    
    var color: Color {
        switch self {
        case .red: return .red
        case .blue: return .blue
        case .green: return .green
        case .yellow: return .yellow
        case .purple: return .purple
        case .cyan: return .cyan
        case .indigo: return .indigo
        case .pink: return .pink
        case .white: return .white
        case .clear: return .clear
        }
    }
}

enum WidgetLayoutType: String, Codable, Hashable {
    case iconTopTextBottom
    case textTopTextBottom
    case temperatureHighLow
    case caloriesStyle
    case largeTextSplit
    case calendarSplit
    case storageStyle
    case circularProgress
    case largeIcon
}

struct CompactWidgetModel: Codable, Hashable, Identifiable {
    var id = UUID()
    var name: String
    var iconName: String
    var widgetColor: WidgetColor
    
    var layout: WidgetLayoutType
    var primaryText: String? = nil
    var secondaryText: String? = nil
    var progress: Double? = nil
    var isSystemImage: Bool = true
    
    var color: Color { widgetColor.color }
}

struct CompactWidgetView: View {
    var item: CompactWidgetModel
    var isLiveActivity: Bool = false
    
    @ViewBuilder
    private func iconView(size: CGFloat) -> some View {
        if item.isSystemImage {
            Image(systemName: item.iconName)
                .font(.system(size: size))
        } else {
            Image(item.iconName)
                .resizable()
                .scaledToFit()
                .frame(width: size, height: size)
        }
    }
    
    var body: some View {
        switch item.layout {
        case .iconTopTextBottom:
            VStack(spacing: 2) {
                iconView(size: 20)
                    .foregroundStyle(item.color)
                if let text = item.primaryText {
                    Text(text)
                        .font(LiveActivityTypography.numericValue)
                        .foregroundStyle(.white)
                        .liveActivityTextFormatting()
                }
            }
        case .temperatureHighLow:
            HStack(spacing: 2) {
                VStack(alignment: .leading, spacing: 1) {
                    if let high = item.primaryText {
                        HStack(spacing: 2) {
                            Image(systemName: "arrow.up.circle.fill").foregroundStyle(.red)
                            Text(high).foregroundStyle(.white)
                        }
                    }
                    if let low = item.secondaryText {
                        HStack(spacing: 2) {
                            Image(systemName: "arrow.down.circle.fill").foregroundStyle(.blue)
                            Text(low).foregroundStyle(.white)
                        }
                    }
                }
                .font(LiveActivityTypography.detailLabel)
                .liveActivityTextFormatting()
            }
        case .caloriesStyle:
            VStack(spacing: 4) {
                iconView(size: 20)
                    .foregroundStyle(item.color)
                if let val = item.primaryText {
                    Text(val)
                        .font(LiveActivityTypography.numericValue)
                        .foregroundStyle(.white)
                        .liveActivityTextFormatting()
                }
            }
        case .calendarSplit:
            VStack(spacing: 0) {
                if let p = item.primaryText {
                    Text(p)
                        .font(LiveActivityTypography.detailLabel)
                        .textCase(.uppercase)
                        .foregroundStyle(item.color)
                        .liveActivityTextFormatting()
                }
                if let s = item.secondaryText {
                    Text(s)
                        .font(LiveActivityTypography.numericValue)
                        .foregroundStyle(.white)
                        .liveActivityTextFormatting()
                }
            }
        case .textTopTextBottom:
            VStack(spacing: 4) {
                iconView(size: 20)
                    .foregroundStyle(item.color)
                if let val = item.primaryText {
                    Text(val)
                        .font(LiveActivityTypography.numericValue)
                        .foregroundStyle(item.color)
                        .liveActivityTextFormatting()
                }
            }
        case .largeTextSplit:
            HStack(spacing: 4) {
                HStack(spacing: 0) {
                    if let p = item.primaryText {
                        Text(p).foregroundStyle(.red)
                    }
                    if let s = item.secondaryText {
                        Text(s).foregroundStyle(.blue)
                    }
                }
                .font(LiveActivityTypography.singleWord)
                .liveActivityTextFormatting()
            }
        case .storageStyle:
            VStack(spacing: 4) {
                iconView(size: 20)
                    .foregroundStyle(item.color)
                if let val = item.primaryText {
                    Text(val)
                        .font(LiveActivityTypography.numericValue)
                        .foregroundStyle(.white)
                        .liveActivityTextFormatting()
                }
            }
        case .circularProgress:
            VStack(spacing: -2) {
                if let p = item.primaryText {
                    Text(p)
                        .font(LiveActivityTypography.detailLabel)
                        .liveActivityTextFormatting()
                }
                if let s = item.secondaryText {
                    Text(s)
                        .font(LiveActivityTypography.microSubtext)
                        .liveActivityTextFormatting()
                }
            }
            .foregroundStyle(.white)
        case .largeIcon:
            iconView(size: 28)
                .font(LiveActivityTypography.iconOnly)
                .foregroundStyle(item.color)
        }
    }
}

// MARK: - Attributes

struct CompactModeAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        var updated: Bool = false
    }

    var leadingWidget: CompactWidgetModel?
    var trailingWidget: CompactWidgetModel?
}

// MARK: - Widget

struct CompactModeLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: CompactModeAttributes.self) { context in
            // Lock screen / Banner UI
            HStack {
                if let widget = context.attributes.leadingWidget {
                    CompactWidgetView(item: widget, isLiveActivity: true)
                        .scaleEffect(0.8)
                }
                Spacer()
                if let widget = context.attributes.trailingWidget {
                    CompactWidgetView(item: widget, isLiveActivity: true)
                        .scaleEffect(0.8)
                }
            }
            .padding()
        } dynamicIsland: { context in
            DynamicIsland {
                // Expanded UI
                DynamicIslandExpandedRegion(.center) {
                    HStack {
                        if let widget = context.attributes.leadingWidget {
                            CompactWidgetView(item: widget, isLiveActivity: true)
                        }
                        
                        Spacer()
                        
                        if let widget = context.attributes.trailingWidget {
                            CompactWidgetView(item: widget, isLiveActivity: true)
                        }
                    }
                    .padding(.horizontal, 24)
                    .padding(.vertical, 16)
                    .frame(width: 280, height: 64)
                    .background(Color.black)
                    .clipShape(Capsule())
                }
            } compactLeading: {
                if let widget = context.attributes.leadingWidget {
                    CompactWidgetView(item: widget, isLiveActivity: true)
                        .fixedSize()
                        .scaleEffect(0.45)
                        .frame(height: 32) // Let the width adjust naturally to the pill's length
                }
            } compactTrailing: {
                if let widget = context.attributes.trailingWidget {
                    CompactWidgetView(item: widget, isLiveActivity: true)
                        .fixedSize()
                        .scaleEffect(0.45)
                        .frame(height: 32) // Let the width adjust naturally to the pill's length
                }
            } minimal: {
                if let widget = context.attributes.leadingWidget {
                    Image(systemName: widget.iconName)
                        .foregroundStyle(widget.color)
                } else {
                    Image(systemName: "app.badge")
                }
            }
        }
    }
}

#Preview("All Widgets Grid") {
    ScrollView {
        LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 5), spacing: 16) {
            // Safe fallback if defaultGalleryPresets is not available in the current target
            let items: [CompactWidgetModel] = {
                #if canImport(LiveActivityViewModel) // Pseudo-check, it will compile if the extension is in scope
                return CompactWidgetModel.defaultGalleryPresets
                #else
                return [
                    CompactWidgetModel(name: "Sun Event", iconName: "sun.max.fill", widgetColor: .yellow, layout: .iconTopTextBottom, primaryText: "18:00"),
                    CompactWidgetModel(name: "Moon Event", iconName: "moon.fill", widgetColor: .purple, layout: .iconTopTextBottom, primaryText: "04:00"),
                    CompactWidgetModel(name: "Temperature", iconName: "thermometer", widgetColor: .red, layout: .temperatureHighLow, primaryText: "32°", secondaryText: "18°"),
                    CompactWidgetModel(name: "Weather", iconName: "cloud.sun.fill", widgetColor: .white, layout: .largeIcon),
                    CompactWidgetModel(name: "Calories", iconName: "flame.fill", widgetColor: .red, layout: .caloriesStyle, primaryText: "173"),
                    CompactWidgetModel(name: "Calendar", iconName: "calendar", widgetColor: .red, layout: .calendarSplit, primaryText: "Wed", secondaryText: "8"),
                    CompactWidgetModel(name: "Steps", iconName: "figure.walk", widgetColor: .blue, layout: .textTopTextBottom, primaryText: "2.561"),
                    CompactWidgetModel(name: "Temperature", iconName: "thermometer", widgetColor: .blue, layout: .largeTextSplit, primaryText: "32", secondaryText: "18"),
                    CompactWidgetModel(name: "Steps", iconName: "shoeprints.fill", widgetColor: .blue, layout: .caloriesStyle, primaryText: "173"),
                    CompactWidgetModel(name: "Stickers", iconName: "face.smiling.fill", widgetColor: .pink, layout: .largeIcon),
                    CompactWidgetModel(name: "Storage", iconName: "externaldrive.fill", widgetColor: .cyan, layout: .storageStyle, primaryText: "54%"),
                    CompactWidgetModel(name: "Sleep", iconName: "bed.double.fill", widgetColor: .indigo, layout: .circularProgress, primaryText: "4H", secondaryText: "18M", progress: 0.7),
                    CompactWidgetModel(name: "Month", iconName: "calendar", widgetColor: .pink, layout: .largeTextSplit, primaryText: "Jul"),
                    CompactWidgetModel(name: "Day", iconName: "calendar", widgetColor: .red, layout: .largeTextSplit, primaryText: "Wed"),
                    CompactWidgetModel(name: "Date", iconName: "calendar", widgetColor: .white, layout: .largeTextSplit, primaryText: "08"),
                    CompactWidgetModel(name: "Wind", iconName: "wind", widgetColor: .cyan, layout: .storageStyle, primaryText: "SE")
                ]
                #endif
            }()
            
            ForEach(items) { item in
                VStack(spacing: 8) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .fill(Color.black)
                            .frame(width: 64, height: 64)
                        
                        CompactWidgetView(item: item)
                            .fixedSize()
                            .scaleEffect(0.85)
                            .frame(width: 64, height: 64)
                    }
                    Text(item.name)
                        .font(.system(size: 10, weight: .medium, design: .rounded))
                        .foregroundStyle(.primary)
                        .lineLimit(1)
                }
            }
        }
        .padding()
    }
}

#Preview("Specific Widget") {
    let item = CompactWidgetModel(name: "Sun Event", iconName: "sun.max.fill", widgetColor: .yellow, layout: .iconTopTextBottom, primaryText: "18:00")
    
    ZStack {
        RoundedRectangle(cornerRadius: 16, style: .continuous)
            .fill(Color.black)
            .frame(width: 64, height: 64)
        
        CompactWidgetView(item: item)
            .fixedSize()
            .scaleEffect(0.85)
            .frame(width: 64, height: 64)
    }
    .padding()
}
