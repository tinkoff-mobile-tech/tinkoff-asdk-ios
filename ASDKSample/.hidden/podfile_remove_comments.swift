import Foundation

let fileURL = URL(fileURLWithPath: "Podfile")
do {
    var content = try String(contentsOf: fileURL)
    var lines = content.components(separatedBy: "\n")

    var startRange: Int?
    var endRange: Int?

    lines.enumerated().forEach { index, line in
        if line.contains("ASDKSampleTests") {
            startRange = index
        }

        if startRange != nil, endRange == nil, line.contains("end") {
            endRange = index
        }
    }

    guard let startRange, let endRange else {
        exit(1)
    }

    for index in startRange ... endRange {
        if index < lines.count {
            lines[index] = lines[index].replacingOccurrences(of: "#", with: "")
        }
    }

    content = lines.joined(separator: "\n")
    try content.write(to: fileURL, atomically: true, encoding: .utf8)
    print("Changes applied to Podfile.")
} catch {
    print("Error: \(error)")
}
