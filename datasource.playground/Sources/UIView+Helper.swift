import UIKit

public protocol AutolayoutView: UIView {}
public extension AutolayoutView {
    static func generate(from superview: UIView) -> Self {
        let view = Self()
        view.translatesAutoresizingMaskIntoConstraints = false
        superview.addSubview(view)
        return view
    }

    static func configure(to superview: UIView, closure: ((Self)->Void)? = nil) -> () -> Self {
        return {
            let view = Self()
            view.translatesAutoresizingMaskIntoConstraints = false
            superview.addSubview(view)
            closure?(view)
            return view
        }
    }

    func withConfigure(closure: (Self)->Void) -> Self {
        closure(self)
        return self
    }

    func add(to superview: UIView, with padding: UIEdgeInsets? = nil) -> Self {
        self.translatesAutoresizingMaskIntoConstraints = false
        superview.addSubview(self)
        if let padding = padding {
            NSLayoutConstraint.activate(
                self.constraint(to: superview, padding: padding)
            )
        }
        return self
    }

    func constraint(to view: UIView, padding: UIEdgeInsets) -> [NSLayoutConstraint] {
        return [
            self.leftAnchor.constraint(equalTo: view.leftAnchor, constant: padding.left),
            self.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -padding.right),
            self.topAnchor.constraint(equalTo: view.topAnchor, constant: padding.top),
            self.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: padding.bottom)
        ]
    }
}
