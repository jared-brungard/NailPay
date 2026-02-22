import Foundation

struct FinanceCalculator {
    static func incomeTotal(pricesAndTips: [(price: Double, tip: Double)]) -> Double {
        pricesAndTips.reduce(0) { $0 + $1.price + $1.tip }
    }

    static func expenseTotal(amounts: [Double]) -> Double {
        amounts.reduce(0, +)
    }

    static func profit(income: Double, expenses: Double) -> Double {
        income - expenses
    }

    static func taxSetAside(profit: Double, taxRate: Double) -> Double {
        max(0, profit) * taxRate
    }
}
