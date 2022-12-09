#prevent bad class def from giving red herrings if it doesn't get created (and then uses the object from the previous run)
$board = $null
#set as req'd...
$DebugPreference = 'silentlycontinue'
#test(f) or prod(t)?
if($true) {
    $input = Get-Content .\input.txt
    [board] $board = [board]::new(10, 500, 500, 350,250)
} else {
    $input = Get-Content .\test_input2.txt
    [board] $board = [board]::new(10, 22,27, 6,12)
}

class board {
    $board
    $x_origin
    $y_origin
    [hashtable[]]$rope

    #constructor
    board([int]$rope_size, [int]$board_y_size, [int]$board_x_size, [int]$y_origin, [int]$x_origin) {
        $this.board = @(foreach($x in 0..$board_y_size) {
            ,@( , '.' * $board_x_size)
        })
        $this.x_origin = $x_origin
        $this.y_origin = $y_origin
        #initialize rope with origin etc
        for($z = 0; $z -lt $rope_size; $z++) {
            $this.rope += @{'y' = $y_origin; 'x' = $x_origin; 'under' = 'S'}
        }
        $this.rope[$rope_size-1]['under'] = '#' #tail leaves behind a hash
        $this.board[$this.y_origin][$this.x_origin] = 'B'
    }

    [string]RenderBoard() {
        $output = "`n"
        foreach($line in $this.board[-1..-$this.board.Length]) { #board[...] stuff runs through it in reverse
            $output += $line -join ''
            $output += "`n"
        }
        return $output
    }

    [void] move($instruction) {
        Write-Debug "Processing move $instruction"
        $instruction = $instruction -split ' '
        for($x=0; $x -lt $instruction[1]; $x++) {
            #restore stuff underneath rope & mark travelled
            foreach($knot in $this.rope) {
                $this.board[$knot.y][$knot.x] = $knot.under
            }
            #move head
            switch($instruction[0]) {
                'R' { $this.rope[0].x++ }
                'L' { $this.rope[0].x-- }
                'U' { $this.rope[0].y++ }
                'D' { $this.rope[0].y-- }
            }

            #calculate remaining knot moves
            for($z = 1; $z -lt $this.rope.Length; $z++) {
                $x_delta = $this.rope[$z-1].x - $this.rope[$z].x
                $y_delta = $this.rope[$z-1].y - $this.rope[$z].y
                if(([math]::abs($x_delta) + [math]::abs($y_delta)) -gt 2) { #a diagnoal is req'd
                    $this.rope[$z].x += $x_delta/[math]::abs($x_delta) #only move one space in the correct direction
                    $this.rope[$z].y += $y_delta/[math]::abs($y_delta) #only move one space in the correct direction
                } else {
                    #in same row or col, move only one directionality
                    if([math]::abs($x_delta) -gt 1) {
                        $this.rope[$z].x += $x_delta/[math]::abs($x_delta) #only move one space in the correct direction
                    } elseif([math]::abs($y_delta) -gt 1) {
                        $this.rope[$z].y += $y_delta/[math]::abs($y_delta) #only move one space in the correct direction
                    }
                }
            }
            #store new unders (except tail)
            for($z = 0; $z -lt $this.rope.Length-1; $z++) {
                $this.rope[$z].under = $this.board[$this.rope[$z].y][$this.rope[$z].x]
            }
            #place knots
            for($z = 0; $z -lt $this.rope.Length; $z++) {
                $this.board[$this.rope[$z].y][$this.rope[$z].x] = $z
            }
            #(re)mark origin
            $this.board[$this.y_origin][$this.x_origin] = 'S'
            if($script:DebugPreference -ieq 'Continue') {
                #
                # AoC: Adventures of Coding AoC - Ep 2:
                #
                # So, as you can see, IDGAF about code optimization, because as my good friend Greg (https://github.com/G-regL/AdventOfCode)
                # pointed out (but I didn't fully appreciate at the time), this /isn't/ code golf. Just answering, and quickly, is what
                # matters. Anyway, the first prod data run I did, I actually thought it was infinite looping since it took *FOREVER* to
                # run. I poked and prodded, and nil. Then I got to wonder, what if PS is like some other things and even if write-debug 
                # isn't going to stdout, perhaps it still runs the code anyway? I had a feeling RenderBoard() was expensive; PS seems to 
                # stutter when outputting swaths of text in my experience. Lo and behold; wrapping this in an explicit check to see if
                # debug is on improved performance by at least an order of magnitude. I had even been running it until the rope hit an
                # out-of-bounds error, then piping the board out to a text file, and using Notepad++ to zoom out and be able to visualize 
                # it and tweak the board size + origin to get the minimum board size (which definately was affecting the perf). After
                # making this change (nb: I couldn't get the scope prefix ("script:") part just right to use whatever I had just manually 
                # entered into the console, so I just decided to hardcode it which made the script: scope work as intended) I was able to
                # just make an arbitrarily large board, and it still was able to do the full 2k instructions in ~15s. Prior to the 'if', it
                # was taking >100s!
                #
                # tl;dr: Warning: write-debug does stuff even when you're not debugging!
                #
                Write-Debug ($this.RenderBoard())
            }
        }
    }
    
    [int]calculate_touched_spaces() {
        #replace previous knot unders & mark tail as travelled
        foreach($knot in $this.rope) {
            $this.board[$knot.y][$knot.x] = $knot.under
        }
        $this.board[$this.y_origin][$this.x_origin] = '#'
        $sum = 0
        foreach($row in $this.board) {
            $sum += $row | group | Where-Object {$_.name -eq '#'} | select -ExpandProperty count 
        }
        return $sum
    }
}


Write-Debug ($board.RenderBoard())
$instruction_num = 0
foreach($line in $input) {
    if($script:DebugPreference -ieq 'SilentlyContinue') {
        Write-Progress -Activity "Processing instructions" -Status "Processing instruction $instruction_num of $($input.Count)" -PercentComplete (($instruction_num/$input.Count)*100)
    }
    $board.move($line)     
    $instruction_num++
}


Write-Output "Number of touched spaces: $($board.calculate_touched_spaces())"

Write-Debug "Final board layout:"
if($DebugPreference -ieq 'Continue') {
    Write-Debug ($board.RenderBoard())
}