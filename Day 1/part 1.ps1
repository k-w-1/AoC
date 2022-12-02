$calories_list = Get-Content input.txt

$calories = 0;
$elves = @();

#sum up elves
foreach($line in $calories_list) {
    #if blank, add new elf & reset
    if($line -eq "") {
        $elves += $calories;
        $calories = 0;
    } else {
        $calories += [int]$line;
    }
}
#find biggest
$elves | measure -Maximum

#find top 3
$elves | Sort-Object -Descending | select -First 3 | measure -Sum