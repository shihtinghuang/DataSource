import UIKit

public protocol AutolayoutView: UIView {}
public extension AutolayoutView {
    /// Generate a subview and add it to the superview, with auto layout enabled
    static func generate(from superview: UIView) -> Self {
        let view = Self()
        view.translatesAutoresizingMaskIntoConstraints = false
        superview.addSubview(view)
        return view
    }

    /// Generate a subview and add it to the superview, with configuration closure
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

    /// Add receiver to the superview with specified padding
    func add(to superview: UIView, with padding: UIEdgeInsets? = nil) -> Self {
        self.translatesAutoresizingMaskIntoConstraints = false
        superview.addSubview(self)
        if let padding = padding {
            self.constraints(to: superview, padding: padding).activate()
        }
        return self
    }

    /// Creare constraints based on the specified padding
    func constraints(to view: UIView, padding: UIEdgeInsets) -> [NSLayoutConstraint] {
        return constraints(to: view, top: padding.top, left: padding.left, bottom: padding.bottom, right: padding.right)
    }

    /// Create constraints to the specific view with padding values (all positive)
    func constraints(to view: UIView, top: CGFloat? = nil, left: CGFloat? = nil, bottom: CGFloat? = nil, right: CGFloat? = nil) -> [NSLayoutConstraint] {
        var constraints: [NSLayoutConstraint] = []
        var topConstant = top
        var bottomConstant = bottom
        var leftConstant = left
        var rightConstant = right
        if top == nil && bottom == nil && left == nil && right == nil {
            topConstant = 0
            bottomConstant = 0
            leftConstant = 0
            rightConstant = 0
        }

        if let top = topConstant {
            constraints.append(topAnchor.constraint(equalTo: view.topAnchor, constant: top))
        }
        if let bottom = bottomConstant {
            constraints.append(bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -bottom))
        }
        if let left = leftConstant {
            constraints.append(leftAnchor.constraint(equalTo: view.leftAnchor, constant: left))
        }
        if let right = rightConstant {
            constraints.append(rightAnchor.constraint(equalTo: view.rightAnchor, constant: -right))
        }
        return constraints
    }
}

public extension Array where Element: NSLayoutConstraint {
    func activate() {
        self.forEach { $0.isActive = true }
    }
    func deactivate() {
        self.forEach { $0.isActive = false }
    }
}
