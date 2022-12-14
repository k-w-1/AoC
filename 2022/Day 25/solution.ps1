class solution {
    [System.Collections.ArrayList]$data = @()

    solution() {
        if($global:DebugPreference -eq 'SilentlyContinue') {
            $puzzle_input = Get-Content .\input.txt
        } else {
            $puzzle_input = Get-Content .\test_input.txt
        }
        foreach($line in $puzzle_input) {
        }
    }
}

$DebugPreference = 'SilentlyContinue'
$DebugPreference = 'Continue'

[solution] $solution = [solution]::new()