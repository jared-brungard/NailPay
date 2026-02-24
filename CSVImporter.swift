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
