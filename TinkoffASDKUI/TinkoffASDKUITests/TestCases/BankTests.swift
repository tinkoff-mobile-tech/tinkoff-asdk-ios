//
//  BankTests.swift
//  TinkoffASDKUI-Unit-Tests
//
//  Created by Ivan Glushko on 17.11.2022.
//

import Foundation
@testable import TinkoffASDKCore
@testable import TinkoffASDKUI
import XCTest

final class BankTests: XCTestCase {

    func test_bank_bins() throws {
        // given
        let banks = Bank.allCases

        // when

        for bank in banks {
            switch bank {
            case .sber:
                XCTAssertEqual(bank.bins, Bin.sber)
            case .tinkoff:
                XCTAssertEqual(bank.bins, Bin.tinkoff)
            case .vtb:
                XCTAssertEqual(bank.bins, Bin.vtb)
            case .gazprom:
                XCTAssertEqual(bank.bins, Bin.gazprom)
            case .raiffaisen:
                XCTAssertEqual(bank.bins, Bin.raiffaisen)
            case .alpha:
                XCTAssertEqual(bank.bins, Bin.alpha)
            case .other:
                XCTAssertEqual(bank.bins, [String]())
            }
        }
    }

    func test_bank_icons() throws {
        // given
        let banks = Bank.allCases

        // when

        for bank in banks {
            switch bank {
            case .sber:
                XCTAssertEqual(bank.icon, .sber)
            case .tinkoff:
                XCTAssertEqual(bank.icon, .tinkoff)
            case .vtb:
                XCTAssertEqual(bank.icon, .vtb)
            case .gazprom:
                XCTAssertEqual(bank.icon, .gazprom)
            case .raiffaisen:
                XCTAssertEqual(bank.icon, .raiffaisen)
            case .alpha:
                XCTAssertEqual(bank.icon, .alpha)
            case .other:
                XCTAssertEqual(bank.icon, .other)
            }
        }
    }
}

extension BankTests {
    enum Bin {}
}

// MARK: - Bins

extension BankTests.Bin {
    // MARK: - Sber Bins

    static let sber: [String] = [
        "427402",
        "427406",
        "427411",
        "427416",
        "427417",
        "427418",
        "427420",
        "427422",
        "427425",
        "427427",
        "427428",
        "427430",
        "427432",
        "427433",
        "427436",
        "427438",
        "427444",
        "427448",
        "427449",
        "427459",
        "427466",
        "427472",
        "427475",
        "427477",
        "427499",
        "427600",
        "427601",
        "427602",
        "427616",
        "427620",
        "427622",
        "427625",
        "427635",
        "427648",
        "427659",
        "427666",
        "427672",
        "427674",
        "427677",
        "427680",
        "427699",
        "427901",
        "427902",
        "427916",
        "427920",
        "427922",
        "427925",
        "427930",
        "427948",
        "427959",
        "427966",
        "427972",
        "427975",
        "427977",
        "427999",
        "527576",
        "531310",
        "546901",
        "546916",
        "546920",
        "546922",
        "546925",
        "546935",
        "546959",
        "546966",
        "546972",
        "546974",
        "546998",
        "547901",
        "547905",
        "547910",
        "547920",
        "547922",
        "547925",
        "547927",
        "547928",
        "547930",
        "547932",
        "547935",
        "547938",
        "547940",
        "547942",
        "547947",
        "547948",
        "547949",
        "547959",
        "547966",
        "547969",
        "547972",
        "547976",
        "547998",
        "548401",
        "548410",
        "548416",
        "548420",
        "548422",
        "548425",
        "548430",
        "548435",
        "548438",
        "548440",
        "548442",
        "548447",
        "548454",
        "548459",
        "548466",
        "548468",
        "548472",
        "548476",
        "548498",
        "639002",
        "676195",
        "676196",
        "676280",
    ]

    // MARK: - VTB Bins

    static let vtb: [String] = [
        "418868",
        "418869",
        "418870",
        "421191",
        "426375",
        "490809",
        "515775",
        "524895",
        "525773",
        "525787",
        "542104",
        "552216",
        "554363",
        "558481",
    ]

    // MARK: - Alpha Bins

    static let alpha: [String] = [
        "415400",
        "415428",
        "415429",
        "415481",
        "415482",
        "419539",
        "419540",
        "427714",
        "428804",
        "428905",
        "428906",
        "431417",
        "431727",
        "434135",
        "439000",
        "458279",
        "458410",
        "458411",
        "477960",
        "477964",
        "479004",
        "479087",
    ]

    // MARK: - Tinkoff Bins

    static let tinkoff: [String] = [
        "220070",
        "437772",
        "437773",
        "437783",
        "470127",
        "518901",
        "521324",
        "524468",
        "528041",
        "538994",
        "551960",
        "553420",
        "553691",
    ]

    // MARK: - Raiffaisen

    static let raiffaisen: [String] = [
        "402178",
        "402179",
        "404807",
        "404885",
        "420705",
        "422287",
        "425884",
        "447603",
        "447624",
        "462729",
        "462730",
        "462758",
        "510069",
        "510070",
        "515876",
        "528053",
        "528808",
        "528809",
        "530867",
        "533594",
        "533616",
        "536392",
        "542772",
        "544237",
        "545115",
        "558273",
        "676625",
    ]

    // MARK: - Gazprom Bins

    static let gazprom: [String] = [
        "404136",
        "404270",
        "424974",
        "424975",
        "424976",
        "426890",
        "427326",
        "487415",
        "487416",
        "487417",
        "489354",
        "518816",
        "518902",
        "521155",
        "522193",
        "522477",
        "522988",
        "525740",
        "526483",
        "529278",
        "530993",
        "532684",
        "534130",
        "539839",
        "540664",
        "542255",
        "543672",
        "543762",
        "544026",
        "544561",
        "545101",
        "547348",
        "548027",
        "548999",
        "549000",
        "549098",
        "549600",
        "552702",
        "556052",
        "558355",
        "676454",
    ]
}
