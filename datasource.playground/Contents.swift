//: A UIKit based Playground for presenting user interface
  
import UIKit
import PlaygroundSupport

extension UIView: AutolayoutView {}
extension UITableViewCell: CellIdentifiable {}
extension UICollectionViewCell: CellIdentifiable {}

protocol HomeContentItem {
}

protocol ContentItem: Hashable {
    var title: String { get set }
    var subtitle: String { get set }
    var imageUrl: String { get set }
}


struct AnyContentItem {
    var base: Any

    init<T>(_ base: T) where T: ContentItem {
        self.base = base
    }
}

extension AnyContentItem: ContentItem {
    var title: String {
        get {
            
        }
        set {

        }
    }

    var subtitle: String {
        get {

        }
        set {

        }
    }

    var imageUrl: String {
        get {

        }
        set {

        }
    }

    static func == (lhs: AnyContentItem, rhs: AnyContentItem) -> Bool {

    }


}

protocol ShowcaseItem {
    var title: String { get set }
    var contentItems: [AnyContentItem] { get set }
}

struct TitleContentItem: ContentItem, Hashable {
    var title: String
    var subtitle: String
    var imageUrl: String
}

struct BookContentItem: ContentItem, Hashable {
    var title: String
    var subtitle: String
    var imageUrl: String
}

struct FeatureShowcaseItem: ShowcaseItem {
    var title: String
    var contentItems: [AnyContentItem]
}

protocol VideoCellConfigurable {
    func setup(item: AnyContentItem)
}

protocol ShowcaseConfigurable {
    func setup(item: ShowcaseItem)
}

class ShowcaseCell: UITableViewCell {
    var indexPath: IndexPath?
    lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.estimatedItemSize = UICollectionViewFlowLayout.automaticSize
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout).add(to: self.contentView, with: .zero)
        collectionView.heightAnchor.constraint(equalToConstant: 200).isActive = true
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.backgroundColor = .clear
        collectionView.register(cellType: VideoTitleThumnailCell.self)
        return collectionView
    }()

    static var offsetTable: [IndexPath: CGPoint] = [:]

    override func prepareForReuse() {
        super.prepareForReuse()
        if let indexPath = self.indexPath {
            ShowcaseCell.offsetTable[indexPath] = collectionView.contentOffset
        }
    }

    private var contentItems: [AnyContentItem] = [] {
        didSet {
            // can be diff resource reload
            collectionView.reloadData()
        }
    }

    func setup(item: ShowcaseItem, for indexPath: IndexPath) {
        self.indexPath = indexPath
        self.contentItems = item.contentItems
        adjustContentOffset()
    }


    private func adjustContentOffset() {
        if let indexPath = indexPath, let contentOffset = ShowcaseCell.offsetTable[indexPath] {
            collectionView.contentOffset = contentOffset
        }
    }
}

extension ShowcaseCell: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return contentItems.count
    }

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: VideoTitleThumnailCell.uniqueCellIdentifier, for: indexPath) as? VideoTitleThumnailCell {
            cell.setup(item: contentItems[indexPath.row])
            return cell
        } else {
            assert(false)
            return UICollectionViewCell()
        }
    }
}

class VideoTitleThumnailCell: UICollectionViewCell, VideoCellConfigurable {
    lazy var titleLabel: UILabel = UILabel.configure(to: self.contentView) { (label) in
        label.font = UIFont.systemFont(ofSize: 18)
        label.numberOfLines = 0
    }()

    lazy var coverImageView: UIImageView = UIImageView.configure(to: self.contentView) { (imageView) in
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupLayout()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("Not implemented")
    }

    func setupLayout() {
        NSLayoutConstraint.activate([
            coverImageView.heightAnchor.constraint(equalToConstant: 200),
            coverImageView.widthAnchor.constraint(equalToConstant: 200),

            titleLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -5),
            titleLabel.leftAnchor.constraint(equalTo: contentView.leftAnchor, constant: 5),
            titleLabel.rightAnchor.constraint(equalTo: contentView.rightAnchor, constant: -5)
            ])
        NSLayoutConstraint.activate(coverImageView.constraint(to: contentView, padding: .zero))
    }

    func setup(item: AnyContentItem) {
        titleLabel.text = item.title
        coverImageView.setupImage(url: item.imageUrl)
    }
}

class VideoTitleContentCell: UITableViewCell, VideoCellConfigurable {
    lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        self.contentView.addSubview(label)
        return label
    }()
    lazy var subtitleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        self.contentView.addSubview(label)
        return label
    }()
    lazy var coverImageView: UIImageView = {
        let imageView: UIImageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        self.contentView.addSubview(imageView)
        return imageView
    }()
    func setupLayout() {
        NSLayoutConstraint.activate([
            titleLabel.leftAnchor.constraint(equalTo: coverImageView.rightAnchor, constant: 10),
            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 15),

            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 10),
            subtitleLabel.leftAnchor.constraint(equalTo: coverImageView.rightAnchor, constant: 10),

            coverImageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 15),
            coverImageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -15),
            coverImageView.heightAnchor.constraint(equalToConstant: 90),
            coverImageView.widthAnchor.constraint(equalToConstant: 120)
            ])
    }

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupLayout()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("Not implemented")
    }

    /* ======= Setup view with model ======== */
    func setup(item: ContentItem) {
        titleLabel.text = item.title
        subtitleLabel.text = item.subtitle
        coverImageView.setupImage(url: item.imageUrl)
    }
}

enum Section {
    case feature
    case showcase
}

extension TitleContentItem: HomeContentItem {}
extension FeatureShowcaseItem: HomeContentItem {}
class MyViewController : UIViewController {

    private lazy var dataSource: UITableViewDiffableDataSource<Section, TitleContentItem> = {
        return UITableViewDiffableDataSource<Section, TitleContentItem>(tableView: self.tableView) { (tableView, indexPath, item) -> UITableViewCell? in
            let cell = tableView.dequeueReusableCell(withIdentifier: VideoTitleContentCell.uniqueCellIdentifier, for: indexPath)
            if let cell = cell as? VideoCellConfigurable {
                cell.setup(item: item)
            }
            return cell
        }
    }()
    private lazy var tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .plain)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.register(cellType: VideoTitleContentCell.self)
        tableView.register(cellType: ShowcaseCell.self)
        self.view.addSubview(tableView)
        return tableView
    }()

    var items: [HomeContentItem] = [] {
        didSet {
            tableView.reloadData()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupLayout()

        tableView.dataSource = dataSource

        items = [
            TitleContentItem(title: "Your name", subtitle: "This summer's blockbuster", imageUrl: "https://contentserver.com.au/assets/525768_gnau_yourname_p_v7_aa.jpg"),
            TitleContentItem(title: "Pulp Fiction", subtitle: "Best movie in 1993", imageUrl: "http://barkerhost.com/wp-content/uploads/sites/4/2015/11/dM2w364MScsjFf8pfMbaWUcWrR-0.jpg"),
            FeatureShowcaseItem(title: "Top ranking", contentItems: [
                TitleContentItem(title: "Test", subtitle: "Sub String", imageUrl: "https://images.pexels.com/photos/60561/winter-snow-nature-60561.jpeg?auto=compress&cs=tinysrgb&h=350"),
                TitleContentItem(title: "Test", subtitle: "Sub String", imageUrl: "https://images.pexels.com/photos/869258/pexels-photo-869258.jpeg?auto=compress&cs=tinysrgb&h=350"),
                TitleContentItem(title: "Test", subtitle: "Sub String", imageUrl: "https://images.pexels.com/photos/688660/pexels-photo-688660.jpeg?auto=compress&cs=tinysrgb&h=350"),
                TitleContentItem(title: "Test", subtitle: "Sub String", imageUrl: "https://images.pexels.com/photos/289649/pexels-photo-289649.jpeg?auto=compress&cs=tinysrgb&h=350"),
                TitleContentItem(title: "Test", subtitle: "Sub String", imageUrl: "https://images.pexels.com/photos/1571442/pexels-photo-1571442.jpeg?auto=compress&cs=tinysrgb&h=350"),
                TitleContentItem(title: "Test", subtitle: "Sub String", imageUrl: "https://images.pexels.com/photos/839462/pexels-photo-839462.jpeg?auto=compress&cs=tinysrgb&h=350"),
                TitleContentItem(title: "Test", subtitle: "Sub String", imageUrl: "https://images.pexels.com/photos/1366919/pexels-photo-1366919.jpeg?auto=compress&cs=tinysrgb&h=350"),
                TitleContentItem(title: "Test", subtitle: "Sub String", imageUrl: "https://images.pexels.com/photos/908644/pexels-photo-908644.jpeg?auto=compress&cs=tinysrgb&h=350")
                ]),
            FeatureShowcaseItem(title: "title2", contentItems: [
                TitleContentItem(title: "Test", subtitle: "Sub String", imageUrl: "https://images.pexels.com/photos/355403/pexels-photo-355403.jpeg?auto=compress&cs=tinysrgb&h=350"),
                TitleContentItem(title: "Test", subtitle: "Sub String", imageUrl: "https://images.pexels.com/photos/54200/pexels-photo-54200.jpeg?auto=compress&cs=tinysrgb&h=350"),
                TitleContentItem(title: "Test", subtitle: "Sub String", imageUrl: "https://images.pexels.com/photos/269370/pexels-photo-269370.jpeg?auto=compress&cs=tinysrgb&h=350"),
                TitleContentItem(title: "Test", subtitle: "Sub String", imageUrl: "https://images.pexels.com/photos/258112/pexels-photo-258112.jpeg?auto=compress&cs=tinysrgb&h=350"),
                TitleContentItem(title: "Test", subtitle: "Sub String", imageUrl: "https://images.pexels.com/photos/89773/wolf-wolves-snow-wolf-landscape-89773.jpeg?auto=compress&cs=tinysrgb&h=350"),
                TitleContentItem(title: "Test", subtitle: "Sub String", imageUrl: "https://images.pexels.com/photos/287229/pexels-photo-287229.jpeg?auto=compress&cs=tinysrgb&h=350"),
                TitleContentItem(title: "Test", subtitle: "Sub String", imageUrl: "https://images.pexels.com/photos/66284/winter-nature-season-trees-66284.jpeg?auto=compress&cs=tinysrgb&h=350")
                ]),
            FeatureShowcaseItem(title: "Top ranking", contentItems: [
                TitleContentItem(title: "Test", subtitle: "Sub String", imageUrl: "https://images.pexels.com/photos/60561/winter-snow-nature-60561.jpeg?auto=compress&cs=tinysrgb&h=350"),
                TitleContentItem(title: "Test", subtitle: "Sub String", imageUrl: "https://images.pexels.com/photos/869258/pexels-photo-869258.jpeg?auto=compress&cs=tinysrgb&h=350"),
                TitleContentItem(title: "Test", subtitle: "Sub String", imageUrl: "https://images.pexels.com/photos/688660/pexels-photo-688660.jpeg?auto=compress&cs=tinysrgb&h=350"),
                TitleContentItem(title: "Test", subtitle: "Sub String", imageUrl: "https://images.pexels.com/photos/289649/pexels-photo-289649.jpeg?auto=compress&cs=tinysrgb&h=350"),
                TitleContentItem(title: "Test", subtitle: "Sub String", imageUrl: "https://images.pexels.com/photos/1571442/pexels-photo-1571442.jpeg?auto=compress&cs=tinysrgb&h=350"),
                TitleContentItem(title: "Test", subtitle: "Sub String", imageUrl: "https://images.pexels.com/photos/839462/pexels-photo-839462.jpeg?auto=compress&cs=tinysrgb&h=350"),
                TitleContentItem(title: "Test", subtitle: "Sub String", imageUrl: "https://images.pexels.com/photos/1366919/pexels-photo-1366919.jpeg?auto=compress&cs=tinysrgb&h=350"),
                TitleContentItem(title: "Test", subtitle: "Sub String", imageUrl: "https://images.pexels.com/photos/908644/pexels-photo-908644.jpeg?auto=compress&cs=tinysrgb&h=350")
                ]),
            FeatureShowcaseItem(title: "title2", contentItems: [
                TitleContentItem(title: "Test", subtitle: "Sub String", imageUrl: "https://images.pexels.com/photos/355403/pexels-photo-355403.jpeg?auto=compress&cs=tinysrgb&h=350"),
                TitleContentItem(title: "Test", subtitle: "Sub String", imageUrl: "https://images.pexels.com/photos/54200/pexels-photo-54200.jpeg?auto=compress&cs=tinysrgb&h=350"),
                TitleContentItem(title: "Test", subtitle: "Sub String", imageUrl: "https://images.pexels.com/photos/269370/pexels-photo-269370.jpeg?auto=compress&cs=tinysrgb&h=350"),
                TitleContentItem(title: "Test", subtitle: "Sub String", imageUrl: "https://images.pexels.com/photos/258112/pexels-photo-258112.jpeg?auto=compress&cs=tinysrgb&h=350"),
                TitleContentItem(title: "Test", subtitle: "Sub String", imageUrl: "https://images.pexels.com/photos/89773/wolf-wolves-snow-wolf-landscape-89773.jpeg?auto=compress&cs=tinysrgb&h=350"),
                TitleContentItem(title: "Test", subtitle: "Sub String", imageUrl: "https://images.pexels.com/photos/287229/pexels-photo-287229.jpeg?auto=compress&cs=tinysrgb&h=350"),
                TitleContentItem(title: "Test", subtitle: "Sub String", imageUrl: "https://images.pexels.com/photos/66284/winter-nature-season-trees-66284.jpeg?auto=compress&cs=tinysrgb&h=350")
                ])
        ]

        let snapshot = NSDiffableDataSourceSnapshot<Section, TitleContentItem>()

        snapshot.appendItems([items], toSection: .showcase))
        snapshot.appendItems(users)

        dataSource.apply(snapshot)

        /* ===== get data from remote and apply it to the model */

    }

    func setupLayout() {
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            tableView.leftAnchor.constraint(equalTo: view.leftAnchor),
            tableView.rightAnchor.constraint(equalTo: view.rightAnchor)
            ])
    }

}

extension MyViewController: UITableViewDataSourcePrefetching {
    func tableView(_ tableView: UITableView, prefetchRowsAt indexPaths: [IndexPath]) {

    }
}

protocol PagingControllerProtocol {

    func prefectchData(indexPaths: [IndexPath])


}

// Present the view controller in the Live View window
PlaygroundPage.current.liveView = MyViewController()
