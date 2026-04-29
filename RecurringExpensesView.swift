import SwiftUI
import SwiftData

struct RecurringExpensesView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \RecurringExpense.name) private var recurringExpenses: [RecurringExpense]

    @State private var showingAdd = false
    @State private var editingExpense: RecurringExpense?

    var body: some View {
        List {
            ForEach(recurringExpenses) { re in
                HStack {
                    VStack(alignment: .leading, spacing: 2) {
                        Text(re.name).font(.headline)
                        Text(re.scheduleLabel)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    Spacer()
                    Text("$\(re.amount, specifier: "%.2f")")
                        .monospacedDigit()
                        .foregroundStyle(.secondary)
                }
                .contentShape(Rectangle())
                .onTapGesture { editingExpense = re }
            }
            .onDelete(perform: deleteRecurringExpenses)
        }
        .navigationTitle("Recurring Expenses")
        .toolbarTitleDisplayMode(.inlineLarge)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button { showingAdd = true } label: { Image(systemName: "plus") }
            }
        }
        .sheet(isPresented: $showingAdd) {
            RecurringExpenseFormView(existingExpense: nil) { newExpense in
                RecurringExpenseHelper.processRecurringExpenses(
                    modelContext: modelContext,
                    recurringExpenses: [newExpense]
                )
            }
        }
        .sheet(item: $editingExpense) { re in
            RecurringExpenseFormView(existingExpense: re) { _ in
                RecurringExpenseHelper.processRecurringExpenses(
                    modelContext: modelContext,
                    recurringExpenses: recurringExpenses
                )
            }
        }
    }

    private func deleteRecurringExpenses(at offsets: IndexSet) {
        for index in offsets {
            modelContext.delete(recurringExpenses[index])
        }
    }
}

struct RecurringExpenseFormView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext

    let existingExpense: RecurringExpense?
    let onSave: ((RecurringExpense) -> Void)?

    @State private var name: String = ""
    @State private var amountText: String = ""
    @State private var frequency: String = "monthly"

    // Weekly
    @State private var weekday: Int = 2  // Monday

    // Monthly
    @State private var dayOfMonth: Int = 1

    // Annual
    @State private var annualMonth: Int = 1
    @State private var annualDay: Int = 1

    // Date range
    @State private var startDate: Date = Date()
    @State private var hasEndDate: Bool = false
    @State private var endDate: Date = Date()

    private let frequencies = ["weekly", "monthly", "annual"]

    private let weekdays: [(Int, String)] = [
        (1, "Sunday"), (2, "Monday"), (3, "Tuesday"),
        (4, "Wednesday"), (5, "Thursday"), (6, "Friday"), (7, "Saturday")
    ]

    private let monthNames = ["January", "February", "March", "April",
                               "May", "June", "July", "August",
                               "September", "October", "November", "December"]

    private var daysInAnnualMonth: [Int] {
        let days = [31,28,31,30,31,30,31,31,30,31,30,31]
        return Array(1...days[max(0, min(annualMonth - 1, 11))])
    }

    private var isSaveDisabled: Bool {
        name.isEmpty || Double(amountText) == nil
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Name") {
                    TextField("e.g. Booth rent", text: $name)
                }

                Section("Amount & Frequency") {
                    TextField("Amount", text: $amountText)
                        .keyboardType(.decimalPad)
                    Picker("Frequency", selection: $frequency) {
                        ForEach(frequencies, id: \.self) { f in
                            Text(f.capitalized).tag(f)
                        }
                    }
                }

                if frequency == "weekly" {
                    Section("Day of Week") {
                        Picker("Day", selection: $weekday) {
                            ForEach(weekdays, id: \.0) { num, label in
                                Text(label).tag(num)
                            }
                        }
                        .pickerStyle(.inline)
                        .labelsHidden()
                    }
                }

                if frequency == "monthly" {
                    Section("Day of Month") {
                        Picker("Day", selection: $dayOfMonth) {
                            ForEach(1...31, id: \.self) { d in
                                Text(ordinal(d)).tag(d)
                            }
                        }
                        .pickerStyle(.wheel)
                        .labelsHidden()
                        .frame(height: 120)
                    }
                }

                if frequency == "annual" {
                    Section("Month") {
                        Picker("Month", selection: $annualMonth) {
                            ForEach(1...12, id: \.self) { m in
                                Text(monthNames[m - 1]).tag(m)
                            }
                        }
                        .pickerStyle(.inline)
                        .labelsHidden()
                        .onChange(of: annualMonth) { _, _ in
                            if !daysInAnnualMonth.contains(annualDay) {
                                annualDay = daysInAnnualMonth.last ?? 1
                            }
                        }
                    }
                    Section("Day") {
                        Picker("Day", selection: $annualDay) {
                            ForEach(daysInAnnualMonth, id: \.self) { d in
                                Text(ordinal(d)).tag(d)
                            }
                        }
                        .pickerStyle(.wheel)
                        .labelsHidden()
                        .frame(height: 120)
                    }
                }

                Section("Date Range") {
                    DatePicker("Start Date", selection: $startDate, displayedComponents: .date)
                    Toggle("Has End Date", isOn: $hasEndDate)
                    if hasEndDate {
                        DatePicker("End Date", selection: $endDate, displayedComponents: .date)
                    }
                }
            }
            .navigationTitle(existingExpense == nil ? "New Recurring Expense" : "Edit Recurring Expense")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") { save() }
                        .disabled(isSaveDisabled)
                }
            }
            .onAppear { populateIfEditing() }
        }
    }

    private func ordinal(_ n: Int) -> String {
        let suffix: String
        switch n % 100 {
        case 11, 12, 13: suffix = "th"
        default:
            switch n % 10 {
            case 1: suffix = "st"
            case 2: suffix = "nd"
            case 3: suffix = "rd"
            default: suffix = "th"
            }
        }
        return "\(n)\(suffix)"
    }

    private func populateIfEditing() {
        guard let re = existingExpense else { return }
        name = re.name
        amountText = String(re.amount)
        frequency = re.frequency
        weekday = re.weekday
        dayOfMonth = re.dayOfMonth
        annualMonth = re.annualMonth
        annualDay = re.annualDay
        startDate = re.startDate ?? Date()
        if let endDate = re.endDate {
            self.endDate = endDate
            hasEndDate = true
        }
    }

    private func save() {
        let amount = Double(amountText) ?? 0
        if let re = existingExpense {
            re.name = name
            re.amount = amount
            re.frequency = frequency
            re.weekday = weekday
            re.dayOfMonth = dayOfMonth
            re.annualMonth = annualMonth
            re.annualDay = annualDay
            re.startDate = startDate
            re.endDate = hasEndDate ? endDate : nil
            onSave?(re)
        } else {
            let newExpense = RecurringExpense(
                name: name, amount: amount, frequency: frequency,
                weekday: weekday, dayOfMonth: dayOfMonth,
                annualMonth: annualMonth, annualDay: annualDay,
                startDate: startDate, endDate: hasEndDate ? endDate : nil
            )
            modelContext.insert(newExpense)
            onSave?(newExpense)
        }
        dismiss()
    }
}
