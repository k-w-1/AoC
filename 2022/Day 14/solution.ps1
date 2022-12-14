class solution {
    [System.Collections.ArrayList]$board = @()
    $puzzle_input = @()

    solution() {
        $this.puzzle_input = Get-Content .\input.txt
        #$this.puzzle_input = Get-Content .\test_input.txt
        
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
        write-debug "Minimum x coord is $($x.Minimum), maximum $($x.Maximum)"
        write-debug "Minimum y coord is $($y.Minimum), maximum $($y.Maximum)"
    }

    draw_lines() {
        foreach($line in $this.puzzle_input) {
            
        }
    }
}

#$DebugPreference = 'SilentlyContinue'
#$DebugPreference = 'Continue'

[solution] $solution = [solution]::new()

$solution.characterize()