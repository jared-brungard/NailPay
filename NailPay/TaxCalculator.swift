import Foundation

struct TaxCalculator {
    // 2024 Tax brackets for Single filers
    static let taxBrackets: [(limit: Double, rate: Double)] = [
        (11600, 0.10),
        (47150, 0.12),
        (100525, 0.22),
        (191950, 0.24),
        (243725, 0.32),
        (609350, 0.35),
        (Double.infinity, 0.37)
    ]

    static let standardDeduction = 13850.0
    static let seSelfEmploymentRate = 0.153
    static let seIncomeThreshold = 0.9235

    // Calculate projected yearly income based on YTD performance
    static func projectYearlyIncome(ytdIncome: Double, currentDate: Date) -> Double {
        let calendar = Calendar.current
        let dayOfYear = calendar.ordinality(of: .day, in: .year, for: currentDate) ?? 1
        let isLeapYear = calendar.dateComponents([.year], from: currentDate).year! % 4 == 0
        let daysInYear = isLeapYear ? 366 : 365

        guard dayOfYear > 0 else { return 0 }
        return (ytdIncome / Double(dayOfYear)) * Double(daysInYear)
    }

    // Calculate self-employment tax
    static func calculateSETax(netProfit: Double) -> Double {
        let seIncome = max(0, netProfit * seIncomeThreshold)
        let seTax = seIncome * seSelfEmploymentRate
        return seTax
    }

    // Calculate deductible portion of SE tax (50% is deductible from AGI)
    static func seDeduction(seTax: Double) -> Double {
        return seTax / 2.0
    }

    // Calculate federal income tax based on taxable income
    static func calculateFederalIncomeTax(taxableIncome: Double) -> Double {
        guard taxableIncome > 0 else { return 0 }

        var tax = 0.0
        var previousLimit = 0.0

        for (limit, rate) in taxBrackets {
            let incomeInBracket = min(taxableIncome, limit) - previousLimit
            if incomeInBracket <= 0 { break }
            tax += incomeInBracket * rate
            previousLimit = limit
        }

        return tax
    }

    // Complete tax calculation for sole proprietor
    static func calculateAnnualTaxes(
        ytdIncome: Double,
        ytdExpenses: Double,
        currentDate: Date
    ) -> AnnualTaxEstimate {
        // Project to year end
        let projectedYearlyIncome = projectYearlyIncome(ytdIncome: ytdIncome, currentDate: currentDate)

        // Calculate net profit
        let netProfit = projectedYearlyIncome - ytdExpenses

        // Calculate self-employment tax
        let seTax = calculateSETax(netProfit: netProfit)
        let seDeductible = seDeduction(seTax: seTax)

        // Calculate AGI (net profit - deductible SE tax)
        let agi = netProfit - seDeductible

        // Calculate taxable income (AGI - standard deduction)
        let taxableIncome = max(0, agi - standardDeduction)

        // Calculate federal income tax
        let incomeTax = calculateFederalIncomeTax(taxableIncome: taxableIncome)

        // Total tax liability
        let totalTax = seTax + incomeTax

        // Quarterly estimated tax
        let quarterlyEstimate = totalTax / 4.0

        return AnnualTaxEstimate(
            projectedYearlyIncome: projectedYearlyIncome,
            projectedYearlyExpenses: ytdExpenses,
            netProfit: netProfit,
            selfEmploymentTax: seTax,
            federalIncomeTax: incomeTax,
            totalTaxLiability: totalTax,
            quarterlyEstimatedTax: quarterlyEstimate,
            taxableIncome: taxableIncome,
            adjustedGrossIncome: agi
        )
    }
}

struct AnnualTaxEstimate {
    let projectedYearlyIncome: Double
    let projectedYearlyExpenses: Double
    let netProfit: Double
    let selfEmploymentTax: Double
    let federalIncomeTax: Double
    let totalTaxLiability: Double
    let quarterlyEstimatedTax: Double
    let taxableIncome: Double
    let adjustedGrossIncome: Double
}
