$moves = @()
$board = New-Object string[] 10 #cheating a bit here since we know the max size; $board[0] is null

foreach($line in Get-Content .\input.txt) {
    if($line -eq '') {
        #skip blank lines
    } elseif($line.substring(0,4) -eq "move") {
        #move info
        $moves += $line
    } else {
        #assuming board layout
        Write-Debug "Parsing cargo line [$line]"
        $cargo = $line -split '(....)' -ne ''
        for($x=1; $x -le $cargo.Length;$x++) {
            if($cargo[$x-1] -ne ' ' -and $cargo[$x-1] -match "[A-Z]" ) { #ignore empty cargo and numbers
                $board[$x] = $cargo[$x-1][1] + $board[$x] #extra [1] will grab just the letter/number
            }
        }
    }
}
$board2 = @()
$board2 += $board #full copy

foreach($move in $moves) {
    write-debug "Board:"
    $board |out-string -stream| write-debug
    $move = $move -split ' ' 
    $cargo_to_move = $board[$move[3]].Substring($board[$move[3]].Length - $move[1]) #when the last char is omitted, substr will go to the end
    Write-Debug "Moving $($move[1]) cargo [$cargo_to_move] from $($move[3]) to $($move[5])"    
    $board[$move[5]] += [string]($cargo_to_move[-1..-$cargo_to_move.Length] -join '')
    #remove cargo from original stack
    $board[$move[3]] = $board[$move[3]].Substring(0, $board[$move[3]].Length - $move[1])
}

write-debug "Board:"
$board |out-string -stream| write-debug

Write-Output "Top cargo for each stack (solution 1):"
$output = ""
foreach($cargo in $board) {
    if($cargo -ne $null) { #since 0 is null (and possibly others when stacks <9)
        $output += $cargo[-1]
    }
}
Write-Output $output

foreach($move in $moves) {
    write-debug "Board 2:"
    $board2 |out-string -stream| write-debug
    $move = $move -split ' ' 
    $cargo_to_move = $board2[$move[3]].Substring($board2[$move[3]].Length - $move[1]) #when the last char is omitted, substr will go to the end
    Write-Debug "Moving $($move[1]) cargo [$cargo_to_move] from $($move[3]) to $($move[5])"    
    $board2[$move[5]] += $cargo_to_move
    #remove cargo from original stack
    $board2[$move[3]] = $board2[$move[3]].Substring(0, $board2[$move[3]].Length - $move[1])
}

write-debug "Board 2:"
$board2 |out-string -stream| write-debug

Write-Output "Top cargo for each stack (solution 2):"
$output = ""
foreach($cargo in $board2) {
    if($cargo -ne $null) { #since 0 is null (and possibly others when stacks <9)
        $output += $cargo[-1]
    }
}
Write-Output $output