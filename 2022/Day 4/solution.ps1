$slacking_elves = 0;

foreach($row in Get-Content test_input.txt) {
    $numbers = $row -split '-,'
    if($numbers[0] -lt $numbers[2]) {
        if($numbers[1] -ge $numbers[3]) {
            $slacking_elves++
        }
    } elseif ($numbers[0] -gt $numbers[2]) {
        if($numbers[1] -le $numbers[3]) {
            $slacking_elves++
        }
    } else { #must be equal to each other, in which case (since we're comparing the two first numbers, a full overlap is implicit)
        $slacking_elves++
    }
}

Write-Output "There are $slacking_elves elves with nothing to do."