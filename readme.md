# New Datasource


## Basic Idea 
Manipulate only data model, don’t touch the view code 

```swift
struct VideoContentItem {
}
struct BookContentItem {
}

// Data Model should looks the same as in the UI 
[
 featureSectionItems,
 editorSelectVideoItems,
 editorSelectBookItems
]


// When user vertically scrolls
[
 featureSectionItems,
 editorSelectVideoItems,
 editorSelectBookItems,
 // Append those 
 newEditorSelectVideoItems,
 newEditorSelectVideoItems2,
 newEditorSelectVideoItems3,
]

// When user horizontally scrolls
[
	featureSectionItems,
	editorSelectVideoItems + nexPageItems,
	editorSelectBookItems
]
```

1. Descriptive view
2. Single data model source of truth is better
3. Make less UI layer (by setup view code inside cell)

## Generic tableview/collectionview

For similar pages, we change data provider only 

```
// Build the video list 
let listViewController = ListViewController<VideoContentItem, VideoListCell>()
listViewController.dataProvider = VideoDataProvider()

// or book list 
let listViewController = ListViewController<BookContentItem, BookListCell>()
listViewController.dataProvider = BookDataProvider()

// or Video list with different layout
let listViewController = ListViewController<VideoContentItem, LargeVideoListCell>()
listViewController.dataProvider = VideoDataProvider()


present(listViewController)
```

## Put UI code inside cell 

To make the UI logics in the most related place. Also make it possible to generic the cell setup

```
protocol ContentConfigurable {
	func setup(item: ContentItem)
}

class VideoCell: UICollectionViewCell, ContentConfigurable {
    /*
    Any UI code here
    */ 

    func setup(item: VideoContentItem) {
        if let item = item as? VideoContentItem {
            titleLabel.text = item.title
            coverImageView.setupImage(url: item.imageUrl)
        }
    }
}

class BookCell: UICollectionViewCell, ContentnConfigurable {
    /*
    Any UI code here
    */ 
    
    func setup(item: BookContentItem) {
        titleLabel.text = item.title
        descriptionLabel.text = item.description
        coverImageView.setupImage(url: item.imageUrl)
    }
}

Note: Above is pseudo code, in Swift the ContentItem need to be type erasured and the setup function in the cell should be with the same footprint

```

## How to update the list

### Swift’s new datasource 

In the ListViewController<Cell, Item>:

```swift
// Setup
let dataSource = UICollectionViewDiffableDataSource(collectionView: collectionView) { (collectionView, indexPath, item) -> UICollectionViewCell? in
    if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: C.cellType.uniqueCellIdentifier, for: indexPath) as? ContentConfigurable {
        cell.setup(item: item) // The cell setup in above section
        return cell
    } else {
        assertionFailure("Unhanlded item: \(type(of: item))")
        return UICollectionViewCell()
    }
}

collectionView.dataSource = dataSource

// To update the collectionView
var items: [Item] = [] {
	didSet {
		let items = DataProvider().getItems() // Could be async call
		let snapshot = NSDiffableDataSourceSnapshot<Section, Item>()
		snapshot.appendItems(items)
		dataSource?.apply(snapshot)
	}
}

```


### Polyfill Library:
[GitHub - ra1028/DiffableDataSources: 💾 A library for backporting UITableView/UICollectionViewDiffableDataSource.](https://github.com/ra1028/DiffableDataSources)



## Feedback 2019.07.26

1. It's better not to bind a single cell type to a view controller since it's possible that a table view might contain mutiple cell types. e.g. Search result 
2. In feature detail, the paging controller and page data source's interaction might not be able to be fixed in the data source structure 
3. Can have an experiment on current project, specificly the search result page and my list page. 

### Actions

* upload the demo project for review
* experiment on current Unext app




