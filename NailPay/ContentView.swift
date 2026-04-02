import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {
            DashboardView()
                .tabItem { Label("Dashboard", systemImage: "chart.bar") }

            AppointmentsView()
                .tabItem { Label("Appointments", systemImage: "calendar") }

            ExpensesView()
                .tabItem { Label("Expenses", systemImage: "creditcard") }

            SettingsView()
                .tabItem { Label("Settings", systemImage: "gear") }
        }
    }
}
