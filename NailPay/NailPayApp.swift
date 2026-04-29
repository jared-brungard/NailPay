//
//  NailPayApp.swift
//  NailPay
//
//  Created by Jared Brungard on 2/22/26.
//

import SwiftUI
import SwiftData
import UIKit

@main
struct NailPayApp: App {
    init() {
        let pink = UIColor(red: 0.98, green: 0.38, blue: 0.66, alpha: 1)

        let nav = UINavigationBarAppearance()
        nav.configureWithOpaqueBackground()
        nav.backgroundColor = .black
        nav.largeTitleTextAttributes = [.foregroundColor: pink]
        nav.titleTextAttributes = [.foregroundColor: pink]
        UINavigationBar.appearance().standardAppearance = nav
        UINavigationBar.appearance().scrollEdgeAppearance = nav
        UINavigationBar.appearance().compactAppearance = nav
        UINavigationBar.appearance().tintColor = pink

        let tab = UITabBarAppearance()
        tab.configureWithOpaqueBackground()
        tab.backgroundColor = .black
        UITabBar.appearance().standardAppearance = tab
        UITabBar.appearance().scrollEdgeAppearance = tab
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .tint(Color(red: 0.98, green: 0.38, blue: 0.66))
                .preferredColorScheme(.dark)
        }
        .modelContainer(for: [Appointment.self, Expense.self, PaymentType.self, RecurringExpense.self])
    }
}
