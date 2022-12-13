if($DebugPreference -eq 'SilentlyContinue') {
    $input = Get-Content .\input.txt
} else {
    $input = Get-Content .\test_input.txt
}

$board = @(foreach($line in $input) {
    @(,$line.toCharArray())
})
$origin_x = $origin_y = $end_x = $end_y = $null

#find start pos
for($y=0; $y -lt $board.Length-1; $y++) {
    for($x=0; $x -lt $board[0].Length-1; $x++) {
        if($board[$y][$x] -ceq 'S') {
            Write-Debug "Origin found at $y,$x"
            $origin_x = $x
            $origin_y = $y
        } elseif($board[$y][$x] -ceq 'E') {
            Write-Debug "End found at $y,$x"
            $end_x = $x
            $end_y = $y
        }
    }
}

#just to make the below code a little cleaner
$board[$origin_y][$origin_x] = 'a'
$board[$end_y][$end_x] = '{' # '{' happens to be [int]([char]'z')+1
$max_steps = 500
if($part_two_solution = $true) {
    $origin_y = 18 #looking at the data, this is the only one that could possibly be better
}

[System.Collections.ArrayList] $paths = @(
    @{'path' = [System.Collections.ArrayList] @(@{'y' = $origin_y; 'x' = $origin_x});
        'dead_end' = $false}
)
[System.Collections.ArrayList] $visited_pos = @("000000") #add 0,0

$not_solved = $true
$step_count = 0
while($not_solved -and ($step_count -lt $max_steps)) {
    #by grabbing this separately, it won't get modified as we play with $paths for this loop
    Write-Progress -Activity "Running step $step_count" -Id 1 -PercentComplete ($step_count/$max_steps*100)
    $paths_to_check = ($paths | where {$_.dead_end -ne $true})
    Write-Debug "Running step $step_count, checking $($paths_to_check.count) paths"
    $paths_checked = 0
    foreach($path in $paths_to_check) {
        Write-Progress -Activity "Checking $paths_checked of $($paths_to_check.count)" -ParentId 1 -PercentComplete ($paths_checked/$paths_to_check.count*100)
        $paths_checked++
        #confirm directions to look
        $current_pos = $path.path[-1]
        $positions_to_look = [System.Collections.ArrayList] @()
        if($current_pos.y -eq 0) { 
            [void]$positions_to_look.add(@{'y' = 1; 'x' = $current_pos.x})
        } elseif($current_pos.y -eq $board.Length-1) {
            [void]$positions_to_look.add(@{'y' = $current_pos.y-1; 'x' = $current_pos.x})
        } else {
            [void]$positions_to_look.add(@{'y' = $current_pos.y-1; 'x' = $current_pos.x})
            [void]$positions_to_look.add(@{'y' = $current_pos.y+1; 'x' = $current_pos.x})
        }
        if($current_pos.x -eq 0) {
            [void]$positions_to_look.add(@{'y' = $current_pos.y; 'x' = 1})
        } elseif($current_pos.x -eq $board[0].Length-1) {
            [void]$positions_to_look.add(@{'y' = $current_pos.y; 'x' = $current_pos.x-1})
        } else {
            [void]$positions_to_look.add(@{'y' = $current_pos.y; 'x' = $current_pos.x-1})
            [void]$positions_to_look.add(@{'y' = $current_pos.y; 'x' = $current_pos.x+1})
        }
        Write-Debug ("`tCurrent pos [$($current_pos.y),$($current_pos.x)]($($board[$current_pos.y][$current_pos.x])), looking at [" + (@(foreach($pos in $positions_to_look){ "$($pos.y),$($pos.x)"}) -join '][') + ']')
        $current_level = [int]([char]$board[$current_pos.y][$current_pos.x])
        if($current_level -eq [int]([char]'{')) {
            Write-Output "Found end after $step_count steps!"
            $not_solved = $false
            break
        }
        $add_path = $false
        foreach($pos in $positions_to_look) {
            #yup, this is hacky... but it works, and it's high performance :)
            #check if on 'n', then look everywhere
            if((($current_level -eq [int]([char]'n')) -and ([int]([char]$board[$pos.y][$pos.x]) -le $current_level+1)) -or `
            #otherwise only look at equal to current or +1
            (([int]([char]$board[$pos.y][$pos.x]) -eq $current_level) -or (([int]([char]$board[$pos.y][$pos.x]) -eq $current_level+1)))) {
                if(("{0:d3}{1:d3}" -f $pos.y, $pos.x) -notin $visited_pos) {
                    if(-not $add_path) {
                        Write-Debug "`t`tFound valid path from [$($current_pos.y),$($current_pos.x)]($($board[$current_pos.y][$current_pos.x])) to [$($pos.y),$($pos.x)]($($board[$pos.y][$pos.x])); adding to current path"
                        [void]$path.path.add(@{'y' = $pos.y; 'x' = $pos.x })
                        [void]$visited_pos.add(("{0:d3}{1:d3}" -f $pos.y, $pos.x))
                        $add_path = $true
                    } else {
                        Write-Debug "`t`tFound additional valid path from [$($current_pos.y),$($current_pos.x)]($($board[$current_pos.y][$current_pos.x])) to [$($pos.y),$($pos.x)]($($board[$pos.y][$pos.x])); adding to new path"
                        $new_path_index = $paths.add(@{'path' = [System.Collections.ArrayList] @(); 'dead_end' = $false})
                        foreach($step in $path.path) { #PS, why u no like deep copying???
                            [void]$paths[$new_path_index].path.add(@{'y' = $step.y; 'x' = $step.x })
                        }
                        [void]$paths[$new_path_index].path.add(@{'y' = $pos.y; 'x' = $pos.x })
                        [void]$visited_pos.add(("{0:d3}{1:d3}" -f $pos.y, $pos.x))
                    }
                }
            }

        }
        #if no paths found, mark this path as dead end
        if(-not $add_path) {
            Write-Debug "`t`tNo valid paths from here, marking as dead end."
            $path.dead_end = $true
        }
    }
    $step_count++
}
