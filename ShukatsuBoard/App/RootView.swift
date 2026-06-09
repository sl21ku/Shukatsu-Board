import SwiftUI

struct RootView: View {
    var body: some View {
        TabView {
            HomeView()
                .tabItem {
                    Label("ホーム", systemImage: "house")
                }

            CompanyListView()
                .tabItem {
                    Label("企業", systemImage: "building.2")
                }

            ComparisonView()
                .tabItem {
                    Label("比較", systemImage: "tablecells")
                }

            TaskListView()
                .tabItem {
                    Label("タスク", systemImage: "calendar")
                }
        }
        .tint(AppTheme.teal)
    }
}
