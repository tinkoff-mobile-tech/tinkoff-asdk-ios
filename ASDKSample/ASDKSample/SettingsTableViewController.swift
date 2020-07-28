//
//  SettingsTableViewController.swift
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

import UIKit
import TinkoffASDKCore

class AppSetting {
	
	private let keySBP = "SettingKeySBP"
	private let keyShowEmailField = "SettingKeyShowEmailField"
	private let keyKindForAlertView = "KindForAlertView"
	private let keyAddCardCheckType = "AddCardChekType"
	private let keyLanguageId = "LanguageId"
	
	/// Система быстрых платежей
	var paySBP: Bool = false {
		didSet {
			UserDefaults.standard.set(paySBP, forKey: keySBP)
			UserDefaults.standard.synchronize()
		}
	}
	
	/// Показыть на форме оплаты поле для ввода email для отправки чека
	var showEmailField: Bool = false {
		didSet {
			UserDefaults.standard.set(showEmailField, forKey: keyShowEmailField)
			UserDefaults.standard.synchronize()
		}
	}
	
	var Acquiring: Bool = false {
		didSet {
			UserDefaults.standard.set(Acquiring, forKey: keyKindForAlertView)
			UserDefaults.standard.synchronize()
		}
	}
	
	var addCardChekType: PaymentCardCheckType = .no {
		didSet {
			UserDefaults.standard.set(addCardChekType.rawValue, forKey: keyAddCardCheckType)
			UserDefaults.standard.synchronize()
		}
	}
	
	var languageId: String? {
		didSet {
			UserDefaults.standard.set(languageId, forKey: keyLanguageId)
			UserDefaults.standard.synchronize()
		}
	}
	
	static let shared = AppSetting()
	
	init() {
		let usd = UserDefaults.standard
		
		self.paySBP = usd.bool(forKey: keySBP)
		self.showEmailField = usd.bool(forKey: keyShowEmailField)
		self.Acquiring = usd.bool(forKey: keyKindForAlertView)
		if let value = usd.value(forKey: keyAddCardCheckType) as? String {
			self.addCardChekType = PaymentCardCheckType.init(rawValue: value)
		}
		
		self.languageId = usd.string(forKey: keyLanguageId)
	}
	
}

class SettingsTableViewController: UITableViewController {
	
	enum TableViewCellType {
		/// включить оплату с помощью `Системы Быстрых Платежей`
		case paySBP
		/// показывать на форме оплаты поле для ввода email
		case showEmail
		/// использовать алерты из Aquaring SDK
		case Acquiring
		/// какой тип проверки использоваться при сохранении карты
		case addCardCheckType
		/// на каком языке показыват форму оплаты
		case language
	}
	
	private var tableViewCells: [TableViewCellType] = []
	private var availableCardChekType: [String] = []
	private var availableLanguage: [String] = []

    override func viewDidLoad() {
        super.viewDidLoad()

		title = NSLocalizedString("title.settings", comment: "Настройки")
		
		tableView.registerCells(types: [SwitchTableViewCell.self, SegmentedTabeViewCell.self])
		
		updateTableViewCells()
    }

	
	func updateTableViewCells() {
		
		availableCardChekType = []
		availableCardChekType.append(PaymentCardCheckType.no.rawValue)
		availableCardChekType.append(PaymentCardCheckType.check3DS.rawValue)
		availableCardChekType.append(PaymentCardCheckType.hold3DS.rawValue)
		availableCardChekType.append(PaymentCardCheckType.hold.rawValue)
		
		availableLanguage.append("auto")
		availableLanguage.append("ru")
		availableLanguage.append("en")
		
		tableViewCells = [.paySBP, .showEmail, .Acquiring, .addCardCheckType, .language]
	}
	
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
		return tableViewCells.count
    }
	
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return 1
    }

	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		switch tableViewCells[indexPath.section] {
			case .paySBP:
				if let cell = tableView.dequeueReusableCell(withIdentifier: SwitchTableViewCell.nibName) as? SwitchTableViewCell {
					let value = AppSetting.shared.paySBP
					cell.switcher.isOn = value
					
					cell.labelTitle.text = value ? NSLocalizedString("status.sbp.on", comment: "Включены") : NSLocalizedString("status.sbp.off", comment: "Выключены")
					cell.onSwitcherChange = { (swither) in
						AppSetting.shared.paySBP = swither.isOn
						tableView.beginUpdates()
							tableView.reloadRows(at: [indexPath], with: .automatic)
						tableView.endUpdates()
					}
					
					return cell
				}
			
			case .showEmail:
				if let cell = tableView.dequeueReusableCell(withIdentifier: SwitchTableViewCell.nibName) as? SwitchTableViewCell {
					let value = AppSetting.shared.showEmailField
					cell.switcher.isOn = value
					
					cell.labelTitle.text = value ? NSLocalizedString("status.showEmailField.on", comment: "Показывать") : NSLocalizedString("status.showEmailField.off", comment: "Скрыто")
					cell.onSwitcherChange = { (swither) in
						AppSetting.shared.showEmailField = swither.isOn
						tableView.beginUpdates()
							tableView.reloadRows(at: [indexPath], with: .automatic)
						tableView.endUpdates()
					}
					
					return cell
				}
			
			case .Acquiring:
				if let cell = tableView.dequeueReusableCell(withIdentifier: SwitchTableViewCell.nibName) as? SwitchTableViewCell {
					let value = AppSetting.shared.Acquiring
					cell.switcher.isOn = value
					
					cell.labelTitle.text = value ? NSLocalizedString("status.alert.on", comment: "Aquaring") : NSLocalizedString("status.alert.off", comment: "Системные")
					cell.onSwitcherChange = { (swither) in
						AppSetting.shared.Acquiring = swither.isOn
						tableView.beginUpdates()
							tableView.reloadRows(at: [indexPath], with: .automatic)
						tableView.endUpdates()
					}
					
					return cell
			}
			
			case .addCardCheckType:
				if let cell = tableView.dequeueReusableCell(withIdentifier: SegmentedTabeViewCell.nibName) as? SegmentedTabeViewCell {
					cell.segmentedControl.removeAllSegments()
					for (index, title) in availableCardChekType.enumerated() {
						cell.segmentedControl.insertSegment(withTitle: title, at: index, animated: false)
						if AppSetting.shared.addCardChekType.rawValue == title {
							cell.segmentedControl.selectedSegmentIndex = index
						}
					}
					
					cell.onSegmentedChanged = { [weak self] (index) in
						if let value = self?.availableCardChekType[index] {
							AppSetting.shared.addCardChekType = PaymentCardCheckType.init(rawValue: value)
						}
					}
					
					return cell
				}
			
			case .language:
				if let cell = tableView.dequeueReusableCell(withIdentifier: SegmentedTabeViewCell.nibName) as? SegmentedTabeViewCell {
					cell.segmentedControl.removeAllSegments()
					
					for (index, title) in availableLanguage.enumerated() {
						cell.segmentedControl.insertSegment(withTitle: title, at: index, animated: false)
						if index == 0 && AppSetting.shared.languageId == nil {
							cell.segmentedControl.selectedSegmentIndex = 0
						} else if let value = AppSetting.shared.languageId, value == title {
							cell.segmentedControl.selectedSegmentIndex = index
						}
					}
					
					cell.onSegmentedChanged = { [weak self] (index) in
						if index > 0 {
							if let value = self?.availableLanguage[index] {
								AppSetting.shared.languageId = value
							}
						} else {
							AppSetting.shared.languageId = nil
						}
					}
					
					return cell
				}
		}
		
		return tableView.defaultCell()
	}
	
	override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
		switch tableViewCells[section] {
			case .paySBP:
				return NSLocalizedString("title.fasterPayments", comment: "Система Быстрых Платежей")
			case .showEmail:
				return NSLocalizedString("title.showEmailField", comment: "")
			case .Acquiring:
				return NSLocalizedString("title.Acquiring", comment: "")
			case .addCardCheckType:
				return NSLocalizedString("title.savingCard", comment: "Сохранение карты")
			case .language:
				return NSLocalizedString("title.paymentFormLanguage", comment: "Локализация платежной формы")
		}
		
	}
	
	override func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
		switch tableViewCells[section] {
			case .paySBP:
				return NSLocalizedString("text.payBySBP.description", comment: "")

			case .showEmail:
				return NSLocalizedString("text.showEmailField", comment: "")
			
			case .Acquiring:
				return NSLocalizedString("text.Acquiring.description", comment: "")
			
			case .addCardCheckType:
				return NSLocalizedString("text.addCardCheckType.description", comment: "")
			
			case .language:
				return NSLocalizedString("text.language.description", comment: "")
		}
		
	}
	
}
