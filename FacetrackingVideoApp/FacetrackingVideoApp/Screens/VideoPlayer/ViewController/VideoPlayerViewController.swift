//
//  VideoPlayerViewController.swift
//  FacetrackingVideoApp
//
//  Created by Abdul Karim on 04/09/21.
//


import UIKit
import PlayerKit
import AVKit
import MaterialComponents.MaterialSlider
import AVFoundation
import Vision

class VideoPlayerViewController: BaseViewController {

    // video player outlets
    @IBOutlet var vBaseView: UIView!
    @IBOutlet weak var vVideoPlayer: UIView!
    @IBOutlet weak var bPlay: UIButton!
    @IBOutlet weak var bBack15: UIButton!
    @IBOutlet weak var bForward15: UIButton!
    @IBOutlet weak var vControlView: UIView!
    @IBOutlet weak var lProgressLabel: UILabel!
    @IBOutlet weak var sBufferSlider: MDCSlider!
    @IBOutlet weak var sProgressSlider: MDCSlider!
    @IBOutlet weak var bFullScreenButton : UIButton!
    @IBOutlet weak var lc_seekingbarView: NSLayoutConstraint!
    
    var videoURL:String = ""
    var player: RegularPlayer?
    private var isScrubbing: Bool = false
    
    // facetracking properties
    private let captureSession = AVCaptureSession()
    private lazy var previewLayer = AVCaptureVideoPreviewLayer(session: self.captureSession)
    private let videoDataOutput = AVCaptureVideoDataOutput()
    private var drawings: [CAShapeLayer] = []
    @IBOutlet weak var lFacedetectionLabel: UILabel!
    var isfaceDected:Bool = false
    

    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureVideoPlayer()
        
        self.addCameraInput()
        self.showCameraFeed()
        self.getCameraFrames()
        self.captureSession.startRunning()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.previewLayer.frame = self.view.frame
    }
    
    @objc func close() {
        stopPlayer()
    }
    
    // MARK:- Player
    private func configureVideoPlayer() {
        player = RegularPlayer()
        player?.volume = 1.0
        player?.fillMode = .fit
        player?.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        player?.view.frame = self.vVideoPlayer.bounds
        vVideoPlayer.addSubview(self.player!.view)
        player?.delegate = self
        player?.set(AVURLAsset(url: URL(string: videoURL)!))
        player?.play()
        view.backgroundColor = .black
        vControlView.backgroundColor = .clear
        
        vVideoPlayer.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.handleTapOnVideoPlayer(_:))))
        setupSlidersSeekers()
    }
    
    @objc func handleTapOnVideoPlayer(_ gestureRecognizer: UITapGestureRecognizer) {
        showHideControls()
    }
    
    private func updateTrackDetails() {
        lProgressLabel.text = "00:00/00:00"
    }
    
    private func stopPlayer() {
        player?.pause()
        player = nil
    }
    
    private func showHideControls() {
        bPlay.isHidden = !bPlay.isHidden
        bForward15.isHidden = !bForward15.isHidden
        bBack15.isHidden = !bBack15.isHidden
        vControlView.isHidden = !vControlView.isHidden
    }
    
    @IBAction func bBack15(_ sender: Any) {
        if let videoPlayer = player  {
            if videoPlayer.time > 15 {
                videoPlayer.seek(to: videoPlayer.time - 15)
            }else {
                videoPlayer.seek(to: 0)
            }
            
        }
    }
    
    @IBAction func bPlay(_ sender: Any) {
        if let videoPlayer = player  {
            if videoPlayer.playing {
                bPlay.setImage(UIImage(named: "ic_pause"), for: .normal)
                videoPlayer.pause()
            }else {
                bPlay.setImage(UIImage(named: "ic_play"), for: .normal)
                videoPlayer.play()
            }
        }
    }
    
    @IBAction func bForward15(_ sender: Any) {
        if let videoPlayer = player  {
            videoPlayer.seek(to: videoPlayer.time + 15)
        }
    }
    

}

extension VideoPlayerViewController: PlayerDelegate {
    
    func playerDidUpdateState(player: Player, previousState: PlayerState) {
        if player.state == .ready {
            showHideControls()
            handleBuffering(sts: false)
            sProgressSlider.maximumValue = CGFloat(player.duration)
            sBufferSlider.maximumValue = CGFloat(player.duration)
        }
        else if player.state == .loading {
            if player.duration > 0 {}
            else {
               handleBuffering(sts: true)
            }
        }
        else if player.state == .failed {
           close()
        }
    }
    
    func playerDidUpdatePlaying(player: Player) {
        // for auto play
//        if player.playing {
//            bPlay.setImage(UIImage(named: "ic_pause"), for: .normal)
//            player.pause()
//        }
//        else {
//            bPlay.setImage(UIImage(named: "ic_play"), for: .normal)
//            player.play()
//        }
    }
    
    func playerDidUpdateTime(player: Player) {
        if !isScrubbing {
            let trackCurrentTimeString = player.time.secondsToString()
            sProgressSlider.value = CGFloat(player.time)
            lProgressLabel.text = "\(trackCurrentTimeString)/\(player.duration.secondsToString())"
        }
    }
     
    func playerDidUpdateBufferedTime(player: Player) {
        sBufferSlider.value = CGFloat(player.bufferedTime)
    }
    
    func playerEnded(player: Player) {
        
    }
    
    func handleBuffering(sts:Bool) {
        if sts {
            lProgressLabel.text = "Buffering.."
        }
    }
    
}

extension VideoPlayerViewController {
    //MARK:- slider
        
        fileprivate func setupSlidersSeekers() {
            //buffer progress background - background layer
            sBufferSlider.isThumbHollowAtStart = false
            sBufferSlider.isStatefulAPIEnabled = true
            sBufferSlider.isUserInteractionEnabled = false
            sBufferSlider.setTrackBackgroundColor(UIColor(named: "TrackProgressBackground"), for: .normal)
            sBufferSlider.setTrackFillColor(UIColor(named: "TrackBufferingFill"), for: .normal)
            sBufferSlider.setThumbColor(.clear, for: .normal)
            
            
            //track progress background -  front layer
            sProgressSlider.isThumbHollowAtStart = false
            sProgressSlider.isStatefulAPIEnabled = true
            sProgressSlider.setThumbColor(.white, for: .normal)
            sProgressSlider.setTrackFillColor(.white, for: .normal)
            sProgressSlider.setTrackBackgroundColor(.clear, for: .normal)
            
            sProgressSlider.addTarget(self,
                                       action: #selector(startScrubbing(senderSlider:)),
                                       for: .touchDown)
            
            sProgressSlider.addTarget(self,
                                       action: #selector(scrubbing(senderSlider:)),
                                       for: .touchUpInside)
            
            sProgressSlider.addTarget(self,
                                       action: #selector(scrubbing(senderSlider:)),
                                       for: .touchUpOutside)
            
            sProgressSlider.addTarget(self,
                             action: #selector(didChangeSliderValue(senderSlider:)),
                             for: .valueChanged)
            
            if player?.playing ?? false {
                bPlay.setImage(UIImage(named: "ic_pause"), for: .normal)
                player?.pause()
            }
            else {
                bPlay.setImage(UIImage(named: "ic_play"), for: .normal)
                player?.play()
            }
        }
        
        @objc func scrubbing(senderSlider: MDCSlider) {
            let sliderSeekValue = Double(senderSlider.value)
            player?.seek(to: sliderSeekValue)
            player?.pause()
            //delay so that small chuck of data is buffered for playing
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                self.player?.play()
            }
            isScrubbing = false
        }
        
        @objc func startScrubbing(senderSlider: MDCSlider) {
            isScrubbing = true
        }
        
        @objc func didChangeSliderValue(senderSlider:MDCSlider) {
            let sliderValue = Double(senderSlider.value)
            lProgressLabel.text = "\(sliderValue.secondsToString())/\(player?.duration.secondsToString() ?? "")"
        }
    
   // fullScreenAction
    @IBAction func bActionFullScreenButton(_ sender: Any) {
        // for future references
    }
    
    private func exitFullScreen() {
        lc_seekingbarView.constant = 20
        bFullScreenButton.setImage(UIImage(named: "fullscreen"), for: .normal)
    }
    
    private func enterFullScreen() {
        lc_seekingbarView.constant = 70
        bFullScreenButton.setImage(UIImage(named: "fullscreenExit"), for: .normal)
    }
}


extension VideoPlayerViewController: ViewFromNib, NavigationControllerChild {
    func backButtonAction() {
        stopPlayer()
    }

    func prefersNavigationBarHidden() -> Bool {
        return true
    }
}


// facedetection
extension VideoPlayerViewController: AVCaptureVideoDataOutputSampleBufferDelegate {
    
    func captureOutput(
        _ output: AVCaptureOutput,
        didOutput sampleBuffer: CMSampleBuffer,
        from connection: AVCaptureConnection) {
        
        guard let frame = CMSampleBufferGetImageBuffer(sampleBuffer) else {
            debugPrint("unable to get image from sample buffer")
            return
        }
        self.detectFace(in: frame)
    }
    
    private func addCameraInput() {
        guard let device = AVCaptureDevice.DiscoverySession(
            deviceTypes: [.builtInWideAngleCamera, .builtInDualCamera, .builtInTrueDepthCamera],
            mediaType: .video,
            position: .front).devices.first else {
                fatalError("No back camera device found, please make sure to run the app in an iOS device and not a simulator")
        }
        let cameraInput = try! AVCaptureDeviceInput(device: device)
        self.captureSession.addInput(cameraInput)
    }
    
    private func showCameraFeed() {
        self.previewLayer.videoGravity = .resizeAspectFill
        // for testing live feed
        //self.view.layer.addSublayer(self.previewLayer)
        self.previewLayer.frame = self.view.frame
    }
    
    private func getCameraFrames() {
        self.videoDataOutput.videoSettings = [(kCVPixelBufferPixelFormatTypeKey as NSString) : NSNumber(value: kCVPixelFormatType_32BGRA)] as [String : Any]
        self.videoDataOutput.alwaysDiscardsLateVideoFrames = true
        self.videoDataOutput.setSampleBufferDelegate(self, queue: DispatchQueue(label: "camera_frame_processing_queue"))
        self.captureSession.addOutput(self.videoDataOutput)
        guard let connection = self.videoDataOutput.connection(with: AVMediaType.video),
            connection.isVideoOrientationSupported else { return }
        connection.videoOrientation = .portrait
    }
    
    private func detectFace(in image: CVPixelBuffer) {
        let faceDetectionRequest = VNDetectFaceLandmarksRequest(completionHandler: { (request: VNRequest, error: Error?) in
            DispatchQueue.main.async {
                if let results = request.results as? [VNFaceObservation] {
                    self.handleFaceDetectionResults(results)
                } else {
                    self.clearDrawings()
                }
            }
        })
        let imageRequestHandler = VNImageRequestHandler(cvPixelBuffer: image, orientation: .leftMirrored, options: [:])
        try? imageRequestHandler.perform([faceDetectionRequest])
    }
    
    private func handleFaceDetectionResults(_ observedFaces: [VNFaceObservation]) {
        
        self.clearDrawings()
        let facesBoundingBoxes: [CAShapeLayer] = observedFaces.flatMap({ (observedFace: VNFaceObservation) -> [CAShapeLayer] in
            let faceBoundingBoxOnScreen = self.previewLayer.layerRectConverted(fromMetadataOutputRect: observedFace.boundingBox)
            let faceBoundingBoxPath = CGPath(rect: faceBoundingBoxOnScreen, transform: nil)
            let faceBoundingBoxShape = CAShapeLayer()
            faceBoundingBoxShape.path = faceBoundingBoxPath
            faceBoundingBoxShape.fillColor = UIColor.clear.cgColor
            faceBoundingBoxShape.strokeColor = UIColor.green.cgColor
            var newDrawings = [CAShapeLayer]()
            newDrawings.append(faceBoundingBoxShape)
            if let landmarks = observedFace.landmarks {
                newDrawings = newDrawings + self.drawFaceFeatures(landmarks, screenBoundingBox: faceBoundingBoxOnScreen)
            }
            return newDrawings
        })
        facesBoundingBoxes.forEach({ faceBoundingBox in self.view.layer.addSublayer(faceBoundingBox) })
        self.drawings = facesBoundingBoxes
        isfaceDected = facesBoundingBoxes.count != 0  ? true : false
        if isfaceDected {
            lFacedetectionLabel.text = "Face Dected Playing"
            if let videoplayer = player {
                if videoplayer.playing {
                }else {
                    videoplayer.play()
                }
            }
        }else{
            lFacedetectionLabel.text = "No Face Dected Paused"
            if let videoplayer = player {
                if videoplayer.playing {
                    videoplayer.pause()
                }
            }
        }
    }
    
    private func clearDrawings() {
        self.drawings.forEach({ drawing in drawing.removeFromSuperlayer() })
    }
    
    private func drawFaceFeatures(_ landmarks: VNFaceLandmarks2D, screenBoundingBox: CGRect) -> [CAShapeLayer] {
        var faceFeaturesDrawings: [CAShapeLayer] = []
        if let leftEye = landmarks.leftEye {
            let eyeDrawing = self.drawEye(leftEye, screenBoundingBox: screenBoundingBox)
            faceFeaturesDrawings.append(eyeDrawing)
        }
        if let rightEye = landmarks.rightEye {
            let eyeDrawing = self.drawEye(rightEye, screenBoundingBox: screenBoundingBox)
            faceFeaturesDrawings.append(eyeDrawing)
        }
        // draw other face features here
        return faceFeaturesDrawings
    }
    private func drawEye(_ eye: VNFaceLandmarkRegion2D, screenBoundingBox: CGRect) -> CAShapeLayer {
        let eyePath = CGMutablePath()
        let eyePathPoints = eye.normalizedPoints
            .map({ eyePoint in
                CGPoint(
                    x: eyePoint.y * screenBoundingBox.height + screenBoundingBox.origin.x,
                    y: eyePoint.x * screenBoundingBox.width + screenBoundingBox.origin.y)
            })
        eyePath.addLines(between: eyePathPoints)
        eyePath.closeSubpath()
        let eyeDrawing = CAShapeLayer()
        eyeDrawing.path = eyePath
        eyeDrawing.fillColor = UIColor.clear.cgColor
        eyeDrawing.strokeColor = UIColor.green.cgColor
        
        return eyeDrawing
    }
}
