//Snowride by Marco and Oleksandr from IPLeiria 2020

import UIKit

class DetailsSensorModel: NSObject {
  var title: String;
  var dateTime: Date;
  var id: UUID;
//  var altitudeData: Dictionary<Int, String>
//  var speedData: Dictionary<Int, String>
//  var gforceData: Dictionary<Int, String>
//  var coordinatesData: Dictionary<Int, String>
  
  init(dateTime: Date, id: UUID, sensorsDataArrays: [Dictionary<Int, String>]) {
      self.title = dateTime.description
      self.dateTime = dateTime
      self.id = id
    /*self.altitudeData = sensorDataArrays.count > 3 ? sensorsDataArrays[2]: []
      self.speedData = sensorsDataArrays[1]
      self.gforceData = sensorsDataArrays[0]
      self.coordinatesData = sensorsDataArrays[3]*/
  }
}
