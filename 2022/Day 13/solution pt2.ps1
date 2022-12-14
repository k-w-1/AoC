$file = Get-Content .\input.txt
#$file = Get-Content .\test_input.txt
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

class solution {
    [System.Collections.ArrayList]$full_packet_list = @()

    solution($file) {
        [void]$this.full_packet_list.add('[[2]]')
        [void]$this.full_packet_list.add('[[6]]')
        foreach($line in $file) {
            if($line -eq '') {
                continue
            }
            [void]$this.full_packet_list.add($line)
        }
    }

    sort() {
        write-debug "Sorting from 0 to $($this.full_packet_list.Count-1)"
        $this.quicksort(0, $this.full_packet_list.Count-1)
    }

    quicksort($start, $end) {
        if($start -ge $end -or $start -lt 0) {
            return
        }
        Write-Debug "Running quicksort part 1 from $start to $end"
        $pivot = $start -1
    
        for($x=$start; $x -lt $end; $x++) {
            Write-Debug "In sort_partition, testing $x against $($end-1)"
            $result = (test -left ($this.full_packet_list[$x]|ConvertFrom-Json) -right ($this.full_packet_list[$end]|ConvertFrom-Json) -depth 1)
            if($result -eq 1) {
                $pivot++
                $this.swap($pivot, $x)
            }
        }
        $pivot++
        $this.swap($pivot, $end)

        Write-Debug "Quicksort part 1 complete; recursing around pivot $pivot"
        $this.quicksort($start, $pivot-1)
        $this.quicksort($pivot+1, $end)
    }


    swap($a, $b) {
        if($a -eq $b) {
            #Write-Error "You fool! you're trying to swap an element with itself!"
            return
        } elseif($a -lt $b) { #tbh I'm unsure if this will ever be +1
            $direction = -1
        } else {
            $direction = 1
        }
        $temp = "$($this.full_packet_list[$a])"
        Write-Debug "Swapping $a ($($this.full_packet_list[$a])) and $b ($($this.full_packet_list[$b]))"
        [void]$this.full_packet_list.removeat($a)
        [void]$this.full_packet_list.insert($a, "$($this.full_packet_list[$b+$direction])")
        [void]$this.full_packet_list.removeat($b)
        [void]$this.full_packet_list.insert($b, $temp)
        Write-Debug "Done swapping $a ($($this.full_packet_list[$a])) and $b ($($this.full_packet_list[$b]))"
    }
    
}

$solution = $null

[solution] $solution = [solution]::new($file)


$solution.sort()
$decoder1 = $solution.full_packet_list.indexof("[[2]]") + 1
$decoder2 = $solution.full_packet_list.indexof("[[6]]") + 1
Write-Output "Decoder keys found at pos $decoder1 and $decoder2; their product is $($decoder1*$decoder2)"


