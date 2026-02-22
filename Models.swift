//
//  Models.swift
//  NailPay
//


import Foundation
import SwiftData

@Model
final class Appointment {
    var date: Date
    var clientName: String
    var serviceName: String
    var price: Double
    var tip: Double

    init(date: Date = .now, clientName: String, serviceName: String, price: Double, tip: Double = 0) {
        self.date = date
        self.clientName = clientName
        self.serviceName = serviceName
        self.price = price
        self.tip = tip
    }

    var total: Double { price + tip }
}

@Model
final class Expense {
    var date: Date
    var category: String
    var amount: Double

    init(date: Date = .now, category: String, amount: Double) {
        self.date = date
        self.category = category
        self.amount = amount
    }
}
