//
//  File.swift
//  
//
//  Created by Colin Wheeler on 6/25/23.
//

import SwiftUI

extension View {

	/// Returns a type erased version of the view.
	public var typeErased: AnyView {
		AnyView(self)
	}
}
