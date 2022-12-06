if($DebugPreference -eq 'SilentlyContinue') {
    $input = Get-Content .\input.txt
} else {
    $input = Get-Content .\test_input.txt
}

$input = $input.ToCharArray();

for($x=0;$x -lt $input.Length-4;$x++) {
    if($input[$x+0] -ne $input[$x+1] -and $input[$x+0] -ne $input[$x+2] -and $input[$x] -ne $input[$x+3] -and `
       $input[$x+1] -ne $input[$x+2] -and $input[$x+1] -ne $input[$x+3] -and `
       $input[$x+2] -ne $input[$x+3]) {
        Write-Output "Packet marker found: [$($input[$x])$($input[$x+1])$($input[$x+2])$($input[$x+3])], at pos $($x+4)."
        break;
    }
}

$message_marker_size=14

for($x=0; $x -lt $input.Length-$message_marker_size; $x++) {
    $nomatches=$true
    for($y=0; $y -lt $message_marker_size-1; $y++) {
        for($z=$y+1; $z -lt $message_marker_size-1; $z++) {
            Write-Debug ("x: {0,4}, y: {1,2}, z: {2,2}; Checking if input[{3,4}] matches input[{5,4}] ({4} -eq {6}?)" -f $x, $y, $z, ($x+$y), $input[$x+$y], ($x+$z), $input[$x+$z])
            if($input[$x+$y] -eq $input[$x+$z]) {
                Write-Debug ("x: {0,4}, y: {1,2}, z: {2,2}; input[{3,4}] ({4}) matches input[{5,4}] ({6})" -f $x, $y, $z, ($x+$y), $input[$x+$y], ($x+$z), $input[$x+$z])
                $nomatches=$false
                #yes in theory I could improve efficiency by advancing $x by $y, but that's feature creep :)
                break;
            }

        }
        if(-not $nomatches) {
            break;
        }
    }
    if($nomatches) {
        Write-Output "Message marker found: [$($input[$x..($x+$message_marker_size-1)] -join '')], at pos $($x+$message_marker_size)."
        break;
    }
}