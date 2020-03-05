//Snowride by Marco and Oleksandr from IPLeiria 2020

import UIKit

class RecordingDataViewController: UIViewController {

    @IBOutlet weak var startStopRecordingButton: UIButton!
    @IBOutlet weak var msecondsLabel: UILabel!
    @IBOutlet weak var minutesLabel: UILabel!
    @IBOutlet weak var secondsLabel: UILabel!
    
    var timer = Timer()
    var counter = 0.0
    var time: Double = 0
    var startTime: Double = 0
    var elasped: Double = 0

    
    var stateRecord = false;
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    navigationController?.setNavigationBarHidden(false, animated: animated)
  }
    
    @IBAction func startStopRecording(_ sender: Any) {
        if(stateRecord == true){
          //PickerViewController().recordVideo(video: false)
          //PickerViewController().saveData(path: " ")
          stopRecord()
          PickerViewController().saveData(path: "default")
        } else {
          //PickerViewController().recordVideo(video: false)
          
            PickerViewController().recordVideo(video: false)

            startRecord()
        }
    }
    
    @objc private func UpdateTimer() {
        time = Date.timeIntervalSinceReferenceDate - startTime
      
      //Calcular minutos
      let minutes = UInt8(time / 60.0)
      time -= (TimeInterval(minutes)*60)
      
      //Calcular segundos
      let seconds = UInt8(time)
      time -= TimeInterval(seconds)
      
      //Calcular milisegundos
      let miliseconds = UInt8(time * 100)
      
      let strMinutes = String(format: "%02d", minutes)
      let strSeconds = String(format: "%02d", seconds)
      let strMiliseconds = String(format: "%02d", miliseconds)
      minutesLabel.text = strMinutes
      secondsLabel.text = strSeconds
      msecondsLabel.text = strMiliseconds
      
      
    }
    
    
    private func startRecord(){
        startTime = Date().timeIntervalSinceReferenceDate - elasped
        timer = Timer.scheduledTimer(timeInterval: 0.01, target: self, selector: #selector(UpdateTimer), userInfo: nil, repeats: true)
        stateRecord = true
        startStopRecordingButton.setTitle("Recording", for: .normal)
        startStopRecordingButton.backgroundColor = .red
        startStopRecordingButton.tintColor = .white
    }
    
    private func stopRecord(){
        elasped = Date().timeIntervalSinceReferenceDate - startTime
        timer.invalidate()
        stateRecord = false
        startStopRecordingButton.setTitle("Record", for: .normal)
        startStopRecordingButton.backgroundColor = .white
        startStopRecordingButton.tintColor = .black
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
