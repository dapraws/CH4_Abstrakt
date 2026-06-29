import SwiftUI

struct BottomBar: View {
    @Binding var selectedTab: BottomBarTab
    let libraryCount: Int
    var isLibraryPresented = false
    var onLibraryBack: (() -> Void)?

    private let tabIconFont = Font.system(size: 18, weight: .bold, design: .rounded)
    private let backIconFont = Font.system(size: 16, weight: .bold, design: .rounded)
    private let libraryBadgeFont = Font.system(size: 12, weight: .black, design: .rounded)

    var body: some View {
        ZStack {
            tabBarContent
                .opacity(isLibraryPresented ? 0 : 1)
                .scaleEffect(isLibraryPresented ? 0.98 : 1)
                .offset(y: isLibraryPresented ? 4 : 0)
                .allowsHitTesting(!isLibraryPresented)
                .animation(tabContentAnimation, value: isLibraryPresented)

            backButton
                .opacity(isLibraryPresented ? 1 : 0)
                .scaleEffect(isLibraryPresented ? 1 : 0.96)
                .offset(y: isLibraryPresented ? 0 : 4)
                .allowsHitTesting(isLibraryPresented)
                .animation(backContentAnimation, value: isLibraryPresented)
        }
        .padding(.horizontal, isLibraryPresented ? 18 : 18)
        .frame(width: isLibraryPresented ? 116 : nil)
        .frame(maxWidth: isLibraryPresented ? nil : .infinity)
        .frame(height: 64)
        .scaleEffect(0.94)
        .background(AppColors.tabBar)
        .overlay {
            RoundedRectangle(cornerRadius: isLibraryPresented ? 22 : 27, style: .continuous)
                .stroke(AppColors.tabBarBorder, lineWidth: 0.5)
        }
        .clipShape(RoundedRectangle(cornerRadius: 30, style: .continuous))
        .padding(.horizontal, isLibraryPresented ? 0 : 50)
        .padding(.bottom, AppSpacing.bottomBarInset)
        .animation(containerAnimation, value: isLibraryPresented)
    }

    private var tabBarContent: some View {
        HStack(spacing: 5) {
            staggeredItem(0) {
                tabButton(.home)
            }
            staggeredItem(1) {
                tabButton(.gallery)
            }
            staggeredItem(2) {
                tabButton(.widgets)
            }
            staggeredItem(3) {
                tabButton(.settings)
            }

            staggeredItem(4) {
                Rectangle()
                    .fill(AppColors.separator)
                    .frame(width: 2, height: 15)
                    .padding(.horizontal, 0)
            }

            staggeredItem(5) {
                Button {
                    selectedTab = .library
                } label: {
                    ZStack {
                        Circle()
                            .fill(Color.white)
                            .frame(width: 22, height: 22)
                            .overlay {
                                Circle()
                                    .stroke(AppColors.tabBarBorder.opacity(0.35), lineWidth: 0.5)
                            }

                        Text("\(libraryCount)")
                            .font(libraryBadgeFont)
                            .foregroundStyle(Color.black)
                    }
                    .frame(maxWidth: .infinity)
                }
                .buttonStyle(.plain)
            }
        }
    }

    private var backButton: some View {
        Button {
            onLibraryBack?()
        } label: {
            HStack(spacing: 8) {
                Image(systemName: "arrowshape.turn.up.backward.fill")
                    .font(backIconFont)

                Text("Back")
                    .font(AppFonts.font(.heading3))
            }
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
        }
        .buttonStyle(.plain)
    }

    private func tabButton(_ tab: BottomBarTab) -> some View {
        Button {
            selectedTab = tab
        } label: {
            Image(systemName: tab.systemImage)
                .font(tabIconFont)
                .foregroundStyle(selectedTab == tab ? AppColors.tabBarIconSelected : AppColors.tabBarIcon)
                .frame(maxWidth: .infinity)
                .frame(height: 22)
        }
        .buttonStyle(.plain)
    }

    private func staggeredItem<Content: View>(_ index: Int, @ViewBuilder content: () -> Content) -> some View {
        let delay = isLibraryPresented ? Double(index) * 0.01 : 0.18 + Double(index) * 0.026

        return content()
            .opacity(isLibraryPresented ? 0 : 1)
            .offset(y: isLibraryPresented ? 3 : 0)
            .animation(.smooth(duration: 0.22).delay(delay), value: isLibraryPresented)
    }

    private var containerAnimation: Animation {
        .smooth(duration: 0.2)
    }

    private var tabContentAnimation: Animation {
        isLibraryPresented ? .smooth(duration: 0.14) : .smooth(duration: 0.2).delay(0.16)
    }

    private var backContentAnimation: Animation {
        isLibraryPresented ? .smooth(duration: 0.2).delay(0.08) : .smooth(duration: 0.12)
    }
}

#Preview {
    ZStack(alignment: .bottom) {
        AppColors.appBackground.ignoresSafeArea()
        BottomBar(selectedTab: .constant(.gallery), libraryCount: 2)
    }
}
