class solution {
    $board = @{}
    $puzzle_instructions = @()

    [int] dist($a, $b) {
        return([math]::abs($a.y - $b.y) + [math]::abs($a.x - $b.x))
    }

    solution($puzzle_input) {        
        foreach($line in Get-Content $puzzle_input) {
            $points = $line -split ':'
            $sensor = ($points[0].substring(12) -split ', y='| % {[int]::parse($_)})
            $beacon = ($points[1].substring(24) -split ', y='| % {[int]::parse($_)})
            $this.puzzle_instructions += @{
                'sensor' = @{ 'y' = $sensor[1]; 'x' = $sensor[0]};
                'beacon' = @{ 'y' = $beacon[1]; 'x' = $beacon[0]};
                'taxicab_distance' = $this.dist(@{'y' = $sensor[1]; 'x' = $sensor[0]}, @{'y' = $beacon[1]; 'x' = $beacon[0]})
            }

        }        
    }

    [hashtable] part2($y_max, $x_max) {
        $found = $false
        for($y=0; $y -le $y_max -and -not $found; $y++) {
            if($y % 1000 -eq 0) {
                Write-Progress -Activity "Checking points, row $y of $y_max" -PercentComplete ($y/$y_max*100) -Id 1
            }
            for($x=0; $x -le $x_max; $x++) {
                #Write-Progress -Activity "Checking points, col $x of $x_max" -PercentComplete ($x/$x_max*100) -ParentId 1
                $coord_is_in_range = $false
                foreach($instruction in $this.puzzle_instructions) {
                    $dist_to_sensor = $this.dist(@{'y' = $y; 'x' = $x}, $instruction.sensor)
                    if($dist_to_sensor -le $instruction.taxicab_distance) {
                        $coord_is_in_range = $true
                        $x += $instruction.taxicab_distance - $dist_to_sensor

                        #avoid running all other instructions against this point
                        break;
                    }
                }
                if(-not $coord_is_in_range) {
                    return @{'y' = $y; 'x' = $x}
                }
            }
        }
        #stop PS from complaining about maybe no return
        return @{}
    }  

}

#$DebugPreference = 'SilentlyContinue'
#$DebugPreference = 'Continue'

#prevent a bad class def from carrying over from a previous run
$solution = $null

if($test_data=$false) {
    $y_max = 20
    $x_max = 20
    [solution] $solution = [solution]::new(".\test_input.txt")        
} else {
    $y_max = 4000000
    $x_max = 4000000
    [solution] $solution = [solution]::new(".\input.txt")
}

$unmonitored_position = $solution.part2($y_max, $x_max)

Write-Host "Solution was $($unmonitored_position.y),$($unmonitored_position.x); aka $($unmonitored_position.x * 4000000 + $unmonitored_position.y)"
