//
//  GalleryView.swift
//  PrivateVault
//
//  Created by Emilio Peláez on 19/2/21.
//

import Photos
import SwiftUI

struct GalleryView: View {
	
	enum SheetItem: Int, Identifiable {
		case tags
		case settings
		case imagePicker
		case cameraPicker
		case documentPicker
		case documentScanner
		case audioRecorder
		
		var id: Int { rawValue }
	}
	
	@Environment(\.managedObjectContext) private var viewContext
	
	@State var contentMode: ContentMode = .fill //	Should this and showDetails be environment values?
	@State var showDetails = true
	@State var showImageActionSheet = false
	@State var showPermissionAlert = false
	@State var currentSheet: SheetItem?
	@State var selectedItem: StoredItem?
	
	var body: some View {
		ZStack(alignment: .bottomLeading) {
			GalleryGridView(contentMode: $contentMode, showDetails: $showDetails, emptyView: EmptyGalleryView(), selection: select, delete: delete)
				.fullScreenCover(item: $selectedItem, content: quickLookView)
				.navigationTitle("Gallery")
				.toolbar(content: {
					ToolbarItemGroup(placement: .navigationBarTrailing) {
						Button(action: { currentSheet = .tags }) {
							Image(systemName: "list.bullet")
						}
						Button(action: { currentSheet = .settings }) {
							Image(systemName: "gearshape")
						}
					}
				})
			FileTypePickerView(action: selectType)
				.sheet(item: $currentSheet, content: filePicker)
				.padding(.horizontal)
				.padding(.bottom, 5)
		}
		.alert(isPresented: $showPermissionAlert) {
			Alert(
				title: Text("Camera Access"),
				message: Text("PrivateVault doesn't have access to use your camera, please update your privacy settings."),
				primaryButton: .default(
					Text("Settings"),
					action: { UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!) }
				),
				secondaryButton: .cancel())
		}
		.actionSheet(isPresented: $showImageActionSheet) {
			ActionSheet(title: Text("Import images"), buttons: [
				.default(Text("Camera"), action: { requestCameraAuthorization() }),
				.default(Text("Photo Library"), action: { requestImageAuthorization() }),
				.cancel()
			])
		}
	}
	
	func select(_ item: StoredItem) {
		selectedItem = item
	}
	
	func delete(_ item: StoredItem) {
		viewContext.delete(item)
		saveContext()
	}
	
	func quickLookView(_ item: StoredItem) -> some View {
		QuickLookView(title: item.name, url: item.url).ignoresSafeArea()
	}
	
	func filePicker(_ item: SheetItem) -> some View {
		Group {
			switch item {
			case .tags: TagListView { currentSheet = nil }
			case .imagePicker: PhotosPicker(closeSheet: { currentSheet = nil }, selectImage: selectImage)
			case .cameraPicker: CameraPicker(selectImage: selectCameraCapture)
			case .documentPicker: DocumentPicker(selectDocuments: selectDocuments)
			case .documentScanner: DocumentScanner(selectScan: selectCameraCapture)
			case .audioRecorder: AudioRecorder(recordAudio: recordAudio)
			case .settings: SettingsView { currentSheet = nil }
			}
		}
	}
	
	func selectType(_ type: FileTypePickerView.FileType) {
		switch type {
		case .photo: showImageActionSheet = true
		case .audio: currentSheet = .audioRecorder
		case .document: currentSheet = .documentPicker
		case .scan: currentSheet = .documentScanner
		}
	}

	func requestImageAuthorization() {
		if PHPhotoLibrary.authorizationStatus() == .authorized {
			currentSheet = .imagePicker
		} else {
			PHPhotoLibrary.requestAuthorization(for: .readWrite) { _ in }
		}
	}

	func requestCameraAuthorization() {
		switch AVCaptureDevice.authorizationStatus(for: .video) {
		case .authorized:
			currentSheet = .cameraPicker
		case .notDetermined:
			AVCaptureDevice.requestAccess(for: .video, completionHandler: { granted in
				guard granted else { return }
				currentSheet = .cameraPicker
			})
		default:
			showPermissionAlert = true
		}
	}

	func selectImage(_ image: UIImage, filename: String) {
		_ = StoredItem(context: viewContext, image: image, filename: filename)
		saveContext()
	}

	func selectCameraCapture(_ image: UIImage) {
		_ = StoredItem(context: viewContext, image: image, filename: "New photo")
		saveContext()
	}
	
	func selectDocuments(_ documentURLs: [URL]) {
		print(documentURLs)
	}
	
	func recordAudio(_ audioURL: URL) {
		fatalError("Audio recording is not implemented yet.")
	}
	
	private func saveContext() {
		do {
			try viewContext.save()
		} catch {
			// Replace this implementation with code to handle the error appropriately.
			let nsError = error as NSError
			fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
		}
	}
}

struct GalleryView_Previews: PreviewProvider {
	static var previews: some View {
		GalleryView()
	}
}

struct AudioRecorder: View {
	var recordAudio: (URL) -> Void
	
	var body: some View {
		EmptyView()
	}
}
