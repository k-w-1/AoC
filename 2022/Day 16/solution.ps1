class solution {
    [hashtable]$valves = @{}

    solution() {
        if($global:DebugPreference -eq 'SilentlyContinue') {
            $puzzle_input = Get-Content .\input.txt
        } else {
            $puzzle_input = Get-Content .\test_input.txt
        }
        foreach($line in $puzzle_input) {
            $values = $line -split ' '
            $tunnels = @()
            $tunnels += $values[9..($values.count-1)]
            foreach($i in $tunnels.count-1) {
                $tunnels[$i] = $tunnels[$i].trim(',')
            }
            $this.valves.add($values[1], @{'flow' = $values[4].trim('rate=;'); 'tunnels' = $tunnels})
        }
    }
}

#$DebugPreference = 'SilentlyContinue'
$DebugPreference = 'Continue'

[solution] $solution = [solution]::new()