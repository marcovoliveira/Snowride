//Snowride by Marco and Oleksandr from IPLeiria 2020

import os.log
import UIKit
import CoreData
import AVFoundation
import CoreMedia

class HistoryTableViewController: UITableViewController {

  var dataSource: [ListSensorModel] = []
  var allDataSource: [DetailsSensorModel] = []
  
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
      getDataSource()
    }
  
  override func viewWillAppear(_ animated: Bool) {
     super.viewWillAppear(animated)
     navigationController?.setNavigationBarHidden(false, animated: animated)
   }
    @IBAction func playVideo(_ sender: UITapGestureRecognizer) {
        print(sender)
    }
    
    
  private func getDataSource() {
    guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
        return
    }
    
    let managedContext = appDelegate.persistentContainer.viewContext
    
    var titleList: [ListSensorModel] = []
    var ds: [DetailsSensorModel] = []
    
    managedContext.performAndWait {
        do {
            let fetchRequest: NSFetchRequest<SensorData> = SensorData.fetchRequest()
            
            let sensorDatas = try fetchRequest.execute()
            
            for sData in sensorDatas {
                if let id = sData.id {
                  titleList.append(ListSensorModel(dateTime: sData.dateTime!, id: id, path: sData.path!))
                  ds.append(DetailsSensorModel(dateTime: sData.dateTime!, id: id, sensorsDataArrays: sData.sensorDataArrays as! [Dictionary<Int, String>]))
                }
            }

        } catch {
            
        }
        
        // qd se fizer a listagem, teremos que aceder as propriedades de cada elemento
    }
    
    
    dataSource = titleList.sorted(by: { $0.dateTime > $1.dateTime} )
    allDataSource = ds.sorted(by: { $0.dateTime > $1.dateTime})
    
  }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
      return dataSource.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
      
      let cellIdentifier = "HistoryTableViewCell"
      
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? HistoryTableViewCell  else {
             fatalError("The dequeued cell is not an instance of HistoryTableViewCell.")
         }
      print(dataSource[indexPath[1]])
        // Configure the cell...
      let asset = AVAsset(url: URL(string: dataSource[indexPath[1]].path)!)

      cell.titleLabel.text = dataSource[indexPath[1]].title
      cell.duration.text = getVideoDuration(videoUrl: asset)
      print(dataSource[indexPath[1]].path)
      cell.videoThumbnail.image = getThumbnail(videoUrl: asset)
      
      return cell
    }
  
  private func getThumbnail(videoUrl: AVAsset) -> UIImage? {
    let assetImgGen = AVAssetImageGenerator(asset: videoUrl)
    assetImgGen.appliesPreferredTrackTransform = true
    
    let time = CMTimeMakeWithSeconds(1.0,preferredTimescale: 600)
    
    do {
      let img = try assetImgGen.copyCGImage(at: time, actualTime: nil)
      let thumbnail = UIImage(cgImage: img)
      return thumbnail
    } catch {
      print(error.localizedDescription)
      return nil
    }
  }
  
  
  private func getVideoDuration(videoUrl: AVAsset) -> String {
    let seconds = CMTimeGetSeconds(videoUrl.duration)

    if seconds.isFinite{
        let second = Int(seconds)
        let secondsText = second % 60
        var secondString = "00"
        if secondsText < 10{
            secondString = "0\(secondsText)"
        }
        else{
            secondString = "\(secondsText)"
        }
        let minutesText = String(format: "%02d", Int(seconds) / 60)
        let videoLength =  "\(minutesText):\(secondString)"
        return videoLength
    }
    return ""
  }

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
      super.prepare(for: segue, sender: sender)
      guard let historyDetailViewController = segue.destination as? HistoryDetailViewController else {
          fatalError("Unexpected destination: \(segue.destination)")
      }
      
      guard let selectedHistoryCell = sender as? HistoryTableViewCell else {
        fatalError("Unexpected sender: \(sender ?? "")")
      }
      
      guard let indexPath = tableView.indexPath(for: selectedHistoryCell) else {
          fatalError("The selected cell is not being displayed by the table")
      }
      
      let selectedHistory = dataSource[indexPath.row]
      
      historyDetailViewController.dataSource = selectedHistory
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    

}
