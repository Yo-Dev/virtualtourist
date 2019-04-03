//
//  PhotoAlbumViewController.swift
//  Virtual Tourist
//
//  Created by InstaDeep Team  on 2/15/19.
//  Copyright © 2019 InstaDeep Team . All rights reserved.
//

import UIKit
import MapKit
import CoreData

class PhotoAlbumViewController: UIViewController, MKMapViewDelegate {
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var flowLayout: UICollectionViewFlowLayout?
    @IBOutlet weak var button: UIButton!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var labelStatus: UILabel!
    
    
    
    var indexes = [IndexPath]()
    var insertedIndexPaths: [IndexPath]!
    var deletedIndexPaths: [IndexPath]!
    var updatedIndexPaths: [IndexPath]!
    var totalPages: Int? = nil
    
    var presentingAlert = false
    var pin: Pin?
    var fetchedResultsController: NSFetchedResultsController<Photo>!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        updateFlowLayout(view.frame.size)
        mapView.delegate = self
        mapView.isZoomEnabled = false
        mapView.isScrollEnabled = false
        
        
        updateMessage("")
        
        guard let pin = pin else {
            return
        }
        showOnTheMap(pin)
        setupFetchedResultControllerWith(pin)
        
        if let photos = pin.photos, photos.count == 0 {
            // pin selected has no photos
            fetchPhotosFromAPI(pin)
        }
    }

    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        updateFlowLayout(size)
    }
    
    // MARK: - Actions
    
    @IBAction func deleteAction(_ sender: Any) {
        // delete all photos
        for photos in fetchedResultsController.fetchedObjects! {
            CoreDataStack.shared().context.delete(photos)
        }
        save()
        fetchPhotosFromAPI(pin!)
    }
    
    // MARK: - Helpers
    
    private func setupFetchedResultControllerWith(_ pin: Pin) {
        
        let fr = NSFetchRequest<Photo>(entityName: "Photo")
        fr.sortDescriptors = []
        fr.predicate = NSPredicate(format: "pin == %@", argumentArray: [pin])
        
        // Create the FetchedResultsController
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fr, managedObjectContext: CoreDataStack.shared().context, sectionNameKeyPath: nil, cacheName: nil)
        fetchedResultsController.delegate = self
        
        // Start the fetched results controller
        var error: NSError?
        do {
            try fetchedResultsController.performFetch()
        } catch let error1 as NSError {
            error = error1
        }
        
        if let error = error {
            print(error)
        }
    }
    
    private func fetchPhotosFromAPI(_ pin: Pin) {
        
        let lat = Double(pin.latitude!)!
        let lon = Double(pin.longitude!)!
        
        activityIndicator.startAnimating()
        self.updateMessage("Fetching photos ...")
        
        Client.shared().searchBy(latitude: lat, longitude: lon, totalPages: totalPages) { (photosParsed, error) in
            self.performUIUpdatesOnMain {
                self.activityIndicator.stopAnimating()
                self.labelStatus.text = ""
            }
            if let photosParsed = photosParsed {
                self.totalPages = photosParsed.photos.pages
                let totalPhotos = photosParsed.photos.photo.count
               
                self.savePhotos(photosParsed.photos.photo, forPin: pin)
                if totalPhotos == 0 {
                    self.updateMessage("No photos found ")
                }
            } else if let error = error {
               
                self.showInfo(withTitle: "Error", withMessage: error.localizedDescription)
                self.updateMessage("Something went wrong, please try again ")
            }
        }
    }
    
    private func updateMessage(_ text: String) {
        self.performUIUpdatesOnMain {
            self.labelStatus.text = text
        }
    }
    
    private func savePhotos(_ photos: [PhotoParser], forPin: Pin) {
        func showErrorMessage(msg: String) {
            showInfo(withTitle: "Error", withMessage: msg)
        }
        
        for photo in photos {
            performUIUpdatesOnMain {
                if let url = photo.url {
                    _ = Photo(title: photo.title, imageUrl: url, forPin: forPin, context: CoreDataStack.shared().context)
                    self.save()
                }
            }
        }
    }
    
    private func showOnTheMap(_ pin: Pin) {
        
       
        let locCoord = CLLocationCoordinate2D(latitude: Double(pin.latitude!)!, longitude: Double(pin.longitude!)!)
        
        let annotation = MKPointAnnotation()
        annotation.coordinate = locCoord
        
        mapView.removeAnnotations(mapView.annotations)
        mapView.addAnnotation(annotation)
        mapView.setCenter(locCoord, animated: true)
    }
    
    private func loadPhotos(using pin: Pin) -> [Photo]? {
        let predicate = NSPredicate(format: "pin == %@", argumentArray: [pin])
        var photos: [Photo]?
        do {
            try photos = CoreDataStack.shared().fetchImages(predicate, entityName: "Photo")
        } catch {
            
            showInfo(withTitle: "Error", withMessage: "Error while lading Photos from disk: \(error)")
        }
        return photos
    }
    
    private func updateFlowLayout(_ withSize: CGSize) {
        
        let landscape = withSize.width > withSize.height
        
        let space: CGFloat = landscape ? 5 : 3
        let items: CGFloat = landscape ? 2 : 3
        
        let dimension = (withSize.width - ((items + 1) * space)) / items
        
        flowLayout?.minimumInteritemSpacing = space
        flowLayout?.minimumLineSpacing = space
        flowLayout?.itemSize = CGSize(width: dimension, height: dimension)
        flowLayout?.sectionInset = UIEdgeInsets(top: space, left: space, bottom: space, right: space)
    }
    
    func updateBottomButton() {
        if indexes.count > 0 {
            button.setTitle("Remove Selected", for: .normal)
        } else {
            button.setTitle("New Collection", for: .normal)
        }
    }
}



extension PhotoAlbumViewController {
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        let reuseId = "pin"
        
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId) as? MKPinAnnotationView
        
        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView!.canShowCallout = false
            pinView!.pinTintColor = .blue
        } else {
            pinView!.annotation = annotation
        }
        
        return pinView
    }
}
