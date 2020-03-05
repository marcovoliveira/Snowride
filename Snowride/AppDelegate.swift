import UIKit
import CoreData

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
  var window: UIWindow?
  
   lazy var persistentContainer: NSPersistentContainer = {
      let container = NSPersistentContainer(name: "snowRideModel")
      container.loadPersistentStores { (storeDesc, error) in
          if let error = error as NSError? {
              fatalError("Unresolved error")
          }
      }
      return container
  }()
}

