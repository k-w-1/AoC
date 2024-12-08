$sample_data = (@'
190: 10 19
3267: 81 40 27
83: 17 5
156: 15 6
7290: 6 8 6 15
161011: 16 10 13
192: 17 8 14
21037: 9 7 18 13
292: 11 6 16 20
'@).Replace("`r", '') -split "`n" 

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
        $out = "With *SAMPLE* dataset, part "
    } else {
        $data = $input_data
        $out = "Part "
    }
    $out += $part2 ? '2: ' : '1: '

    $dataLines = $data.Count
    $progress = 0
    $calibrationSum =0
    foreach($line in $data) {
        $temp = $line.split(': ')
        $calibration = [bigint]$temp[0]
        $operands = $temp[1].split(' ')

        Write-Debug "Testing $line..."
        $lefthandOperands = @($operands[0])
        for($i=1; $i -lt $operands.Count; $i++){
            $results = [System.Collections.ArrayList]::new()
            foreach($lefthandOperand in $lefthandOperands) {
                $results.add([bigint]$lefthandOperand * [bigint]$operands[$i]) | Out-Null
                $results.add([bigint]$lefthandOperand + [bigint]$operands[$i]) | Out-Null
                if($part2) {
                    $results.add([bigint]([string]$lefthandOperand + [string]$operands[$i])) | Out-Null
                }
            }
            Write-Debug "Stage $i, results of $($operands[$i]) */+(/||) [$($lefthandOperands -join ', ')]: [$($results -join ', ')]"
            #$lefthandOperands.add( $results | ? {$_ -lt $calibration} ) # only keep results still less than the calibration
            $lefthandOperands = $results.Clone()
        }
        
        if($calibration -in $results) {
            Write-Debug "Calibration successful!"
            $calibrationSum += $calibration
        }
        $pct = [int]($progress/$dataLines*100)
        Write-Progress -Activity "Processing calibrations..." -Status "$progress/$datalines ($pct%) complete" -PercentComplete $pct
        $progress++
    }

    $out += "total calibration result is $calibrationSum"
    Write-Output $out
}

dostuff -sample -Debug
dostuff
dostuff -part2 -sample -Debug
Measure-Command { dostuff -part2 | Out-Default }