import UIKit
import AVFoundation

class CustomCameraViewController: UIViewController {
  
  var captureSession = AVCaptureSession()
  var backCamera: AVCaptureDevice?
  var frontCamera: AVCaptureDevice?
  var currentCamera: AVCaptureDevice?
  var videoOutput: AVCaptureVideoDataOutput?
  
    @IBOutlet weak var overlayView: UIView!
    @IBOutlet weak var recordButton: UIButton!
    var cameraPreviewLayer: AVCaptureVideoPreviewLayer?
  
    override func viewDidLoad() {
        super.viewDidLoad()
      setupCaptureSession()
      setupDevice()
      setupInputOutput()
      setupPreviewLayer()
      startRuningCaptureSession()
        // Do any additional setup after loading the view.
    }
  
  
    @IBAction func recordButtonAction(_ sender: Any) {
      
    }
    
  
  func setupCaptureSession() {
    captureSession.sessionPreset = AVCaptureSession.Preset.photo
    
  }
  
  func setupDevice() {
    let deviceDiscoverySession = AVCaptureDevice.DiscoverySession(deviceTypes: [AVCaptureDevice.DeviceType.builtInWideAngleCamera], mediaType: AVMediaType.video, position: AVCaptureDevice.Position.unspecified)
    
    let devices = deviceDiscoverySession.devices
    
    for device in devices {
      if device.position == AVCaptureDevice.Position.back  {
         backCamera = device
      } else if device.position == AVCaptureDevice.Position.front {
        frontCamera = device
      }
    }
    
    currentCamera = backCamera
  }
  
  func setupInputOutput() {
    do {
      let captureDeviceInput = try AVCaptureDeviceInput(device: currentCamera!)
      captureSession.addInput(captureDeviceInput)
      videoOutput = AVCaptureVideoDataOutput()
          } catch  {
      print(error)
    }
    
    captureSession.addOutput(videoOutput!)
  }
  
  func setupPreviewLayer() {
    cameraPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
    cameraPreviewLayer?.videoGravity = AVLayerVideoGravity.resizeAspectFill
    cameraPreviewLayer?.connection?.videoOrientation = AVCaptureVideoOrientation.portrait
    cameraPreviewLayer?.frame = self.view.frame
    self.view.layer.insertSublayer(cameraPreviewLayer!, at: 0)
  }
  
  func startRuningCaptureSession() {
    captureSession.startRunning()
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
