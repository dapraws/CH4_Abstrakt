import SwiftUI

struct ScrollFadeView<Header: View, BodyContent: View>: View {
    let showsIndicators: Bool
    let headerHeight: CGFloat
    let contentTopPadding: CGFloat
    let contentBottomPadding: CGFloat
    let coordinateSpaceName: String
    @ViewBuilder let header: (_ fadeProgress: CGFloat) -> Header
    @ViewBuilder let content: () -> BodyContent

    @State private var contentOffset: CGFloat = 0

    init(
        showsIndicators: Bool,
        headerHeight: CGFloat,
        contentTopPadding: CGFloat,
        contentBottomPadding: CGFloat = 140,
        coordinateSpaceName: String = "scrollFade",
        @ViewBuilder header: @escaping (_ fadeProgress: CGFloat) -> Header,
        @ViewBuilder content: @escaping () -> BodyContent
    ) {
        self.showsIndicators = showsIndicators
        self.headerHeight = headerHeight
        self.contentTopPadding = contentTopPadding
        self.contentBottomPadding = contentBottomPadding
        self.coordinateSpaceName = coordinateSpaceName
        self.header = header
        self.content = content
    }

    var body: some View {
        ZStack(alignment: .top) {
            ScrollView(showsIndicators: showsIndicators) {
                offsetReader

                content()
                    .padding(.top, headerHeight + contentTopPadding)
                    .padding(.bottom, contentBottomPadding)
            }
            .coordinateSpace(name: coordinateSpaceName)
            .onPreferenceChange(ScrollFadeOffsetKey.self) { value in
                contentOffset = value
            }

            header(fadeProgress)
                .frame(height: headerHeight)
        }
    }

    private var fadeProgress: CGFloat {
        let threshold: CGFloat = 40
        return max(0, min(1, -contentOffset / threshold))
    }

    private var offsetReader: some View {
        GeometryReader { proxy in
            Color.clear
                .preference(
                    key: ScrollFadeOffsetKey.self,
                    value: proxy.frame(in: .named(coordinateSpaceName)).minY
                )
        }
        .frame(height: 0)
    }
}

private struct ScrollFadeOffsetKey: PreferenceKey {
    static var defaultValue: CGFloat = 0

    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}
