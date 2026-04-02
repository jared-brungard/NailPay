import Foundation
import SwiftData

@Model final class PaymentType {
    var name: String
    var feeType: String      // "percentage" | "flat"
    var feeAmount: Double
    var sortOrder: Int

    init(name: String, feeType: String = "percentage", feeAmount: Double = 0.0, sortOrder: Int = 0) {
        self.name = name
        self.feeType = feeType
        self.feeAmount = feeAmount
        self.sortOrder = sortOrder
    }

    var feeLabel: String {
        feeType == "percentage"
            ? String(format: "%.1f%%", feeAmount)
            : String(format: "$%.2f", feeAmount)
    }
}

@Model final class RecurringExpense {
    var name: String
    var amount: Double
    var frequency: String    // "weekly" | "monthly" | "annual"
    var weekday: Int         // weekly: 1=Sun, 2=Mon ... 7=Sat
    var dayOfMonth: Int      // monthly: 1–31
    var annualMonth: Int     // annual: 1–12
    var annualDay: Int       // annual: 1–31

    init(name: String, amount: Double, frequency: String = "monthly",
         weekday: Int = 2, dayOfMonth: Int = 1,
         annualMonth: Int = 1, annualDay: Int = 1) {
        self.name = name
        self.amount = amount
        self.frequency = frequency
        self.weekday = weekday
        self.dayOfMonth = dayOfMonth
        self.annualMonth = annualMonth
        self.annualDay = annualDay
    }

    var scheduleLabel: String {
        switch frequency {
        case "weekly":
            let days = ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"]
            let day = days[max(0, min(weekday - 1, 6))]
            return "Weekly — Every \(day)"
        case "monthly":
            return "Monthly — Day \(dayOfMonth)"
        case "annual":
            let months = ["Jan","Feb","Mar","Apr","May","Jun",
                          "Jul","Aug","Sep","Oct","Nov","Dec"]
            let month = months[max(0, min(annualMonth - 1, 11))]
            return "Annual — \(month) \(annualDay)"
        default:
            return frequency.capitalized
        }
    }
}
