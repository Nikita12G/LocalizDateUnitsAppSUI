//
//  ContentView.swift
//  LocalizDateUnitsAppSUI
//
//  Created by Никита Гуляев on 25.07.2024.
//

import SwiftUI

struct ContentView: View {
    
    let tableViewSourceKeys: [String] = [
        "zero",
        "one",
        "two",
        "three",
        "four",
        "five",
        "six",
        "seven",
        "eight",
        "nine"
    ]
    
    @AppStorage("language") private var currentSysLanguage = Locale.current.language.languageCode?.identifier ?? "ru"
    @State private var toggleState: Bool = false
    
    var body: some View {
        VStack {
            List(tableViewSourceKeys, id: \.self) { key in
                Text(NSLocalizedString(key, comment: "List view source"))
            }
            Toggle(isOn: Binding(
                get: { toggleState },
                set: { isOn in
                    toggleState = isOn
                    currentSysLanguage = isOn ? "ru" : "en"
                    Bundle.setLanguage(currentSysLanguage)
                }
            )) {
                Text(NSLocalizedString("Russian language", comment: ""))
            }
            .onAppear {
                toggleState = (currentSysLanguage == "ru")
            }
            .padding()
            Text(Date().description)
            Text(formattedDate(style: .full))
            Text(formattedDate(style: .medium))
            Text(formattedDate(style: .short))
                .padding(.bottom)
            Text(NSLocalizedString("100 meters in", comment: ""))
            Text("\(NSLocalizedString("kilometers", comment: "")) \(formattedDistance(metersToKilometers(100), unit: UnitLength.kilometers))")
            Text("\(NSLocalizedString("miles", comment: "")) \(formattedDistance(metersToMiles(100), unit: UnitLength.miles))")
        }
    }
    
    private func formattedDate(style: DateFormatter.Style) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = style
        formatter.timeStyle = style
        formatter.locale = Locale(identifier: currentSysLanguage)
        return formatter.string(from: Date())
    }
    
    private func metersToKilometers(_ meters: Double) -> Double {
        let measurement = Measurement(value: meters, unit: UnitLength.meters)
        return measurement.converted(to: .kilometers).value
    }

    private func metersToMiles(_ meters: Double) -> Double {
        let measurement = Measurement(value: meters, unit: UnitLength.meters)
        return measurement.converted(to: .miles).value
    }

    private func formattedDistance(_ distance: Double, unit: UnitLength) -> String {
        let measurement = Measurement(value: distance, unit: unit)
        
        let formatter = MeasurementFormatter()
        formatter.locale = Locale(identifier: currentSysLanguage)
        formatter.unitOptions = .providedUnit
        formatter.numberFormatter.maximumFractionDigits = 2
        
        return formatter.string(from: measurement)
    }
}

#Preview {
    ContentView()
}

private var bundleKey: UInt8 = 0

final class BundleEx: Bundle {
    override func localizedString(forKey key: String, value: String?, table tableName: String?) -> String {
        if let path = objc_getAssociatedObject(self, &bundleKey) as? String, let bundle = Bundle(path: path) {
            return bundle.localizedString(forKey: key, value: value, table: tableName)
        }
        return super.localizedString(forKey: key, value: value, table: tableName)
    }
}

extension Bundle {
    static let once: Void = {
        object_setClass(Bundle.main, BundleEx.self)
    }()
    
    static func setLanguage(_ language: String) {
        Bundle.once
        let value = language.isEmpty ? nil : Bundle.main.path(forResource: language, ofType: "lproj")
        objc_setAssociatedObject(Bundle.main, &bundleKey, value, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
    }
}
