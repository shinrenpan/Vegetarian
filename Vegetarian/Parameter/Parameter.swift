//
// Copyright (c) 2020 shinren.pan@gmail.com All rights reserved.
//

import Foundation

struct Parameter {

    static let TotalItems = URL(string: "https://raw.githubusercontent.com/shinrenpan/VegetarianMap/master/data/All_City_Map.geojson")!

    static let BugReport = URL(string: "https://api.github.com/repos/shinrenpan/VegetarianMap/issues")!

    static let AdMobUID = ""
    
    static let GitHubToken = ""

    static func Suggestion(_ type: SuggestionViewModel.SuggestionType) -> URL {
        switch type {
        case .suggestion:
            return URL(string: "https://api.github.com/repos/shinrenpan/Vegetarian/issues")!
        case .new:
            return URL(string: "https://api.github.com/repos/shinrenpan/VegetarianMap/issues")!
        }
    }

    static func Google(_ item: MapItem) -> URL {
        let str = "https://www.google.com/search?q=\(item.properties.name)+\(item.properties.address)"
            .addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!

        return URL(string: str)!
    }

    static func GoogleMap(_ item: MapItem) -> URL {
        let str = "comgooglemaps://?q=\(item.properties.address)"
            .addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!

        return URL(string: str)!
    }
}
