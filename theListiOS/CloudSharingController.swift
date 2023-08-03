import SwiftUI
import UIKit
import CloudKit

struct CloudSharingController: UIViewControllerRepresentable {
	var share: CKShare
	var container: CKContainer
	
	func makeUIViewController(context: Context) -> UICloudSharingController {
		let controller = UICloudSharingController { controller, preparationCompletionHandler in
			preparationCompletionHandler(self.share, self.container, nil)
		}
		return controller
	}
	
	func updateUIViewController(_ uiViewController: UICloudSharingController, context: Context) {
		// No update needed
	}
}
