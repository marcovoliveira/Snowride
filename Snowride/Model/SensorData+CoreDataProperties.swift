//Snowride by Marco and Oleksandr from IPLeiria 2020
//

import Foundation
import CoreData


extension SensorData {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<SensorData> {
        return NSFetchRequest<SensorData>(entityName: "SensorData")
    }

    @NSManaged public var dateTime: Date?
    @NSManaged public var id: UUID?
    @NSManaged public var path: String?
    @NSManaged public var sensorDataArrays: NSObject?

}
