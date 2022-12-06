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
                

                # AoC storytime to self/code creepers: apparently using continue with a label does WEIRD things.
                # I orginally didn't use a $nomatches bool and had a continue :outer_for_loop_label, which is a neato
                # throwback to BASIC's goto :label thing (lol and weird because to me its such a janky thing IDKWTF MS
                # was thinking adding it to PS, which otherwise seems to be well thought out, logical, and encourages
                # good code hygiene). Anyway, although the code did indeed jump up to the $x loop, /it didn't increment
                # the $x (which, OK, I know the $x++ is executed at the end of the loop code block, so it sorta makes 
                # sense). So I thought, no sweat, I'll just throw in a manual $x++ just before calling the continue. 
                # That worked, except it seems that the $y and $z loops asked, "are we initialized?" (i.e. should they
                # run the $y=0 and $z=$y+1 init bits of the for loops?). Apparently the answer was 'yes', which led to
                # all kinds of wonky AF stuff like it looking /behind/ $x to see what chars it should compare.
                #
                # The end.
                #
                # PS: the moral of this story is that you should half listen to the MS Scripting Guy blog; using 
                # break/continue is fine, JUST AVOID IT WITH LABELS. DRAGONS BE HERE!
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