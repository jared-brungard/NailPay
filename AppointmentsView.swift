import SwiftUI
import SwiftData

struct AppointmentsView: View {
    @Environment(\.modelContext) private var modelContext
    @AppStorage("paycheckFrequency") private var paycheckFrequency: String = "biweekly"
    @Query(sort: \Appointment.date, order: .reverse) private var appointments: [Appointment]

    @State private var selectedPayPeriod: PayPeriod = PayPeriodHelper.currentPeriod(frequency: "biweekly")
    @State private var availablePeriods: [PayPeriod] = []
    @State private var showingAdd = false
    @State private var editingAppointment: Appointment?

    private var filteredAppointments: [Appointment] {
        appointments.filter { $0.date >= selectedPayPeriod.start && $0.date <= selectedPayPeriod.end }
            .sorted { $0.date < $1.date }
    }

    private var periodSummary: (income: Double, count: Int) {
        let income = filteredAppointments.reduce(0) { $0 + $1.total }
        return (income, filteredAppointments.count)
    }

    var body: some View {
        NavigationStack {
            VStack {
                Picker("Pay Period", selection: $selectedPayPeriod) {
                    ForEach(availablePeriods, id: \.start) { period in
                        Text("\(period.start, style: .date) – \(period.end, style: .date)")
                            .tag(period)
                    }
                }
                .pickerStyle(.menu)
                .padding()

                List {
                    Section("Period Summary") {
                        HStack {
                            Text("Appointments")
                            Spacer()
                            Text("\(periodSummary.count)")
                                .fontWeight(.semibold)
                        }
                        HStack {
                            Text("Total Income")
                            Spacer()
                            Text("$\(periodSummary.income, specifier: "%.2f")")
                                .fontWeight(.semibold)
                                .monospacedDigit()
                        }
                    }

                    Section("Details") {
                        if filteredAppointments.isEmpty {
                            Text("No appointments in this period")
                                .foregroundStyle(.secondary)
                        } else {
                            ForEach(filteredAppointments) { appt in
                                VStack(alignment: .leading, spacing: 4) {
                                    HStack {
                                        VStack(alignment: .leading, spacing: 2) {
                                            Text(appt.clientName).font(.headline)
                                            Text(appt.date, style: .date).font(.caption).foregroundStyle(.secondary)
                                        }
                                        Spacer()
                                        VStack(alignment: .trailing, spacing: 2) {
                                            Text("$\(appt.total, specifier: "%.2f")")
                                                .fontWeight(.semibold)
                                                .monospacedDigit()
                                            if appt.tip > 0 {
                                                Text("Tip: $\(appt.tip, specifier: "%.2f")")
                                                    .font(.caption)
                                                    .foregroundStyle(.secondary)
                                            }
                                            if appt.fee > 0 {
                                                Text("Fee: -$\(appt.fee, specifier: "%.2f")")
                                                    .font(.caption)
                                                    .foregroundStyle(.red)
                                                    .monospacedDigit()
                                            }
                                        }
                                    }
                                    Text(appt.serviceName).font(.subheadline).foregroundStyle(.secondary)
                                }
                                .padding(.vertical, 4)
                                .contentShape(Rectangle())
                                .onTapGesture { editingAppointment = appt }
                            }
                            .onDelete(perform: deleteAppointments)
                        }
                    }
                }
            }
            .navigationTitle("Appointments")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button { showingAdd = true } label: { Image(systemName: "plus") }
                }
            }
            .sheet(isPresented: $showingAdd) {
                AppointmentFormView(existing: nil)
            }
            .sheet(item: $editingAppointment) { appt in
                AppointmentFormView(existing: appt)
            }
        }
        .onAppear(perform: loadAvailablePeriods)
        .onChange(of: paycheckFrequency) { _, _ in loadAvailablePeriods() }
    }

    private func loadAvailablePeriods() {
        var periods = PayPeriodHelper.pastPeriods(frequency: paycheckFrequency, count: 24)
        periods.insert(PayPeriodHelper.currentPeriod(frequency: paycheckFrequency), at: 0)
        availablePeriods = periods
        selectedPayPeriod = periods.first ?? PayPeriodHelper.currentPeriod(frequency: paycheckFrequency)
    }

    private func deleteAppointments(at offsets: IndexSet) {
        for index in offsets {
            modelContext.delete(filteredAppointments[index])
        }
    }
}
