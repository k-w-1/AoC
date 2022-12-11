$input = Get-Content .\input.txt
#$input = Get-Content .\test_input.txt

[hashtable[]]$monkeys = @()
$monkey = 0

foreach($line in $input) {
    #Write-Debug "Processing instruction $line"
    $instruction = $line.trim() -split ' '
    switch($instruction[0]) {
        'Monkey' {
            $monkey = $instruction[1].Trim(':')
            #$monkeys[$monkey] = @{}
            $monkeys += @{"inspections" = 0}
            Write-Debug "Added monkey $monkey"
        }
        'Starting' {
            $monkeys[$monkey] += @{"items" = @((@($instruction[2..($instruction.length-1)])).trim(','))}
            Write-Debug "Added items $($monkeys[$monkey].items -join ', ') to monkey $monkey"
        }
        'Operation:' {
            if($instruction[5] -eq 'old') {
                $monkeys[$monkey] += @{"operation" = '^'}
                $monkeys[$monkey] += @{"operand" = 2}
            } else {
                $monkeys[$monkey] += @{"operation" = $instruction[4]}
                $monkeys[$monkey] += @{"operand" = $instruction[5]}
            }
            Write-Debug "Added operator $($monkeys[$monkey].operation) and operand $($monkeys[$monkey].operand) to monkey $monkey"
        }
        'Test:' {
            $monkeys[$monkey] += @{"test" = $instruction[3]}
            Write-Debug "Added test val $($monkeys[$monkey].test) to monkey $monkey"

        }
        'If' {
            if($instruction[1] -eq 'true:') {
                $monkeys[$monkey] += @{"test_true" = $instruction[5]}
                Write-Debug "Added true test pass to monkey $($monkeys[$monkey].test_true) for monkey $monkey"
            } else {
                $monkeys[$monkey] += @{"test_false" = $instruction[5]}
                Write-Debug "Added false test pass to monkey $($monkeys[$monkey].test_false) for monkey $monkey"
            }
        }
    }
}


$magic_divisor = 1
foreach($operand in $monkeys.test) {
    $magic_divisor *= $operand
}

$rounds = 10000
foreach($x in 1..$rounds) {
    Write-Debug "Round $x"
    Write-Progress -Activity "Processing round $x" -PercentComplete ($x/$rounds*100)
    for($y=0; $y -lt $monkeys.Count; $y++) {
        Write-Debug "Processing monkey $y with items $($monkeys[$y].items -join ', ')"
        foreach($item in $monkeys[$y].items) {
            $monkeys[$y].inspections++
            $og_item = $item
            switch($monkeys[$y].operation) {
                '+' {[bigint]$item += $monkeys[$y].operand}
                '*' {[bigint]$item *= $monkeys[$y].operand}
                '^' {[bigint]$item = [bigint]::pow($item, $monkeys[$y].operand)}
            }
            #Write-Debug "`tProcessing item $og_item $($monkeys[$y].operation) $($monkeys[$y].operand) = $item; done inspection (now $([math]::Floor($item/3)))"
            Write-Debug "`tProcessing item $og_item $($monkeys[$y].operation) $($monkeys[$y].operand) = $item"
            #$item = [math]::Floor($item/3)

            $item = $item % $magic_divisor
            Write-Debug "Reduced worry to $item"
            #test/pass
            if(($item % $monkeys[$y].test) -eq 0) {
                Write-Debug "`tAs $item is divisible by $($monkeys[$y].test), passing to monkey $($monkeys[$y].test_true)"
                $monkeys[$monkeys[$y].test_true].items += ,($item)
            } else {
                Write-Debug "`tAs $item is NOT divisible by $($monkeys[$y].test), passing to monkey $($monkeys[$y].test_false)"
                $monkeys[$monkeys[$y].test_false].items += ,($item)
            }
        }
        #remove all items from this monkey
        $monkeys[$y].items = @()
    }
}
$busy_monkeys = $monkeys.inspections | Sort-Object -Descending | select -First 2

Write-Output "Monkey business ($($busy_monkeys[0])*$($busy_monkeys[1])) is $($busy_monkeys[0]*$busy_monkeys[1])"
