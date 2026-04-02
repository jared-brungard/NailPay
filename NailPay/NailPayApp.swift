//
//  NailPayApp.swift
//  NailPay
//
//  Created by Jared Brungard on 2/22/26.
//

import SwiftUI
import SwiftData

@main
struct NailPayApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(for: [Appointment.self, Expense.self, PaymentType.self, RecurringExpense.self])
    }
}
