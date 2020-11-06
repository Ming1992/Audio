//
//  SoundRecordingViewController.swift
//  AudioAssistant
//
//  Created by liaozhenming on 2020/10/16.
//
//  录音-视图
import UIKit

class SoundRecordingViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var btn_record: UIButton!
    
    private var recordFileDirectory = ""
    private var subRecordFileNames: [String] = []
    
    
    private var recordPannelView: UIView!
    private var lab_recordTime: UILabel = UILabel.init()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        //https://zhuanlan.zhihu.com/p/85040596
        self.navigationItem.title = "录音"
        self.btn_record.layer.cornerRadius = self.btn_record.bounds.height/2.0
        self.tableView.tableFooterView = UIView.init()
        
        self.recordPannelView = UIView.init(frame: CGRect.init(x: 0, y: 0, width: 160, height: 160))
        self.recordPannelView.center = CGPoint.init(x: self.view.bounds.width / 2.0, y: self.view.bounds.height/2.0)
        self.recordPannelView.backgroundColor = UIColor.init(white: 0.0, alpha: 0.6)
        self.recordPannelView.layer.cornerRadius = 5.0
        self.view.addSubview(self.recordPannelView)
        do{
            let lab_title = UILabel.init(frame: CGRect.init(x: 0, y: 15, width: self.recordPannelView.bounds.width, height: 20))
            lab_title.text = "正在录音中"
            lab_title.font = UIFont.systemFont(ofSize: 16)
            lab_title.textColor = .white
            lab_title.textAlignment = .center
            self.recordPannelView.addSubview(lab_title)
            
            self.lab_recordTime.frame = CGRect.init(x: 0, y: self.recordPannelView.bounds.height/2.0 - 15, width: self.recordPannelView.bounds.width, height: 30)
            self.lab_recordTime.textAlignment = .center
            self.lab_recordTime.font = UIFont.systemFont(ofSize: 24)
            self.lab_recordTime.text = "00:00"
            self.lab_recordTime.textColor = .white
            self.recordPannelView.addSubview(self.lab_recordTime)
            self.recordPannelView.isHidden = true
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        self.loadRecordFileFromLocation()
    }
    
    //  MARK: Action methods
    //  开始录音
    @IBAction func action_startRecording(){
        print("开始录音")
        self.recordPannelView.isHidden = false
        KKRecorderManager.sharedInstance.record { (timeInterval) in
            print("..timeInterval",timeInterval)

            let minute = Int(timeInterval / 60)
            let secord = Int(timeInterval.truncatingRemainder(dividingBy: 60.0))

            self.lab_recordTime.text = (minute > 9 ? "\(minute)" : "0\(minute)") + ":" + (secord > 9 ? "\(secord)" : "0\(secord)")

        } finishedHandle: { (totalTime, cacheFilePath) in
            print("总时长：",totalTime)
            print("文件路径：",cacheFilePath)
            
            if totalTime < 2 {
                let tmpAlertViewController = UIAlertController.init(title: "", message: "录音时间太短", preferredStyle: .alert)
                tmpAlertViewController.addAction(UIAlertAction.init(title: "关闭", style: .default, handler: nil))
                self.present(tmpAlertViewController, animated: true, completion: nil)
                
                try? FileManager.default.removeItem(atPath: cacheFilePath)
            }
            else {
                
                let cacheFileURL = URL.init(string: cacheFilePath)
                
                let tmpFileName = cacheFileURL?.lastPathComponent
                self.subRecordFileNames.append(tmpFileName!)
                self.tableView.reloadData()
                
                let tmpAlertViewController = UIAlertController.init(title: "", message: "录音完成", preferredStyle: .alert)
                tmpAlertViewController.addAction(UIAlertAction.init(title: "关闭", style: .default, handler: nil))
                self.present(tmpAlertViewController, animated: true, completion: nil)
            }
        }
    }
    
    //  结束录音
    @IBAction func action_stopRecording(){
        print("结束录音")
        self.recordPannelView.isHidden = true
        self.lab_recordTime.text = "00:00"
        KKRecorderManager.sharedInstance.stopRecording()
    }

    //  MARK: Private methods
    private func loadRecordFileFromLocation(){
        
        let directorys = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
        let documentDirectory = directorys.first
        self.recordFileDirectory = documentDirectory! + "/record"
        if !FileManager.default.fileExists(atPath: self.recordFileDirectory) {
            try? FileManager.default.createDirectory(at: URL.init(fileURLWithPath: self.recordFileDirectory), withIntermediateDirectories: true, attributes: nil)
        }
        
        let items = FileManager.default.subpaths(atPath: self.recordFileDirectory)
        if items != nil {
            self.subRecordFileNames = items!
        }
        self.tableView.reloadData()
    }
    
    //  MARK: UITableView methods
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.subRecordFileNames.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "RecordTableViewCell", for: indexPath)
        cell.textLabel?.text = self.subRecordFileNames[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let tmpItem = self.subRecordFileNames[indexPath.row]
        let tmpItemPath = self.recordFileDirectory + "/" + tmpItem
        print(tmpItemPath)
        
        let url = URL.init(fileURLWithPath: tmpItemPath)
        KKAudioPlayerManager.sharedInstance.playWithURL(url: url)
    }
}
