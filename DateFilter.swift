import Foundation

enum TimeFilter: String, CaseIterable, Identifiable {
    case all = "All"
    case month = "Month"
    case year = "Year"

    var id: String { rawValue }
}

struct DateRangeHelper {
    static func range(for filter: TimeFilter, now: Date = .now) -> (start: Date?, end: Date?) {
        let calendar = Calendar.current

        switch filter {
        case .all:
            return (nil, nil)

        case .month:
            let start = calendar.date(from: calendar.dateComponents([.year, .month], from: now))!
            let end = calendar.date(byAdding: .month, value: 1, to: start)!
            return (start, end)

        case .year:
            let start = calendar.date(from: calendar.dateComponents([.year], from: now))!
            let end = calendar.date(byAdding: .year, value: 1, to: start)!
            return (start, end)
        }
    }
}
