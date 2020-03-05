import UIKit
import MobileCoreServices
import AVKit
import CoreMotion
import CoreLocation
import CoreData

class PickerViewController: UIViewController, CLLocationManagerDelegate {
  private let editor = VideoEditor()
  var sensores = false;
  
  @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
  @IBOutlet weak var recordButton: UIButton!
  @IBOutlet weak var pickButton: UIButton!
  @IBOutlet weak var settingsButton: UIButton!
  @IBOutlet var overlayView: UIView?
  @IBOutlet weak var recordVideoButton: UIButton!
  @IBOutlet weak var goBackButton: UIBarButtonItem!
  @IBOutlet weak var recordOnlyVideoButton: UIButton!
  @IBOutlet weak var historyButton: UIButton!
  @IBOutlet weak var aboutButton: UIButton!
    
    
  var pickerController = UIImagePickerController()
    
  var isRecording = false;
    
  var timer = Timer()

  var videoTimeInSec = 0
  
  let locationManager = CLLocationManager()
  
  let motionManager = CMMotionManager()
  
  var uniqueId: UUID = UUID()
  
  var currentDateTime = Date()
  
  var arrayToStore: [Dictionary<Int, String>] = []


  @objc func addTimerValue() {
        videoTimeInSec += 1
    }
    
  // Gravar Video com dados dos sensores
  @IBAction func recordVideoAndSensors(_ sender: Any) {
    sensores = true;
    pickVideo(from: .camera)
  }
  
  // Gravar dados dos sensores
  @IBAction func recordSensores(_ sender: Any) {
    sensores = true
    
  }
    
  // Gravar video
  @IBAction func recordOnlyVideo(_ sender: Any) {
    sensores = false
    pickVideo(from: .camera)
  }
  
  @IBAction func recordVideoStartStop(_ sender: Any) {
      
    recordVideo()
  }
  
  func recordVideo(video: Bool = true) {
    if !isRecording {
      if video {
        recordVideoButton.backgroundColor = .red
      }
      videoTimeInSec = 0
      
      if(video) {
      timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(addTimerValue), userInfo: nil, repeats: true)
      }
      isRecording = true
      
      getSensorsData()
      if video {
      pickerController.startVideoCapture()
      }
    } else {
      recordVideoButton.backgroundColor = .white


      isRecording = false
      
      self.motionManager.stopDeviceMotionUpdates()
      self.locationManager.stopUpdatingLocation()
      self.locationManager.stopUpdatingHeading()
      
      if video {
      pickerController.stopVideoCapture()
      }
      
      timer.invalidate()
      
    }
  }
    
  private func getSensorsData() {
    
    self.uniqueId = UUID()
    
    self.arrayToStore = []
        
    self.currentDateTime = Date()
    
    // config do locationManager
    // aqui verifico se é preciso usar o locationManager ou nao; nao se usa caso nenhum dos 3 valores for para ser apresentado
    if UserDefaults.standard.bool(forKey: "speed") || UserDefaults.standard.bool(forKey: "altitude") || UserDefaults.standard.bool(forKey: "weather") {
      locationManager.delegate = self
      locationManager.requestWhenInUseAuthorization()
      locationManager.startUpdatingLocation()
      locationManager.startUpdatingHeading()
    }

        
    // dados de gForce
    self.arrayToStore.append(Dictionary<Int, String>())
    // dados de velocidade
    self.arrayToStore.append(Dictionary<Int, String>())
    // dados de altitude
    self.arrayToStore.append(Dictionary<Int, String>())
    // dados de gps
    self.arrayToStore.append(Dictionary<Int, String>())
    
    // aqui falta um if a verificar userDefaults para gForce
    if self.motionManager.isAccelerometerAvailable && UserDefaults.standard.bool(forKey: "gforce") {
        self.motionManager.accelerometerUpdateInterval = 60.0 / 60.0
    
        self.motionManager.startAccelerometerUpdates(to: OperationQueue.current!) { (data, error) in
            if(self.isRecording) {
                if let data = self.motionManager.accelerometerData {
                    let x = data.acceleration.x;
                    let y = data.acceleration.y;
                    let z = data.acceleration.z;
                    
                    // Força G é calculada através desta fórmula. O valor parado é ~1g (representa o estado normal sem movimento na terra).
                    let gForce = sqrt((abs(x) * abs(x)) +
                    (abs(y) * abs(y)) +
                    (abs(z) * abs(z)))
                                            
                  self.arrayToStore[0][self.videoTimeInSec] = String(format: "%.2f", gForce)
                }
            }
        }

    } else {
        print("Acelarometer is not available")
    }
  }
  
  public func saveData(path: String) {
    guard let appDelegate = UIApplication.shared.delegate as? AppDelegate
          else {
              return
          }
          
          let managedContext = appDelegate.persistentContainer.viewContext
          
          let sensorDataEntity = NSEntityDescription.entity(forEntityName: "SensorData", in: managedContext)
          
          let sensorDataValue = NSManagedObject(entity: sensorDataEntity!, insertInto: managedContext)
          
          sensorDataValue.setValue(self.uniqueId, forKey: "id")
          // colocar um path correcto
          sensorDataValue.setValue(path, forKey: "path")
          
          sensorDataValue.setValue(self.currentDateTime, forKey: "dateTime")

          sensorDataValue.setValue(arrayToStore, forKey: "sensorDataArrays")
              
          print(arrayToStore);
          do {
              try managedContext.save()
              print("Saved with success")
          } catch _ as NSError {
              print("Error saving")
          }
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    recordButton.isEnabled = true
    pickButton.isEnabled = true
    recordVideoButton.isEnabled = true
  }
  
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    navigationController?.setNavigationBarHidden(true, animated: animated)
  }
  
  private func pickVideo(from sourceType: UIImagePickerController.SourceType) {
    pickerController = UIImagePickerController()
    pickerController.sourceType = sourceType
    pickerController.mediaTypes = [kUTTypeMovie as String]
    pickerController.videoQuality = .typeIFrame1280x720
    if sourceType == .camera {
        pickerController.showsCameraControls = false
      overlayView?.frame = (pickerController.cameraOverlayView?.frame)!
      
      pickerController.cameraOverlayView = overlayView
      pickerController.cameraDevice = .rear
        
        navigationController?.setNavigationBarHidden(true, animated: false)
      
    }
    pickerController.delegate = self
    present(pickerController, animated: true)
  }
    
    @IBAction func closeCamera(_ sender: Any) {
        recordVideoButton.backgroundColor = .white
        pickerController.stopVideoCapture()
        pickerController.dismiss(animated: true, completion: nil)
    }
    
  
  private func showVideo(at url: URL) {
    let player = AVPlayer(url: url)
    let playerViewController = AVPlayerViewController()
    playerViewController.player = player
    present(playerViewController, animated: true) {
      player.play()
    }
  }
  
  private var pickedURL: URL?
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    guard
      let url = pickedURL,
      let destination = segue.destination as? PlayerViewController
      else {
        return
    }
    
    destination.videoURL = url
  }
  
  private func showInProgress() {
    activityIndicator.startAnimating()
    recordVideoButton.isEnabled = false
    recordOnlyVideoButton.isEnabled = false
    historyButton.isEnabled = false
    pickButton.isEnabled = false
    recordButton.isEnabled = false
    settingsButton.isEnabled = false
    aboutButton.isEnabled = false
  }
  
  private func showCompleted() {
    activityIndicator.stopAnimating()
    recordVideoButton.isEnabled = true
    recordOnlyVideoButton.isEnabled = true
    historyButton.isEnabled = true
    pickButton.isEnabled = true
    recordButton.isEnabled = true
    settingsButton.isEnabled = true
    aboutButton.isEnabled = true
    recordButton.isEnabled = UIImagePickerController.isSourceTypeAvailable(.camera)
  }
  
  func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
      for currentLocation in locations {

        if UserDefaults.standard.bool(forKey: "speed") {
          let speed = currentLocation.speed
          self.arrayToStore[1][self.videoTimeInSec] = speed == -1 ? 0.description : String(format: "%.0f", abs((speed * 3.6)))
        }
        
        if UserDefaults.standard.bool(forKey: "altitude") {
          self.arrayToStore[2][self.videoTimeInSec] = String(format: "%.1f", currentLocation.altitude)
        }
        
        if UserDefaults.standard.bool(forKey: "weather") {
            self.arrayToStore[3][self.videoTimeInSec] = currentLocation.coordinate.latitude.description + ", " + currentLocation.coordinate.longitude.description
        }
        

      }
  }
}

extension PickerViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
  func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
    guard
      let url = info[.mediaURL] as? URL
      else {
        print("Cannot get video URL")
        return
    }
    let name = ""
    
    showInProgress()
    
    dismiss(animated: true) {
      self.editor.handleVideo(fromVideoAt: url, forName: name, sensoresData: self.arrayToStore, sensores: self.sensores) { exportedURL in
        self.showCompleted()
        guard let exportedURL = exportedURL else {
          return
        }
        self.pickedURL = exportedURL
        //self.saveData(path: exportedURL.absoluteString)
        self.performSegue(withIdentifier: "showVideo", sender: nil)
      }
    }
  }
}

extension PickerViewController: UITextFieldDelegate {
  func textFieldShouldReturn(_ textField: UITextField) -> Bool {
    textField.resignFirstResponder()
    return true
  }
}
