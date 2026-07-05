import WidgetKit
import SwiftUI

// App Group compartido con la app (debe coincidir con _iosAppGroupId en
// lib/core/home_widget_service.dart y con el entitlement de ambos targets).
private let appGroupId = "group.app.finanzapp.client"

// Paleta Finanzapp (misma que el design system Flutter).
private let cBg = Color(red: 0.043, green: 0.059, blue: 0.051)      // #0B0F0D
private let cCard = Color(red: 0.078, green: 0.106, blue: 0.094)    // #141B18
private let cBorder = Color(red: 0.122, green: 0.165, blue: 0.149)  // #1F2A26
private let cText = Color(red: 0.910, green: 0.929, blue: 0.918)    // #E8EDEA
private let cDim = Color(red: 0.541, green: 0.584, blue: 0.565)     // #8A9590
private let cMute = Color(red: 0.361, green: 0.400, blue: 0.380)    // #5C6661
private let cPrimary = Color(red: 0.122, green: 0.722, blue: 0.478) // #1FB87A
private let cPrimaryHi = Color(red: 0.176, green: 0.847, blue: 0.569) // #2DD891
private let cLateInk = Color(red: 1.0, green: 0.545, blue: 0.447)   // #FF8B72

struct FinanzappEntry: TimelineEntry {
    let date: Date
    let period: String
    let falta: String
    let progressLabel: String
    let percent: Int
    let hasNext: Bool
    let nextName: String
    let nextAmount: String
    let nextWhen: String
    let nextOverdue: Bool

    static func load() -> FinanzappEntry {
        let d = UserDefaults(suiteName: appGroupId)
        return FinanzappEntry(
            date: Date(),
            period: d?.string(forKey: "period") ?? "",
            falta: d?.string(forKey: "falta") ?? "—",
            progressLabel: d?.string(forKey: "progress_label") ?? "",
            percent: d?.integer(forKey: "progress_percent") ?? 0,
            hasNext: d?.bool(forKey: "has_next") ?? false,
            nextName: d?.string(forKey: "next_name") ?? "",
            nextAmount: d?.string(forKey: "next_amount") ?? "",
            nextWhen: d?.string(forKey: "next_when") ?? "",
            nextOverdue: d?.bool(forKey: "next_overdue") ?? false
        )
    }

    static let placeholder = FinanzappEntry(
        date: Date(), period: "julio 2026", falta: "$2.425.695",
        progressLabel: "0/14 pagadas", percent: 0, hasNext: true,
        nextName: "Renta", nextAmount: "$18.000", nextWhen: "en 2 días",
        nextOverdue: false
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
            if family == .systemSmall {
                SmallView(entry: entry)
            } else {
                MediumView(entry: entry)
            }
        }
        .widgetBackgroundCompat(cBg)
    }
}

private struct MediumView: View {
    let entry: FinanzappEntry
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text(entry.period.uppercased())
                .font(.system(size: 11, design: .monospaced)).foregroundColor(cDim)
            Text("Te falta pagar")
                .font(.system(size: 12)).foregroundColor(cDim).padding(.top, 10)
            Text(entry.falta)
                .font(.system(size: 24, weight: .semibold)).foregroundColor(cText)
            ProgressView(value: Double(entry.percent), total: 100)
                .tint(cPrimary).padding(.top, 10)
            HStack {
                Text(entry.progressLabel).font(.system(size: 11)).foregroundColor(cDim)
                Spacer()
                Text("\(entry.percent)%").font(.system(size: 11)).foregroundColor(cDim)
            }.padding(.top, 4)
            Divider().background(cBorder).padding(.vertical, 8)
            if entry.hasNext {
                HStack(spacing: 8) {
                    Circle().fill(entry.nextOverdue ? cLateInk : cPrimary)
                        .frame(width: 7, height: 7)
                    Text("\(entry.nextName) · \(entry.nextWhen)")
                        .font(.system(size: 12)).foregroundColor(cText).lineLimit(1)
                    Spacer()
                    Text(entry.nextAmount)
                        .font(.system(size: 12, weight: .semibold)).foregroundColor(cText)
                }
            } else {
                Text("Todo al día este mes")
                    .font(.system(size: 12)).foregroundColor(cDim)
            }
        }
        .padding(16)
    }
}

private struct SmallView: View {
    let entry: FinanzappEntry
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text(entry.hasNext ? entry.nextWhen.uppercased() : "ESTE MES")
                .font(.system(size: 11, design: .monospaced))
                .foregroundColor(entry.nextOverdue ? cLateInk : cDim)
            Text(entry.hasNext ? entry.nextName : "Todo al día")
                .font(.system(size: 18, weight: .semibold)).foregroundColor(cText)
                .lineLimit(1).padding(.top, 10)
            Text(entry.hasNext ? entry.nextAmount : entry.falta)
                .font(.system(size: 22, weight: .semibold)).foregroundColor(cPrimaryHi)
            Spacer()
            Text("Finanzapp").font(.system(size: 10)).foregroundColor(cMute)
        }
        .padding(14)
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
        .description("Cuánto te falta pagar este mes y tu próximo vencimiento.")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}
