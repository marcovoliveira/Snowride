import UIKit
import AVFoundation

class VideoEditor {
  func handleVideo(fromVideoAt videoURL: URL, forName name: String, sensoresData: [Dictionary<Int, String>],  sensores: Bool, onComplete: @escaping (URL?) -> Void) {
    print(videoURL)
    let asset = AVURLAsset(url: videoURL)
    let composition = AVMutableComposition()
    guard
      let compositionTrack = composition.addMutableTrack(
        withMediaType: .video, preferredTrackID: kCMPersistentTrackID_Invalid),
      let assetTrack = asset.tracks(withMediaType: .video).first
      else {
        print("Something is wrong with the asset.")
        onComplete(nil)
        return
    }
    
    do {
      let timeRange = CMTimeRange(start: .zero, duration: asset.duration)
      try compositionTrack.insertTimeRange(timeRange, of: assetTrack, at: .zero)
      
      if let audioAssetTrack = asset.tracks(withMediaType: .audio).first,
        let compositionAudioTrack = composition.addMutableTrack(
          withMediaType: .audio,
          preferredTrackID: kCMPersistentTrackID_Invalid) {
        try compositionAudioTrack.insertTimeRange(
          timeRange,
          of: audioAssetTrack,
          at: .zero)
      }
    } catch {
      print(error)
      onComplete(nil)
      return
    }
    
    compositionTrack.preferredTransform = assetTrack.preferredTransform
    let videoInfo = orientation(from: assetTrack.preferredTransform)
    
    let videoSize: CGSize
    if videoInfo.isPortrait {
      videoSize = CGSize(
        width: assetTrack.naturalSize.height,
        height: assetTrack.naturalSize.width)
    } else {
      videoSize = assetTrack.naturalSize
    }
    
    let backgroundLayer = CALayer()
    backgroundLayer.frame = CGRect(origin: .zero, size: videoSize)
    let videoLayer = CALayer()
    videoLayer.frame = CGRect(origin: .zero, size: videoSize)
    let overlayLayer = CALayer()
    overlayLayer.frame = CGRect(origin: .zero, size: videoSize)
    
    

    backgroundLayer.backgroundColor = UIColor(named: "blue")?.cgColor
    videoLayer.frame = CGRect(
      x: 20,
      y: 20,
      width: videoSize.width - 40,
      height: videoSize.height - 40)
    
    backgroundLayer.contents = UIImage(named: "back")?.cgImage
    backgroundLayer.contentsGravity = .resizeAspectFill
    
    if sensores == true {
      
      // G force overlay
      for (secondG, valueG) in sensoresData[0] {
        add(
          text: valueG + " G",
          to: overlayLayer,
          startTime: Double(secondG),
          oldLayer: nil,
          first: true,
          videoSize: videoSize,
          position: [CGFloat(0.03), CGFloat (0.01)],
          outTime: secondG+1)
      }
      
      let speed = sensoresData[1].sorted(by: <)
      var i = 0;
      for (secondS, valueS) in speed {
        
        var speedSeconds = Int(asset.duration.seconds)+1

        if i < speed.count-1 {
          i = i+1
          speedSeconds = Array(speed)[i].key
        }
        
       add(
         text: valueS + " Km/H",
         to: overlayLayer,
         startTime: Double(secondS),
         oldLayer: nil,
         first: true,
         videoSize: videoSize,
         position: [CGFloat(0.65), CGFloat (0.01)],
         outTime: speedSeconds)
        
      }
      //Altitude position: [CGFloat(0.03), CGFloat (0.80)],
       // addImage(to: overlayLayer, videoSize: videoSize)
      let altitude = sensoresData[2].sorted(by: <)
      var ai = 0;
      for (secondA, valueA) in altitude {
        
        var altitudeSeconds = Int(asset.duration.seconds)+1

        if ai < altitude.count-1 {
          ai = ai+1
          altitudeSeconds = Array(altitude)[ai].key
        }
        print(altitudeSeconds)
       add(
         text: valueA + " m",
         to: overlayLayer,
         startTime: Double(secondA),
         oldLayer: nil,
         first: true,
         videoSize: videoSize,
         position: [CGFloat(0.03), CGFloat (0.8)],
         outTime: altitudeSeconds)
        
      }
        
        

    } else {
      addText(text: "Recorded with Snowride", to: overlayLayer, videoSize: videoSize)
    }
    
    
    let outputLayer = CALayer()
    outputLayer.frame = CGRect(origin: .zero, size: videoSize)
    //outputLayer.addSublayer(backgroundLayer)
    outputLayer.addSublayer(videoLayer)
    outputLayer.addSublayer(overlayLayer)
    
    let videoComposition = AVMutableVideoComposition()
    videoComposition.renderSize = videoSize
    videoComposition.frameDuration = CMTime(value: 1, timescale: 30)
    videoComposition.animationTool = AVVideoCompositionCoreAnimationTool(
      postProcessingAsVideoLayer: videoLayer,
      in: outputLayer)
    
    let instruction = AVMutableVideoCompositionInstruction()
    instruction.timeRange = CMTimeRange(
      start: .zero,
      duration: composition.duration)
    videoComposition.instructions = [instruction]
    let layerInstruction = compositionLayerInstruction(
      for: compositionTrack,
      assetTrack: assetTrack)
    instruction.layerInstructions = [layerInstruction]
    
    guard let export = AVAssetExportSession(
      asset: composition,
      presetName: AVAssetExportPresetHighestQuality)
      else {
        print("Cannot create export session.")
        onComplete(nil)
        return
    }
    
    let videoName = UUID().uuidString
    let exportURL = URL(fileURLWithPath: NSTemporaryDirectory())
      .appendingPathComponent(videoName)
      .appendingPathExtension("mov")
    
    export.videoComposition = videoComposition
    export.outputFileType = .mov
    export.outputURL = exportURL
    
    export.exportAsynchronously {
      DispatchQueue.main.async {
        switch export.status {
        case .completed:
          onComplete(exportURL)
        default:
          print("Something went wrong during export.")
          print(export.error ?? "unknown error")
          onComplete(nil)
          break
        }
      }
    }
  }
  
  private func addImage(to layer: CALayer, videoSize: CGSize) {
    let image = UIImage(named: "overlay")!
    let imageLayer = CALayer()
    
    let aspect: CGFloat = image.size.width / image.size.height
    let width = videoSize.width
    let height = width / aspect
    imageLayer.frame = CGRect(
      x: 0,
      y: -height * 0.15,
      width: width,
      height: height)
    
    imageLayer.contents = image.cgImage
    layer.addSublayer(imageLayer)
  }
  
  private func add(text: String, to layer: CALayer, startTime: Double, oldLayer: CATextLayer?,
                   first: Bool, videoSize: CGSize, position: [CGFloat], outTime: Int) {
    let attributedText = NSAttributedString(
      string: text,
      attributes: [
        .font: UIFont(name: "ArialRoundedMTBold", size: 60) as Any,
        .foregroundColor: UIColor(named: "overlay-text-color")!,
        .strokeColor: UIColor.white,
        .strokeWidth: -3])
    
  
    let textLayer = CATextLayer()
    textLayer.opacity = 0.0
    
    textLayer.frame = CGRect(
         x: videoSize.width * position[0], // 320 - 20
         y: videoSize.height * position[1],
         width: videoSize.width,
         height: 150)
    textLayer.string = attributedText
    
    let startAnim = CABasicAnimation.init(keyPath: "opacity")
    startAnim.duration = 0
    startAnim.fromValue = 0.0
    startAnim.toValue = 1.0
    
    startAnim.repeatCount = 1
    startAnim.beginTime = AVCoreAnimationBeginTimeAtZero + startTime
    startAnim.isRemovedOnCompletion = false
    startAnim.fillMode = CAMediaTimingFillMode.forwards
    textLayer.add(startAnim, forKey: "StartAnimation")
    
    let endAnim = CABasicAnimation.init(keyPath: "opacity")
    endAnim.duration = 0
    endAnim.repeatCount = 1
    endAnim.fromValue = 1.0
    endAnim.toValue = 0
    endAnim.beginTime = AVCoreAnimationBeginTimeAtZero + Double(outTime)
    endAnim.isRemovedOnCompletion = false
    endAnim.fillMode = CAMediaTimingFillMode.forwards
    textLayer.add(endAnim, forKey: "EndAnimation")
   
    layer.addSublayer(textLayer)
    
  }
  
  private func addText(text: String, to layer: CALayer, videoSize: CGSize) {
    let attributedText = NSAttributedString(
      string: text,
      attributes: [
        .font: UIFont(name: "ArialRoundedMTBold", size: 30) as Any,
        .foregroundColor: UIColor(named: "overlay-text-color")!,
        .strokeColor: UIColor.white,
        .strokeWidth: -3])
    
    let textLayer = CATextLayer()
    textLayer.opacity = 0.7
    textLayer.frame = CGRect(
         x: videoSize.width * 0.05,
         y: videoSize.height * 0.01,
         width: videoSize.width,
         height: 40)
    textLayer.string = attributedText
    print(textLayer.frame)
    layer.addSublayer(textLayer)
  }
  
  private func orientation(from transform: CGAffineTransform) -> (orientation: UIImage.Orientation, isPortrait: Bool) {
    var assetOrientation = UIImage.Orientation.up
    var isPortrait = false
    if transform.a == 0 && transform.b == 1.0 && transform.c == -1.0 && transform.d == 0 {
      assetOrientation = .right
      isPortrait = true
    } else if transform.a == 0 && transform.b == -1.0 && transform.c == 1.0 && transform.d == 0 {
      assetOrientation = .left
      isPortrait = true
    } else if transform.a == 1.0 && transform.b == 0 && transform.c == 0 && transform.d == 1.0 {
      assetOrientation = .up
    } else if transform.a == -1.0 && transform.b == 0 && transform.c == 0 && transform.d == -1.0 {
      assetOrientation = .down
    }
    
    return (assetOrientation, isPortrait)
  }
  
  private func compositionLayerInstruction(for track: AVCompositionTrack, assetTrack: AVAssetTrack) -> AVMutableVideoCompositionLayerInstruction {
    let instruction = AVMutableVideoCompositionLayerInstruction(assetTrack: track)
    let transform = assetTrack.preferredTransform
    
    instruction.setTransform(transform, at: .zero)
    
    return instruction
  }
}
