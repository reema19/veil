//
//  FontsTest.swift
//  VEIL
//
//  Created by reema aljohani on 5/23/26.
//

import SwiftUI

struct FontsTest: View {
    //تركت هذا الملف بس الحين عشان نعرف اسماء الخطوط وننسخ اسهل  بس بعدين نحذفها
    let fonts = [
        "DM Sans",
        "DM Sans Thin",
        "DM Sans Light",
        "DM Sans Medium",
        "DM Sans SemiBold",
        "DM Sans Bold",
        "DM Sans ExtraBold",
        "DM Sans Thin Italic",
        "DM Sans ExtraLight Italic"
    ]
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                
                Text("DM Sans Fonts Test")
                    .font(.system(size: 34, weight: .bold))
                    .padding(.bottom, 10)
                
                ForEach(fonts, id: \.self) { fontName in
                    
                    VStack(alignment: .leading, spacing: 8) {
                        
                        Text(fontName)
                            .font(.caption)
                            .foregroundStyle(.gray)
                        
                        Text("The quick brown fox jumps over the lazy dog")
                            .font(.custom(fontName, size: 26))
                    }
                }
            }
            .padding()
        }
    }
}

#Preview {
    FontsTest()
}
