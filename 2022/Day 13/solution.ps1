#$file = Get-Content .\input.txt
$file = Get-Content .\test_input.txt


function test {
    [CmdletBinding()]
    param (
        $left,
        $right,
        [int] $depth
    )

    if($left -isnot [array]) {
        $left = [array]$left
    }
    if($right -isnot [array]) {
        $right = [array]$right
    }
  
    write-debug (("`t"*$depth)+ "Testing L:" +($left -join ',') + " R:"+($right -join ','))

    if($left.Length -le $right.Length) {
        $limit = $left.Length
    } else {
        $limit = $right.Length
    }

    for($y=0; $y -lt $limit; $y++) {
        if($left[$y] -is [array] -or $right[$y] -is [array]) {
            write-debug (("`t"*$depth)+ "Array! Recursing ($depth) down. L:" +($left[$y] -join ',') + " R:"+($right[$y] -join ','))
            $result = test -left $left[$y] -right $right[$y] -depth ($depth+1)
            if($result -ne 0) {
                return $result
            } else {
                continue
            }
        } else {
            if($left[$y] -lt $right[$y]) {
                Write-Debug (("`t"*$depth)+"Left is smaller, we're in order!")
                return 1
            } elseif($left[$y] -gt $right[$y]) {
                Write-Debug (("`t"*$depth)+"Right is smaller, we're out of order!")
                return -1
            } else {
                Write-Debug (("`t"*$depth)+"Left and right are equal; continuing examination.")
                continue
            }
        }
        
    }
    #the only way we reach the end of the for loop is if all pairs were equal; in this case the shorter list wins
    if($left.Length -lt $right.Length) {
        Write-Debug (("`t"*$depth)+"Left ran out of pairs first, we're in order!")
        return 1
    } elseif ($left.Length -gt $right.Length) {
        Write-Debug (("`t"*$depth)+"Right ran out of pairs first, we're out of order!")
        return -1
    } else {
        Write-Debug (("`t"*$depth)+"Left and right are equal length; continuing examination.")
        return 0
    }

}

$indices_sum = 0 

for($x=0; $x -lt $file.Length; $x += 3) {
    $left = $file[$x] | ConvertFrom-Json
    $right = $file[$x+1] | ConvertFrom-Json

    write-debug "Comparing index $($x/3+1):"
    Write-Debug $file[$x]
    Write-Debug $file[$x+1]
    
    switch(test -left $left -right $right -depth 1) {
        1 {
            $indices_sum += $x/3+1
            Write-Debug "Was in order! indices sum: $indices_sum`n"
        } 
        -1 {
            Write-Debug "Was NOT in order! indices sum: $indices_sum`n"
        } 
        0 {
            Write-error "Were equal?!?! indices sum: $indices_sum`n"
        }
    }

}

Write-Output "Total sum of the indices of correctly ordered pairs: $indices_sum"