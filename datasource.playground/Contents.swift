//: A UIKit based Playground for presenting user interface
  
import UIKit
import PlaygroundSupport

extension UIView: AutolayoutView {}
extension UITableViewCell: CellIdentifiable {}
extension UICollectionViewCell: CellIdentifiable {}



// MARK: Data model

protocol GenericContentItem {
    static var cellType: ContentConfigurable.Type { get }
}

// Root protocol of content item
protocol ContentItem: Hashable, GenericContentItem {
    var id: String { get }
    static var cellType: ContentConfigurable.Type { get }
    var onPress: (() -> Void)? { get }
}

/// Type erasured content item
struct AnyContentItem<T: ContentItem>: ContentItem {
    static func == (lhs: AnyContentItem<T>, rhs: AnyContentItem<T>) -> Bool {
        return lhs.id == rhs.id
    }
    func hash(into hasher: inout Hasher) {
        hasher.combine(self.id)
    }

    var id: String {
        return base.id
    }
    static var cellType: ContentConfigurable.Type {
        return T.cellType
    }
    var onPress: (() -> Void)? {
        return base.onPress
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
    static func == (lhs: VideoContentItem, rhs: VideoContentItem) -> Bool {
        return lhs.id == rhs.id
    }
    func hash(into hasher: inout Hasher) {
        hasher.combine(self.id)
    }

    var onPress: (() -> Void)?

    var id: String
    var title: String
    var subtitle: String
    var imageUrl: String
    static var cellType: ContentConfigurable.Type { return VideoTitleThumnailCell.self }
    // Convivenet
    static func video(id: String, title: String, subtitle: String, imageUrl: String) -> VideoContentItem {
        return VideoContentItem(id: id, title: title, subtitle: subtitle, imageUrl: imageUrl)
    }
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

struct BookContentItem: ContentItem, FeaturableContentItem {
    static func == (lhs: BookContentItem, rhs: BookContentItem) -> Bool {
        return lhs.id == rhs.id
    }
    func hash(into hasher: inout Hasher) {
        hasher.combine(self.id)
    }

    var onPress: (() -> Void)?

    var id: String
    var title: String
    var subtitle: String
    var imageUrl: String
    static var cellType: ContentConfigurable.Type { return BookTitleThumbnailCell.self }
    // Convivenet
    static func book(id: String, title: String, subtitle: String, imageUrl: String) -> BookContentItem {
        return BookContentItem(id: id, title: title, subtitle: subtitle, imageUrl: imageUrl)
    }
    static func randomBookImageUrl() -> String {
        return [
            "https://pictures.abebooks.com/isbn/9789381607794-uk.jpg",
            "https://kbimages1-a.akamaihd.net/9a13e8d8-2349-404b-83ab-f388807ff945/353/569/90/False/animal-farm-55.jpg",
            "https://upload.wikimedia.org/wikipedia/en/0/08/We_first_ed_dust_jacket.jpg",
            "https://upload.wikimedia.org/wikipedia/en/6/62/BraveNewWorld_FirstEdition.jpg"
            ].randomElement()!
    }
}

struct FeatureContentItem: ContentItem {
    var onPress: (() -> Void)?

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

protocol ContentConfigurable where Self: UICollectionViewCell {
    func setup<C: ContentItem>(item: C)
}

struct ContentGroup: Hashable {
    let id: String
    let title: String?
    var items: [GenericContentItem]

    init(id: String, title: String? = nil, items: [GenericContentItem]) {
        self.id = id
        self.title = title
        self.items = items
    }

    static func == (lhs: ContentGroup, rhs: ContentGroup) -> Bool {
        return lhs.id == rhs.id
    }
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}




// MAKR: Cells


class HorizontalScrollableCell<C: ContentItem>: UITableViewCell, UICollectionViewDelegate {
    // The offset table for saving the offset for a specific indexpath. Note that the life cycle is the same as the cell
    private struct CellCache {
        private var indexPath: IndexPath
        private var offsetTable: [IndexPath: CGFloat]

        var currentOffset: CGFloat? {
            return offsetTable[indexPath]
        }

        init() {
            indexPath = IndexPath(row: 0, section: 0)
            offsetTable = [:]
        }

        mutating func setIndexPath(_ indexPath: IndexPath) {
            self.indexPath = indexPath
        }

        mutating func save(offset: CGFloat) {
            offsetTable[indexPath] = offset
        }
    }

    /// Dummy section definition
    private struct Section: Hashable {}

    private var dataSource: UICollectionViewDiffableDataSource<Section, C>?
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

    /// View models of cells, updating this view model triggers the update of the collectionView
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

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupCollectionView()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        cache.save(offset: collectionView.contentOffset.x)
    }

    func setup(items: [GenericContentItem], for indexPath: IndexPath) {
        /// Handle the type-erqaured and non-type-erasured case. The items could be [AnyContentItem] or [ContentItem]
        if let items = items as? [C] {
            let typeErasuredItems = items.map { AnyContentItem($0) }
            self.contentItems = typeErasuredItems
        } else if let items = items as? [AnyContentItem<C>] {
            self.contentItems = items
        }

        /// Setup offset for reused cells
        cache.setIndexPath(indexPath)
        if let contentOffsetX = cache.currentOffset {
            collectionView.contentOffset = CGPoint(x: contentOffsetX, y: collectionView.contentOffset.y)
        }
    }

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

    private func setupCollectionView() {
        dataSource = createDataSource(collectionView: collectionView)
        collectionView.dataSource = dataSource
        collectionView.delegate = self
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        let item = self.contentItems[indexPath.row]
        item.onPress?()
    }
}

class VideoListCell: UICollectionViewCell, ContentConfigurable {
    lazy var titleLabel: UILabel = UILabel.configure(to: self.contentView) { (label) in
        label.font = UIFont.systemFont(ofSize: 18)
        label.textColor = .black
        label.numberOfLines = 1
        }()

    lazy var descriptionLabel: UILabel = UILabel.configure(to: self.contentView) { (label) in
        label.font = UIFont.systemFont(ofSize: 12)
        label.textColor = .lightGray
        label.numberOfLines = 0
    }()

    lazy var coverImageView: UIImageView = UIImageView.configure(to: self.contentView) { [unowned self] (imageView) in
        imageView.clipsToBounds = true
        imageView.contentMode = .scaleAspectFill
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupLayout()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("Not implemented")
    }

    func setupLayout() {
        [coverImageView.heightAnchor.constraint(equalToConstant: 120),
         coverImageView.widthAnchor.constraint(equalToConstant: 80),
         titleLabel.leftAnchor.constraint(equalTo: coverImageView.rightAnchor, constant: 10),
         descriptionLabel.leftAnchor.constraint(equalTo: coverImageView.rightAnchor, constant: 10),
         descriptionLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8)
        ].activate()
        titleLabel.constraints(to: contentView, top: 10, right: 10).activate()
        descriptionLabel.constraints(to: contentView, bottom: 10, right: 10).activate()
        coverImageView.constraints(to: contentView, top: 10, left: 10, bottom: 10).activate()
    }

    func setup<C>(item: C) where C : ContentItem {
        if let item = item as? VideoContentItem {
            titleLabel.text = item.title
            descriptionLabel.text = item.subtitle
            coverImageView.setupImage(url: item.imageUrl)
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

protocol ListDataProvider: AnyObject {
    func fetchData<C: ContentItem>(at index: Int, complete: @escaping ([C]) -> Void)
}


// MAKR: Generic list

class ListViewController<Item: ContentItem, Cell: ContentConfigurable>: UIViewController, UICollectionViewDelegate {
    enum Section: Hashable {
        case main
    }

    private let collectionView: UICollectionView
    private let dataSource: UICollectionViewDiffableDataSource<Section, Item>

    var dataProvider: ListDataProvider?

    var items: [Item] = [] {
        didSet {
            // can be diff resource reload
            let snapshot = NSDiffableDataSourceSnapshot<Section, Item>()
            snapshot.appendSections([.main])
            snapshot.appendItems(items)
            dataSource.apply(snapshot)
        }
    }

    init() {
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.scrollDirection = .vertical
        flowLayout.estimatedItemSize = CGSize(width: 100, height: 100)
        flowLayout.itemSize = UICollectionViewFlowLayout.automaticSize
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: flowLayout)
        collectionView.register(cellType: Cell.self)

        let dataSource = UICollectionViewDiffableDataSource<Section, Item>(collectionView: collectionView) { (collectionView, indexPath, item) -> UICollectionViewCell? in
            if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Cell.uniqueCellIdentifier, for: indexPath) as? Cell {
                cell.setup(item: item)
                cell.setupWidthConstraint(constant: collectionView.frame.width)
                cell.setNeedsLayout()
                return cell
            } else {
                assertionFailure("unhandled cell")
                return UICollectionViewCell()
            }
        }
        self.collectionView = collectionView
        self.dataSource = dataSource
        super.init(nibName: nil, bundle: nil)

        setupLayout()
        collectionView.delegate = self
    }

    required init?(coder: NSCoder) {
        fatalError("Haven't implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
    }

    private func setupLayout() {
        collectionView.add(to: self.view, with: .zero)
        collectionView.backgroundColor = .white
    }

    private var isLoading = false
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if isLoading { return }

        if indexPath.row == items.count - 1 {
            isLoading = true
            let complete: ([Item])->Void = { [weak self] receivedItems in
                self?.isLoading = false
                self?.items.append(contentsOf: receivedItems)
            }
            print(indexPath)
            dataProvider?.fetchData(at: indexPath.row+1, complete: complete)
        }
    }
}

class GridViewController: UIViewController, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return rows.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let section = rows[indexPath.row]
        if let items = section.items as? [FeatureContentItem],
            let cell = tableView.dequeueReusableCell(withIdentifier: HorizontalScrollableCell<FeatureContentItem>.uniqueCellIdentifier, for: indexPath) as? HorizontalScrollableCell<FeatureContentItem> {
            cell.setup(items: items, for: indexPath)
            return cell
        } else if let items = section.items as? [VideoContentItem], let cell = tableView.dequeueReusableCell(withIdentifier: HorizontalScrollableCell<VideoContentItem>.uniqueCellIdentifier, for: indexPath) as? HorizontalScrollableCell<VideoContentItem> {
            cell.setup(items: items, for: indexPath)
            return cell
        } else if let items = section.items as? [BookContentItem], let cell = tableView.dequeueReusableCell(withIdentifier: HorizontalScrollableCell<BookContentItem>.uniqueCellIdentifier, for: indexPath) as? HorizontalScrollableCell<BookContentItem> {
            cell.setup(items: items, for: indexPath)
            return cell
        } else {
            assertionFailure("Unhandled type \(type(of: section.items))")
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

    var rows: [ContentGroup] = [] {
        didSet {
            tableView.reloadData()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupLayout()

        tableView.dataSource = self
    }

    func videoPagination() {
        var videoGroup = self.rows[1]
        let lastIdx = videoGroup.items.count
        let nextPageItems = (lastIdx..<lastIdx+10).map { idx in
            return VideoContentItem(onPress: { self.handleSelectContent(at: idx) }, id: "\(idx)", title: "Video", subtitle: String.dummySentences, imageUrl: VideoContentItem.randsomVideoImageUrl())
        }


        videoGroup.items.append(contentsOf: nextPageItems)
        tableView.reloadRows(at: [IndexPath(row: 1, section: 0)], with: .automatic)
    }

    private func handleSelectContent(at index: Int) {
        if let videoItems = rows[1].items as? [VideoContentItem] {
            gotoVideoList(with: videoItems)
        }
    }

    private func setupLayout() {
        tableView.constraints(to: view).activate()
    }

    func gotoVideoList(with items: [VideoContentItem]) {
        let listViewController = ListViewController<VideoContentItem, VideoListCell>()
        listViewController.items = items
        navigationController?.pushViewController(listViewController, animated: true)
    }

}





// MARK: Domain pages, e.g. video list, book list, feature list, etc....

let listViewController = ListViewController<VideoContentItem, VideoListCell>()
let navigationController = UINavigationController(rootViewController: listViewController)

// Mock data
listViewController.items = (0..<1).map { idx in
    return VideoContentItem(id: "\(idx)", title: "Video", subtitle: String.dummySentences, imageUrl: VideoContentItem.randsomVideoImageUrl())
}

class VideoDataProvider: ListDataProvider {
    func fetchData<C>(at index: Int, complete: @escaping ([C]) -> Void) where C : ContentItem {
        guard let complete = complete as? (([VideoContentItem]) -> Void) else { return }

        DispatchQueue.main.asyncAfter(deadline: .now()+1) {
            let fetchedItems = (index..<index+10).map { idx in
                return VideoContentItem(id: "\(idx)", title: "Video", subtitle: String.dummySentences, imageUrl: VideoContentItem.randsomVideoImageUrl())
            }
            complete(fetchedItems)
        }
    }
}

listViewController.dataProvider = VideoDataProvider()


// Another example
let gridViewController = GridViewController()
let demoVideoItems = (0..<10).map { idx in
    return VideoContentItem(id: "\(idx)", title: "Video", subtitle: String.dummySentences, imageUrl: VideoContentItem.randsomVideoImageUrl())
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

let featureSectionItems = ContentGroup(id: "1", items: featureItems)
let editorSelectVideoItems = ContentGroup(id: "2", title: "Best Movie", items: demoVideoItems)
let editorSelectBookItems = ContentGroup(id: "3", title: "Editor Choice Book", items: demoBookItems)

// Update data
gridViewController.rows = [
    featureSectionItems,
    editorSelectVideoItems,
    editorSelectBookItems
]

PlaygroundPage.current.liveView = listViewController

