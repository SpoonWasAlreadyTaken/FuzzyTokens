package main 

import "core:fmt"
import "core:time"
import "core:strings"
import "core:os"
import "core:strconv"



items: [dynamic]Item
inputPath := "./input.txt"


main :: proc() {

    startTime := time.now()

    parser := Parser{
        nameSign = "name:",
        bodySign = "description:",
        stringEnclosures = {'"', '\'', '`'},
        container = {' ', ' '},
    }


    data, err := os.read_entire_file_from_path(inputPath, context.allocator)
    if err != nil { fmt.print("Failed to load file"); return }
    defer delete(data, context.allocator)

    text := string(data)
    strings.to_lower(text)

    ParseText(&text, &parser)
    

    elapsed := time.since(startTime)
    fmt.print("Execution time: ")
    fmt.print(elapsed)
    fmt.print("\nNumber of Items: ")
    fmt.print(len(items))


    fmt.print("\nSelect Item: \n")
    buf := [2048]u8{}
    totalRead, rerr  := os.read(os.stdin, buf[:])
    inputNumber, ok := strconv.parse_int(string(buf[:totalRead]), 10)

    fmt.print("Item nr: ")
    fmt.print(inputNumber)
    fmt.print("\nName: ")
    fmt.print(string(items[inputNumber].name[:]))
    fmt.print("\nBody: ")
    fmt.print(string(items[inputNumber].bodyString[:]))


}





Parser :: struct {
    nameSign : string,
    bodySign : string,
    stringEnclosures : []u8,
    container : [2]u8,
}

Item :: struct {
    name : [dynamic]u8,
    bodyString : [dynamic]u8,
    bodyTokens : [dynamic]int,
}


ParseText :: proc (toParse : ^string, parser : ^Parser) {
    toSkip : int
    foundName : bool = false
    foundBody : bool = false
    hasName : bool = false
    hasBody : bool = false
    
    tempName : [dynamic]u8
    tempBody : [dynamic]u8 
    defer delete(tempName)
    defer delete(tempBody)

    for i := 0; i < len(toParse); i += 1 {
        if toParse[i] == parser.nameSign[0] && (i + len(parser.nameSign)) < len(toParse) && !foundName && !foundBody {
            foundName = true
            for c := 1; c < len(parser.nameSign); c += 1 {
                if toParse[i + c] == parser.nameSign[c] { toSkip = c }
                else { foundName = false; break; }
            }

            i += toSkip
            toSkip = 0
        }

        if toParse[i] == parser.bodySign[0] && (i + len(parser.bodySign)) < len(toParse) && !foundName && !foundBody {
            foundBody = true
            for c := 1; c < len(parser.bodySign); c += 1 {
                if toParse[i + c] == parser.bodySign[c] { toSkip = c }
                else { foundBody = false; break; }
            }

            i += toSkip
            toSkip = 0
        }


        if foundName && !hasName {
            stringMarkerID := -1
            for m := 0; m < len(parser.stringEnclosures); m += 1 {
                if toParse[i] == parser.stringEnclosures[m] {
                    stringMarkerID = m
                    break
                }
            }

            if stringMarkerID > -1 {
                for b := 1; i + b < len(toParse); b += 1 {
                    if toParse[i + b] == parser.stringEnclosures[stringMarkerID] { break }
                    append(&tempName, toParse[i + b])
                    toSkip = b
                }

                i += toSkip
                toSkip = 0
                hasName = true
                foundName = false
            }
        }

        if foundBody && !hasBody {
            stringMarkerID := -1
            for m := 0; m < len(parser.stringEnclosures); m += 1 {
                if toParse[i] == parser.stringEnclosures[m] {
                    stringMarkerID = m
                    break
                }
            }

            if stringMarkerID > -1 {
                for b := 1; i + b < len(toParse); b += 1 {
                    if toParse[i + b] == parser.stringEnclosures[stringMarkerID] { break }
                    append(&tempBody, toParse[i + b])
                    toSkip = b
                }

                i += toSkip
                toSkip = 0
                hasBody = true
                foundBody = false
            }
        }

        if hasName && hasBody {
            hasName = false
            hasBody = false

            append(&items, Item {})

            append(&items[len(items) - 1].name, ..tempName[:])
            append(&items[len(items) - 1].bodyString, ..tempBody[:])
            
            clear(&tempName)
            clear(&tempBody)
        }
    }
}


















