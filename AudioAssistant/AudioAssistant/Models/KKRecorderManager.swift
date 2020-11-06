//
//  KKRecorderManager.swift
//  AudioAssistant
//
//  Created by liaozhenming on 2020/10/16.
//
//  录音
import UIKit
import AVFoundation

typealias KKRecorderManagerRecordResultBlockHandle = (TimeInterval,String)->()
typealias KKRecorderManagerRecordProgressBlockHandle = (TimeInterval)->()

class KKRecorderManager: NSObject, AVAudioRecorderDelegate {
    static let sharedInstance = KKRecorderManager()
    
    var audioRecorder: AVAudioRecorder!
    let recordSettings = [
        AVFormatIDKey: Int(kAudioFormatLinearPCM),
        AVSampleRateKey: 44100.0,
        AVNumberOfChannelsKey: 1,
        AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
    ] as [String : Any]
    
    private var appHasMicAccess = false
    private var timeInterval: TimeInterval = 0.0
    private var timer: Timer?
    private var recordFileDirectory: String = ""
    private var recordFilePath: String = ""
    public var recordFinishedBlock:KKRecorderManagerRecordResultBlockHandle?
    public var recordProgressBlock:KKRecorderManagerRecordProgressBlockHandle?
    
    
    override init() {
        super.init()
        self.configSettings()
    }
    
    //  MARK: Private methods
    //  配置录音
    private func configSettings(){
        
        //  创建录音的文件夹
        let directorys = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
        let documentDirectory = directorys.first
        self.recordFileDirectory = documentDirectory! + "/record"
        if !FileManager.default.fileExists(atPath: self.recordFileDirectory) {
            try? FileManager.default.createDirectory(at: URL.init(fileURLWithPath: self.recordFileDirectory), withIntermediateDirectories: true, attributes: nil)
        }
        else {
            let items = FileManager.default.subpaths(atPath: self.recordFileDirectory)
            print("子文件：",items)
            
            
        }
        
        //  配置录音需要的格式信息
        let session = AVAudioSession.sharedInstance()
        let authStatus = session.recordPermission
        if authStatus == .undetermined {
            do {
                try session.setCategory(.playAndRecord, options: .defaultToSpeaker)
                try session.setActive(true, options: .notifyOthersOnDeactivation)
                //  检查app有没有权限，使用该设备的麦克风
                session.requestRecordPermission { (isGranted) in
                    self.appHasMicAccess = isGranted
                }
                
            } catch let error as NSError {
                print("AVAudioSession Configuration error: \(error.localizedDescription)")
            }
        }
        else if authStatus == .denied {
            appHasMicAccess = false
        }
        else {
            appHasMicAccess = true
        }
    }
    
    private func startTimer(){
        self.timer?.invalidate()
        self.timer = nil
        self.timeInterval = 0.0
        self.timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true, block: { (tmpTimer) in
            self.timeInterval += 1.0
            if self.recordProgressBlock != nil {
                self.recordProgressBlock!(self.timeInterval)
            }
        })
    }
    
    //  MARK: Public methods
    public func record(progress:KKRecorderManagerRecordProgressBlockHandle? = nil, finishedHandle finished:@escaping KKRecorderManagerRecordResultBlockHandle){
        //  开始录音
        
        if !self.appHasMicAccess {
            return
        }
        
        let currentDateTime = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyyMMddHHmmss"
        
        let fileName = formatter.string(from: currentDateTime) + ".caf"
        self.recordFilePath = self.recordFileDirectory + "/\(fileName)"
        let fileURL = URL.init(fileURLWithPath: self.recordFilePath)
        
        do {
            self.audioRecorder = try AVAudioRecorder.init(url: fileURL, settings: self.recordSettings)
            audioRecorder.delegate = self
            audioRecorder.prepareToRecord()
        } catch {
            print("Error create audio Recorder.")
        }
        
        self.recordProgressBlock = progress
        self.recordFinishedBlock = finished
        self.audioRecorder.record()
        self.startTimer()
    }
    
    public func stopRecording(){
        //  结束录音
        self.timer?.invalidate()
        self.timer = nil
        self.audioRecorder.stop()
    }
    
    //  MARK: AVAudioRecorderDelegate methods
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        self.recordFinishedBlock!(self.timeInterval,self.recordFilePath)
    }
    
    func audioRecorderEncodeErrorDidOccur(_ recorder: AVAudioRecorder, error: Error?) {
        
    }
}
