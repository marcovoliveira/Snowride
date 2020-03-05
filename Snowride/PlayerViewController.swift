import UIKit
import AVKit
import Photos

class PlayerViewController: UIViewController {
  var videoURL: URL!
  
  private var player: AVPlayer!
  private var playerLayer: AVPlayerLayer!
  
  @IBOutlet weak var videoView: UIView!
  
  private func saveVideo() {
    PHPhotoLibrary.requestAuthorization { [weak self] status in
      switch status {
      case .authorized:
        self?.saveVideoToPhotos()
      default:
        print("Não garantiu permissao para gravar")
        return
      }
    }
  }
  
  private func saveVideoToPhotos() {
    PHPhotoLibrary.shared().performChanges( {
      PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: self.videoURL)
    }) { (isSaved, error) in
      if isSaved {
        let fetchOptions = PHFetchOptions()
        fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: true)]
        let fetchResult = PHAsset.fetchAssets(with: .video, options: fetchOptions).lastObject
        PHImageManager().requestAVAsset(forVideo: fetchResult!, options: nil, resultHandler: { (avurlAsset, audioMix, dict) in
          let newObj = avurlAsset as! AVURLAsset
          PickerViewController().saveData(path: newObj.url.absoluteString)
        })
        
        print("Gravado.")
      } else {
        print("Nao gravou.")
        print(error ?? "erro")
      }
//      DispatchQueue.main.async {
//        self?.navigationController?.popViewController(animated: true)
//      }
    }
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    player = AVPlayer(url: videoURL)
    playerLayer = AVPlayerLayer(player: player)
    playerLayer.frame = videoView.bounds
    print(videoView.bounds)
    
    videoView.layer.addSublayer(playerLayer)
    player.play()
    
    NotificationCenter.default.addObserver(
      forName: .AVPlayerItemDidPlayToEndTime,
      object: nil,
      queue: nil) { [weak self] _ in self?.restart() }
    
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    saveVideo();
    navigationController?.setNavigationBarHidden(false, animated: animated)
  }
  
  override func viewDidLayoutSubviews() {
    super.viewDidLayoutSubviews()
    
    playerLayer.frame = videoView.bounds
  }
  
  private func restart() {
    player.seek(to: .zero)
    player.play()
  }
  
  deinit {
    NotificationCenter.default.removeObserver(
      self,
      name: .AVPlayerItemDidPlayToEndTime,
      object: nil)
  }
}
