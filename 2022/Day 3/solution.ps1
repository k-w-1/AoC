$rucksacks = Get-Content input.txt

$total_priority = 0;
$total_badge_priority = 0;

$elf_team = @()

function GetItemPriority {
    param (
        [char]$char
    )
    if([int]$char -le 90 ) {
        Write-Debug "Item (uppercase) $char has value $([int]$char - 38)"
        return [int]$char - 38
    } else {
        Write-Debug "Item (lowercase) $char has value $([int]$char - 96)"
        return [int]$char - 96
    }
    
}

foreach($rucksack in $rucksacks) {
    $compartment_size = $rucksack.length/2
    Write-Debug "Compartment size $compartment_size"
    foreach($char in $rucksack.substring(0,$compartment_size).toCharArray()) {
        if($rucksack.substring($compartment_size,$compartment_size).indexOf($char) -ne -1) {
            $total_priority += GetItemPriority($char)
            #prevent further matches from counting
            break;
        }
    }
    #part 2
    $elf_team += $rucksack
    if($elf_team.length -eq 3) {
        foreach($char in $elf_team[0].toCharArray()) {
            if(($elf_team[1].indexOf($char) -ne -1) -and ($elf_team[2].indexOf($char) -ne -1)) {
                Write-Debug "Elf team badge priority is $(GetItemPriority($char))"
                $total_badge_priority += GetItemPriority($char)
                #prevent further matches from counting
                break;
            }
        }
        #reset team for next run
        $elf_team = @()
    }
}

Write-Output "Sum of priorities is $total_priority"
Write-Output "Sum of badge priorities is $total_badge_priority"

