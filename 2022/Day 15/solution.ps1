class solution {
    $board = @{}
    $puzzle_input = @()

    solution([array]$y_size, [array]$x_size, $puzzle_input) {
        $this.puzzle_input = Get-Content $puzzle_input
        $range = $x_size | select -first 1 -last 1 | sort
        foreach($row in $y_size) {
            $this.board[$row] = @{}
            foreach($pos in $x_size) {  
                [void]$this.board[$row].add($pos, '.')
            }
        }
        
    }

    characterize() {
        [System.Collections.ArrayList]$x_points = @()
        [System.Collections.ArrayList]$y_points = @()

        #Sensor at x=2, y=18: closest beacon is at x=-2, y=15

        foreach($line in $this.puzzle_input) {
            $points = $line -split ':'
            $sensor = @($points[0].substring(12) -split ', y=')
            [void]$x_points.add($sensor[0])
            [void]$y_points.add($sensor[1])
            $beacon = @($points[1].substring(24) -split ', y=')
            [void]$x_points.add($beacon[0])
            [void]$y_points.add($beacon[1])
            
        }
        $x = ($x_points | measure -Maximum -Minimum -Average)
        $y = ($y_points | measure -Maximum -Minimum -Average)
        write-host "Minimum x coord is $($x.Minimum), maximum $($x.Maximum), average $($x.Average) (a range of $($x.Maximum - $x.Minimum))"
        write-host "Minimum y coord is $($y.Minimum), maximum $($y.Maximum), average $($x.Average) (a range of $($x.Maximum - $x.Minimum))"
    }

    draw_lines() {
        foreach($line in $this.puzzle_input) {
            $points = $line -split ' -> '
            foreach($z in 1..($points.count-1)) {
                $point = ($points[$z] -split ','| % {[int]::parse($_)})    
                $prev_point = ($points[$z-1] -split ','| % {[int]::parse($_)})    

                Write-Debug "Drawing line from $($prev_point -join ',') to $($point -join ',')"
                    
                foreach($y in ($point[1]..$prev_point[1])) {
                    foreach($x in ($point[0]..$prev_point[0])) {
                        #Write-Debug "Marking at y:$y, x:$x"
                        $this.board[$y][$x] = '#'
                    }
                }

            }
        }
    }

    [string] display_board() {
        $output = ""
        foreach($row in ($this.board.keys | sort )) {
            #ordered lists are hard =P
            $output += ($this.board[$row][($this.board[$row].keys | sort)] -join '')+"`n"
        }
        return $output
    }
}

#$DebugPreference = 'SilentlyContinue'
#$DebugPreference = 'Continue'

#prevent a bad class def from carrying over from a previous run
$solution = $null

if($test_data=$true) {
    if($part_1=$true) {
        [solution] $solution = [solution]::new(0..9, 493..504, ".\test_input.txt")
        $solution.characterize()
    } else {
        $x_range = (493-10)..(504+10)
        $y_max = 11
        [solution] $solution = [solution]::new(0..$y_max, $x_range, ".\test_input.txt")

        $solution.board[$y_max+1] = @{}
        foreach($pos in $x_range) {  
            $solution.board[$y_max+1].add($pos, '.')
        }
        $solution.board[$y_max+2] = @{}
        foreach($pos in $x_range) {  
            $solution.board[$y_max+2].add($pos, '#')
        }

        $solution.board_void += 2
        
    }
} else {
    if($part_1=$false) {
        [solution] $solution = [solution]::new(0..169, 439..522, ".\input.txt")
    } else {
        
        $x_range = (439-150)..(522+160)
        $y_max = 169
        [solution] $solution = [solution]::new(0..$y_max, $x_range, ".\input.txt")


        $solution.board[$y_max+1] = @{}
        foreach($pos in $x_range) {  
            $solution.board[$y_max+1].add($pos, '.')
        }
        $solution.board[$y_max+2] = @{}
        foreach($pos in $x_range) {  
            $solution.board[$y_max+2].add($pos, '#')
        }

        $solution.board_void += 2

    }
}
#$solution.characterize()

#Write-debug "Board setup complete; looks like this:"
#write-debug ($solution.display_board())

#Write-Host "Dropped $dropped_sand"
#$solution.display_board() > board.txt
