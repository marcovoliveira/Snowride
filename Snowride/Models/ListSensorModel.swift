//Snowride by Marco and Oleksandr from IPLeiria 2020

import UIKit

class ListSensorModel: NSObject {
  var title: String;
  var dateTime: Date;
  var id: UUID;
  var path: String;
  
  init(dateTime: Date, id: UUID, path: String) {
    
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "yyyy-MM-dd HH:mm"
    
    self.title = dateFormatter.string(from: dateTime)
    self.dateTime = dateTime
    self.id = id
    self.path = path
  }
}
