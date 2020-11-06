//
//  KKAudioPlayerManager.swift
//  AudioAssistant
//
//  Created by liaozhenming on 2020/11/2.
//

import UIKit
import AVFoundation

class KKAudioPlayerManager: NSObject, AVAudioPlayerDelegate {
    static let sharedInstance = KKAudioPlayerManager()
    var audioPlayer: AVAudioPlayer?
    
    //  音频引擎
    var audioAVEngine = AVAudioEngine()
    //  播放节点
    var enginePlayer = AVAudioPlayerNode()
    //  变声单元：调节音高
    let pitchEffect = AVAudioUnitTimePitch()
    //  混响单元
    let reverbEffect = AVAudioUnitReverb()
    //  调节音频播放速度单元
    let rateEffect = AVAudioUnitVarispeed()
    //  调节音量单元
    let volumeEffect = AVAudioUnitEQ()
    //  音频输入文件
    var engineAudioFile: AVAudioFile!
    
    //  MARK: Private methods
    //  配置录音
    private func configSettings(){
        
        let format = audioAVEngine.inputNode.inputFormat(forBus: 0)
        
        audioAVEngine.attach(enginePlayer)
        audioAVEngine.attach(pitchEffect)
        audioAVEngine.attach(reverbEffect)
        audioAVEngine.attach(rateEffect)
        audioAVEngine.attach(volumeEffect)
        //  连接功能
        audioAVEngine.connect(enginePlayer, to: pitchEffect, format: format)
        audioAVEngine.connect(pitchEffect, to: reverbEffect, format: format)
        audioAVEngine.connect(reverbEffect, to: rateEffect, format: format)
        audioAVEngine.connect(rateEffect, to: volumeEffect, format: format)
        audioAVEngine.connect(volumeEffect, to: audioAVEngine.mainMixerNode, format: format)
        
        //  选择混响效果为大房间
        reverbEffect.loadFactoryPreset(.largeChamber)
        
        do {
            try audioAVEngine.start()
        } catch {
            print("Error starting AVAudioEngine.")
        }
    }
    
    //  MARK: Public methods
    public func playWithURL(url: URL){
        
        if (self.audioPlayer != nil && self.audioPlayer!.isPlaying) {
            return
        }
        
        var playFlag = true
        
//        do {
//            engineAudioFile = try AVAudioFile.init(forReading: url)
//            pitchEffect.pitch = 2400
////            reverbEffect.wetDryMix = Use
////            rateEffect.rate =
////            volumeEffect.globalGain =
//        } catch {
//            playFlag = false
//            print("Error loading AVAudioFile.")
//        }
        
        do {
            self.audioPlayer = try AVAudioPlayer.init(contentsOf: url)
            self.audioPlayer?.volume = 0.5
            self.audioPlayer?.numberOfLoops = 1
            self.audioPlayer?.currentTime = 0
            self.audioPlayer?.delegate = self
            let prepareToPlay = self.audioPlayer?.prepareToPlay()
            if !prepareToPlay! {
                playFlag = false
                print("..播放音频数据出错了")
            }
        } catch let error as NSError {
            playFlag = false
            print("AVAudioPlayer error: \(error.localizedDescription)")
        }
        
        if playFlag {
//            enginePlayer.scheduleFile(engineAudioFile, at: nil, completionHandler: nil)
//            enginePlayer.play()
            
            audioPlayer?.play()
        }
    }
    
    //  MARK: AVAudioPlayerDelegate methods
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        
    }
    
    func audioPlayerDecodeErrorDidOccur(_ player: AVAudioPlayer, error: Error?) {
        
    }
}
