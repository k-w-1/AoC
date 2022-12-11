if($DebugPreference -eq 'SilentlyContinue') {
    $input = Get-Content .\input.txt
} else {
    $input = Get-Content .\test_input.txt
}

$X = 1
$program_step = $sum = $pending_instructions = 0
$display = @( , ' ' * 40*6)

foreach($cycle in 1..240) {
    #draw screen
    if((($cycle % 40)-1) -in ($X-1)..($X+1)) {
        Write-Debug ("C:{0,3} X:{1,4} - X is +/-1 of cycle%40 ({2}), drawing lit pixel at" -F $cycle, $X, (($cycle % 40)-1))
        $display[$cycle-1] = '#'
    } else {
        Write-Debug ("C:{0,3} X:{1,4} - X is NOT +/-1 of cycle%40 ({2}), drawing not lit pixel" -F $cycle, $X, (($cycle % 40)-1))
        $display[$cycle-1] = '.'
    }
    
    if($pending_instructions -eq 0) {
        Write-Debug ("C:{0,3} X:{1,4} - loading instruction {2}" -F $cycle, $X, $input[$program_step])
        $instruction = $input[$program_step++] -split ' '
    } else {
        Write-Debug ("C:{0,3} X:{1,4} - decrementing pending instructions" -F $cycle, $X)
        $pending_instructions--
    }
    if($cycle -in @(20, 60, 100, 140, 180, 220)) {
        $signal = $X * $cycle
        $sum += $signal
        Write-Output ("C:{0,3} X:{1,4} - SPECIAL step: signal:{2}, sum:{3}" -F $cycle, $X, $signal, $sum)
    }
    switch($instruction[0]) {
        'noop' {
            Write-Debug ("C:{0,3} X:{1,4} - Processing noop." -F $cycle, $X)
        }
        'add2' {
            $X += [int]$instruction[1]
            Write-Debug ("C:{0,3} X:{1,4} - Processing add2." -F $cycle, $X)
            Write-Debug ("Sprite position: " + ('.'*($x-1)) + '###' + ('.'*(38-$x)))
        }
        'addx' {
            Write-Debug ("C:{0,3} X:{1,4} - Processing addx." -F $cycle, $X)
            $instruction[0] = 'add2'
            $pending_instructions = 1
        }
    }
}

Write-Output "Sum of special instructions: $sum`n"

$Output = '|'
for($z=0; $z -lt $display.Length; $z++) {
    $Output += $display[$z]
    if((($z+1) % 40) -eq 0) {
        $Output += "|`n|"
    }
}

Write-Output $Output