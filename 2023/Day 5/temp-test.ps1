$sample_data = @'
seeds: 79 14 55 13

seed-to-soil map:
50 98 2
52 50 48

soil-to-fertilizer map:
0 15 37
37 52 2
39 0 15

fertilizer-to-water map:
49 53 8
0 11 42
42 0 7
57 7 4

water-to-light map:
88 18 7
18 25 70

light-to-temperature map:
45 77 23
81 45 19
68 64 13

temperature-to-humidity map:
0 69 1
1 0 69

humidity-to-location map:
60 56 37
56 93 4
'@ -split "`r`n"

$input_data = Get-Content .\data.txt


function dostuff {
    [CmdletBinding()] Param(
        [Parameter(Mandatory=$false)]
        [switch] $sample,
        [Parameter(Mandatory=$false)]
        [switch] $part2
    )

    if($sample) {
        $data = $sample_data
    } else {
        $data = $input_data
    }

    ## Get our list of seeds....
    $temp = ($data[0].split(': '))[1].split(' ')
    $seeds = [System.Collections.ArrayList]::new()
    if(!$part2) {
        for($x=0; $x -lt $temp.count; $x+=1 ) {
            $seeds.add([PSCustomObject] @{
                start  = [long]$temp[$x]
                end    = [long]$temp[$x]
                })
        }
    } else {
        for($x=0; $x -lt $temp.count; $x+=2 ) { #nb that we're jumping by twos
            $seeds.add([PSCustomObject] @{
                start  = [long]$temp[$x]
                end    = [long]$temp[$x] + [long]$temp[$x+1] - 1 # less one because the start is included in the range length
                })
        }
    }

    ## Prepare a "multilayer map" of the data

    $current_map_layer = 0
    $layers = @()
    1..7 | % {$layers += ,[System.Collections.ArrayList]::new()} # based on the different layers of things
    # line 0 is seeds, line 1 is blank, line 2 is first map
    for($x=3; $x -lt $data.count; $x++) {
        #if we hit a blank, means a new map layer is incoming
        if($data[$x] -eq '' -or [string]::IsNullOrWhiteSpace($data[$x])) {
            $current_map_layer++
            $x++ #skip the blank line. The for loop will still iterate to skip the layer desc (layer-to-layer map:)
            Write-Debug "Processed layer $($current_map_layer) with $($layers[$current_map_layer-1].count) spans";
            continue;
        }
        Write-Verbose "Working line $x as `"$($data[$x])`""
        $values = $data[$x].split(' ')

        # build up a nice object of the values
        $map = [PSCustomObject]::new()
        [PSCustomObject]$map = @{
            start  = [long]$values[1]
            end    = [long]$values[1] + [long]$values[2] - 1 # less one because the start is included in the range length
            offset = [long]$values[0] - [long]$values[1]
        }

        $layers[$current_map_layer].add($map) | Out-Null
    }

    [long]$best_location = 999999999999999999
    ## Iterate over seeds
    foreach($seed in $seeds){
        $temp = $seed.PsObject.copy()
        for($x=0; $x -lt $layers.count; $x++) {
            #collect the span(s) that apply for this seed (series)

            #    3456    seeds
            #     456789 layers
            #  12345                 Layer end must be >= seed start, and layer start must be <= seed end
            $map = $layers[$x] | ? {$_.end -ge $seed.start -and $_.start -le $seed.end}
            if($map.count -lt 1) {
                # Note: 'not found' in a layer means it's equal to the current number
                Write-Verbose "Processing $($seed.start)-$($seed.end), layer $($x+1) didn't have any match so it continues unchanged."
            } elseif(($map.GetType()).FullName -eq "System.Object[]") {
                foreach($item in $map) {
                    Write-Error "Seed $($seed.start)-$($seed.end), layer $($x+1) matches [S=$($item.start) E=$($item.end) O=$($item.offset)]"
                }
                Write-Error "Matched more than one!"
            } else {
                Write-Verbose "Processing $($seed.start)-$($seed.end), layer $($x+1) matches [S=$($map.start) E=$($map.end) O=$($map.offset)]. Current pos: $($temp.start)-$($temp.end), new pos: $($temp.start+ $map.offset)-$($temp.end+$map.offset)"
                # Decide if this range needs to be "sliced"

                $temp.start = $temp.start + [long]$map.offset
                $temp.end = $temp.end + [long]$map.offset
            }
        }
        Write-Debug "Final location for $($seed.start)-$($seed.end) was $($temp.start)-$($temp.end)"
        if($temp.start -lt $best_location) {
            $best_location = [long]$temp.start
            Write-Debug "New best location: $best_location"
        }

    }
    Write-Debug "? $($best_location) Type: $($best_location.GetType().FullName)"
    
    return $best_location
}

$best = dostuff -sample #-Debug -Verbose
$best.count
Write-Output "Best location to start planting is $($best)"