import Foundation
import SwiftData

struct RecurringExpenseHelper {
    static func processRecurringExpenses(modelContext: ModelContext, recurringExpenses: [RecurringExpense]) {
        let today = Calendar.current.startOfDay(for: Date())
        print("RecurringExpenseHelper: Processing \(recurringExpenses.count) recurring expenses for today: \(today)")

        for recurring in recurringExpenses {
            print("  - Processing: \(recurring.name)")
            let startDate = Calendar.current.startOfDay(for: recurring.startDate)
            let endDate = recurring.endDate.map { Calendar.current.startOfDay(for: $0) }

            var currentDate = startDate
            while currentDate <= today {
                defer { currentDate = Calendar.current.date(byAdding: .day, value: 1, to: currentDate) ?? today }

                if let endDate = endDate, currentDate > endDate {
                    break
                }

                if shouldCreateExpense(recurring: recurring, date: currentDate) {
                    if !checkIfExpenseExists(modelContext: modelContext, name: recurring.name, date: currentDate) {
                        let expense = Expense(
                            date: currentDate,
                            category: recurring.name,
                            amount: recurring.amount
                        )
                        modelContext.insert(expense)
                    }
                }

                if currentDate == today {
                    break
                }
            }
        }

        try? modelContext.save()
    }

    private static func shouldCreateExpense(recurring: RecurringExpense, date: Date) -> Bool {
        let cal = Calendar.current
        let dateComponents = cal.dateComponents([.weekday, .day, .month], from: date)

        switch recurring.frequency {
        case "weekly":
            return dateComponents.weekday == recurring.weekday

        case "monthly":
            return dateComponents.day == recurring.dayOfMonth

        case "annual":
            return dateComponents.month == recurring.annualMonth && dateComponents.day == recurring.annualDay

        default:
            return false
        }
    }

    private static func checkIfExpenseExists(modelContext: ModelContext, name: String, date: Date) -> Bool {
        let startOfDay = Calendar.current.startOfDay(for: date)
        let endOfDay = Calendar.current.date(byAdding: .day, value: 1, to: startOfDay) ?? startOfDay

        let fetchDescriptor = FetchDescriptor<Expense>(
            predicate: #Predicate { expense in
                expense.category == name &&
                expense.date >= startOfDay &&
                expense.date < endOfDay
            }
        )

        if let expenses = try? modelContext.fetch(fetchDescriptor) {
            return !expenses.isEmpty
        }
        return false
    }
}
