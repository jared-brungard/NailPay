import Foundation
import SwiftData

struct DemoData {

    struct Service {
        let name: String
        let price: Double
    }

    struct PaymentMix {
        let name: String
        let weight: Int
    }

    struct OneOff {
        let month: Int
        let day: Int
        let category: String
        let amount: Double
    }

    struct MonthlyRecurring {
        let name: String
        let amount: Double
        let dayOfMonth: Int
    }

    struct AnnualRecurring {
        let name: String
        let amount: Double
        let month: Int
        let day: Int
    }

    struct Profile {
        let label: String
        let services: [Service]
        let clients: [String]
        let appointmentsPerWeek: Int
        let paymentMix: [PaymentMix]
        let oneOffs: [OneOff]
        let monthly: [MonthlyRecurring]
        let annual: [AnnualRecurring]
    }

    // MARK: - Profiles

    static let beginner = Profile(
        label: "Beginner (~$30k/yr)",
        services: [
            Service(name: "Classic Manicure", price: 40),
            Service(name: "Gel Manicure",     price: 55),
            Service(name: "Pedicure",         price: 50),
            Service(name: "Gel Pedicure",     price: 65),
        ],
        clients: [
            "Emma", "Olivia", "Ava", "Sophia", "Isabella", "Mia",
            "Charlotte", "Amelia", "Harper", "Evelyn", "Abigail",
            "Emily", "Elizabeth", "Sofia",
        ],
        appointmentsPerWeek: 10,
        paymentMix: [
            PaymentMix(name: "Venmo",       weight: 5),
            PaymentMix(name: "Cash",        weight: 3),
            PaymentMix(name: "Credit Card", weight: 2),
        ],
        oneOffs: [
            OneOff(month: 1, day: 15, category: "Sally Beauty Supply", amount: 87.42),
            OneOff(month: 2, day: 4,  category: "Amazon",              amount: 54.18),
            OneOff(month: 3, day: 12, category: "Cuticle and Co",      amount: 145.30),
            OneOff(month: 4, day: 10, category: "Em Beauty",           amount: 78.55),
        ],
        monthly: [
            MonthlyRecurring(name: "Booth Rent",            amount: 250, dayOfMonth: 1),
            MonthlyRecurring(name: "GlossGenius (Booking)", amount: 30,  dayOfMonth: 5),
            MonthlyRecurring(name: "Supplies Restock",      amount: 80,  dayOfMonth: 15),
        ],
        annual: [
            AnnualRecurring(name: "Liability Insurance", amount: 180, month: 2, day: 1),
            AnnualRecurring(name: "Business License",    amount: 75,  month: 4, day: 1),
        ]
    )

    static let established = Profile(
        label: "Established (~$50k/yr)",
        services: [
            Service(name: "Gel Manicure", price: 55),
            Service(name: "Dip Powder",   price: 65),
            Service(name: "Pedicure",     price: 50),
            Service(name: "Gel Pedicure", price: 70),
            Service(name: "Acrylic Fill", price: 60),
        ],
        clients: [
            "Madison", "Ella", "Avery", "Scarlett", "Grace", "Chloe",
            "Victoria", "Riley", "Aria", "Lily", "Aubrey", "Zoey",
            "Hannah", "Layla", "Brooklyn", "Stella", "Natalie",
        ],
        appointmentsPerWeek: 14,
        paymentMix: [
            PaymentMix(name: "Credit Card", weight: 4),
            PaymentMix(name: "Venmo",       weight: 3),
            PaymentMix(name: "Cash",        weight: 3),
        ],
        oneOffs: [
            OneOff(month: 1, day: 8,  category: "Polished Pinkies", amount: 216.50),
            OneOff(month: 1, day: 28, category: "Em Beauty",        amount: 165.40),
            OneOff(month: 2, day: 17, category: "Amazon",           amount: 94.20),
            OneOff(month: 3, day: 22, category: "Cuticle and Co",   amount: 187.55),
            OneOff(month: 4, day: 8,  category: "Em Beauty",        amount: 245.85),
        ],
        monthly: [
            MonthlyRecurring(name: "Booth Rent",            amount: 500, dayOfMonth: 1),
            MonthlyRecurring(name: "GlossGenius Pro",       amount: 50,  dayOfMonth: 5),
            MonthlyRecurring(name: "Business Phone",        amount: 80,  dayOfMonth: 10),
            MonthlyRecurring(name: "Supplies Restock",      amount: 200, dayOfMonth: 15),
            MonthlyRecurring(name: "Business Banking",      amount: 25,  dayOfMonth: 20),
        ],
        annual: [
            AnnualRecurring(name: "Liability Insurance", amount: 280, month: 2, day: 1),
            AnnualRecurring(name: "Business License",    amount: 125, month: 3, day: 15),
            AnnualRecurring(name: "CPA / Tax Prep",      amount: 400, month: 4, day: 10),
        ]
    )

    static let senior = Profile(
        label: "Senior (~$115k/yr)",
        services: [
            Service(name: "Acrylic Full Set", price: 100),
            Service(name: "Acrylic Fill",     price: 75),
            Service(name: "Gel Manicure",     price: 65),
            Service(name: "Dip Powder",       price: 80),
            Service(name: "Spa Pedicure",     price: 95),
            Service(name: "Ombre Nails",      price: 120),
        ],
        clients: [
            "Addison", "Eleanor", "Penelope", "Skylar", "Leah", "Audrey",
            "Allison", "Savannah", "Anna", "Nora", "Hazel", "Aaliyah",
            "Violet", "Maya", "Caroline", "Genesis", "Aubree", "Eliana",
            "Jocelyn", "Quinn", "Brielle",
        ],
        appointmentsPerWeek: 22,
        paymentMix: [
            PaymentMix(name: "Credit Card", weight: 6),
            PaymentMix(name: "Venmo",       weight: 3),
            PaymentMix(name: "Cash",        weight: 1),
        ],
        oneOffs: [
            OneOff(month: 1, day: 5,  category: "Polished Pinkies",     amount: 385.00),
            OneOff(month: 1, day: 14, category: "Em Beauty",            amount: 620.45),
            OneOff(month: 1, day: 26, category: "Sally Beauty Supply",  amount: 267.90),
            OneOff(month: 2, day: 11, category: "Amazon",               amount: 187.30),
            OneOff(month: 2, day: 22, category: "NailSuper",            amount: 445.65),
            OneOff(month: 3, day: 6,  category: "Em Beauty",            amount: 510.20),
            OneOff(month: 3, day: 24, category: "Cuticle and Co",       amount: 378.50),
            OneOff(month: 4, day: 7,  category: "Polished Pinkies",     amount: 295.75),
            OneOff(month: 4, day: 19, category: "Em Beauty",            amount: 480.30),
        ],
        monthly: [
            MonthlyRecurring(name: "Booth Rent (Private Suite)", amount: 1100, dayOfMonth: 1),
            MonthlyRecurring(name: "Vagaro Pro",                 amount: 85,   dayOfMonth: 5),
            MonthlyRecurring(name: "Business Phone",             amount: 95,   dayOfMonth: 10),
            MonthlyRecurring(name: "Supplies Restock",           amount: 400,  dayOfMonth: 15),
            MonthlyRecurring(name: "Business Banking",           amount: 35,   dayOfMonth: 20),
            MonthlyRecurring(name: "Instagram Marketing",        amount: 150,  dayOfMonth: 25),
        ],
        annual: [
            AnnualRecurring(name: "Liability Insurance", amount: 385,  month: 1, day: 15),
            AnnualRecurring(name: "Equipment Upgrade",   amount: 850,  month: 2, day: 20),
            AnnualRecurring(name: "Business License",   amount: 250,   month: 3, day: 10),
            AnnualRecurring(name: "Nail Expo / CE",     amount: 1200,  month: 3, day: 25),
            AnnualRecurring(name: "CPA / Tax Prep",     amount: 650,   month: 4, day: 12),
        ]
    )

    // MARK: - Loader

    @MainActor
    static func load(profile: Profile, modelContext: ModelContext) throws {
        clearAll(modelContext: modelContext)
        let paymentTypes = ensurePaymentTypes(modelContext: modelContext)
        generateAppointments(profile: profile, paymentTypes: paymentTypes, modelContext: modelContext)
        insertExpenses(profile: profile, modelContext: modelContext)
        try modelContext.save()
    }

    // MARK: - Clear

    @MainActor
    private static func clearAll(modelContext: ModelContext) {
        try? modelContext.delete(model: Appointment.self)
        try? modelContext.delete(model: Expense.self)
        try? modelContext.delete(model: RecurringExpense.self)
    }

    // MARK: - Payment Types

    private static let requiredPaymentTypes: [(name: String, fee: Double, sort: Int)] = [
        ("Cash",        0.0, 0),
        ("Credit Card", 2.9, 1),
        ("Venmo",       1.8, 2),
    ]

    @MainActor
    private static func ensurePaymentTypes(modelContext: ModelContext) -> [String: PaymentType] {
        let existing = (try? modelContext.fetch(FetchDescriptor<PaymentType>())) ?? []
        var byName = Dictionary(uniqueKeysWithValues: existing.map { ($0.name, $0) })

        for (name, fee, sort) in requiredPaymentTypes {
            if let pt = byName[name] {
                pt.feeType = "percentage"
                pt.feeAmount = fee
                pt.sortOrder = sort
            } else {
                let pt = PaymentType(name: name, feeType: "percentage", feeAmount: fee, sortOrder: sort)
                modelContext.insert(pt)
                byName[name] = pt
            }
        }
        return byName
    }

    // MARK: - Appointments

    @MainActor
    private static func generateAppointments(
        profile: Profile,
        paymentTypes: [String: PaymentType],
        modelContext: ModelContext
    ) {
        let cal = Calendar(identifier: .gregorian)
        let today = cal.startOfDay(for: Date())
        let yearStart = cal.date(from: DateComponents(year: cal.component(.year, from: today), month: 1, day: 1))!

        let weekdayCounts = appointmentsPerWeekday(total: profile.appointmentsPerWeek)
        let paymentBuckets = expandPaymentMix(profile.paymentMix)

        var clientCursor = 0
        var serviceCursor = 0
        var paymentCursor = 0
        var apptIndex = 0

        var day = yearStart
        while day <= today {
            let weekdayIdx = (cal.component(.weekday, from: day) + 5) % 7  // Mon=0 ... Sun=6
            if weekdayIdx < weekdayCounts.count {
                let count = weekdayCounts[weekdayIdx]
                for slot in 0..<count {
                    let service = profile.services[serviceCursor % profile.services.count]
                    let client = profile.clients[clientCursor % profile.clients.count]
                    let paymentName = paymentBuckets[paymentCursor % paymentBuckets.count]
                    let pt = paymentTypes[paymentName]
                    let tip = tipFor(price: service.price, index: apptIndex)
                    let total = service.price + tip
                    let fee = pt.map { $0.feeAmount / 100.0 * total } ?? 0
                    let apptDate = cal.date(byAdding: .hour, value: 9 + slot, to: day) ?? day

                    let appt = Appointment(
                        date: apptDate,
                        clientName: client,
                        serviceName: service.name,
                        price: service.price,
                        tip: tip,
                        paymentTypeName: pt?.name,
                        fee: fee
                    )
                    modelContext.insert(appt)

                    clientCursor += 1
                    serviceCursor += 1
                    paymentCursor += 1
                    apptIndex += 1
                }
            }
            day = cal.date(byAdding: .day, value: 1, to: day) ?? today.addingTimeInterval(86400)
            if day > today { break }
        }
    }

    private static func appointmentsPerWeekday(total: Int) -> [Int] {
        // Mon..Sat (6 working days)
        var counts = Array(repeating: total / 6, count: 6)
        let remainder = total % 6
        for i in 0..<remainder { counts[i] += 1 }
        return counts
    }

    private static func expandPaymentMix(_ mix: [PaymentMix]) -> [String] {
        var bucket: [String] = []
        for entry in mix {
            for _ in 0..<entry.weight { bucket.append(entry.name) }
        }
        return bucket
    }

    private static func tipFor(price: Double, index: Int) -> Double {
        // Cycle through realistic tip percentages: 0%, 10%, 15%, 18%, 20%, 25%
        let percents: [Double] = [0, 10, 15, 18, 20, 25]
        let pct = percents[index % percents.count]
        return (price * pct / 100.0 * 4).rounded() / 4  // round to nearest $0.25
    }

    // MARK: - Expenses

    @MainActor
    private static func insertExpenses(profile: Profile, modelContext: ModelContext) {
        let cal = Calendar(identifier: .gregorian)
        let today = cal.startOfDay(for: Date())
        let year = cal.component(.year, from: today)
        let yearStart = cal.date(from: DateComponents(year: year, month: 1, day: 1))!

        // One-offs
        for one in profile.oneOffs {
            guard let date = cal.date(from: DateComponents(year: year, month: one.month, day: one.day)) else { continue }
            if date > today { continue }
            modelContext.insert(Expense(date: date, category: one.category, amount: one.amount))
        }

        // Monthly: insert RecurringExpense + materialize past Expense rows
        for m in profile.monthly {
            modelContext.insert(RecurringExpense(
                name: m.name,
                amount: m.amount,
                frequency: "monthly",
                dayOfMonth: m.dayOfMonth,
                startDate: yearStart
            ))

            var probe = yearStart
            while probe <= today {
                let comps = cal.dateComponents([.year, .month, .day], from: probe)
                if comps.day == m.dayOfMonth {
                    modelContext.insert(Expense(date: probe, category: m.name, amount: m.amount))
                }
                probe = cal.date(byAdding: .day, value: 1, to: probe) ?? today.addingTimeInterval(86400)
            }
        }

        // Annual: insert RecurringExpense + materialize if past
        for a in profile.annual {
            modelContext.insert(RecurringExpense(
                name: a.name,
                amount: a.amount,
                frequency: "annual",
                annualMonth: a.month,
                annualDay: a.day,
                startDate: yearStart
            ))

            if let date = cal.date(from: DateComponents(year: year, month: a.month, day: a.day)),
               date <= today {
                modelContext.insert(Expense(date: date, category: a.name, amount: a.amount))
            }
        }
    }
}
