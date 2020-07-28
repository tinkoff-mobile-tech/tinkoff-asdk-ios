//
//  CardListPresenter.swift
//  TinkoffASDKUI
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

import UIKit
import TinkoffASDKCore

protocol CardListViewInConenction {
	/// отрисовка карточек для сохраненных карт и новых реквизитов
	var contentCollectionView: UICollectionView! { get }
	/// статус по аналогии с UIPagecontroll
	var pageStatusCollectionView: UICollectionView! { get }
	
}

enum CardRequisitesState {
	/// новая карты, реквизиты: номер карты дата и cvc код
	case requisites(number: String?, expDate: String?, cvc: String?)
	/// ранее сохраненная карта и cvc код, для случаев когда его нужно ввести для оплаты
	case savedCard(card: PaymentCard, cvc: String?)
}

protocol CardListViewOutConnection: InputViewStatus {
	
	func requisies() -> CardRequisitesState
	
	func presentCardList(dataSource: AcquiringCardListDataSourceDelegate?, in view: CardListViewInConenction, becomeFirstResponderListener: BecomeFirstResponderListener?, scaner: CardRequisitesScanerProtocol?)
	
	func waitCVCInput(forCardWith parentPaymentId: Int64, fieldActivated : @escaping (()-> Void))
	
	func updateView()
		
	var didSelectSBPItem: (() -> Void)? { get set }
	
	var didSelectShowCardList: (() -> Void)? { get set }
	
}

class CardListPresenter: NSObject {

	// MARK: CardListViewOutConnection didSelect closure
	
	var didSelectSBPItem: (() -> Void)?
	var didSelectShowCardList: (() -> Void)?
	weak var scaner: CardRequisitesScanerProtocol?
	
	// MARK: private
	
	enum ListItemType {
		case card
		case requisites
		case sbp
	}
	
	struct CellInfo {
		var type: ListItemType
		var index: Int
	}
	
	private var cellIndex: [CellInfo] = []
	private weak var cardListCollectionView: UICollectionView?
	private weak var pageStatusCollectionView: UICollectionView?
	private weak var dataSource: AcquiringCardListDataSourceDelegate?
	private lazy var inputCardRequisitesController: InputCardRequisitesDataSource = InputCardRequisitesController()
	private weak var becomeFirstResponderListener: BecomeFirstResponderListener?
	private lazy var inputCardCVCRequisitesPresenter: InputCardCVCRequisitesViewOutConnection = InputCardCVCRequisitesPresenter()
	private lazy var cardRequisitesBrandInfo: CardRequisitesBrandInfoProtocol = CardRequisitesBrandInfo()
	private var waitingInputCVCForParentPaymentId: Int64?
	private var waitingInputIndexPath: IndexPath?
	private var lastActiveCardIndexPath: IndexPath?
	
	private func setupCardListCollectionView(_ collectionView: UICollectionView) {
		collectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "defaultCell")
		
		collectionView.register(UINib.init(nibName: "PaymentCardCollectionViewCell", bundle: Bundle(for: type(of: self))), forCellWithReuseIdentifier: "PaymentCardCollectionViewCell")
		collectionView.register(UINib.init(nibName: "CardListLoadingCollectionViewCell", bundle: Bundle(for: type(of: self))), forCellWithReuseIdentifier: "CardListLoadingCollectionViewCell")
		collectionView.register(UINib.init(nibName: "CardListStatusCollectionViewCell", bundle: Bundle(for: type(of: self))), forCellWithReuseIdentifier: "CardListStatusCollectionViewCell")
		collectionView.register(UINib.init(nibName: "PaymentCardInputRequisitesCollectionViewCell", bundle: Bundle(for: type(of: self))), forCellWithReuseIdentifier: "PaymentCardInputRequisitesCollectionViewCell")
		collectionView.register(UINib.init(nibName: "SBPCollectionViewCell", bundle: Bundle(for: type(of: self))), forCellWithReuseIdentifier: "SBPCollectionViewCell")
		
		collectionView.register(UINib.init(nibName: "UICollectionReusableViewEmpty", bundle: Bundle(for: type(of: self))), forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "UICollectionReusableViewEmpty")
		collectionView.register(UINib.init(nibName: "UICollectionReusableViewEmpty", bundle: Bundle(for: type(of: self))), forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter, withReuseIdentifier: "UICollectionReusableViewEmpty")
		
		collectionView.delegate = self
		collectionView.dataSource = self
	}
	
	private func setupPageStatusCollectionView(_ collectionView: UICollectionView) {
		collectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "defaultCell")
				
		collectionView.register(UINib.init(nibName: "PageStatusCollectionViewCell", bundle: Bundle(for: type(of: self))), forCellWithReuseIdentifier: "PageStatusCollectionViewCell")
		collectionView.register(UINib.init(nibName: "PageStatusListCollectionViewCell", bundle: Bundle(for: type(of: self))), forCellWithReuseIdentifier: "PageStatusListCollectionViewCell")
		
		collectionView.register(UINib.init(nibName: "UICollectionReusableViewEmpty", bundle: Bundle(for: type(of: self))), forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "UICollectionReusableViewEmpty")
		collectionView.register(UINib.init(nibName: "UICollectionReusableViewEmpty", bundle: Bundle(for: type(of: self))), forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter, withReuseIdentifier: "UICollectionReusableViewEmpty")
		
		collectionView.delegate = self
		collectionView.dataSource = self
	}

}

extension CardListPresenter: UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
	
	// MARK: UICollectionViewDelegate
	
	func numberOfSections(in collectionView: UICollectionView) -> Int {
		cellIndex = []
		switch dataSource?.cardListFetchStatus() {
			case .object:
				if let count = dataSource?.cardListNumberOfCards() {
					for index in 0...count-1 {
						cellIndex.append(CellInfo.init(type: .card, index: index))
						if let parentPaymentId = waitingInputCVCForParentPaymentId, let card = dataSource?.cardListCard(at: index), card.parentPaymentId == parentPaymentId {
							waitingInputIndexPath = IndexPath.init(item: index, section: 0)
						}
					}
				}
			
			default:
				break
		}
		
		cellIndex.append(CellInfo.init(type: .requisites, index: 0))
		
		return 1
	}
	
	func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		return cellIndex.count
	}
	
	func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
		let cellInfo = cellIndex[indexPath.row]

		if collectionView == cardListCollectionView {
			switch cellInfo.type {
				case .card:
					switch dataSource?.cardListFetchStatus() {
						case .loading:
							if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CardListLoadingCollectionViewCell", for: indexPath) as? LoadingCollectionViewCell {
								cell.activityIndicator.startAnimating()
								return cell
							}
						
						case .object:
							if let card = dataSource?.cardListCard(at: cellInfo.index), let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PaymentCardCollectionViewCell", for: indexPath) as? PaymentCardCollectionViewCell {
								cell.labelCardName.text = card.pan
								cell.labelCardExpData.text = card.expDateFormat()
								
								cardRequisitesBrandInfo.cardBrandInfo(numbers: card.pan, completion: { [weak cell] (requisites, icon, _) in
									if let numbers = requisites, card.pan.hasPrefix(numbers) {
										cell?.imageViewLogo.image = icon
										cell?.imageViewLogo.isHidden = false
									} else {
										cell?.imageViewLogo.image = nil
										cell?.imageViewLogo.isHidden = true
									}
								})
								
								if let parentPaymentId = waitingInputCVCForParentPaymentId, parentPaymentId == card.parentPaymentId {
									cell.textFieldCardCVCContainer.isHidden = false

									inputCardCVCRequisitesPresenter.present(responderListener: becomeFirstResponderListener,
																			inputView: cell)
								} else {
									cell.textFieldCardCVCContainer.isHidden = true
								}
								
								return cell
							}
						
						case .empty:
							if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CardListStatusCollectionViewCell", for: indexPath) as? CardListStatusCollectionViewCell {
								cell.buttonAction.isHidden = true
								cell.buttonAction.setTitle(nil, for: .normal)
								return cell
							}
						
						case .error:
							if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PaymentCardInputRequisitesCollectionViewCell", for: indexPath) as? PaymentCardInputRequisitesCollectionViewCell {
								inputCardRequisitesController.setup(responderListener: becomeFirstResponderListener,
																	inputView: cell,
																	inputAccessoryView: nil,
																	scaner: nil)
								
								return cell
							}
						
						default:
							break
					}

				case .requisites:
					if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PaymentCardInputRequisitesCollectionViewCell", for: indexPath) as? PaymentCardInputRequisitesCollectionViewCell {
						inputCardRequisitesController.setup(responderListener: becomeFirstResponderListener,
															inputView: cell,
															inputAccessoryView: nil,
															scaner: scaner)
						
						return cell
					}
				
				default:
					break
			}//switch .type
		} else if collectionView == pageStatusCollectionView {
			if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PageStatusCollectionViewCell", for: indexPath) as? PageStatusCollectionViewCell {
				let selectedCardCellIndex = scrollViewCurrentPage(cardListCollectionView)
				
				switch cellInfo.type {
					case .card:
						if indexPath.row == 0, let cellCardList = collectionView.dequeueReusableCell(withReuseIdentifier: "PageStatusListCollectionViewCell", for: indexPath) as? PageStatusListCollectionViewCell {
							cellCardList.setIconList(UIImage.init(named: "pageList", in: Bundle(for: type(of: self)), compatibleWith: nil))
							if selectedCardCellIndex == indexPath.row {
								cellCardList.setIcon(UIImage.init(named: "pageDotActive", in: Bundle(for: type(of: self)), compatibleWith: nil))
							} else {
								cellCardList.setIcon(UIImage.init(named: "pageDot", in: Bundle(for: type(of: self)), compatibleWith: nil))
							}
							
							cellCardList.onTouchList = { [weak self] in
								self?.didSelectShowCardList?()
							}
							
							cellCardList.onTouch = { [weak self] in
								self?.cardListCollectionView?.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
							}
							
							return cellCardList
						} else {
							if selectedCardCellIndex == indexPath.row {
								cell.setIcon(UIImage.init(named: "pageDotActive", in: Bundle(for: type(of: self)), compatibleWith: nil))
							} else {
								cell.setIcon(UIImage.init(named: "pageDot", in: Bundle(for: type(of: self)), compatibleWith: nil))
							}
						}
					case .requisites:
						if selectedCardCellIndex == indexPath.row {
							cell.setIcon(UIImage.init(named: "pageAddCardActive", in: Bundle(for: type(of: self)), compatibleWith: nil))
						} else {
							cell.setIcon(UIImage.init(named: "pageAddCard", in: Bundle(for: type(of: self)), compatibleWith: nil))
						}
					case .sbp:
						cell.setIcon(UIImage.init(named: "pageQR", in: Bundle(for: type(of: self)), compatibleWith: nil))
				}
				
				cell.onTouch = { [weak self] in
					self?.cardListCollectionView?.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
				}
				
				return cell
			}
			
		}
		
		return collectionView.dequeueReusableCell(withReuseIdentifier: "defaultCell", for: indexPath)
	}
	
	// MARK: UICollectionViewDelegateFlowLayout
	
	func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
		var cellSize: CGSize = collectionView.bounds.size
		if collectionView == cardListCollectionView {
			//cellSize.width -= 30
			//cellSize.height -= 30
		} else if collectionView == pageStatusCollectionView {
			if case .object = dataSource?.cardListFetchStatus(), let count = dataSource?.cardListNumberOfCards(), indexPath.row < count  {
				if indexPath.row == 0 {
					cellSize = CGSize.init(width: 46, height: 30)
				} else {
					cellSize = CGSize.init(width: 14, height: 30)
				}
			} else {
				cellSize = CGSize.init(width: 24, height: 30)
			}
		}
		
		return cellSize
	}
	
	func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
		if collectionView == cardListCollectionView {
			return 8
		}

		return 2
	}
	
	func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
		if collectionView == cardListCollectionView {
			return 8
		}
		
		return 2
	}
	
	func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
		return .zero
	}
	
	func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {
		return .zero
	}

}


extension CardListPresenter: UICollectionViewDataSource {
	
	// MARK: UICollectionViewDataSource
	
	func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {

		switch kind {
			case UICollectionView.elementKindSectionHeader:
				if let view = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "UICollectionReusableViewEmpty", for: indexPath) as? UICollectionReusableViewEmpty {
					return view
				}
			
			default:
				if let view = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "UICollectionReusableViewEmpty", for: indexPath) as? UICollectionReusableViewEmpty {
					return view
				}
		}
		
		return UICollectionReusableView.init()
	}
	
}


extension CardListPresenter: UIScrollViewDelegate {
	
	// MARK: UIScrollViewDelegate
	
	func scrollViewDidScroll(_ scrollView: UIScrollView) {
		if cardListCollectionView == scrollView {
			pageStatusCollectionView?.reloadData()
		}
		
		if let activeCell = cardListCollectionView?.visibleCells.first, let indexPath = cardListCollectionView?.indexPath(for: activeCell) {
			lastActiveCardIndexPath = indexPath
		}
	}
	
	func scrollViewCurrentPage(_ scrollView: UIScrollView?) -> Int {
		if let scv = scrollView, cardListCollectionView == scv {
			let cellWidth = scv.bounds.size.width
			let currentPage = Int(scv.contentOffset.x / cellWidth)
			
			return currentPage
		}
		
		return 0
	}
	
}


extension CardListPresenter: CardListViewOutConnection {
	
	// MARK: CardListViewOutConnection
	
	func requisies() -> CardRequisitesState {
		let selectedCardCellIndex = scrollViewCurrentPage(cardListCollectionView)
		
		switch cellIndex[selectedCardCellIndex].type {
			case .card:
				if let card = dataSource?.cardListCard(at: selectedCardCellIndex) {
					let cvc = inputCardCVCRequisitesPresenter.cardCVC()
					return CardRequisitesState.savedCard(card: card, cvc: cvc)
				}
			
			case .requisites:
				let requisites = inputCardRequisitesController.requisies()
				return CardRequisitesState.requisites(number: requisites.number, expDate: requisites.expDate, cvc: requisites.cvc)

			default:
				break
		}
		
		let requisites = inputCardRequisitesController.requisies()
		return CardRequisitesState.requisites(number: requisites.number, expDate: requisites.expDate, cvc: requisites.cvc)
	}
	
	func presentCardList(dataSource: AcquiringCardListDataSourceDelegate?, in view: CardListViewInConenction, becomeFirstResponderListener: BecomeFirstResponderListener?, scaner: CardRequisitesScanerProtocol?) {
		self.dataSource = dataSource
		self.becomeFirstResponderListener = becomeFirstResponderListener
		self.scaner = scaner
		
		setupCardListCollectionView(view.contentCollectionView)
		cardListCollectionView = view.contentCollectionView
		
		setupPageStatusCollectionView(view.pageStatusCollectionView)
		pageStatusCollectionView = view.pageStatusCollectionView
	}
	
	func waitCVCInput(forCardWith parentPaymentId: Int64, fieldActivated: @escaping (() -> Void)) {
		waitingInputCVCForParentPaymentId = parentPaymentId
		pageStatusCollectionView?.isHidden = true
		cardListCollectionView?.isScrollEnabled = false
		DispatchQueue.main.asyncAfter(deadline: .now() + 1) { [weak self] in
			self?.updateView()
			if let indexPath = self?.waitingInputIndexPath {
				self?.cardListCollectionView?.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
				DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
					if let cell = self?.cardListCollectionView?.cellForItem(at: indexPath) as? PaymentCardCollectionViewCell {
						cell.textFieldCardCVCContainer.isHidden = false
						cell.textFieldCardCVC.becomeFirstResponder()
					}
				}

				fieldActivated()
			}
		}
	}

	func updateView() {
		cardListCollectionView?.reloadData()
		pageStatusCollectionView?.reloadData()
		
		DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) { [weak self] in
			if let indexPath = self?.lastActiveCardIndexPath, indexPath.row != self?.scrollViewCurrentPage(self?.cardListCollectionView) {
				self?.cardListCollectionView?.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
			}
		}
	}
	
	func setStatus(_ value: InputFieldTableViewCellStatus, statusText: String?) {
		let indexPath = IndexPath.init(row: scrollViewCurrentPage(cardListCollectionView), section: 0)
		if let cell = cardListCollectionView?.cellForItem(at: indexPath) as? InputViewStatus {
			cell.setStatus(value, statusText: statusText)
		}
	}
	
}
