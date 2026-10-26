//
//  WorklyWidget.swift
//  IOS_Coursework
//
//  Created by cobsccomp251p-055 on 2026-10-26.
//

import WidgetKit
import SwiftUI





struct WorklyEntry: TimelineEntry {
    let date: Date
    let snapshot: WidgetSnapshot
}

struct WorklyProvider: TimelineProvider {

    func placeholder(in context: Context) -> WorklyEntry {
        WorklyEntry(date: Date(), snapshot: .preview)
    }

    func getSnapshot(in context: Context, completion: @escaping (WorklyEntry) -> Void) {
        let snapshot = context.isPreview ? WidgetSnapshot.preview : WidgetStore.load()
        completion(WorklyEntry(date: Date(), snapshot: snapshot))
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<WorklyEntry>) -> Void) {
        let entry = WorklyEntry(date: Date(), snapshot: WidgetStore.load())
        let next = Calendar.current.date(byAdding: .minute, value: 30, to: Date()) ?? Date()
        completion(Timeline(entries: [entry], policy: .after(next)))
    }
}



private let brandBlue = Color(red: 0.23, green: 0.49, blue: 0.94)

struct WorklyWidgetView: View {

    @Environment(\.widgetFamily) private var family
    let entry: WorklyEntry

    private var s: WidgetSnapshot { entry.snapshot }

    var body: some View {
        Group {
            if !s.isSignedIn {
                message(icon: "person.crop.circle", title: "Workly", text: "Open the app and log in.")
            } else if s.role == "worker" {
                workerView
            } else {
                customerView
            }
        }
        .containerBackground(for: .widget) { Color(.systemBackground) }
    }

 

    @ViewBuilder
    private var customerView: some View {
        if let date = s.nextDate {
            VStack(alignment: .leading, spacing: 6) {
                header("Next booking")

                Text(s.nextService ?? "Service")
                    .font(family == .systemSmall ? .headline : .title3.bold())
                    .lineLimit(1)

                if let person = s.nextPerson, !person.isEmpty {
                    Text(person)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                }

                Spacer(minLength: 0)

                Text(date, format: .dateTime.weekday(.abbreviated).day().month(.abbreviated).hour().minute())
                    .font(.caption.bold())
                    .foregroundColor(brandBlue)

                statusPill(s.nextStatus)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        } else {
            message(icon: "calendar", title: "No bookings", text: "Find a worker in Workly.")
        }
    }



    @ViewBuilder
    private var workerView: some View {
        VStack(alignment: .leading, spacing: 8) {
            header("Workly")

            HStack(spacing: 12) {
                counter(s.pendingCount, "New requests", highlight: s.pendingCount > 0)
                if family != .systemSmall {
                    counter(s.upcomingCount, "Upcoming jobs", highlight: false)
                }
            }

            Spacer(minLength: 0)

            if family == .systemSmall {
                Text("\(s.upcomingCount) upcoming")
                    .font(.caption)
                    .foregroundColor(.secondary)
            } else if let date = s.nextDate {
                Text("Next: \(s.nextService ?? "Job")")
                    .font(.caption.bold())
                    + Text(" · ")
                    + Text(date, format: .dateTime.weekday(.abbreviated).hour().minute())
                    .font(.caption)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    

    private func header(_ text: String) -> some View {
        HStack(spacing: 5) {
            Image(systemName: "briefcase.fill")
                .font(.caption2)
                .foregroundColor(.white)
                .frame(width: 18, height: 18)
                .background(brandBlue)
                .clipShape(RoundedRectangle(cornerRadius: 5))
            Text(text)
                .font(.caption.bold())
                .foregroundColor(.secondary)
        }
    }

    private func counter(_ value: Int, _ label: String, highlight: Bool) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            Text("\(value)")
                .font(.system(size: 34, weight: .bold, design: .rounded))
                .foregroundColor(highlight ? brandBlue : .primary)
            Text(label)
                .font(.caption2)
                .foregroundColor(.secondary)
        }
    }

    private func statusPill(_ status: String?) -> some View {
        let (text, color): (String, Color) = {
            switch status {
            case "accepted": return ("Accepted", .green)
            case "in_progress": return ("In progress", brandBlue)
            default: return ("Pending", .orange)
            }
        }()
        return Text(text)
            .font(.caption2.bold())
            .foregroundColor(color)
            .padding(.horizontal, 8)
            .padding(.vertical, 3)
            .background(color.opacity(0.15))
            .clipShape(Capsule())
    }

    private func message(icon: String, title: String, text: String) -> some View {
        VStack(spacing: 6) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(brandBlue)
            Text(title).font(.headline)
            Text(text)
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}


struct WorklyWidget: Widget {
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: WidgetShared.widgetKind, provider: WorklyProvider()) { entry in
            WorklyWidgetView(entry: entry)
        }
        .configurationDisplayName("Workly")
        .description("Your next booking, or your new requests if you're a worker.")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}

@main
struct WorklyWidgetBundle: WidgetBundle {
    var body: some Widget {
        WorklyWidget()
    }
}

#Preview(as: .systemSmall) {
    WorklyWidget()
} timeline: {
    WorklyEntry(date: .now, snapshot: .preview)
}
