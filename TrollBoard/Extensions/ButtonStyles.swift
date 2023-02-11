//
//  ButtonStyle.swift
//  TrollBoard
//
//  Created by Анохин Юрий on 03.02.2023.
//

import SwiftUI

// fancy
public struct ApplyButtonStyle: ButtonStyle {
    public func makeBody(configuration: Self.Configuration) -> some View {
        configuration.label
            .font(Font.body.weight(.medium))
            .padding(.vertical, 12)
            .foregroundColor(Color.accentColor)
            .frame(maxWidth: 75)
            .background(
                RoundedRectangle(cornerRadius: 10.0, style: .continuous)
                    .fill(Color.accentColor)
                    .opacity(0.1)
            )
            .opacity(configuration.isPressed ? 0.4 : 1.0)
    }
}
