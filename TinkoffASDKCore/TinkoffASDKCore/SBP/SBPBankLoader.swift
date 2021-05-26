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
            "bankName": "ПАО Промсвязьбанк",
            "logoURL": "https://qr.nspk.ru/proxyapp/logo/bank100000000010.png",
            "schema": "bank100000000010"
        },
                {
            "bankName": "ПАО СКБ-банк",
            "logoURL": "https://qr.nspk.ru/proxyapp/logo/bank100000000003.png",
            "schema": "bank100000000003"
        },
                {
            "bankName": "АО Газэнергобанк",
            "logoURL": "https://qr.nspk.ru/proxyapp/logo/bank100000000043.png",
            "schema": "bank100000000043"
        },
           {
            "bankName": "ПАО АКБ АВАНГАРД",
            "logoURL": "https://qr.nspk.ru/proxyapp/logo/bank100000000028.png",
            "schema": "bank100000000028"
        },
        {
            "bankName": "ООО ПНКО ЭЛПЛАТ",
            "logoURL": "https://qr.nspk.ru/proxyapp/logo/bank100000000086.png",
            "schema": "bank100000000086"
        },
        {
            "bankName": "НКО Русское финансовое общество",
            "logoURL": "https://qr.nspk.ru/proxyapp/logo/bank100000000104.png",
            "schema": "bank100000000104"
        },
                {
            "bankName": "РНКБ Банк ПАО",
            "logoURL": "https://qr.nspk.ru/proxyapp/logo/bank100000000011.png",
            "schema": "bank100000000011"
        },
                {
            "bankName": "ООО Экспобанк",
            "logoURL": "https://qr.nspk.ru/proxyapp/logo/bank100000000044.png",
            "schema": "bank100000000044"
        },
                {
            "bankName": "АО Банк ККБ",
            "logoURL": "https://qr.nspk.ru/proxyapp/logo/bank100000000054.png",
            "schema": "bank100000000054"
        },
                {
            "bankName": "Банк ВБРР АО",
            "logoURL": "https://qr.nspk.ru/proxyapp/logo/bank100000000049.png",
            "schema": "bank100000000049"
        },
                {
            "bankName": "ПАО МОСКОВСКИЙ КРЕДИТНЫЙ БАНК",
            "logoURL": "https://qr.nspk.ru/proxyapp/logo/bank100000000025.png",
            "schema": "bank100000000025"
        },
                {
            "bankName": "RSB+ Банк Русский Стандарт",
            "logoURL": "https://qr.nspk.ru/proxyapp/logo/bank100000000500.png",
            "schema": "bank100000000500"
        },
                {
            "bankName": "АО АБ РОССИЯ",
            "logoURL": "https://qr.nspk.ru/proxyapp/logo/bank100000000095.png",
            "schema": "bank100000000095"
        },
                {
            "bankName": "ДБО Фактура",
            "logoURL": "https://qr.nspk.ru/proxyapp/logo/bank100000000900.png",
            "schema": "bank100000000900"
        },
                {
            "bankName": "АО Россельхозбанк",
            "logoURL": "https://qr.nspk.ru/proxyapp/logo/bank100000000020.png",
            "schema": "bank100000000020"
        },
                {
            "bankName": "АО КБ Хлынов",
            "logoURL": "https://qr.nspk.ru/proxyapp/logo/bank100000000056.png",
            "schema": "bank100000000056"
        },
                {
            "bankName": "Инвестиционный Банк ВЕСТА ООО",
            "logoURL": "https://qr.nspk.ru/proxyapp/logo/bank100000000053.png",
            "schema": "bank100000000053"
        },
                {
            "bankName": "АО ЮниКредит Банк",
            "logoURL": "https://qr.nspk.ru/proxyapp/logo/bank100000000030.png",
            "schema": "bank100000000030"
        },
                {
            "bankName": "АО КБ Солидарность",
            "logoURL": "https://qr.nspk.ru/proxyapp/logo/bank100000000121.png",
            "schema": "bank100000000121"
                },
                {
            "bankName": "АО АЛЬФА-БАНК",
            "logoURL": "https://qr.nspk.ru/proxyapp/logo/bank100000000008.png",
            "schema": "bank100000000008"
                },
                {
            "bankName": "АО Банк ДОМ.РФ",
            "logoURL": "https://qr.nspk.ru/proxyapp/logo/bank100000000082.png",
            "schema": "bank100000000082"
                },
        {
            "bankName": "ООО Хакасский муниципальный банк",
            "logoURL": "https://qr.nspk.ru/proxyapp/logo/bank100000000127.png",
            "schema": "bank100000000127"
                },
        {
            "bankName": "ПАО МТС-Банк",
            "logoURL": "https://qr.nspk.ru/proxyapp/logo/bank100000000017.png",
            "schema": "bank100000000017"
                },
        {
            "bankName": "АО Банк ПСКБ",
            "logoURL": "https://qr.nspk.ru/proxyapp/logo/bank100000000087.png",
            "schema": "bank100000000087"
                },
        {
            "bankName": "Банк Левобережный ПАО",
            "logoURL": "https://qr.nspk.ru/proxyapp/logo/bank100000000052.png",
            "schema": "bank100000000052"
                },
        {
            "bankName": "АО Райффайзенбанк",
            "logoURL": "https://qr.nspk.ru/proxyapp/logo/bank100000000007.png",
            "schema": "bank100000000007"
                },
        {
            "bankName": "ПАО АК БАРС БАНК",
            "logoURL": "https://qr.nspk.ru/proxyapp/logo/bank100000000006.png",
            "schema": "bank100000000006"
                },
        {
            "bankName": "ООО КБ РостФинанс",
            "logoURL": "https://qr.nspk.ru/proxyapp/logo/bank100000000098.png",
            "schema": "bank100000000098"
                },
        {
            "bankName": "ПАО Быстробанк",
            "logoURL": "https://qr.nspk.ru/proxyapp/logo/bank100000000092.png",
            "schema": "bank100000000092"
                },
        {
            "bankName": "АО МС Банк РУС",
            "logoURL": "https://qr.nspk.ru/proxyapp/logo/bank100000000229.png",
            "schema": "bank100000000229"
                },
                {
            "bankName": "АО Кредит Европа Банк Россия",
            "logoURL": "https://qr.nspk.ru/proxyapp/logo/bank100000000027.png",
            "schema": "bank100000000027"
                },
        {
            "bankName": "Тестовое приложение 1",
            "logoURL": "https://qr.nspk.ru/proxyapp/logo/bank100000000998.png",
            "schema": "bank100000000998"
        },
        {
            "bankName": "Тестовое приложение 2",
            "logoURL": "https://qr.nspk.ru/proxyapp/logo/bank100000000999.png",
            "schema": "bank100000000999"
        }

    ]
}
"""
