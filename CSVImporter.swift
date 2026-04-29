import Foundation
import SwiftData

enum CSVImportError: Error {
    case fileNotFound(String)
    case badFormat(String)
}

struct CSVImporter {

    static func loadTextFile(named name: String, ext: String) throws -> String {
        guard let url = Bundle.main.url(forResource: name, withExtension: ext) else {
            throw CSVImportError.fileNotFound("\(name).\(ext)")
        }
        return try String(contentsOf: url, encoding: .utf8)
    }

    // Very simple CSV split (works if your fields don't contain commas inside quotes)
    static func rows(from csv: String) -> [[String]] {
        csv
            .split(whereSeparator: \.isNewline)
            .map { String($0) }
            .map { $0.split(separator: ",", omittingEmptySubsequences: false).map(String.init) }
    }

    static func parseISODate(_ s: String) -> Date? {
        let f = DateFormatter()
        f.dateFormat = "yyyy-MM-dd"
        f.locale = Locale(identifier: "en_US_POSIX")
        f.timeZone = TimeZone(secondsFromGMT: 0)
        return f.date(from: s.trimmingCharacters(in: .whitespacesAndNewlines))
    }

    static func importAppointments(modelContext: ModelContext, filename: String = "appointments") throws {
        let text = try loadTextFile(named: filename, ext: "csv")
        let all = rows(from: text)
        guard all.count >= 2 else { return } // header + at least 1 row

        // Assume header: date,clientName,serviceName,price,tip
        for (i, cols) in all.dropFirst().enumerated() {
            guard cols.count >= 5 else { throw CSVImportError.badFormat("appointments row \(i+2)") }
            guard let date = parseISODate(cols[0]) else { throw CSVImportError.badFormat("bad date on row \(i+2)") }
            let client = cols[1]
            let service = cols[2]
            let price = Double(cols[3]) ?? 0
            let tip = Double(cols[4]) ?? 0

            modelContext.insert(Appointment(date: date, clientName: client, serviceName: service, price: price, tip: tip))
        }
    }

    static func importExpenses(modelContext: ModelContext, filename: String = "expenses") throws {
        let text = try loadTextFile(named: filename, ext: "csv")
        let all = rows(from: text)
        guard all.count >= 2 else { return }

        // header: date,category,amount
        for (i, cols) in all.dropFirst().enumerated() {
            guard cols.count >= 3 else { throw CSVImportError.badFormat("expenses row \(i+2)") }
            guard let date = parseISODate(cols[0]) else { throw CSVImportError.badFormat("bad date on row \(i+2)") }
            let category = cols[1]
            let amount = Double(cols[2]) ?? 0

            modelContext.insert(Expense(date: date, category: category, amount: amount))
        }
    }
}

struct ExcelImporter {
    static func importAppointmentsFromExcel(modelContext: ModelContext) throws {
        let appointments: [(String, String, Double, Double)] = [
            ("2026-01-02", "Gen", 50.0, 0.0), ("2026-01-02", "Danika", 90.0, 5.0), ("2026-01-02", "Olivia", 55.0, 5.0), ("2026-01-02", "Chloe", 54.0, 10.8), ("2026-01-05", "Alysa", 60.0, 15.0), ("2026-01-05", "Brandie", 50.0, 10.0), ("2026-01-05", "Abby", 60.0, 9.0), ("2026-01-05", "Kenna", 60.0, 15.0), ("2026-01-06", "Whitney l", 56.0, 5.0), ("2026-01-06", "Emily", 60.0, 10.0), ("2026-01-06", "Maddie", 50.0, 10.0), ("2026-01-06", "Claudette", 60.0, 12.0), ("2026-01-07", "Livie", 60.0, 15.0), ("2026-01-07", "Mia", 68.0, 0.0), ("2026-01-07", "Shelly", 55.0, 0.0), ("2026-01-08", "Jazmine", 65.0, 10.0), ("2026-01-08", "Ayleth", 66.0, 4.0), ("2026-01-08", "Alanna", 66.0, 4.0), ("2026-01-08", "Alanna", 45.0, 9.0), ("2026-01-09", "Andrea m", 60.0, 5.0), ("2026-01-09", "Kendra", 50.0, 7.5), ("2026-01-09", "Lily", 65.0, 5.0), ("2026-01-09", "KP", 55.0, 5.0), ("2026-01-09", "Gen", 45.0, 15.0), ("2026-01-12", "Megan", 65.0, 13.0), ("2026-01-12", "Leslie", 68.0, 17.0), ("2026-01-12", "Whitney", 65.0, 25.0), ("2026-01-12", "Saige", 50.0, 0.0), ("2026-01-13", "Morgan l", 50.0, 5.0), ("2026-01-13", "Gayle", 54.0, 0.0), ("2026-01-13", "Morgan", 58.0, 5.0), ("2026-01-14", "Cheryl", 70.0, 0.0), ("2026-01-14", "Cheryl", 75.0, 0.0), ("2026-01-14", "Jocelyn", 60.0, 0.0), ("2026-01-14", "Cris", 50.0, 15.0), ("2026-01-15", "Andrea r", 60.0, 13.0), ("2026-01-15", "Ashley", 60.0, 15.0), ("2026-01-15", "Mylee", 60.0, 3.0), ("2026-01-16", "Kristin", 50.0, 10.0), ("2026-01-16", "Tamra", 45.0, 11.25), ("2026-01-16", "Thalia", 65.0, 10.0), ("2026-01-19", "Angelica", 37.0, 7.4), ("2026-01-19", "Britany", 60.0, 0.0), ("2026-01-19", "Brandy", 50.0, 0.0), ("2026-01-19", "Carly", 50.0, 15.0), ("2026-01-20", "Andrea c", 60.0, 5.0), ("2026-01-20", "DeAnne", 60.0, 0.0), ("2026-01-20", "Sasha", 50.0, 5.0), ("2026-01-20", "Morgan", 55.0, 5.0), ("2026-01-21", "Kristin", 50.0, 10.0), ("2026-01-21", "Kathryn", 56.0, 4.0), ("2026-01-21", "Lacey", 65.0, 10.0), ("2026-01-22", "Andrea t", 65.0, 10.0), ("2026-01-22", "Morgan", 45.0, 15.0), ("2026-01-22", "Rachel", 58.0, 3.0), ("2026-01-23", "Tania", 60.0, 12.0), ("2026-01-23", "Cortney", 60.0, 5.0), ("2026-01-23", "Ashlyn", 60.0, 7.5), ("2026-01-23", "Michelle", 45.0, 5.0), ("2026-01-26", "Hannah b", 60.0, 10.0), ("2026-01-26", "Kristen", 60.0, 15.0), ("2026-01-26", "Heather", 58.0, 10.0), ("2026-01-26", "Desiree", 48.0, 4.0), ("2026-01-27", "Andrea m", 60.0, 15.0), ("2026-01-27", "KP", 55.0, 0.0), ("2026-01-27", "Morgan", 50.0, 10.0), ("2026-01-28", "Danika", 90.0, 0.0), ("2026-01-28", "Chloe", 54.0, 5.4), ("2026-01-28", "Kristin", 50.0, 5.0), ("2026-01-29", "Hannah b", 60.0, 0.0), ("2026-01-29", "Tania", 60.0, 0.0), ("2026-01-29", "Morgan", 45.0, 15.0), ("2026-01-29", "Susan", 60.0, 15.0), ("2026-01-30", "Kristen", 60.0, 10.0), ("2026-01-30", "Mylee", 60.0, 3.0), ("2026-01-30", "Lacey", 65.0, 10.0), ("2026-02-02", "Gen", 50.0, 0.0), ("2026-02-02", "Danika", 90.0, 5.0), ("2026-02-02", "Olivia", 55.0, 5.0), ("2026-02-02", "Chloe", 54.0, 10.8), ("2026-02-05", "Alysa", 60.0, 15.0), ("2026-02-05", "Brandie", 50.0, 10.0), ("2026-02-05", "Abby", 60.0, 9.0), ("2026-02-05", "Kenna", 60.0, 15.0), ("2026-02-06", "Whitney l", 56.0, 5.0), ("2026-02-06", "Emily", 60.0, 10.0), ("2026-02-06", "Maddie", 50.0, 10.0), ("2026-02-06", "Claudette", 60.0, 12.0), ("2026-02-09", "Livie", 60.0, 15.0), ("2026-02-09", "Mia", 68.0, 0.0), ("2026-02-09", "Shelly", 55.0, 0.0), ("2026-02-10", "Jazmine", 65.0, 10.0), ("2026-02-10", "Ayleth", 66.0, 4.0), ("2026-02-10", "Alanna", 66.0, 4.0), ("2026-02-10", "Alanna", 45.0, 9.0), ("2026-02-11", "Andrea m", 60.0, 5.0), ("2026-02-11", "Kendra", 50.0, 7.5), ("2026-02-11", "Lily", 65.0, 5.0), ("2026-02-11", "KP", 55.0, 5.0), ("2026-02-11", "Gen", 45.0, 15.0), ("2026-02-12", "Megan", 65.0, 13.0), ("2026-02-12", "Leslie", 68.0, 17.0), ("2026-02-12", "Whitney", 65.0, 25.0), ("2026-02-12", "Saige", 50.0, 0.0), ("2026-02-13", "Morgan l", 50.0, 5.0), ("2026-02-13", "Gayle", 54.0, 0.0), ("2026-02-13", "Morgan", 58.0, 5.0), ("2026-02-16", "Cheryl", 70.0, 0.0), ("2026-02-16", "Cheryl", 75.0, 0.0), ("2026-02-16", "Jocelyn", 60.0, 0.0), ("2026-02-16", "Cris", 50.0, 15.0), ("2026-02-17", "Andrea r", 60.0, 13.0), ("2026-02-17", "Ashley", 60.0, 15.0), ("2026-02-17", "Mylee", 60.0, 3.0), ("2026-02-18", "Kristin", 50.0, 10.0), ("2026-02-18", "Tamra", 45.0, 11.25), ("2026-02-18", "Thalia", 65.0, 10.0), ("2026-02-19", "Angelica", 37.0, 7.4), ("2026-02-19", "Britany", 60.0, 0.0), ("2026-02-19", "Brandy", 50.0, 0.0), ("2026-02-19", "Carly", 50.0, 15.0), ("2026-02-20", "Andrea c", 60.0, 5.0), ("2026-02-20", "DeAnne", 60.0, 0.0), ("2026-02-20", "Sasha", 50.0, 5.0), ("2026-02-20", "Morgan", 55.0, 5.0), ("2026-02-23", "Kristin", 50.0, 10.0), ("2026-02-23", "Kathryn", 56.0, 4.0), ("2026-02-23", "Lacey", 65.0, 10.0), ("2026-02-24", "Andrea t", 65.0, 10.0), ("2026-02-24", "Morgan", 45.0, 15.0), ("2026-02-24", "Rachel", 58.0, 3.0), ("2026-02-25", "Tania", 60.0, 12.0), ("2026-02-25", "Cortney", 60.0, 5.0), ("2026-02-25", "Ashlyn", 60.0, 7.5), ("2026-02-25", "Michelle", 45.0, 5.0), ("2026-02-26", "Hannah b", 60.0, 10.0), ("2026-02-26", "Kristen", 60.0, 15.0), ("2026-02-26", "Heather", 58.0, 10.0), ("2026-02-26", "Desiree", 48.0, 4.0), ("2026-03-02", "Andrea m", 60.0, 15.0), ("2026-03-02", "KP", 55.0, 0.0), ("2026-03-02", "Morgan", 50.0, 10.0), ("2026-03-03", "Danika", 90.0, 0.0), ("2026-03-03", "Chloe", 54.0, 5.4), ("2026-03-03", "Kristin", 50.0, 5.0), ("2026-03-04", "Hannah b", 60.0, 0.0), ("2026-03-04", "Tania", 60.0, 0.0), ("2026-03-04", "Morgan", 45.0, 15.0), ("2026-03-04", "Susan", 60.0, 15.0), ("2026-03-05", "Kristen", 60.0, 10.0), ("2026-03-05", "Mylee", 60.0, 3.0), ("2026-03-05", "Lacey", 65.0, 10.0), ("2026-03-09", "Gen", 50.0, 0.0), ("2026-03-09", "Danika", 90.0, 5.0), ("2026-03-09", "Olivia", 55.0, 5.0), ("2026-03-09", "Chloe", 54.0, 10.8), ("2026-03-10", "Alysa", 60.0, 15.0), ("2026-03-10", "Brandie", 50.0, 10.0), ("2026-03-10", "Abby", 60.0, 9.0), ("2026-03-10", "Kenna", 60.0, 15.0), ("2026-03-11", "Whitney l", 56.0, 5.0), ("2026-03-11", "Emily", 60.0, 10.0), ("2026-03-11", "Maddie", 50.0, 10.0), ("2026-03-11", "Claudette", 60.0, 12.0), ("2026-03-12", "Livie", 60.0, 15.0), ("2026-03-12", "Mia", 68.0, 0.0), ("2026-03-12", "Shelly", 55.0, 0.0), ("2026-03-16", "Jazmine", 65.0, 10.0), ("2026-03-16", "Ayleth", 66.0, 4.0), ("2026-03-16", "Alanna", 66.0, 4.0), ("2026-03-16", "Alanna", 45.0, 9.0), ("2026-03-17", "Andrea m", 60.0, 5.0), ("2026-03-17", "Kendra", 50.0, 7.5), ("2026-03-17", "Lily", 65.0, 5.0), ("2026-03-17", "KP", 55.0, 5.0), ("2026-03-17", "Gen", 45.0, 15.0), ("2026-03-18", "Megan", 65.0, 13.0), ("2026-03-18", "Leslie", 68.0, 17.0), ("2026-03-18", "Whitney", 65.0, 25.0), ("2026-03-18", "Saige", 50.0, 0.0), ("2026-03-19", "Morgan l", 50.0, 5.0), ("2026-03-19", "Gayle", 54.0, 0.0), ("2026-03-19", "Morgan", 58.0, 5.0), ("2026-03-23", "Cheryl", 70.0, 0.0), ("2026-03-23", "Cheryl", 75.0, 0.0), ("2026-03-23", "Jocelyn", 60.0, 0.0), ("2026-03-23", "Cris", 50.0, 15.0), ("2026-03-24", "Andrea r", 60.0, 13.0), ("2026-03-24", "Ashley", 60.0, 15.0), ("2026-03-24", "Mylee", 60.0, 3.0), ("2026-03-25", "Kristin", 50.0, 10.0), ("2026-03-25", "Tamra", 45.0, 11.25), ("2026-03-25", "Thalia", 65.0, 10.0), ("2026-03-26", "Angelica", 37.0, 7.4), ("2026-03-26", "Britany", 60.0, 0.0), ("2026-03-26", "Brandy", 50.0, 0.0), ("2026-03-26", "Carly", 50.0, 15.0), ("2026-03-27", "Andrea c", 60.0, 5.0), ("2026-03-27", "DeAnne", 60.0, 0.0), ("2026-03-27", "Sasha", 50.0, 5.0), ("2026-03-27", "Morgan", 55.0, 5.0), ("2026-03-30", "Kristin", 50.0, 10.0), ("2026-03-30", "Kathryn", 56.0, 4.0), ("2026-03-30", "Lacey", 65.0, 10.0), ("2026-03-31", "Andrea t", 65.0, 10.0), ("2026-03-31", "Morgan", 45.0, 15.0), ("2026-03-31", "Rachel", 58.0, 3.0), ("2026-04-01", "Tania", 60.0, 12.0), ("2026-04-01", "Cortney", 60.0, 5.0), ("2026-04-01", "Ashlyn", 60.0, 7.5), ("2026-04-01", "Michelle", 45.0, 5.0), ("2026-04-02", "Hannah b", 60.0, 10.0), ("2026-04-02", "Kristen", 60.0, 15.0), ("2026-04-02", "Heather", 58.0, 10.0), ("2026-04-02", "Desiree", 48.0, 4.0), ("2026-04-06", "Andrea m", 60.0, 15.0), ("2026-04-06", "KP", 55.0, 0.0), ("2026-04-06", "Morgan", 50.0, 10.0), ("2026-04-07", "Danika", 90.0, 0.0), ("2026-04-07", "Chloe", 54.0, 5.4), ("2026-04-07", "Kristin", 50.0, 5.0), ("2026-04-08", "Hannah b", 60.0, 0.0), ("2026-04-08", "Tania", 60.0, 0.0), ("2026-04-08", "Morgan", 45.0, 15.0), ("2026-04-08", "Susan", 60.0, 15.0), ("2026-04-09", "Kristen", 60.0, 10.0), ("2026-04-09", "Mylee", 60.0, 3.0), ("2026-04-09", "Lacey", 65.0, 10.0),
        ]

        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"

        for (dateStr, clientName, price, tip) in appointments {
            guard let date = dateFormatter.date(from: dateStr) else { continue }
            guard price > 0 else { continue }
            let appointment = Appointment(date: date, clientName: clientName, serviceName: clientName, price: price, tip: tip)
            modelContext.insert(appointment)
        }

        try modelContext.save()
    }

    static func importExpensesFromExcel(modelContext: ModelContext) throws {
        let expenses = [
            ("2026-01-21", "Cuticle and Co", 86.86),
            ("2026-02-11", "Amazon", 96.85),
            ("2026-02-15", "Polished pinkies", 216.50),
            ("2026-02-19", "Target", 5.34),
            ("2026-03-08", "Em beauty", 376.56),
            ("2026-03-26", "Amazon", 106.46),
        ]

        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"

        for (dateStr, category, amount) in expenses {
            guard let date = dateFormatter.date(from: dateStr) else { continue }
            let expense = Expense(date: date, category: category, amount: amount)
            modelContext.insert(expense)
        }

        try modelContext.save()
    }
}

struct RecurringExpenseHelper {
    static func processRecurringExpenses(modelContext: ModelContext, recurringExpenses: [RecurringExpense]) {
        let today = Calendar.current.startOfDay(for: Date())
        print("RecurringExpenseHelper: Processing \(recurringExpenses.count) recurring expenses")

        for recurring in recurringExpenses {
            guard let recurringStart = recurring.startDate else {
                print("  Skipping \(recurring.name) — no startDate")
                continue
            }
            let startDate = Calendar.current.startOfDay(for: recurringStart)
            let endDate = recurring.endDate.map { Calendar.current.startOfDay(for: $0) }

            var currentDate = startDate
            while currentDate <= today {
                defer { currentDate = Calendar.current.date(byAdding: .day, value: 1, to: currentDate) ?? today }

                if let endDate = endDate, currentDate > endDate {
                    break
                }

                if shouldCreateExpense(recurring: recurring, date: currentDate) {
                    if !checkIfExpenseExists(modelContext: modelContext, name: recurring.name, date: currentDate) {
                        let expense = Expense(date: currentDate, category: recurring.name, amount: recurring.amount)
                        modelContext.insert(expense)
                        print("  Created: \(recurring.name) on \(currentDate)")
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
