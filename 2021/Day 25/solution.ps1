$lines = Get-Content .\input.txt

$board = @()

foreach($lines in $line) {
    $board += $line.ToCharArray()
}

