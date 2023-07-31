//
//  ViewController.swift
//  SherpaNcnn
//
//  Created by fangjun on 2023/1/28.
//

import AVFoundation
import UIKit
import SnapKit

extension AudioBuffer {
    func array() -> [Float] {
        return Array(UnsafeBufferPointer(self))
    }
}

extension AVAudioPCMBuffer {
    func array() -> [Float] {
        return self.audioBufferList.pointee.mBuffers.array()
    }
}


@objcMembers public class ASRViewController: FaceDetectionViewController {
    
    let resultLabel: UILabel = {
        let lbl = UILabel()
        lbl.numberOfLines = 0
        return lbl
    }()
    let recordBtn : UIButton = {
        let btn = UIButton(type: .custom)
        btn.setTitle("start", for: .normal)
        btn.setTitleColor(UIColor.blue, for: .normal)
        return btn
    }()

    var audioEngine: AVAudioEngine? = nil
    var recognizer: SherpaNcnnRecognizer! = nil

    /// It saves the decoded results so far
    var sentences: [String] = [] {
        didSet {
            updateLabel()
        }
    }
    var lastSentence: String = ""
    let maxSentence: Int = 20
    var results: String {
        if sentences.isEmpty && lastSentence.isEmpty {
            return ""
        }
        if sentences.isEmpty {
            return "0: \(lastSentence.lowercased())"
        }

        let start = max(sentences.count - maxSentence, 0)
        if lastSentence.isEmpty {
            return sentences.enumerated().map { (index, s) in "\(index): \(s.lowercased())" }[start...]
                .joined(separator: "\n")
        } else {
            return sentences.enumerated().map { (index, s) in "\(index): \(s.lowercased())" }[start...]
                .joined(separator: "\n") + "\n\(sentences.count): \(lastSentence.lowercased())"
        }
    }

    func updateLabel() {
        DispatchQueue.main.async {
            self.resultLabel.text = self.results
        }
    }

    public override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        setupViews()
//        resultLabel.text = "ASR with Next-gen Kaldi\n\nSee https://github.com/k2-fsa/sherpa-ncnn\n\nPress the Start button to run!"

        recordBtn.setTitle("Start", for: .normal)
        initRecognizer()
        initRecorder()
    }
    public override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    public override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        stopRecorder()
        removeL2dView()
    }
    
    private func addL2dView(){
        self.view.addSubview(self.live2dView!)
//        self.view.bringSubviewToFront(self.live2dView!)
        self.view.insertSubview(self.live2dView!, belowSubview: resultLabel);
        self.live2dView!.snp.makeConstraints { make in
            make.edges.equalTo(self.view)
        }
        self.live2dView?.zoom = 2
        self.live2dView?.owner = true
        self.live2dView?.loadModel(withName: "xiaomi4")
        self.live2dView?.startAnimation()
        self.captureStartRunning()
    }
    
    private func removeL2dView(){
        self.captureStopRunning()
        self.live2dView!.destroy()
        self.live2dView?.removeFromSuperview()
        self.live2dView = nil
    }
    
    private func setupViews(){
        self.view.backgroundColor = UIColor.white
        self.view.addSubview(resultLabel)
        self.view.addSubview(recordBtn)
        recordBtn.addTarget(self, action: #selector(onRecordBtnClick), for: .touchUpInside)
        resultLabel.snp.makeConstraints { make in
            make.left.right.equalTo(self.view)
            make.top.equalTo(8)
        }
        recordBtn.snp.makeConstraints { make in
            make.centerX.equalTo(self.view)
            make.bottom.equalTo(-10)
        }
    }
    
    @objc private func onRecordBtnClick(_ sender: UIButton) {
        addL2dView()
        if recordBtn.currentTitle == "Start" {
            startRecorder()
            recordBtn.setTitle("Stop", for: .normal)
        } else {
            stopRecorder()
            recordBtn.setTitle("Start", for: .normal)
        }
    }

    func initRecognizer() {
        // Please select one model that is best suitable for you.
        //
        // You can also modify Model.swift to add new pre-trained models from
        // https://k2-fsa.github.io/sherpa/ncnn/pretrained_models/index.html
        let featConfig = sherpaNcnnFeatureExtractorConfig(
            sampleRate: 16000,
            featureDim: 80)

        let modelConfig = getMultilingualModelConfig2022_12_06()
        // let modelConfig = getMultilingualModelConfig2022_12_06_Int8()
        // let modelConfig = getConvEmformerSmallEnglishModelConfig2023_01_09()
        // let modelConfig = getConvEmformerSmallEnglishModelConfig2023_01_09_Int8()
        // let modelConfig = getLstmTransducerEnglish_2022_09_05()

        let decoderConfig = sherpaNcnnDecoderConfig(
            decodingMethod: "modified_beam_search",
            numActivePaths: 4)

        var config = sherpaNcnnRecognizerConfig(
            featConfig: featConfig,
            modelConfig: modelConfig,
            decoderConfig: decoderConfig,
            enableEndpoint: true,
            rule1MinTrailingSilence: 1.2,
            rule2MinTrailingSilence: 2.4,
            rule3MinUtteranceLength: 200)

        recognizer = SherpaNcnnRecognizer(config: &config)
    }

    func initRecorder() {
        print("init recorder")
        audioEngine = AVAudioEngine()
        let inputNode = self.audioEngine?.inputNode
        let bus = 0
        let inputFormat = inputNode?.outputFormat(forBus: bus)
        let outputFormat = AVAudioFormat(
            commonFormat: .pcmFormatFloat32,
            sampleRate: 16000, channels: 1,
            interleaved: false)!

        let converter = AVAudioConverter(from: inputFormat!, to: outputFormat)!

        inputNode!.installTap(
            onBus: bus,
            bufferSize: 1024,
            format: inputFormat
        ) {
            (buffer: AVAudioPCMBuffer, when: AVAudioTime) in
            var newBufferAvailable = true

            let inputCallback: AVAudioConverterInputBlock = {
                inNumPackets, outStatus in
                if newBufferAvailable {
                    outStatus.pointee = .haveData
                    newBufferAvailable = false

                    return buffer
                } else {
                    outStatus.pointee = .noDataNow
                    return nil
                }
            }

            let convertedBuffer = AVAudioPCMBuffer(
                pcmFormat: outputFormat,
                frameCapacity:
                    AVAudioFrameCount(outputFormat.sampleRate)
                * buffer.frameLength
                / AVAudioFrameCount(buffer.format.sampleRate))!

            var error: NSError?
            let _ = converter.convert(
                to: convertedBuffer,
                error: &error, withInputFrom: inputCallback)

            // TODO(fangjun): Handle status != haveData

            let array = convertedBuffer.array()
            if !array.isEmpty {
                self.recognizer.acceptWaveform(samples: array)
                while (self.recognizer.isReady()){
                    self.recognizer.decode()
                }
                let isEndpoint = self.recognizer.isEndpoint()
                let text = self.recognizer.getResult().text
                if text.count != 0{
                    for word in text {
                        let singleWord:String = LJZTool.getLipType(with:"\(word)")!
                        print("word===\(word)\(singleWord)")
                        self.updateLive2d(word: singleWord)
                    }
                }
                if !text.isEmpty && self.lastSentence != text {
                    self.lastSentence = text
                    self.updateLabel()
                    print(text)
                }

                if isEndpoint{
                    if !text.isEmpty {
                        let tmp = self.lastSentence
                        self.lastSentence = ""
                        self.sentences.append(tmp)
                    }
                    self.recognizer.reset()
                }
            }
        }

    }
    func updateLive2d(
        word:String){
        self.live2dView?.visemesValue =  word
    }
    func startRecorder() {
        lastSentence = ""
        sentences = []

        do {
            try self.audioEngine?.start()
        } catch let error as NSError {
            print("Got an error starting audioEngine: \(error.domain), \(error)")
        }
        print("started")
    }

    func stopRecorder() {
        audioEngine?.stop()
        print("stopped")
    }
}
