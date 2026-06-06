package main 

import "core:fmt"
import "core:time"
import "core:strings"
import "core:os"



items: [dynamic]Item
inputPath := "./input.txt"


main :: proc() {

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
    

}





Parser :: struct {
    nameSign : string,
    bodySign : string,
    stringEnclosures : []u8,
    container : [2]u8,
}

Item :: struct {
    name : string,
    bodyString : string,
    bodyTokens : [dynamic]int,
}


ParseText :: proc (toParse : ^string, parser : ^Parser) {
    toSkip : int
    foundName : bool = false;
    foundBody : bool = false;

    for i := 0; i < len(toParse); i += 1 {
        if toParse[i] == parser.nameSign[0] && (i + len(parser.nameSign)) < len(toParse) && !foundName && !foundBody {
            for c := 1; c < len(parser.nameSign); c += 1 {
                foundName = true
                if toParse[i + c] == parser.nameSign[c] { toSkip = c }
                else { foundName = false; break; }
            }

            i += toSkip 
            toSkip = 0
        }

        if foundName {
            stringMarkerID := -1
            for m := 0; m < len(parser.stringEnclosures); m += 1 {
            }
        }
    }
}


















