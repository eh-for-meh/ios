//
//  LoadingView.swift
//  meh.com
//
//  Created by Kirin Patel on 8/9/19.
//  Copyright © 2019 Kirin Patel. All rights reserved.
//

import SwiftUI

struct LoadingView: View {
    var body: some View {
        Text("eh for meh")
            .font(Font.largeTitle)
    }
}

#if DEBUG
struct LoadingView_Previews: PreviewProvider {
    static var previews: some View {
        LoadingView()
    }
}
#endif
