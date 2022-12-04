$slacking_elves = 0;

foreach($row in Get-Content input.txt) {
    Write-Debug "Checking $row"
    $numbers = $row.split("-,")
    if([int]$numbers[0] -lt [int]$numbers[2]) {
        if([int]$numbers[1] -ge [int]$numbers[3]) {
            Write-Debug "Slacker! $($numbers[0])-$($numbers[1]) entirely contains $($numbers[2])-$($numbers[3])"
            $slacking_elves++
        }
    } elseif ([int]$numbers[0] -gt [int]$numbers[2]) { #the second elf starts earlier and therefore must also finish later
        if([int]$numbers[3] -ge [int]$numbers[1]) {
            Write-Debug "Slacker! $($numbers[0])-$($numbers[1]) is entirely contained by $($numbers[2])-$($numbers[3])"
            $slacking_elves++
        }
    } else { #must be equal to each other, in which case (since we're comparing the two first numbers, a full overlap is implicit)
        $slacking_elves++
        Write-Debug "Slacker! Since $($numbers[0]) is the same as $($numbers[2]), it's implicit that one contains entirely the other"
    }
}

Write-Output "There are $slacking_elves elves with nothing to do."

$partial_slacking_elves = 0

foreach($row in Get-Content input.txt) {
    Write-Debug "Checking $row"
    $numbers = $row.split("-,")
    if([int]$numbers[0] -lt [int]$numbers[2]) {
        if([int]$numbers[1] -ge [int]$numbers[2]) {
            Write-Debug "Partial slacker! $($numbers[0])-$($numbers[1]) overlaps $($numbers[2])-$($numbers[3])"
            $partial_slacking_elves++
        }
    } elseif ([int]$numbers[0] -gt [int]$numbers[2]) { #the second elf starts earlier and therefore must also finish later
        if([int]$numbers[3] -ge [int]$numbers[0]) {
            Write-Debug "Partial slacker! $($numbers[0])-$($numbers[1]) overlaps $($numbers[2])-$($numbers[3])"
            $partial_slacking_elves++
        }
    } else { #must be equal to each other, in which case (since we're comparing the two first numbers, a full overlap is implicit)
        $partial_slacking_elves++
        Write-Debug "Slacker! Since $($numbers[0]) is the same as $($numbers[2]), it's implicit that one contains entirely the other"
    }
}

Write-Output "There are $slacking_elves elves with some overlap."