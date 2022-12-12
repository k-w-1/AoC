if($DebugPreference -eq 'SilentlyContinue') {
    $input = Get-Content .\input.txt
} else {
    $input = Get-Content .\test_input.txt
}

$board = @(foreach($line in $input) {
    @(,$line.toCharArray())
})

#find start pos

#find next step

#path towards

