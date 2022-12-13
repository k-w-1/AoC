if($DebugPreference -eq 'SilentlyContinue') {
    $file = Get-Content .\input.txt
} else {
    $file = Get-Content .\test_input.txt
}

function test {
    [CmdletBinding()]
    param (
        $left,
        $right,
        $depth
    )
  
    write-debug (("`t"*$depth)+ "Testing L:" +($left -join ',') + "R:"+($right -join ','))

    if($left -isnot [array]) {
        Write-Debug (("`t"*$depth)+"Left wasn't an array; converting...")
        $left = [array]$left
    } 
    if($right -isnot [array]) {
        Write-Debug (("`t"*$depth)+"Right wasn't an array; converting...")
        $right = [array]$right
    }

    if($left.Length -ge $right.Length) {
        $limit = $left.Length
    } else {
        $limit = $right.Length
    }

    for($y=0; $y -lt $limit; $y++) {
        if($left[$y] -is [array] -or $right[$y] -is [array]) {
            write-debug (("`t"*$depth)+ "Array! Recursing ($depth) down. L:" +($left[$y] -join ',') + "R:"+($right[$y] -join ','))
            test($left[$y], $right[$y], $depth+1)
            continue
        } else {
            if($left[$y] -lt $right[$y]) {
                Write-Debug (("`t"*$depth)+"Left")
            }
        }
        
    }

}

for($x=0; $x -lt $file.Length; $x += 2) {
    $left = $file[$x] | ConvertFrom-Json
    $right = $file[$x+1] | ConvertFrom-Json

    test($left, $right, 1)

}