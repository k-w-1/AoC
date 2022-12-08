if($DebugPreference -eq 'SilentlyContinue') {
    $input = Get-Content .\input.txt
} else {
    $input = Get-Content .\test_input.txt
}

$visible_trees = ($input.Length + $input[0].Length - 2) * 2 #all the exterior trees

for($y=1; $y -lt $input.Length-1; $y++) {
    for($x=1; $x -lt $input[$y].Length-1; $x++) {
        Write-Debug "Looking at tree [$y][$x] ($($input[$y][$x])):"
        $current_tree_hidden = $false
        for($z=0; $z -lt $y; $z++) { #above
            if($input[$z][$x] -ge $input[$y][$x]) {
                Write-Debug "`tComparing (above) with [$z][$x] ($($input[$z][$x])): hidden!"
                $current_tree_hidden = $true
                break;
            } else {
                Write-Debug "`tComparing (above) with [$z][$x] ($($input[$z][$x])): not hidden so far"
            }
        }
        if(-not $current_tree_hidden) {
            Write-Debug "`tTree [$y][$x] visible from above; skipping to next"
            $visible_trees++
            continue;
        }
        $current_tree_hidden = $false
        for($z=$y+1; $z -lt $input.Length; $z++) { #below
            if($input[$z][$x] -ge $input[$y][$x]) {
                Write-Debug "`tComparing (below) with [$z][$x] ($($input[$z][$x])): hidden!"
                $current_tree_hidden = $true
                break;
            } else {
                Write-Debug "`tComparing (below) with [$z][$x] ($($input[$z][$x])): not hidden so far"
            }
        }
        if(-not $current_tree_hidden) {
            Write-Debug "`tTree [$y][$x] visible from below; skipping to next"
            $visible_trees++
            continue;
        }
        $current_tree_hidden = $false
        for($z=0; $z -lt $x; $z++) { #left
            if($input[$y][$z] -ge $input[$y][$x]) {
                Write-Debug "`tComparing (left) with [$y][$z] ($($input[$y][$z])): hidden!"
                $current_tree_hidden = $true
                break;
            } else {
                Write-Debug "`tComparing (left) with [$y][$z] ($($input[$y][$z])): not hidden so far"

            }
        }
        if(-not $current_tree_hidden) {
            Write-Debug "`tTree [$y][$x] visible from left; skipping to next"
            $visible_trees++
            continue;
        }
        $current_tree_hidden = $false
        for($z=$x+1; $z -lt $input[$y].Length; $z++) { #right
            if($input[$y][$z] -ge $input[$y][$x]) {
                Write-Debug "`tComparing (right) with [$y][$z] ($($input[$y][$z])): hidden!"
                $current_tree_hidden = $true
                break;
            } else {
                Write-Debug "`tComparing (right) with [$y][$z] ($($input[$y][$z])): not hidden so far"

            }
        }
        if(-not $current_tree_hidden) {
            Write-Debug "`tTree [$y][$x] is visible from right; skipping to next"
            $visible_trees++
            continue;
        }
        Write-Debug "Tree [$y][$x] is NOT visible." #only way to reach this is with no continues
    }
}

Write-Output "In total, there are $visible_trees visible trees."