//
//  AcquiringSdk+Ext.swift
//
//
//  Created by Ivan Glushko on 25.10.2022.
//

import TinkoffASDKCore

protocol IAcquiringSdk: IAcquiringThreeDSService,
    IAcquiringPaymentsService,
    IAcquiringTinkoffPayService,
    IAcquiringTerminalService,
    IAcquiringSBPService,
    IAddCardService,
    ICardService {}

extension AcquiringSdk: IAcquiringSdk {}
