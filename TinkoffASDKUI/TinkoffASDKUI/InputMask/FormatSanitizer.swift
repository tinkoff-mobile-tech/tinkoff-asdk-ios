//
//

import Foundation

class FormatSanitizer {
    func sanitize(formatString string: String) throws -> String {
        try checkOpenBraces(string)
        let blocks: [String] = divideBlocksWithMixedCharacters(getFormatBlocks(string))
        return sortFormatBlocks(blocks).joined(separator: "")
    }
}

private extension FormatSanitizer {
    func checkOpenBraces(_ string: String) throws {
        var squareBraceOpen = false
        for char in string {
            if char == "[" {
                if squareBraceOpen {
                    throw InputMaskBuilder.InputMaskBuildError.wrongFormat
                }
                squareBraceOpen = true
            }

            if char == "]" {
                squareBraceOpen = false
            }
        }
    }

    func getFormatBlocks(_ string: String) -> [String] {
        var blocks: [String] = []
        var currentBlock = ""

        for char in string {
            if char == "[" {
                if currentBlock.count > 0 {
                    blocks.append(currentBlock)
                }

                currentBlock = ""
            }

            currentBlock += String(char)

            if char == "]" {
                blocks.append(currentBlock)
                currentBlock = ""
            }
        }

        if !currentBlock.isEmpty {
            blocks.append(currentBlock)
        }

        return blocks
    }

    func divideBlocksWithMixedCharacters(_ blocks: [String]) -> [String] {
        var resultingBlocks: [String] = []

        for block in blocks {
            if block.hasPrefix("[") {
                var blockBuffer: String = ""
                for blockCharacter in block {
                    if blockCharacter == "[" {
                        blockBuffer += String(blockCharacter)
                        continue
                    }

                    if blockCharacter == "]" {
                        blockBuffer += String(blockCharacter)
                        resultingBlocks.append(blockBuffer)
                        break
                    }

                    if blockCharacter == "0" {
                        blockBuffer += "]"
                        resultingBlocks.append(blockBuffer)
                        blockBuffer = "[" + String(blockCharacter)
                        continue
                    }

                    blockBuffer += String(blockCharacter)
                }
            } else {
                resultingBlocks.append(block)
            }
        }

        return resultingBlocks
    }

    func sortFormatBlocks(_ blocks: [String]) -> [String] {
        var sortedBlocks: [String] = []

        for block in blocks {
            var sortedBlock: String
            if block.hasPrefix("[") {
                if block.contains("0") {
                    sortedBlock = sortBlock(block: block)
                } else {
                    sortedBlock =
                        "["
                            + String(block
                                .replacingOccurrences(of: "[", with: "")
                                .replacingOccurrences(of: "]", with: "")
                                .sorted()
                            )
                            + "]"
                }
            } else {
                sortedBlock = block
            }

            sortedBlocks.append(sortedBlock)
        }

        return sortedBlocks
    }

    private func sortBlock(block: String) -> String {
        return
            "["
                + String(block
                    .replacingOccurrences(of: "[", with: "")
                    .replacingOccurrences(of: "]", with: "")
                    .sorted()
                )
                + "]"
    }
}
