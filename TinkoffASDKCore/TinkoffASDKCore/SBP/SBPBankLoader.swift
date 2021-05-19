//
//
//  SBPBankLoader.swift
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


import Foundation
 
protocol SBPBankLoader {
    func loadBanks(completion: @escaping (Result<[SBPBank], Error>) -> Void)
}

final class MockSBPBankLoader: SBPBankLoader {
    func loadBanks(completion: @escaping (Result<[SBPBank], Error>) -> Void) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            let jsonData = json.data(using: .utf8)!
            do {
                let response = try JSONDecoder().decode(SBPBankResponse.self, from: jsonData)
                completion(.success(response.banks))
            } catch {
                completion(.failure(error))
            }
        }
        
    }
}

let json = """
{
    "version": "1.0",
    "dictionary": [
        {
            "bankName": "ÐŸÐÐž ÐŸÑ€Ð¾Ð¼ÑÐ²ÑÐ·ÑŒÐ±Ð°Ð½Ðº",
            "logoURL": "https://qr.nspk.ru/proxyapp/logo/bank100000000010.png",
            "schema": "bank100000000010"
        },
                {
            "bankName": "ÐŸÐÐž Ð¡ÐšÐ‘-Ð±Ð°Ð½Ðº",
            "logoURL": "https://qr.nspk.ru/proxyapp/logo/bank100000000003.png",
            "schema": "bank100000000003"
        },
                {
            "bankName": "ÐÐž Ð“Ð°Ð·ÑÐ½ÐµÑ€Ð³Ð¾Ð±Ð°Ð½Ðº",
            "logoURL": "https://qr.nspk.ru/proxyapp/logo/bank100000000043.png",
            "schema": "bank100000000043"
        },
           {
            "bankName": "ÐŸÐÐž ÐÐšÐ‘ ÐÐ’ÐÐÐ“ÐÐ Ð”",
            "logoURL": "https://qr.nspk.ru/proxyapp/logo/bank100000000028.png",
            "schema": "bank100000000028"
        },
        {
            "bankName": "ÐžÐžÐž ÐŸÐÐšÐž Ð­Ð›ÐŸÐ›ÐÐ¢",
            "logoURL": "https://qr.nspk.ru/proxyapp/logo/bank100000000086.png",
            "schema": "bank100000000086"
        },
        {
            "bankName": "ÐÐšÐž Ð ÑƒÑÑÐºÐ¾Ðµ Ñ„Ð¸Ð½Ð°Ð½ÑÐ¾Ð²Ð¾Ðµ Ð¾Ð±Ñ‰ÐµÑÑ‚Ð²Ð¾",
            "logoURL": "https://qr.nspk.ru/proxyapp/logo/bank100000000104.png",
            "schema": "bank100000000104"
        },
                {
            "bankName": "Ð ÐÐšÐ‘ Ð‘Ð°Ð½Ðº ÐŸÐÐž",
            "logoURL": "https://qr.nspk.ru/proxyapp/logo/bank100000000011.png",
            "schema": "bank100000000011"
        },
                {
            "bankName": "ÐžÐžÐž Ð­ÐºÑÐ¿Ð¾Ð±Ð°Ð½Ðº",
            "logoURL": "https://qr.nspk.ru/proxyapp/logo/bank100000000044.png",
            "schema": "bank100000000044"
        },
                {
            "bankName": "ÐÐž Ð‘Ð°Ð½Ðº ÐšÐšÐ‘",
            "logoURL": "https://qr.nspk.ru/proxyapp/logo/bank100000000054.png",
            "schema": "bank100000000054"
        },
                {
            "bankName": "Ð‘Ð°Ð½Ðº Ð’Ð‘Ð Ð  ÐÐž",
            "logoURL": "https://qr.nspk.ru/proxyapp/logo/bank100000000049.png",
            "schema": "bank100000000049"
        },
                {
            "bankName": "ÐŸÐÐž ÐœÐžÐ¡ÐšÐžÐ’Ð¡ÐšÐ˜Ð™ ÐšÐ Ð•Ð”Ð˜Ð¢ÐÐ«Ð™ Ð‘ÐÐÐš",
            "logoURL": "https://qr.nspk.ru/proxyapp/logo/bank100000000025.png",
            "schema": "bank100000000025"
        },
                {
            "bankName": "RSB+ Ð‘Ð°Ð½Ðº Ð ÑƒÑÑÐºÐ¸Ð¹ Ð¡Ñ‚Ð°Ð½Ð´Ð°Ñ€Ñ‚",
            "logoURL": "https://qr.nspk.ru/proxyapp/logo/bank100000000500.png",
            "schema": "bank100000000500"
        },
                {
            "bankName": "ÐÐž ÐÐ‘ Ð ÐžÐ¡Ð¡Ð˜Ð¯",
            "logoURL": "https://qr.nspk.ru/proxyapp/logo/bank100000000095.png",
            "schema": "bank100000000095"
        },
                {
            "bankName": "Ð”Ð‘Ðž Ð¤Ð°ÐºÑ‚ÑƒÑ€Ð°",
            "logoURL": "https://qr.nspk.ru/proxyapp/logo/bank100000000900.png",
            "schema": "bank100000000900"
        },
                {
            "bankName": "ÐÐž Ð Ð¾ÑÑÐµÐ»ÑŒÑ…Ð¾Ð·Ð±Ð°Ð½Ðº",
            "logoURL": "https://qr.nspk.ru/proxyapp/logo/bank100000000020.png",
            "schema": "bank100000000020"
        },
                {
            "bankName": "ÐÐž ÐšÐ‘ Ð¥Ð»Ñ‹Ð½Ð¾Ð²",
            "logoURL": "https://qr.nspk.ru/proxyapp/logo/bank100000000056.png",
            "schema": "bank100000000056"
        },
                {
            "bankName": "Ð˜Ð½Ð²ÐµÑÑ‚Ð¸Ñ†Ð¸Ð¾Ð½Ð½Ñ‹Ð¹ Ð‘Ð°Ð½Ðº Ð’Ð•Ð¡Ð¢Ð ÐžÐžÐž",
            "logoURL": "https://qr.nspk.ru/proxyapp/logo/bank100000000053.png",
            "schema": "bank100000000053"
        },
                {
            "bankName": "ÐÐž Ð®Ð½Ð¸ÐšÑ€ÐµÐ´Ð¸Ñ‚ Ð‘Ð°Ð½Ðº",
            "logoURL": "https://qr.nspk.ru/proxyapp/logo/bank100000000030.png",
            "schema": "bank100000000030"
        },
                {
            "bankName": "ÐÐž ÐšÐ‘ Ð¡Ð¾Ð»Ð¸Ð´Ð°Ñ€Ð½Ð¾ÑÑ‚ÑŒ",
            "logoURL": "https://qr.nspk.ru/proxyapp/logo/bank100000000121.png",
            "schema": "bank100000000121"
                },
                {
            "bankName": "ÐÐž ÐÐ›Ð¬Ð¤Ð-Ð‘ÐÐÐš",
            "logoURL": "https://qr.nspk.ru/proxyapp/logo/bank100000000008.png",
            "schema": "bank100000000008"
                },
                {
            "bankName": "ÐÐž Ð‘Ð°Ð½Ðº Ð”ÐžÐœ.Ð Ð¤",
            "logoURL": "https://qr.nspk.ru/proxyapp/logo/bank100000000082.png",
            "schema": "bank100000000082"
                },
        {
            "bankName": "ÐžÐžÐž Ð¥Ð°ÐºÐ°ÑÑÐºÐ¸Ð¹ Ð¼ÑƒÐ½Ð¸Ñ†Ð¸Ð¿Ð°Ð»ÑŒÐ½Ñ‹Ð¹ Ð±Ð°Ð½Ðº",
            "logoURL": "https://qr.nspk.ru/proxyapp/logo/bank100000000127.png",
            "schema": "bank100000000127"
                },
        {
            "bankName": "ÐŸÐÐž ÐœÐ¢Ð¡-Ð‘Ð°Ð½Ðº",
            "logoURL": "https://qr.nspk.ru/proxyapp/logo/bank100000000017.png",
            "schema": "bank100000000017"
                },
        {
            "bankName": "ÐÐž Ð‘Ð°Ð½Ðº ÐŸÐ¡ÐšÐ‘",
            "logoURL": "https://qr.nspk.ru/proxyapp/logo/bank100000000087.png",
            "schema": "bank100000000087"
                },
        {
            "bankName": "Ð‘Ð°Ð½Ðº Ð›ÐµÐ²Ð¾Ð±ÐµÑ€ÐµÐ¶Ð½Ñ‹Ð¹ ÐŸÐÐž",
            "logoURL": "https://qr.nspk.ru/proxyapp/logo/bank100000000052.png",
            "schema": "bank100000000052"
                },
        {
            "bankName": "ÐÐž Ð Ð°Ð¹Ñ„Ñ„Ð°Ð¹Ð·ÐµÐ½Ð±Ð°Ð½Ðº",
            "logoURL": "https://qr.nspk.ru/proxyapp/logo/bank100000000007.png",
            "schema": "bank100000000007"
                },
        {
            "bankName": "ÐŸÐÐž ÐÐš Ð‘ÐÐ Ð¡ Ð‘ÐÐÐš",
            "logoURL": "https://qr.nspk.ru/proxyapp/logo/bank100000000006.png",
            "schema": "bank100000000006"
                },
        {
            "bankName": "ÐžÐžÐž ÐšÐ‘ Ð Ð¾ÑÑ‚Ð¤Ð¸Ð½Ð°Ð½Ñ",
            "logoURL": "https://qr.nspk.ru/proxyapp/logo/bank100000000098.png",
            "schema": "bank100000000098"
                },
        {
            "bankName": "ÐŸÐÐž Ð‘Ñ‹ÑÑ‚Ñ€Ð¾Ð±Ð°Ð½Ðº",
            "logoURL": "https://qr.nspk.ru/proxyapp/logo/bank100000000092.png",
            "schema": "bank100000000092"
                },
        {
            "bankName": "ÐÐž ÐœÐ¡ Ð‘Ð°Ð½Ðº Ð Ð£Ð¡",
            "logoURL": "https://qr.nspk.ru/proxyapp/logo/bank100000000229.png",
            "schema": "bank100000000229"
                },
                {
            "bankName": "ÐÐž ÐšÑ€ÐµÐ´Ð¸Ñ‚ Ð•Ð²Ñ€Ð¾Ð¿Ð° Ð‘Ð°Ð½Ðº Ð Ð¾ÑÑÐ¸Ñ",
            "logoURL": "https://qr.nspk.ru/proxyapp/logo/bank100000000027.png",
            "schema": "bank100000000027"
                },
        {
            "bankName": "Ð¢ÐµÑÑ‚Ð¾Ð²Ð¾Ðµ Ð¿Ñ€Ð¸Ð»Ð¾Ð¶ÐµÐ½Ð¸Ðµ 1",
            "logoURL": "https://qr.nspk.ru/proxyapp/logo/bank100000000998.png",
            "schema": "bank100000000998"
        },
        {
            "bankName": "Ð¢ÐµÑÑ‚Ð¾Ð²Ð¾Ðµ Ð¿Ñ€Ð¸Ð»Ð¾Ð¶ÐµÐ½Ð¸Ðµ 2",
            "logoURL": "https://qr.nspk.ru/proxyapp/logo/bank100000000999.png",
            "schema": "bank100000000999"
        }

    ]
}
"""
