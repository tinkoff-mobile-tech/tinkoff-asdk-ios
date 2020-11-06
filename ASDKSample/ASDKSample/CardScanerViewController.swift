//
//  CardScanerViewController.swift
//  ASDKSample
//
//  Copyright (c) 2020 Tinkoff Bank
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//   http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//

import AVFoundation
import UIKit

class CardScanerViewController: UIViewController, AVCaptureMetadataOutputObjectsDelegate {

    @IBOutlet weak var scannerViewPort: UIView!
    @IBOutlet weak var buttonClose: UIButton!

    private var captureSession: AVCaptureSession!
    private var previewLayer: AVCaptureVideoPreviewLayer!

    var scannerMetadataObjectTypes: [AVMetadataObject.ObjectType] = [.qr]
    var onScannerResult: ((String?) -> Void)?

    @IBAction func onButtonCloseTouchUpInside(_ sender: UIButton) {
        let scannerClosure = onScannerResult
        dismiss(animated: true, completion: {
            scannerClosure?(nil)
        })
    }

    var showErrorBlock: (_ errorTitle: String, _ errorMessage: String) -> Void = { (errorTitle: String, errorMessage: String) -> Void in
        var alertController = UIAlertController(title: errorTitle, message: errorMessage, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "OK"), 
                                                style: UIAlertAction.Style.default, 
                                                handler: { (_) -> Void in }))

        if let topController = UIApplication.shared.keyWindow?.rootViewController {
            topController.present(alertController, animated: true, completion: nil)
        }
    }

    // MARK: UIVeiwController Lifecycable

    override func viewDidLoad() {
        super.viewDidLoad()

        buttonClose.setTitle(NSLocalizedString("button.close", comment: "Закрыть"), for: .normal)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        #if targetEnvironment(simulator)

        #else
            startCaptureSession()
        #endif
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        if captureSession?.isRunning == false {
            captureSession.startRunning()
        }
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        if let view = scannerViewPort, previewLayer != nil {
            previewLayer.frame = view.bounds
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        if captureSession?.isRunning == true {
            captureSession.stopRunning()
        }
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }

    // MARK: CaptureSession

    func startCaptureSession() {
        modalPresentationStyle = .overFullScreen
        captureSession = AVCaptureSession()

        guard let videoCaptureDevice = AVCaptureDevice.default(for: .video) else {
            return
        }

        let videoInput: AVCaptureDeviceInput

        do {
            videoInput = try AVCaptureDeviceInput(device: videoCaptureDevice)
        } catch let outError {
            showError(NSLocalizedString("Device setup error occured", comment: ""), message: "\(outError)")
            return
        }

        if captureSession.canAddInput(videoInput) {
            captureSession.addInput(videoInput)
        } else {
            showError(NSLocalizedString("Camera error", comment: ""), 
                      message: NSLocalizedString("No valid capture session found, I can't take any pictures or videos.", 
                                                 comment: ""))
            captureSession = nil
            return
        }

        let metadataOutput = AVCaptureMetadataOutput()

        if captureSession.canAddOutput(metadataOutput) {
            captureSession.addOutput(metadataOutput)

            metadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
            metadataOutput.metadataObjectTypes = scannerMetadataObjectTypes
        } else {
            showError(NSLocalizedString("Preset not supported", comment: ""), 
                      message: NSLocalizedString("Camera preset not supported. Please try another one.", 
                                                 comment: ""))
            return
        }

        previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer.frame = view.layer.bounds
        previewLayer.videoGravity = .resizeAspectFill
        scannerViewPort.layer.addSublayer(previewLayer)

        captureSession.startRunning()
    }

    private func showError(_ title: String, message: String) {
        DispatchQueue.main.async(execute: { () -> Void in
            self.showErrorBlock(title, message)
        })
    }

    // MARK: AVCaptureMetadataOutputObjectsDelegate

    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        captureSession.stopRunning()

        if let metadataObject = metadataObjects.first {
            guard let readableObject = metadataObject as? AVMetadataMachineReadableCodeObject, let stringValue = readableObject.stringValue else {
                return
            }

            AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))

            let scannerClosure = onScannerResult
            dismiss(animated: true, completion: {
                scannerClosure?(stringValue)
            })
        } // metadataObject
    } // metadataOutput
}
