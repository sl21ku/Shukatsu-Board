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

            QuickAddView()
                .tabItem {
                    Label("追加", systemImage: "plus.circle")
                }

            TaskListView()
                .tabItem {
                    Label("タスク", systemImage: "calendar")
                }

            SettingsView()
                .tabItem {
                    Label("設定", systemImage: "gearshape")
                }
        }
    }
}
