function dostuff {
    [CmdletBinding()] Param(
        [Parameter(Mandatory=$false)]
        [switch] $sample,
        [Parameter(Mandatory=$false)]
        [switch] $part2
    )

    if($sample) {
        if(!$part2) {
            $data = $sample_data 
        } else {
            $data = @'
LR

11A = (11B, XXX)
11B = (XXX, 11Z)
11Z = (11B, XXX)
22A = (22B, XXX)
22B = (22C, 22C)
22C = (22Z, 22Z)
22Z = (22B, 22B)
XXX = (XXX, XXX)
'@ -split "`n"
        }
    } else {
        $data = Get-Content .\data.txt
    }

    $directions = $data[0].trim()
    $direction_step = 0
    $pedometer = 0
    if(!$part2) {
        $positions = @('AAA')
    } else {
        $positions = [System.Collections.ArrayList]::new()
    }
    
    # setup the location map (& for part2 find the start positions)
    $map = @{}
    for($x = 2; $x -lt $data.count; $x++) {
        $temp = $data[$x].trim().replace(' ', '').split('=') # adding .trim() as some weird NPCs are sneaking in
        $temp2 = $temp[1].trim('()').split(',')
        $map.Add($temp[0], @{ 'L' = $temp2[0]; 'R' = $temp2[1] })
        Write-Verbose "From data line $x, adding pos $($temp[0]) with L=$($temp2[0]) and R=$( $map[$temp[0]]['R'] )"
        if($part2 -and $temp[0][2] -eq 'A') {
            $positions.add($temp[0]) | Out-Null
        }
    }

    Write-Debug "Parsed $($map.keys.count) nodes and $($directions.length) directions [$directions]."
    if($part2) { Write-Debug "Also found $($positions.count) start positions ($($positions -join ', '))" }

    # follow the map!
    $continue_looking = $true
    while($continue_looking) {
        $part2_end = $true #gets falsed as soon as at least one position != xxZ
        for($x=0; $x -lt $positions.Count; $x++) {
            #update our location to our new location
            $newpos = $map[$positions[$x]]["$($directions[$direction_step])"]
            Write-Debug "Step $pedometer position #$x presently at $($positions[$x]) ($x of $($positions.Count-1)), will be heading $($directions[$direction_step]) to $newpos"
            $positions[$x] = $newpos
            # Solution checking
            if(!$part2) {
                if($positions[0] -eq 'ZZZ') {
                    $continue_looking = $false
                }
            } else {
                if($part2_end -and $positions[$x][2] -ne 'Z') { # the "$part2_end -and" should allow PoSH to skip the string slice/comparison, and improve performance.
                    $part2_end = $false
                }
            }
        }
        if($part2_end) {
            $continue_looking = $false
        }
        $pedometer++
        $direction_step++
        if($direction_step -ge $directions.length) {
            $direction_step = 0 #loop around per instructions
        }
        if(!$sample -and $pedometer -gt $bailtime -or $sample -and $pedometer -gt 30) {
            Write-Error "Bailing out since we've looped too long..."
            break
        }
        #Write-Progress -Activity "Search in Progress" -Status "working" -PercentComplete ($pedometer/$bailtime*100)
    }
    return $pedometer
}

$bailtime = 10000

$timer = [Math]::Round((Get-Date).ToFileTime()/10000)
$DebugPreference = 'SilentlyContinue'
Write-Output "Took $(dostuff -part2) steps to get to xxZ."
#Write-Output "Took $(dostuff -part2) steps to get to xxZ."

Write-Output "The above calc took $(([Math]::Round((Get-Date).ToFileTime()/10000) - $timer)/1000)s"