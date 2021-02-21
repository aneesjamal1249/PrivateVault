//
//  GalleryGridView.swift
//  PrivateVault
//
//  Created by Emilio Peláez on 20/2/21.
//

import SwiftUI

struct GalleryGridView: View {
	private func columns(spacing: CGFloat) -> [GridItem] {
		[
			GridItem(.flexible(), spacing: spacing),
			GridItem(.flexible(), spacing: spacing),
			GridItem(.flexible(), spacing: spacing)
		]
	}
	
	@FetchRequest(sortDescriptors: [NSSortDescriptor(keyPath: \StoredItem.timestamp, ascending: false)], animation: .default)
	var data: FetchedResults<StoredItem>
	
	@State var searchText = ""
	@Binding var selectedTags: Set<Tag>
	let selection: (StoredItem) -> Void
	let delete: (StoredItem) -> Void
	
	@State var tagEditingItem: StoredItem?
	
	var filteredData: [StoredItem] {
		data.filter { item in
			selectedTags.reduce(true) {
				$0 && (item.tags?.contains($1) ?? false)
			}
		}
		.filter { item in
			if searchText.isEmpty { return true }
			return item.searchText.localizedStandardContains(searchText)
		}
	}
	
	var body: some View {
		if data.isEmpty {
			ZStack {
				Color.clear
				EmptyGalleryView()
					.frame(maxWidth: 280)
					.transition(.opacity)
			}
		} else if filteredData.isEmpty {
			ZStack {
				Color.clear
				FilteredGalleryView {
					withAnimation {
						selectedTags = []
					}
				}
				.frame(maxWidth: 280)
				.transition(.opacity)
			}
		} else {
			ScrollView {
				SearchBarView(text: $searchText, placeholder: "Search files...")
				LazyVGrid(columns: columns(spacing: 4), spacing: 4) {
					ForEach(filteredData) { item in
						GalleryGridCell(item: item)
							.onTapGesture { selection(item) }
							.contextMenu {
								Button(action: { tagEditingItem = item }) {
									Text("Edit")
									Image(systemName: "edit")
								}
								Menu {
									Button(action: { delete(item) }) {
										Text("Delete")
										Image(systemName: "trash")
									}
									Button(action: { }) {
										Text("Cancel")
									}
								} label: {
									Text("Delete")
									Image(systemName: "trash")
								}
							}
						
					}
				}
				.padding(4)
				.padding(.bottom, 55)
			}
			.popover(item: $tagEditingItem) { item in
				ItemEditView(item: item) { tagEditingItem = nil }
			}
		}
	}
	
//	var filteredData: [StoredItem] {
//		if searchText.isEmpty { return Array(data) }
//		return data.filter({ $0.name?.localizedStandardContains(searchText) ?? false })
//	}
}

struct GalleryGridView_Previews: PreviewProvider {
	static let data: [Item] = .examples
	static var previews: some View {
		EmptyView()
		GalleryGridView(selectedTags: .constant([])) { _ in }
			delete: { _ in }
			.environment(\.managedObjectContext, PreviewEnvironment().context)
		
		GalleryGridView(selectedTags: .constant([])) { _ in }
			delete: { _ in }
			.environment(\.managedObjectContext, PreviewEnvironment().context)
	}
}
