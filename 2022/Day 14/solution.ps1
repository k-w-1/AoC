class solution {
    $board = @{}
    $board_void
    $puzzle_input = @()
    $sand_ingress = @{}
    $board_x_range = @{}

    solution([array]$y_size, [array]$x_size, $puzzle_input) {
        $this.puzzle_input = Get-Content $puzzle_input
        $range = $x_size | select -first 1 -last 1 | sort
        $this.board_x_range= @{'min' = ($x_size | sort | select -first 1); 'max' = ($x_size | sort | select -last 1)}
        foreach($row in $y_size) {
            $this.board[$row] = @{}
            foreach($pos in $x_size) {  
                [void]$this.board[$row].add($pos, '.')
            }
        }
        #add sand generator
        $this.board[0][500] = '+'
        $this.sand_ingress = @{x=500; y=0}

        $this.board_void = $y_size[-1] + 1
        
    }

    characterize() {
        [System.Collections.ArrayList]$x_points = @()
        [System.Collections.ArrayList]$y_points = @()

        foreach($line in $this.puzzle_input) {
            foreach($pair in ($line -split ' -> ')) {
                $coord = $pair -split ','
                [void]$x_points.add($coord[0])
                [void]$y_points.add($coord[1])
            }
        }
        $x = ($x_points | measure -Maximum -Minimum)
        $y = ($y_points | measure -Maximum -Minimum)
        write-host "Minimum x coord is $($x.Minimum), maximum $($x.Maximum)"
        write-host "Minimum y coord is $($y.Minimum), maximum $($y.Maximum)"
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

    [bool] drop_sand() {
        if($this.board[$this.sand_ingress.y][$this.sand_ingress.x] -eq 'o') {
            #board is full!
            return $false
        }
        $sand_pos = $this.sand_ingress.clone()
        while($true) {
            #Write-Debug "Ingress sand pos: $($sand_pos.y), $($sand_pos.x)"
            if($sand_pos.y+1 -ge $this.board_void) {
                #a unit of sand fell out!
                return $false
            }
            if($sand_pos.x -le $this.board_x_range.min -or $sand_pos.x -ge $this.board_x_range.max) {
                Write-Error "Some sand is about to fall horizontally out of the world! Plz make x bigger."
                return $false
            }

            if($this.board[$sand_pos.y+1][$sand_pos.x] -eq '.') {
                $sand_pos.y++
            } elseif($this.board[$sand_pos.y+1][$sand_pos.x-1] -eq '.') {
                $sand_pos.y++
                $sand_pos.x--
            } elseif($this.board[$sand_pos.y+1][$sand_pos.x+1] -eq '.') {
                $sand_pos.y++
                $sand_pos.x++
            } else {
                Write-Debug "Ingress sand final position: $($sand_pos.y), $($sand_pos.x)"
                $this.board[$sand_pos.y][$sand_pos.x] = 'o'
                return $true
            }
        }
        #to stop PS from complaining
        return $true
    }

}

#$DebugPreference = 'SilentlyContinue'
#$DebugPreference = 'Continue'

#prevent a bad class def from carrying over from a previous run
$solution = $null

if($test_data=$false) {
    if($part_1=$false) {
        [solution] $solution = [solution]::new(0..9, 493..504, ".\test_input.txt")
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
$solution.draw_lines()

Write-debug "Board setup complete; looks like this:"
write-debug ($solution.display_board())
$dropped_sand = 0
while($solution.drop_sand()) {
    $dropped_sand++
}

Write-Host "Dropped $dropped_sand"
$solution.display_board() > board.txt
