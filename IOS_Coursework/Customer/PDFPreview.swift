//
//  PDFPreview.swift
//  IOS_Coursework
//

import SwiftUI
import PDFKit


struct PDFKitView: UIViewRepresentable {

    let url: URL

    func makeUIView(context: Context) -> PDFView {
        let view = PDFView()
        view.autoScales = true
        view.displayMode = .singlePageContinuous
        view.displayDirection = .vertical
        view.backgroundColor = .secondarySystemBackground
        view.document = PDFDocument(url: url)
        return view
    }

    func updateUIView(_ view: PDFView, context: Context) { }
}


struct PDFPreviewScreen: View {

    let file: PDFFile

    @Environment(\.dismiss) var dismiss

    var body: some View {
        NavigationStack {
            PDFKitView(url: file.url)
                .ignoresSafeArea(edges: .bottom)
                .navigationTitle("Service Summary")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Close") { dismiss() }
                    }
                    ToolbarItem(placement: .primaryAction) {
                        ShareLink(item: file.url) {
                            Label("Save or Share", systemImage: "square.and.arrow.up")
                        }
                    }
                }
        }
    }
}

