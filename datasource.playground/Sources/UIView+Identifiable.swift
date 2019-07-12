import UIKit

public protocol CellIdentifiable {
    static var uniqueCellIdentifier: String { get }
}

extension CellIdentifiable {
    public static var uniqueCellIdentifier: String {
        return String(describing: self)
    }
}

public extension UITableView {
    func register<T: CellIdentifiable&UITableViewCell>(cellType: T.Type) {
        register(cellType, forCellReuseIdentifier: cellType.uniqueCellIdentifier)
    }
}

public extension UICollectionView {
    func register<T: CellIdentifiable&UICollectionViewCell>(cellType: T.Type) {
        register(cellType, forCellWithReuseIdentifier: cellType.uniqueCellIdentifier)
    }
}
