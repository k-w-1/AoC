class solution {
    $board = @{}
    $puzzle_instructions = @()
    $worst_x_min_oob = $null
    $worst_x_max_oob = $null
    $filled_ranges = @{}

    solution($puzzle_input) {        
        foreach($line in Get-Content $puzzle_input) {
            $points = $line -split ':'
            $sensor = ($points[0].substring(12) -split ', y='| % {[int]::parse($_)})
            $beacon = ($points[1].substring(24) -split ', y='| % {[int]::parse($_)})
            $this.puzzle_instructions += @{
                'sensor' = @{ 'y' = $sensor[1]; 'x' = $sensor[0]};
                'beacon' = @{ 'y' = $beacon[1]; 'x' = $beacon[0]};
                'taxicab_distance' = [bigint]([math]::abs($sensor[1] - $beacon[1]) + [math]::abs($sensor[0] - $beacon[0]))
            }

        }        
    }

    init_board([array]$y_size, [array]$x_size) {
        $step = 0
        foreach($row in $y_size) {
            $step++
            #Write-Progress -Activity "Initializing board, row $step of $($y_size.count)" -PercentComplete ($step/$y_size.count*100) -Id 1
            $this.board[$row] = @{}
            $sub_step = 0
            foreach($pos in $x_size) {  
                $sub_step++
                if($sub_step % 100000 -eq 0) {
                    #Write-Progress -Activity "Initializing pos $sub_step of $($x_size.count)" -PercentComplete ($sub_step/$x_size.count*100) -ParentId 1
                }
                [void]$this.board[$row].add($pos, '.')
            }
        }
        Write-Debug "Finished board init"
    }
    characterize() {
        $x = (($this.puzzle_instructions.sensor.x + $this.puzzle_instructions.beacon.x) | measure -Maximum -Minimum -Average)
        $y = (($this.puzzle_instructions.sensor.y + $this.puzzle_instructions.beacon.y)  | measure -Maximum -Minimum -Average)
        write-host "Minimum x coord is $($x.Minimum), maximum $($x.Maximum), average $([int]$x.Average) (a range of $($x.Maximum - $x.Minimum))"
        write-host "Minimum y coord is $($y.Minimum), maximum $($y.Maximum), average $([int]$y.Average) (a range of $($y.Maximum - $y.Minimum))"
        write-host "Maximum taxicab distance is $(($this.puzzle_instructions.taxicab_distance | measure -Maximum).Maximum)"
    }

    edit_board($y, $x, $newval) {
        if($y -notin $this.board.keys) {
            Write-Debug "Skipping drawing '$newval' at $y,$x as it is OoB"
        } elseif($x -notin $this.board[$y].keys) {
            if($x -lt ($this.board[$y].keys | measure -Minimum).Minimum ) {
                if($x -lt $this.worst_x_min_oob) {
                    $this.worst_x_min_oob = $x
                }
            } else {
                if($x -gt $this.worst_x_max_oob) {
                    $this.worst_x_max_oob = $x
                }
            }
            Write-Error ("Board x range is too small! trying to draw '$newval' at $y,$x`n" + `
                        "Please set the board bound to at least $($this.worst_x_min_oob) to $($this.worst_x_max_oob)")
        } else {
            $this.board[$y][$x] = $newval
        }
    }

    draw_sensors_and_beacons() {
        foreach($instruction in $this.puzzle_instructions) {
            $this.edit_board($instruction.sensor.y, $instruction.sensor.x, 'S')
            $this.edit_board($instruction.beacon.y, $instruction.beacon.x, 'B')
        }
    }

    draw_coverage() {
        $this.draw_coverage($false)
    }

    draw_coverage($check_bounds) {
        $num_sensors = $this.puzzle_instructions.count
        $step = 0
        foreach($instruction in $this.puzzle_instructions) {
            #Write-Progress -Activity "Processing sensor $step of $num_sensors" -PercentComplete ($step/$num_sensors*100)
            if($check_bounds) {
                if($instruction  )
            }
            foreach($y in -$instruction.taxicab_distance..$instruction.taxicab_distance) {
                $x_distance_this_row = $instruction.taxicab_distance-[math]::abs($y)
                foreach($x in (-$x_distance_this_row)..$x_distance_this_row) {
                    $this.edit_board($y+$instruction.sensor.y, $x+$instruction.sensor.x, '#')
                }
            }

        }
    }

    draw_selective_coverage($y) {
        $num_sensors = $this.puzzle_instructions.count
        $step = 0
        foreach($instruction in $this.puzzle_instructions) {
            Write-Progress -Activity "Processing sensor $step of $num_sensors" -PercentComplete ($step/$num_sensors*100)

            $taxicab_distance_on_this_row = [bigint]($instruction.taxicab_distance - [math]::abs(($y - $instruction.sensor.y)))
            if($taxicab_distance_on_this_row -gt 0) {  #if -lt 0, means it didn't touch this row (y)
                $this.filled_ranges[[bigint]$instruction.sensor.x-$taxicab_distance_on_this_row] `
                                 =[bigint]$instruction.sensor.x+$taxicab_distance_on_this_row
            }
        }

        $consolidation_cycles = 0
        while($consolidation_cycles -lt $this.filled_ranges.count-1){
            Write-Debug "Conslolidation cycle $consolidation_cycles : $($this.filled_ranges.Count) ranges."
            $index_of_smallest = $this.filled_ranges.keys | sort | select -skip $consolidation_cycles -First 1
            $indexes_to_remove = $this.filled_ranges.keys | where {$_ -lt $this.filled_ranges[$index_of_smallest]} | sort | select -Skip 1
            Write-Debug "Checking $index_of_smallest; found that rows $($indexes_to_remove -join ', ') all start before it's end $($this.filled_ranges[$index_of_smallest])"
            if($indexes_to_remove.Count -ne 0) {
                $this.filled_ranges[$index_of_smallest] = $this.filled_ranges[$indexes_to_remove] | sort | select -Last 1
                $indexes_to_remove | % {$this.filled_ranges.Remove($_)}
            }
            $consolidation_cycles++
        }

    }

    [string] display_board() {
        $output = ""
        foreach($row in ($this.board.keys | sort )) { #ordered lists are hard =P
            #8 spaces to leave room for a possible sign
            $output += ("{0,8} " -F $row) + ($this.board[$row][($this.board[$row].keys | sort)] -join '')+"`n"
        }
        return $output
    }
}

#$DebugPreference = 'SilentlyContinue'
#$DebugPreference = 'Continue'

#prevent a bad class def from carrying over from a previous run
$solution = $null

if($test_data=$false) {
    if($part_1=$true) {
        [solution] $solution = [solution]::new(".\test_input2.txt")
        $solution.characterize()
        $solution.init_board(-11..33, -15..40)
        $solution.draw_coverage()
        $solution.draw_sensors_and_beacons()
        write-output $solution.display_board()
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
        [solution] $solution = [solution]::new(".\input.txt")
        $solution.characterize()
        #$solution.init_board((134640-1287797)..(3998032+1287797), (-532461-1510495)..(3999024+1510495))
        $interesting_row = 2000000
        #$solution.init_board(@($interesting_row), (-532461-1756807)..(3999024+1756807))
        $solution.init_board(@($interesting_row), (-532461-1756807)..(3999024+1756807))
        $solution.draw_selective_coverage($interesting_row)
        #$solution.draw_sensors_and_beacons()
        #write-output $solution.display_board()
    } else {
        
        [solution] $solution = [solution]::new(".\input.txt")

    }
}
