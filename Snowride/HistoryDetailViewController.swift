//Snowride by Marco and Oleksandr from IPLeiria 2020

import UIKit
import AVKit

class HistoryDetailViewController: UIViewController {
  
    @IBOutlet weak var minAltitudeLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var maxAltitudeLabel: UILabel!
    @IBOutlet weak var altidudeDifferenceLabel: UILabel!
    @IBOutlet weak var maxGForceLabel: UILabel!
    @IBOutlet weak var maxSpeedLabel: UILabel!
    @IBOutlet weak var durationLabel: UILabel!
    @IBOutlet weak var imageThumb: UIImageView!
    @IBOutlet weak var weatherIcon: UIImageView!
    
  var dataSource: ListSensorModel?

  var path: String?
    override func viewDidLoad() {
        super.viewDidLoad()
             
             // Set up views if editing an existing Meal.
             if let dataSource = dataSource {
              //print(dataSource)
              dateLabel.text = "Date: \(dataSource.title)"
              path = dataSource.path
              //minAltitudeLabel.text = dataSource.altitudeData.count > 0 ? dataSource.altitudeData.first?.value.description : ""
              
      }
        // Do any additional setup after loading the view.
    }
  
    @IBAction func playVideo(_ sender: Any) {
      
      showVideo(at: NSURL(string: path!)! as URL)
    }
  
  private func showVideo(at url: URL) {
     let player = AVPlayer(url: url)
     let playerViewController = AVPlayerViewController()
     playerViewController.player = player
     present(playerViewController, animated: true) {
       player.play()
     }
   }
    
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
