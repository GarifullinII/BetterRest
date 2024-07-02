//
//  ContentView.swift
//  BetterRest
//
//  Created by Ildar Garifullin on 01/07/2024.
//

import CoreML
import SwiftUI

struct ContentView: View {
    @State private var wakeUp = defaultWakeTime
    @State private var sleepAmound = 8.0
    @State private var coffeeAmound = 1
    
    @State private var alertTitle = ""
    @State private var alertMessage = ""
    @State private var showingAlert = false
    
    static var defaultWakeTime: Date {
        var components = DateComponents()
        components.hour = 7
        components.minute = 0
        return Calendar.current.date(from: components) ?? .now
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Section("When do you want to wake up?") {
                    DatePicker(
                        "Please enter a time",
                        selection: $wakeUp,
                        displayedComponents: .hourAndMinute
                    )
                    .labelsHidden()
                }
                VStack(alignment: .leading, spacing: 0) {
                    Text("Desired amount of sleep")
                        .font(.headline)
                    Stepper(
                        "\(sleepAmound.formatted()) hours",
                        value: $sleepAmound,
                        in: 4...12,
                        step: 0.35
                    )
                }
                Picker("Daily coffee intake", selection: $coffeeAmound) {
                    ForEach(1..<11) {
                        Text("^[\($0) cup](inflect: true)")
                    }
                }
            }
            .navigationTitle("BetterRest")
            .toolbar {
                Button("Calculate", action: calculateBedtime)
            }
            .alert(alertTitle, isPresented: $showingAlert) {
                Button("Ok") {
                }
            } message: {
                Text(alertMessage)
            }
        }
    }
    
    func calculateBedtime() {
        do {
            let config = MLModelConfiguration()
            let model = try SleepCalculator(configuration: config)
            
            let components = Calendar.current.dateComponents([.hour, .minute], from: wakeUp)
            let hour = (components.hour ?? 0) * 60 * 60
            let minute = (components.minute ?? 0) * 60
            
            let prediction = try model.prediction(
                wake: Double(hour + minute),
                estimatedSleep: sleepAmound,
                coffee: Double(coffeeAmound)
            )
            let sleepTime = wakeUp - prediction.actualSleep
            
            alertTitle = "Your ideal beadtime is ..."
            alertMessage = sleepTime.formatted(date: .omitted, time: .shortened)
        } catch {
            alertTitle = "Error"
            alertMessage = "Sorry, there was a problem calculating your bedtime"
        }
        
        showingAlert = true
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
