//
//  GalleryGridCell.swift
//  PrivateVault
//
//  Created by Emilio Peláez on 20/2/21.
//

import SwiftUI

struct GalleryGridCell: View {
	let item: Item
	@Binding var contentMode: ContentMode
	@Binding var showDetails: Bool
	let selection: (Item) -> Void
	
	var body: some View {
		VStack(alignment: .leading) {
			Color.clear.aspectRatio(1, contentMode: .fill)
				.overlay(
					item.placeholder
						.resizable()
						.aspectRatio(contentMode: contentMode)
				)
				.clipped()
			if showDetails {
				VStack(alignment: .leading) {
					Text(item.title)
						.font(.headline)
//					Text("12/31/20")
//						.font(.footnote)
//						.foregroundColor(.secondary)
					Text(String(format: "%.1f MB", CGFloat(item.size) / 1_000_000))
						.font(.footnote)
						.foregroundColor(.secondary)
				}
			}
		}
		.onTapGesture { selection(item) }
	}
}

struct GalleryGridCell_Previews: PreviewProvider {
	static var previews: some View {
		GalleryGridCell(item: .example, contentMode: .constant(.fill), showDetails: .constant(true)) { _ in }
			.previewLayout(.fixed(width: 200, height: 300))
		GalleryGridCell(item: .example, contentMode: .constant(.fill), showDetails: .constant(false)) { _ in }
			.previewLayout(.fixed(width: 200, height: 200))
	}
}
