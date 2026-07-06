import WidgetKit
import SwiftUI

// App Group compartido con la app (debe coincidir con _iosAppGroupId en
// lib/core/home_widget_service.dart y con el entitlement de ambos targets).
private let appGroupId = "group.app.finanzapp.client"

// Paleta Finanzapp (misma que el design system Flutter + widgets Android).
private let cBg = Color(red: 0.043, green: 0.059, blue: 0.051)      // #0B0F0D
private let cBorder = Color(red: 0.122, green: 0.165, blue: 0.149)  // #1F2A26
private let cText = Color(red: 0.910, green: 0.929, blue: 0.918)    // #E8EDEA
private let cDim = Color(red: 0.541, green: 0.584, blue: 0.565)     // #8A9590
private let cMute = Color(red: 0.361, green: 0.400, blue: 0.380)    // #5C6661
private let cGreen = Color(red: 0.122, green: 0.722, blue: 0.478)   // #1FB87A
private let cGreenHi = Color(red: 0.176, green: 0.847, blue: 0.569) // #2DD891
private let cAmber = Color(red: 0.937, green: 0.659, blue: 0.227)   // #EFA83A
private let cAmberInk = Color(red: 0.949, green: 0.722, blue: 0.294) // #F2B84B
private let cRed = Color(red: 0.898, green: 0.376, blue: 0.290)     // #E5604A
private let cRedInk = Color(red: 1.0, green: 0.545, blue: 0.447)    // #FF8B72

// urgency: 2 = vencido/hoy (rojo), 1 = esta semana (ámbar), 0 = tranquilo (verde)
private func dotColor(_ u: Int) -> Color { u == 2 ? cRed : (u == 1 ? cAmber : cGreen) }
private func whenColor(_ u: Int) -> Color { u == 2 ? cRedInk : (u == 1 ? cAmberInk : cDim) }

struct DueItem: Identifiable {
    let id = UUID()
    let name: String
    let amount: String
    let whenShort: String
    let urgency: Int
}

struct FinanzappEntry: TimelineEntry {
    let date: Date
    let period: String
    let falta: String
    let percent: Int
    let weekAmount: String
    let weekCount: Int
    let weekSub: String
    let weekUrgent: Bool
    let hasNext: Bool
    let nextName: String
    let nextAmount: String
    let nextWhen: String
    let nextUrgency: Int
    let items: [DueItem]

    static func load() -> FinanzappEntry {
        let d = UserDefaults(suiteName: appGroupId)
        var items: [DueItem] = []
        let count = d?.integer(forKey: "upcoming_count") ?? 0
        for i in 0..<min(count, 4) {
            items.append(DueItem(
                name: d?.string(forKey: "item\(i)_name") ?? "",
                amount: d?.string(forKey: "item\(i)_amount") ?? "",
                whenShort: d?.string(forKey: "item\(i)_short") ?? "",
                urgency: d?.integer(forKey: "item\(i)_urgency") ?? 0
            ))
        }
        return FinanzappEntry(
            date: Date(),
            period: d?.string(forKey: "period") ?? "",
            falta: d?.string(forKey: "falta") ?? "—",
            percent: d?.integer(forKey: "progress_percent") ?? 0,
            weekAmount: d?.string(forKey: "week_amount") ?? "—",
            weekCount: d?.integer(forKey: "week_count") ?? 0,
            weekSub: d?.string(forKey: "week_sub") ?? "",
            weekUrgent: d?.bool(forKey: "week_urgent") ?? false,
            hasNext: d?.bool(forKey: "has_next") ?? false,
            nextName: d?.string(forKey: "next_name") ?? "",
            nextAmount: d?.string(forKey: "next_amount") ?? "",
            nextWhen: d?.string(forKey: "next_when") ?? "",
            nextUrgency: d?.integer(forKey: "next_urgency") ?? 0,
            items: items
        )
    }

    static let placeholder = FinanzappEntry(
        date: Date(), period: "julio 2026", falta: "$2.425.695", percent: 10,
        weekAmount: "$1.030.578", weekCount: 3, weekSub: "Renta · en 2 días",
        weekUrgent: false, hasNext: true, nextName: "Renta",
        nextAmount: "$18.000", nextWhen: "en 2 días", nextUrgency: 1,
        items: [
            DueItem(name: "Renta", amount: "$18.000", whenShort: "2d", urgency: 1),
            DueItem(name: "Luz", amount: "$32.400", whenShort: "5d", urgency: 1),
            DueItem(name: "Visa", amount: "$175.557", whenShort: "10d", urgency: 0),
        ]
    )
}

struct FinanzappProvider: TimelineProvider {
    func placeholder(in context: Context) -> FinanzappEntry { .placeholder }

    func getSnapshot(in context: Context, completion: @escaping (FinanzappEntry) -> Void) {
        completion(context.isPreview ? .placeholder : .load())
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<FinanzappEntry>) -> Void) {
        // Refrescamos cada hora como fallback; la app fuerza update al cambiar datos.
        let next = Calendar.current.date(byAdding: .hour, value: 1, to: Date()) ?? Date()
        completion(Timeline(entries: [.load()], policy: .after(next)))
    }
}

struct FinanzappWidgetEntryView: View {
    @Environment(\.widgetFamily) var family
    var entry: FinanzappEntry

    var body: some View {
        Group {
            switch family {
            case .systemSmall: SmallView(entry: entry)
            case .systemLarge: LargeView(entry: entry)
            default: MediumView(entry: entry)
            }
        }
        .widgetBackgroundCompat(cBg)
    }
}

// Chico: qué pagar ya — punto de urgencia + próximo vencimiento.
private struct SmallView: View {
    let entry: FinanzappEntry
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(spacing: 6) {
                Circle().fill(dotColor(entry.nextUrgency)).frame(width: 7, height: 7)
                Text(entry.hasNext ? entry.nextWhen.uppercased() : "ESTE MES")
                    .font(.system(size: 10, design: .monospaced))
                    .foregroundColor(entry.hasNext ? whenColor(entry.nextUrgency) : cDim)
            }
            Text(entry.hasNext ? entry.nextName : "Todo al día")
                .font(.system(size: 17, weight: .semibold)).foregroundColor(cText)
                .lineLimit(1).padding(.top, 8)
            Text(entry.hasNext ? entry.nextAmount : entry.falta)
                .font(.system(size: 21, weight: .semibold)).foregroundColor(cText)
            Spacer()
            Text("Finanzapp").font(.system(size: 10)).foregroundColor(cMute)
        }
        .padding(14)
    }
}

// Mediano: esta semana — anillo de progreso + total + próximo.
private struct MediumView: View {
    let entry: FinanzappEntry
    var body: some View {
        HStack(spacing: 14) {
            ZStack {
                Circle().stroke(cBorder, lineWidth: 5)
                Circle()
                    .trim(from: 0, to: CGFloat(max(entry.percent, 0)) / 100)
                    .stroke(cGreen, style: StrokeStyle(lineWidth: 5, lineCap: .round))
                    .rotationEffect(.degrees(-90))
                Text("\(entry.percent)%")
                    .font(.system(size: 12, weight: .semibold)).foregroundColor(cText)
            }
            .frame(width: 54, height: 54)

            VStack(alignment: .leading, spacing: 2) {
                let plural = entry.weekCount == 1 ? "PAGO" : "PAGOS"
                Text(entry.weekCount == 0 ? "ESTA SEMANA" : "ESTA SEMANA · \(entry.weekCount) \(plural)")
                    .font(.system(size: 10, design: .monospaced)).foregroundColor(cDim)
                Text(entry.weekAmount)
                    .font(.system(size: 22, weight: .semibold)).foregroundColor(cText)
                Text(entry.weekCount == 0 ? "Sin vencimientos cercanos" : entry.weekSub)
                    .font(.system(size: 11))
                    .foregroundColor(entry.weekCount == 0 ? cDim : (entry.weekUrgent ? cRedInk : cAmberInk))
                    .lineLimit(1)
            }
            Spacer(minLength: 0)
        }
        .padding(14)
    }
}

// Grande: agenda — puntos de urgencia + día + total pendiente.
private struct LargeView: View {
    let entry: FinanzappEntry
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack {
                Text("Próximos pagos")
                    .font(.system(size: 14, weight: .semibold)).foregroundColor(cText)
                Spacer()
                Text(entry.period.uppercased())
                    .font(.system(size: 11, design: .monospaced)).foregroundColor(cDim)
            }
            if entry.items.isEmpty {
                Spacer()
                Text("Todo al día este mes").font(.system(size: 13)).foregroundColor(cDim)
                Spacer()
            } else {
                ForEach(entry.items) { it in
                    HStack(spacing: 9) {
                        Circle().fill(dotColor(it.urgency)).frame(width: 7, height: 7)
                        Text(it.name)
                            .font(.system(size: 13)).foregroundColor(cText).lineLimit(1)
                        Spacer()
                        Text(it.whenShort)
                            .font(.system(size: 11, design: .monospaced))
                            .foregroundColor(whenColor(it.urgency))
                        Text(it.amount)
                            .font(.system(size: 13, weight: .semibold)).foregroundColor(cText)
                    }
                    .padding(.top, 10)
                }
                Spacer(minLength: 0)
            }
            Rectangle().fill(cBorder).frame(height: 1).padding(.top, 12)
            HStack {
                Text("Total pendiente").font(.system(size: 11)).foregroundColor(cDim)
                Spacer()
                Text(entry.falta)
                    .font(.system(size: 13, weight: .semibold)).foregroundColor(cGreenHi)
            }
            .padding(.top, 10)
        }
        .padding(16)
    }
}

// containerBackground existe en iOS 17+; en versiones previas usamos ZStack.
private extension View {
    @ViewBuilder
    func widgetBackgroundCompat(_ color: Color) -> some View {
        if #available(iOS 17.0, *) {
            self.containerBackground(color, for: .widget)
        } else {
            ZStack { color; self }
        }
    }
}

@main
struct FinanzappWidget: Widget {
    let kind = "FinanzappWidget"
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: FinanzappProvider()) { entry in
            FinanzappWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("Finanzapp")
        .description("Cuánto te falta pagar este mes y tus próximos vencimientos.")
        .supportedFamilies([.systemSmall, .systemMedium, .systemLarge])
    }
}
