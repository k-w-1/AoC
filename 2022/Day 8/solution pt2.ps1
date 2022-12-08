if($DebugPreference -eq 'SilentlyContinue') {
    $input = Get-Content .\input.txt
} else {
    $input = Get-Content .\test_input.txt
}

$tree_high_score = 0

#since edge trees will have at least one direction multiplied by 0, just skip them altogether
for($y=1; $y -lt $input.Length-1; $y++) {
    for($x=1; $x -lt $input[$y].Length-1; $x++) {
        $tree_score = 1
        $directional_score = 1
        Write-Debug "Looking at tree [$y][$x] ($($input[$y][$x])):"
        for($z=$y-1; $z -gt 0; $z--) { #above
            if($input[$z][$x] -ge $input[$y][$x]) {
                Write-Debug "`tComparing (above) with [$z][$x] ($($input[$z][$x])): hidden! Directional score: $directional_score"
                break;
            } else {
                $directional_score++
                Write-Debug "`tComparing (above) with [$z][$x] ($($input[$z][$x])): not hidden so far. Directional score: $directional_score"
            }
        }
        $tree_score = $tree_score * $directional_score
        $directional_score = 1
        Write-Debug "`tRunning tree score: $tree_score"
        for($z=$y+1; $z -lt $input.Length-1; $z++) { #below
            if($input[$z][$x] -ge $input[$y][$x]) {
                Write-Debug "`tComparing (below) with [$z][$x] ($($input[$z][$x])): hidden! Directional score: $directional_score"
                break;
            } else {
                $directional_score++
                Write-Debug "`tComparing (below) with [$z][$x] ($($input[$z][$x])): not hidden so far. Directional score: $directional_score"
            }
        }
        $tree_score = $tree_score * $directional_score
        $directional_score = 1
        Write-Debug "`tRunning tree score: $tree_score"
        for($z=$x-1; $z -gt 0; $z--) { #left
            if($input[$y][$z] -ge $input[$y][$x]) {
                Write-Debug "`tComparing (left) with [$y][$z] ($($input[$y][$z])): hidden! Directional score: $directional_score"
                break;
            } else {
                $directional_score++
                Write-Debug "`tComparing (left) with [$y][$z] ($($input[$y][$z])): not hidden so far. Directional score: $directional_score"
            }
        }
        $tree_score = $tree_score * $directional_score
        $directional_score = 1
        Write-Debug "`tRunning tree score: $tree_score"
        for($z=$x+1; $z -lt $input[$y].Length-1; $z++) { #right
            if($input[$y][$z] -ge $input[$y][$x]) {
                Write-Debug "`tComparing (right) with [$y][$z] ($($input[$y][$z])): hidden! Directional score: $directional_score"
                break;
            } else {
                $directional_score++
                Write-Debug "`tComparing (right) with [$y][$z] ($($input[$y][$z])): not hidden so far. Directional score: $directional_score"

            }
        }
        $tree_score = $tree_score * $directional_score
        write-debug "`tTotal score for this tree: $tree_score"
        if($tree_score -gt $tree_high_score) {
            Write-Debug "New highscore for [$x][$y] with $tree_score!"
            $tree_high_score = $tree_score
        }
    }
}

Write-Output "The best tree score found was $tree_high_score"