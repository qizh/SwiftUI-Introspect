#if canImport(UIKit)
import SwiftUI
import UIKit

/// Introspection UIViewController that is inserted alongside the target view controller.
@available(iOS 13.0, tvOS 13.0, macOS 10.15.0, *)
public class IntrospectionUIViewController: UIViewController {
    required init() {
        super.init(nibName: nil, bundle: nil)
        view = IntrospectionUIView()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

/// This is the same logic as IntrospectionView but for view controllers. Please see details above.
@available(iOS 13.0, tvOS 13.0, macOS 10.15.0, *)
public struct UIKitIntrospectionViewController<TargetViewControllerType: UIViewController>: UIViewControllerRepresentable {
    
    let selector: (IntrospectionUIViewController) -> TargetViewControllerType?
    let customize: (TargetViewControllerType) -> Void
    
    public init(
        selector: @escaping (UIViewController) -> TargetViewControllerType?,
        customize: @escaping (TargetViewControllerType) -> Void
    ) {
        self.selector = selector
        self.customize = customize
    }
    
    public func makeUIViewController(
        context: UIViewControllerRepresentableContext<UIKitIntrospectionViewController>
    ) -> IntrospectionUIViewController {
        let viewController = IntrospectionUIViewController()
        viewController.accessibilityLabel = "IntrospectionUIViewController<\(TargetViewControllerType.self)>"
        viewController.view.accessibilityLabel = "IntrospectionUIView<\(TargetViewControllerType.self)>"
        return viewController
    }
    
    public func updateUIViewController(
        _ uiViewController: IntrospectionUIViewController,
        context: UIViewControllerRepresentableContext<UIKitIntrospectionViewController>
    ) {
		performCustomize(uiViewController, dispatchAttemptsLeft: 8)
    }
	
	private func performCustomize(
		_ uiViewController: IntrospectionUIViewController,
		dispatchAttemptsLeft: Int,
		dispatchStep: DispatchTimeInterval = .milliseconds(10)
	) {
		DispatchQueue.main.asyncAfter(deadline: .now() + dispatchStep) {
			guard let targetView = self.selector(uiViewController) else {
				if dispatchAttemptsLeft > 0 {
					performCustomize(
						uiViewController,
						dispatchAttemptsLeft: dispatchAttemptsLeft - 1,
						dispatchStep: dispatchStep
					)
				}
				return
			}
			self.customize(targetView)
		}
	}
}
#endif
