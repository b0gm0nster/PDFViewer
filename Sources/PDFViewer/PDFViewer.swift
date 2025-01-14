//
//  PDFViewer.swift
//  PDFViewer
//
//  Created by Raju on 15/4/20.
//  Copyright © 2020 Raju. All rights reserved.
//

import SwiftUI
import PDFKit

public enum PDFType {
    case local
    case remote
    case data
}

public struct PDFViewer: View {
    var pdfName: String = ""
    var pdfUrlString: String = ""
    var pdfData: Data? = nil
    var showThumbnails: Bool = true
    var showPageNumber: Bool = true
    @State private var showingShare = false
    @State private var pdfType: PDFType = .local

    public init(pdfName: String? = nil, pdfUrlString: String? = nil, showThumbnails: Bool = false, showPageNumbers: Bool = false) {
        self.pdfName = pdfName ?? ""
        self.pdfUrlString = pdfUrlString ?? ""
        self.showThumbnails = showThumbnails
        self.showPageNumber = showPageNumbers
    }
    
    public init(withData data: Data? = nil, showThumbnails: Bool = false, showPageNumbers: Bool = false) {
        self.pdfData = data
        self.showThumbnails = showThumbnails
        self.showPageNumber = showPageNumbers
        self.pdfType = .data
    }
    
    public var body: some View {
        GeometryReader { geometry in
            ZStack {
                HStack {
                if pdfType == .data {
                    PDFReaderView(pdfData: self.pdfData, pdfType: self.pdfType, viewSize: geometry.size, showThumbnails: showThumbnails, showPageNumbers: showPageNumber)
                } else {
                PDFReaderView(pdfName: self.pdfName, pdfUrlString: self.pdfUrlString, pdfType: self.pdfName.count > 0 ? .local : .remote, viewSize: geometry.size, showThumbnails: showThumbnails, showPageNumbers: showPageNumber)
                }
                    
                }
                    .navigationBarItems(trailing:
                        Button(action: {
                            self.showingShare = true
                        }, label: {
                            Image(systemName: "arrowshape.turn.up.right.circle")
                                .resizable()
                        })
                        .sheet(isPresented: self.$showingShare, onDismiss: {
                            //dismiss
                        }, content: {
                            if (self.pdfLocalData() != nil) {
                                ActivityViewController(activityItems: [self.pdfLocalData()!, self.pdfName.count > 0 ? self.pdfName : URL(fileURLWithPath: self.pdfUrlString).deletingPathExtension().lastPathComponent])
                            }
                        })
                    )
                    .navigationBarTitle(self.pdfName.count > 0 ? self.pdfName : URL(fileURLWithPath: self.pdfUrlString).deletingPathExtension().lastPathComponent)
                    .onAppear() {
                        self.pdfType = self.pdfName.count > 0 ? .local : .remote
                    }
            }
        }
    }
    
    private func pdfLocalData() -> Data? {
        if pdfType == .local {
            if let url = Bundle.main.url(forResource: pdfName, withExtension: "pdf") {
                do {
                    let pdfLocalData = try Data(contentsOf: url)
                    return pdfLocalData
                } catch let error {
                    print(error.localizedDescription)
                }
            }
        } else {
            if let cachesDirectoryUrl =  FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first, let lastPathComponent = URL(string: self.pdfUrlString)?.lastPathComponent {
                let url = cachesDirectoryUrl.appendingPathComponent(lastPathComponent)
                do {
                    let pdfLocalData = try Data(contentsOf: url)
                    return pdfLocalData
                } catch let error {
                    print(error.localizedDescription)
                }
            }
        }
        return nil
    }
}

struct PDFViewer_Previews: PreviewProvider {
    static var previews: some View {
        PDFViewer()
            .previewLayout(.sizeThatFits)
    }
}
