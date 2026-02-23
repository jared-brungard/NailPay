import SwiftUI
import SwiftData

struct AppointmentsView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Appointment.date, order: .reverse) private var appointments: [Appointment]

    @State private var filter: TimeFilter = .month
    @State private var showingAdd = false

    private func filteredAppointments() -> [Appointment] {
        let (start, end) = DateRangeHelper.range(for: filter)
        guard let start, let end else { return appointments }
        return appointments.filter { $0.date >= start && $0.date < end }
    }

    var body: some View {
        NavigationStack {
            List {
                ForEach(filteredAppointments()) { appt in
                    VStack(alignment: .leading, spacing: 4) {
                        Text(appt.clientName).font(.headline)
                        Text(appt.serviceName).font(.subheadline).foregroundStyle(.secondary)
                        Text(appt.date, style: .date).font(.caption).foregroundStyle(.secondary)
                        Text("$\(appt.total, specifier: "%.2f")").font(.subheadline)
                    }
                    .padding(.vertical, 4)
                }
                .onDelete(perform: deleteAppointments)
            }
            .navigationTitle("Appointments")
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Picker("", selection: $filter) {
                        ForEach(TimeFilter.allCases) { f in
                            Text(f.rawValue).tag(f)
                        }
                    }
                    .pickerStyle(.segmented)
                    .frame(width: 240)
                }

                ToolbarItem(placement: .topBarTrailing) {
                    Button { showingAdd = true } label: { Image(systemName: "plus") }
                }
            }
            .sheet(isPresented: $showingAdd) {
                AddAppointmentView()
            }
        }
    }

    private func deleteAppointments(at offsets: IndexSet) {
        let current = filteredAppointments()
        for index in offsets {
            modelContext.delete(current[index])
        }
    }
}
