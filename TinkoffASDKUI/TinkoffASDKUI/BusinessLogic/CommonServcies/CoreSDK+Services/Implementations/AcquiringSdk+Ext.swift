//
//  AcquiringSdk+Ext.swift
//
//
//  Created by Ivan Glushko on 25.10.2022.
//

import TinkoffASDKCore

extension AcquiringSdk: IAcquiringThreeDSService,
    IAcquiringPaymentsService,
    IAcquiringTinkoffPayService,
    IAcquiringTerminalService,
    IAddCardService,
    ICardService {}
