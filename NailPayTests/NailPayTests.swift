import XCTest
@testable import NailPay

final class NailPayTests: XCTestCase {

    func testIncomeTotal() {
        let income = FinanceCalculator.incomeTotal(pricesAndTips: [
            (price: 50, tip: 10),
            (price: 30, tip: 0)
        ])
        XCTAssertEqual(income, 90, accuracy: 0.0001)
    }

    func testExpenseTotal() {
        let expenses = FinanceCalculator.expenseTotal(amounts: [12.34, 20.00])
        XCTAssertEqual(expenses, 32.34, accuracy: 0.0001)
    }

    func testProfit() {
        let profit = FinanceCalculator.profit(income: 60, expenses: 12.34)
        XCTAssertEqual(profit, 47.66, accuracy: 0.0001)
    }

    func testTaxSetAsideNeverNegative() {
        let tax = FinanceCalculator.taxSetAside(profit: -100, taxRate: 0.25)
        XCTAssertEqual(tax, 0, accuracy: 0.0001)
    }
}
