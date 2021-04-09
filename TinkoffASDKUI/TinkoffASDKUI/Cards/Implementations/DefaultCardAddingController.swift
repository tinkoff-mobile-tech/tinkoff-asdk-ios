//
//
//  DefaultCardAddingController.swift
//
//  Copyright (c) 2021 Tinkoff Bank
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


import TinkoffASDKCore

final class DefaultCardAddingController: CardAddingController {
    
    // Dependencies
    
    private let acquiringSDK: AcquiringSdk
    private let threeDSHandler: ThreeDSWebViewHandler<AddCardStatusResponse>
    
    weak var uiProvider: CardAddingControllerUIProvider?
    weak var delegate: CardAddingControllerDelegate?
    
    // State
    
    private var process: AddCardProcess?
    private var confirmationViewController: UIViewController?
    
    // MARK: - Init
    
    init(acquiringSDK: AcquiringSdk,
         threeDSHandler: ThreeDSWebViewHandler<AddCardStatusResponse>) {
        self.acquiringSDK = acquiringSDK
        self.threeDSHandler = threeDSHandler
    }
    
    // MARK: - CardAddingController
    
    func addCard(cardData: CardData,
                 customerKey: String,
                 checkType: PaymentCardCheckType) {
        resetProcess { [weak self] in
            guard let self = self else { return }
            let process = DefaultAddCardProcess(acquiringSDK: self.acquiringSDK,
                                                customerKey: customerKey,
                                                cardData: cardData,
                                                checkType: checkType)
            process.delegate = self
            process.start()
            self.process = process
        }
    }
}

extension DefaultCardAddingController: AddCardProcessDelegate {
    func addCardProcessDidFinish(_ addCardProcess: AddCardProcess,
                                 state: GetAddCardStatePayload) {
        DispatchQueue.safePerformOnMainQueueAsyncIfNeeded {
            self.dismissConfirmationIfNeeded { [weak self] in
                guard let self = self else { return }
                if state.status == .cancelled {
                    self.delegate?.cardAddingController(self,
                                                        addCardWasCancelled: addCardProcess)
                } else {
                    self.delegate?.cardAddingController(self,
                                                        didFinish: addCardProcess,
                                                        state: state)
                }
            }
            self.confirmationViewController = nil
            self.process = nil
        }
    }
    
    func addCardProcessDidFailed(_ addCardProcess: AddCardProcess,
                                 error: Error) {
        DispatchQueue.safePerformOnMainQueueAsyncIfNeeded {
            self.dismissConfirmationIfNeeded { [weak self] in
                guard let self = self else { return }
                self.delegate?.cardAddingController(self, didFailed: error)
            }
            self.confirmationViewController = nil
            self.process = nil
        }
    }
    
    func addCardProcess(_ addCardProcess: AddCardProcess,
                        need3DSConfirmation data: Confirmation3DSData,
                        confirmationCancelled: @escaping () -> Void,
                        completion: @escaping (Result<Void, Error>) -> Void) {
        do {
            let request = try self.acquiringSDK.createConfirmation3DSRequest(data: data)
            startThreeDSConfirmation(for: addCardProcess,
                                     request: request,
                                     confirmationCancelled: confirmationCancelled,
                                     completion: completion)
        } catch {
            completion(.failure(error))
        }
    }
    
    func addCardProcess(_ addCardProcess: AddCardProcess,
                        need3DSConfirmationACS data: Confirmation3DSDataACS,
                        confirmationCancelled: @escaping () -> Void, completion: @escaping (Result<Void, Error>) -> Void) {
        do {
            let request = try self.acquiringSDK.createConfirmation3DSRequestACS(data: data, messageVersion: "1.0")
            startThreeDSConfirmation(for: addCardProcess,
                                     request: request,
                                     confirmationCancelled: confirmationCancelled,
                                     completion: completion)
        } catch {
            completion(.failure(error))
        }
    }
    
    func addCardProcess(_ addCardProcess: AddCardProcess,
                        needRandomAmountConfirmation requestKey: String,
                        confirmationCancelled: @escaping () -> Void,
                        completion: @escaping (Result<Void, Error>) -> Void) {
        startRandomAmountConfirmation(for: addCardProcess,
                                      requestKey: requestKey,
                                      confirmationCancelled: confirmationCancelled,
                                      completion: completion)
    }
}

private extension DefaultCardAddingController {
    func resetProcess(completion: @escaping () -> Void) {
        process?.cancel()
        process = nil
        
        dismissConfirmationIfNeeded { [weak self] in
            self?.confirmationViewController = nil
            completion()
        }
    }
    
    func dismissConfirmationIfNeeded(completion: @escaping () -> Void) {
        guard let confirmationViewController = confirmationViewController,
              let confirmationPresentingViewController = confirmationViewController.presentingViewController else {
            completion()
            return
        }
        
        if confirmationViewController.isBeingPresented {
            confirmationPresentingViewController.transitionCoordinator?.animate(alongsideTransition: nil, completion: { _ in
                confirmationPresentingViewController.dismiss(animated: true, completion: completion)
            })
        } else if confirmationViewController.isBeingDismissed {
            confirmationPresentingViewController.transitionCoordinator?.animate(alongsideTransition: nil, completion: { _ in
                completion()
            })
        } else {
            confirmationPresentingViewController.dismiss(animated: true, completion: completion)
        }
    }
    
    func startThreeDSConfirmation(for addCardProcess: AddCardProcess,
                                  request: URLRequest,
                                  confirmationCancelled: @escaping () -> Void,
                                  completion: @escaping (Result<Void, Error>) -> Void) {
        
        threeDSHandler.didCancel = {
            addCardProcess.cancel()
            confirmationCancelled()
        }
        
        threeDSHandler.didFinish = { result in
            switch result {
            case .success:
                completion(.success(()))
            case let .failure(error):
                completion(.failure(error))
            }
        }
        
        DispatchQueue.main.async {
            self.presentThreeDSViewController(urlRequest: request)
        }
    }
    
    func presentThreeDSViewController(urlRequest: URLRequest, completion: (() -> Void)? = nil) {
        dismissConfirmationIfNeeded {
            let threeDSViewController = ThreeDSViewController(urlRequest: urlRequest,
                                                              handler: self.threeDSHandler)
            let navigationController = UINavigationController(rootViewController: threeDSViewController)
            if #available(iOS 13.0, *) {
                navigationController.isModalInPresentation = true
            }
            self.uiProvider?.sourceViewControllerToPresent().present(navigationController,
                                                                     animated: true,
                                                                     completion: completion)
            self.confirmationViewController = threeDSViewController
        }
    }
    
    func startRandomAmountConfirmation(for addCardProcess: AddCardProcess,
                                       requestKey: String,
                                       confirmationCancelled: @escaping () -> Void,
                                       completion: @escaping (Result<Void, Error>) -> Void) {
        DispatchQueue.safePerformOnMainQueueAsyncIfNeeded {
            self.dismissConfirmationIfNeeded { [weak self] in
                let viewController = RandomAmounCheckingViewController(nibName: "RandomAmounCheckingViewController", bundle: Bundle(for: RandomAmounCheckingViewController.self))
                
                viewController.onCancel = {
                    confirmationCancelled()
                }
                
                viewController.completeHandler = { [weak self, weak viewController] value in
                    guard let self = self else { return }
                    viewController?.viewWaiting.isHidden = false
                    let amountDecimal = NSDecimalNumber(value: value)
                    let data = SubmitRandomAmountData(amount: Int64(amountDecimal.multiplying(byPowerOf10: 2).uint64Value),
                                                      requestKey: requestKey)
                    _ = self.acquiringSDK.checkRandomAmount(data: data) { response in
                        switch response {
                        case .success:
                            completion(.success(()))
                        case let .failure(error):
                            completion(.failure(error))
                        }
                    }
                }
                
                let navigationController = UINavigationController(rootViewController: viewController)
                if #available(iOS 13.0, *) {
                    navigationController.isModalInPresentation = true
                }
                
                self?.uiProvider?.sourceViewControllerToPresent().present(navigationController, animated: true)
                self?.confirmationViewController = navigationController
            }
        }
    }
}
