//
//  NavigationLock.swift
//  App
//

import SwiftUI
import UIKit

/// Disables the interactive swipe-to-go-back gesture while isLocked is true.
/// Use alongside .navigationBarBackButtonHidden to fully prevent navigation during async work.
struct NavigationLock: UIViewControllerRepresentable {
    let isLocked: Bool

    func makeUIViewController(context: Context) -> UIViewController {
        UIViewController()
    }

    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {
        DispatchQueue.main.async {
            uiViewController.navigationController?.interactivePopGestureRecognizer?.isEnabled = !isLocked
        }
    }
}
