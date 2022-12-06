$lines = Get-Content .\test_input.txt

$board = ,@() * $lines.size

$board = @(foreach($line in $lines) {
    [Collections.ArrayList]@(,$line.ToCharArray())
})

function DisplayBoard {
    $width = [int]($original_board[0].Length/2)
    Write-Output (('=' * $width) + "OG" + ('='*($original_board[0].Length - $width)))
    foreach($row in $original_board) {
        write-output "|$($row -join '')|"
    }
    Write-Output (('=' * $width) + "New" + ('='*($original_board[0].Length - $width -1)))
    foreach($row in $board) {
        write-output "|$($row -join '')|"
    }
    Write-Output ('=' * ($original_board[0].Length + 2))
}

$original_board = @()
$original_board += $board;
#process east moving
for($y=0; $y -le $board.Length-1; $y++) {
    for($x=0; $x -le $board[$y].Length-1; $x++) {
        Write-Debug "Checking at [$y][$x] ($($original_board[$y][$x]))"
        if($original_board[$y][$x] -eq '>') {
            if($x -eq $original_board[$y].Length-1) { #look around the corner
                Write-Debug "Looking ardound the edge [$y][0] ($($original_board[$y][0]))"
                if($original_board[$y][0] -eq '.') { #free space
                    Write-Debug "Moving [$y][$x]($($original_board[$y][$x])) to [$y][0]($($original_board[$y][0]))"
                    $board[$y][$x] = '.'
                    $board[$y][0] = '>'
                }
            } else {
                if($original_board[$y][$x+1] -eq '.') { #free space
                    Write-Debug "Moving [$y][$x]($($original_board[$y][$x])) to [$y][$($x+1)]($($original_board[$y][$x+1]))"
                    $board[$y][$x] = '.'
                    $board[$y][$x+1] = '>'
                } else {
                    Write-Debug "Not moving [$y][$x]($($original_board[$y][$x])) because [$y][$($x+1)]($($original_board[$y][$x+1]))"
                }

            }
        }
    }
}

DisplayBoard
#process south moving
$original_board = @()
$original_board += $board;
for($y=0; $y -le $board.Length-1; $y++) {   
    for($x=0; $x -le $board[$y].Length-1; $x++) {
        Write-Debug "Checking at [$y][$x] ($($original_board[$y][$x]))"
        if($original_board[$y][$x] -eq 'v') {
            if($y -eq $board.Length-1) { #look around the corner
                Write-Debug "Looking ardound the edge [0][$x] ($($original_board[0][$x]))"
                if($original_board[0][$x] -eq '.') { #free space
                    Write-Debug "Moving [$y][$x] to [0][$x]"
                    $board[$y][$x] = '.'
                    $board[0][$x] = 'v'
                }
            } else {
                if($original_board[$y+1][$x] -eq '.') { #free space
                    Write-Debug "Moving [$y][$x]($($original_board[$y][$x])) to [$($y+1)][$x]($($original_board[$y+1][$x]))"
                    $board[$y][$x] = '.'
                    $board[$y+1][$x] = 'v'
                } else {
                    Write-Debug "Not moving [$y][$x]($($original_board[$y][$x])) because [$($y+1)][$x]($($original_board[$y+1][$x]))"
                }

            }
        }
    }
}

DisplayBoard

