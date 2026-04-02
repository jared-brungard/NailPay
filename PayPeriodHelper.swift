import Foundation

struct PayPeriod {
    let start: Date
    let end: Date
}

struct PayPeriodHelper {

    // MARK: - Current period

    static func currentPeriod(frequency: String) -> PayPeriod {
        let cal = Calendar.current
        let today = Date()

        switch frequency {
        case "weekly":
            let start = cal.dateInterval(of: .weekOfYear, for: today)?.start ?? today
            let end   = cal.date(byAdding: .day, value: 6, to: start) ?? today
            return PayPeriod(start: start, end: end)

        case "biweekly":
            let start = biweeklyStart(for: today, cal: cal)
            let end   = cal.date(byAdding: .day, value: 13, to: start) ?? today
            return PayPeriod(start: start, end: end)

        default: // monthly
            let start = cal.dateInterval(of: .month, for: today)?.start ?? today
            let end   = cal.dateInterval(of: .month, for: today)
                .flatMap { cal.date(byAdding: .second, value: -1, to: $0.end) } ?? today
            return PayPeriod(start: start, end: end)
        }
    }

    // MARK: - Past periods (most recent first, only up to today)

    static func pastPeriods(frequency: String, count: Int = 24) -> [PayPeriod] {
        let cal = Calendar.current
        let today = Date()
        var result: [PayPeriod] = []

        switch frequency {
        case "weekly":
            let currentStart = cal.dateInterval(of: .weekOfYear, for: today)?.start ?? today
            for i in 1...count {
                guard let start = cal.date(byAdding: .weekOfYear, value: -i, to: currentStart),
                      let end   = cal.date(byAdding: .day, value: 6, to: start) else { continue }
                result.append(PayPeriod(start: start, end: end))
            }

        case "biweekly":
            let currentStart = biweeklyStart(for: today, cal: cal)
            for i in 1...count {
                guard let start = cal.date(byAdding: .day, value: -(i * 14), to: currentStart),
                      let end   = cal.date(byAdding: .day, value: 13, to: start) else { continue }
                result.append(PayPeriod(start: start, end: end))
            }

        default: // monthly
            for i in 1...count {
                guard let ref   = cal.date(byAdding: .month, value: -i, to: today),
                      let start = cal.dateInterval(of: .month, for: ref)?.start,
                      let end   = cal.dateInterval(of: .month, for: ref)
                                    .flatMap({ cal.date(byAdding: .second, value: -1, to: $0.end) })
                else { continue }
                result.append(PayPeriod(start: start, end: end))
            }
        }

        return result
    }

    // MARK: - Private

    private static func biweeklyStart(for date: Date, cal: Calendar) -> Date {
        var anchor = DateComponents()
        anchor.year = 2025; anchor.month = 1; anchor.day = 6
        let anchorDate = cal.date(from: anchor) ?? date
        let daysSince = cal.dateComponents([.day], from: anchorDate, to: date).day ?? 0
        let periodIndex = daysSince >= 0 ? daysSince / 14 : (daysSince - 13) / 14
        return cal.date(byAdding: .day, value: periodIndex * 14, to: anchorDate) ?? date
    }
}
