//: A UIKit based Playground for presenting user interface
  
import UIKit
import PlaygroundSupport

extension UIView: AutolayoutView {}
extension UITableViewCell: CellIdentifiable {}
extension UICollectionViewCell: CellIdentifiable {}

// Root protocol of content item
protocol ContentItem: Hashable {
    var id: String { get }
    static var cellType: ContentConfigurable.Type { get }
}

/// Type erasured content item
struct AnyContentItem<T: ContentItem>: ContentItem {
    var id: String {
        return base.id
    }
    static var cellType: ContentConfigurable.Type {
        return T.cellType
    }

    let base: T
    init(_ base: T) {
        self.base = base
    }
}

protocol FeaturableContentItem {
    var id: String { get }
}

extension Array where Element: FeaturableContentItem {
    func features() -> [FeatureContentItem] {
        return self.map { FeatureContentItem($0) }
    }
}

extension Array where Element: ContentItem {
    func wrap() -> [AnyContentItem<Element>] {
        return self.map { AnyContentItem($0) }
    }
}

struct VideoContentItem: ContentItem, FeaturableContentItem {
    var id: String
    var title: String
    var subtitle: String
    var imageUrl: String
    static var cellType: ContentConfigurable.Type { return VideoTitleThumnailCell.self }
    // Convivenet
    static func video(id: String, title: String, subtitle: String, imageUrl: String) -> VideoContentItem {
        return VideoContentItem(id: id, title: title, subtitle: subtitle, imageUrl: imageUrl)
    }
}

struct BookContentItem: ContentItem, FeaturableContentItem {
    var id: String
    var title: String
    var subtitle: String
    var imageUrl: String
    static var cellType: ContentConfigurable.Type { return BookTitleThumbnailCell.self }
    // Convivenet
    static func book(id: String, title: String, subtitle: String, imageUrl: String) -> BookContentItem {
        return BookContentItem(id: id, title: title, subtitle: subtitle, imageUrl: imageUrl)
    }
}

struct FeatureContentItem: ContentItem {
    var id: String { return content.id }
    static var cellType: ContentConfigurable.Type { return FeatureContentCell.self }

    let content: FeaturableContentItem

    init(_ content: FeaturableContentItem) {
        self.content = content
    }

    static func ==(lhs: FeatureContentItem, rhs: FeatureContentItem) -> Bool {
        return lhs.id == rhs.id
    }
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
        hasher.combine(String(describing: type(of: content)))
    }
}

protocol ContentConfigurable: UICollectionViewCell {
    func setup<C: ContentItem>(item: C)
}

protocol ContentSectionProtocol {}
struct ContentSection<C: ContentItem>: Hashable & ContentSectionProtocol {
    let items: [AnyContentItem<C>]
    static func section(items: [C]) -> ContentSection<C> {
        return ContentSection(items: items.map { AnyContentItem($0) })
    }
}

class HorizontalScrollableCell<C: ContentItem>: UITableViewCell, UICollectionViewDelegate {
    // The offset table for saving the offset for a specific indexpath. Note that the life cycle is the same as the cell
    private struct CellCache {
        var offsetTable: [IndexPath: CGPoint]
        init() {
            offsetTable = [:]
        }
    }

    private struct Section: Hashable {
    }

    private var dataSource: UICollectionViewDiffableDataSource<Section, C>?

    // Save the previous indexPath
    private var indexPath: IndexPath?
    private var cache: CellCache = CellCache()

    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.estimatedItemSize = UICollectionViewFlowLayout.automaticSize
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout).add(to: self.contentView, with: .zero)
        collectionView.heightAnchor.constraint(equalToConstant: 120).isActive = true
        collectionView.backgroundColor = .clear
        collectionView.register(cellType: C.cellType)
        return collectionView
    }()

    private func createDataSource(collectionView: UICollectionView) -> UICollectionViewDiffableDataSource<Section, C> {
        return UICollectionViewDiffableDataSource(collectionView: collectionView) { (collectionView, indexPath, item) -> UICollectionViewCell? in

            if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: C.cellType.uniqueCellIdentifier, for: indexPath) as? ContentConfigurable {
                cell.setup(item: item)
                return cell
            } else {
                assertionFailure("Unhanlded item: \(type(of: item))")
                return UICollectionViewCell()
            }
        }
    }

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupCollectionView()
    }

    private func setupCollectionView() {
        dataSource = createDataSource(collectionView: collectionView)
        collectionView.dataSource = dataSource
        collectionView.delegate = self
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        if let indexPath = self.indexPath {
            cache.offsetTable[indexPath] = collectionView.contentOffset
        }
    }

    private var contentItems: [AnyContentItem<C>] = [] {
        didSet {
            // can be diff resource reload
            let snapshot = NSDiffableDataSourceSnapshot<Section, C>()
            let section = Section()
            let items = self.contentItems.map {$0.base}
            snapshot.appendSections([section])
            snapshot.appendItems(items, toSection: section)
            dataSource?.apply(snapshot)
        }
    }

    func setup(group: ContentSection<C>, for indexPath: IndexPath) {
        self.indexPath = indexPath
        self.contentItems = group.items
        adjustContentOffset()
    }

    private func adjustContentOffset() {
        if let indexPath = indexPath, let contentOffset = cache.offsetTable[indexPath] {
            collectionView.contentOffset = contentOffset
        }
    }

}

class BookTitleThumbnailCell: UICollectionViewCell, ContentConfigurable {

    lazy var coverImageView: UIImageView = {
        return UIImageView.configure(to: self.contentView) { (imageView) in
            imageView.contentMode = .scaleAspectFill
            [imageView.widthAnchor.constraint(equalToConstant: 80),
             imageView.heightAnchor.constraint(equalToConstant: 120)].activate()
        }()
    }()

    override init(frame: CGRect) {
        super.init(frame: .zero)
        setupConstraint()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupConstraint() {
        coverImageView.constraints(to: contentView).activate()
    }

    func setup<C>(item: C) where C : ContentItem {
        if let item = item as? BookContentItem {
            coverImageView.setupImage(url: item.imageUrl)
        }
    }
}

class VideoTitleThumnailCell: UICollectionViewCell, ContentConfigurable {
    lazy var titleLabel: UILabel = UILabel.configure(to: self.contentView) { (label) in
        label.font = UIFont.systemFont(ofSize: 18)
        label.textColor = .white
        label.backgroundColor = UIColor.gray.withAlphaComponent(0.7)
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
            coverImageView.heightAnchor.constraint(equalToConstant: 120),
            coverImageView.widthAnchor.constraint(equalToConstant: 120),
            ])
        titleLabel.constraints(to: contentView, left: 0, bottom: 0, right: 0).activate()
        coverImageView.constraints(to: contentView).activate()
    }

    func setup(item: AnyContentItem<VideoContentItem>) {
        titleLabel.text = item.base.title
        coverImageView.setupImage(url: item.base.imageUrl)
    }
    func setup<C>(item: C) where C : ContentItem {
        if let item = item as? VideoContentItem {
            titleLabel.text = item.title
            coverImageView.setupImage(url: item.imageUrl)
        }
    }
}

class FeatureContentCell: UICollectionViewCell, ContentConfigurable {
    lazy var titleLabel: UILabel = UILabel.configure(to: self.contentView) { (label) in
        label.font = UIFont.systemFont(ofSize: 12)
        label.backgroundColor = UIColor.black.withAlphaComponent(0.3)
        label.textColor = .white
    }()

    lazy var subtitleLabel: UILabel = UILabel.configure(to: self.contentView) { (label) in
        label.font = UIFont.systemFont(ofSize: 10)
        label.backgroundColor = UIColor.black.withAlphaComponent(0.3)
        label.textColor = .lightGray
    }()

    lazy var coverImageView: UIImageView = UIImageView.configure(to: self.contentView) { (imageView) in
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
    }()

    private func setupLayout() {
        coverImageView.constraints(to: contentView).activate()
        titleLabel.constraints(to: contentView, left: 0, right: 0).activate()
        subtitleLabel.constraints(to: contentView, left: 0, bottom: 0, right: 0).activate()
        [subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 0),
         coverImageView.widthAnchor.constraint(equalToConstant: 200),
         coverImageView.heightAnchor.constraint(equalToConstant: 120)
        ].activate()
    }

    override init(frame: CGRect) {
        super.init(frame: .zero)
        setupLayout()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("Not implemented")
    }

    /* ======= Setup view with model ======== */
    func setup<C>(item: C) where C : ContentItem {

        if let item = item as? FeatureContentItem {
            if let content = item.content as? VideoContentItem {
                titleLabel.text = "V: \(content.title)"
                subtitleLabel.text = content.subtitle
                coverImageView.setupImage(url: content.imageUrl)

            } else if let content = item.content as? BookContentItem {
                titleLabel.text = "B: \(content.title)"
                subtitleLabel.text = content.subtitle
                coverImageView.setupImage(url: content.imageUrl)
            } else {
                assertionFailure("Unhandled item type \(type(of: item))")
            }
        } else {
            assertionFailure("Unhandled item type \(type(of: item))")
        }
    }
}

class HomeViewController: UIViewController, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return rows.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let item = rows[indexPath.row]

        if let item = item as? ContentSection<FeatureContentItem>,
            let cell = tableView.dequeueReusableCell(withIdentifier: HorizontalScrollableCell<FeatureContentItem>.uniqueCellIdentifier, for: indexPath) as? HorizontalScrollableCell<FeatureContentItem> {
            cell.setup(group: item, for: indexPath)
            return cell
        } else if let item = item as? ContentSection<VideoContentItem>, let cell = tableView.dequeueReusableCell(withIdentifier: HorizontalScrollableCell<VideoContentItem>.uniqueCellIdentifier, for: indexPath) as? HorizontalScrollableCell<VideoContentItem> {
            cell.setup(group: item, for: indexPath)
            return cell
        } else if let item = item as? ContentSection<BookContentItem>, let cell = tableView.dequeueReusableCell(withIdentifier: HorizontalScrollableCell<BookContentItem>.uniqueCellIdentifier, for: indexPath) as? HorizontalScrollableCell<BookContentItem> {
            cell.setup(group: item, for: indexPath)
            return cell
        } else {
            assertionFailure("Unhandled type \(type(of: item))")
            return UITableViewCell()
        }
    }

    private lazy var tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .plain)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.register(cellType: HorizontalScrollableCell<FeatureContentItem>.self)
        tableView.register(cellType: HorizontalScrollableCell<VideoContentItem>.self)
        tableView.register(cellType: HorizontalScrollableCell<BookContentItem>.self)
        self.view.addSubview(tableView)
        return tableView
    }()

    var rows: [ContentSectionProtocol] = [] {
        didSet {
            tableView.reloadData()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupLayout()

        tableView.dataSource = self

        let demoVideoItems = (0..<10).map {
            return VideoContentItem(id: "\($0)", title: "Video", subtitle: "Sub", imageUrl: VideoContentItem.randsomVideoImageUrl())
        }

        let demoBookItems = (0..<10).map {
                return BookContentItem(id: "\($0)", title: "Animal Farm \($0)", subtitle: "Book sub title", imageUrl: BookContentItem.randomBookImageUrl())
            }

        let featureItems: [FeatureContentItem] = [
            FeatureContentItem(demoVideoItems[0]),
            FeatureContentItem(demoBookItems[1]),
            FeatureContentItem(demoVideoItems[1]),
            FeatureContentItem(demoVideoItems[2]),
            FeatureContentItem(demoBookItems[3])
        ]

        let featureSectionItems = ContentSection<FeatureContentItem>.section(items: featureItems)
        let editorSelectVideoItems = ContentSection<VideoContentItem>.section(items: demoVideoItems)
        let editorSelectBookItems = ContentSection<BookContentItem>.section(items: demoBookItems)

        self.rows = [
            featureSectionItems,
            editorSelectVideoItems,
            editorSelectBookItems
        ]
    }

    private func setupLayout() {
        tableView.constraints(to: view).activate()
    }

}

protocol PagingControllerProtocol {

    func prefectchData(indexPaths: [IndexPath])


}

extension BookContentItem {
    static func randomBookImageUrl() -> String {
        return [
            "https://pictures.abebooks.com/isbn/9789381607794-uk.jpg",
            "https://kbimages1-a.akamaihd.net/9a13e8d8-2349-404b-83ab-f388807ff945/353/569/90/False/animal-farm-55.jpg",
            "https://upload.wikimedia.org/wikipedia/en/0/08/We_first_ed_dust_jacket.jpg",
            "https://upload.wikimedia.org/wikipedia/en/6/62/BraveNewWorld_FirstEdition.jpg"
        ].randomElement()!
    }
}

extension VideoContentItem {
    static func randsomVideoImageUrl() -> String {
        return [
            "https://m.media-amazon.com/images/M/MV5BMDFkYTc0MGEtZmNhMC00ZDIzLWFmNTEtODM1ZmRlYWMwMWFmXkEyXkFqcGdeQXVyMTMxODk2OTU@._V1_UX182_CR0,0,182,268_AL_.jpg",
            "https://m.media-amazon.com/images/M/MV5BM2MyNjYxNmUtYTAwNi00MTYxLWJmNWYtYzZlODY3ZTk3OTFlXkEyXkFqcGdeQXVyNzkwMjQ5NzM@._V1_SY1000_CR0,0,704,1000_AL_.jpg",
            "https://m.media-amazon.com/images/M/MV5BMTMxNTMwODM0NF5BMl5BanBnXkFtZTcwODAyMTk2Mw@@._V1_SY1000_CR0,0,675,1000_AL_.jpg",
            "https://images.pexels.com/photos/289649/pexels-photo-289649.jpeg?auto=compress&cs=tinysrgb&h=350",
            "https://m.media-amazon.com/images/M/MV5BNGNhMDIzZTUtNTBlZi00MTRlLWFjM2ItYzViMjE3YzI5MjljXkEyXkFqcGdeQXVyNzkwMjQ5NzM@._V1_SY1000_CR0,0,686,1000_AL_.jpg",
            "https://m.media-amazon.com/images/M/MV5BNDE4OTMxMTctNmRhYy00NWE2LTg3YzItYTk3M2UwOTU5Njg4XkEyXkFqcGdeQXVyNjU0OTQ0OTY@._V1_SY1000_CR0,0,666,1000_AL_.jpg",
        ].randomElement()!
    }
}

// Present the view controller in the Live View window
PlaygroundPage.current.liveView = HomeViewController()
