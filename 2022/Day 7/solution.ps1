if($DebugPreference -eq 'SilentlyContinue') {
    $input = Get-Content .\input.txt
} else {
    $input = Get-Content .\test_input.txt
}

$filesystem  = @{ 
    '/' = @{}
}

$cwd = [System.Collections.ArrayList]::new()

foreach($line in $input) {
    $cmd = $line -split ' '
    if($cmd[0] -eq '$') {
        if($cmd[1] -eq "cd") {
            #navigate up if ..
            if($cmd[2] -eq '..') {
                [void]$cwd.RemoveAt($cwd.count-1)
                Write-Debug "Navigating up a directory, cwd is now: /$($cwd -join '/')"
            } elseif($cmd[2] -eq '/') {
                [void]$cwd.clear()
                Write-Debug "Navigating to cwd /"
            } else {
                [void]$cwd.add($cmd[2])
                Write-Debug "Navigating into cwd /$($cwd -join '/')"
            }
            #check if dir exists, create if not
        } elseif($cmd[1] -eq "ls") {
            Write-Debug "Ignoring ls command..."
            #nothing to do really, since we assume non $ commands are dir listings
        }
    } else {
        #assumed that it's a dir listing if no $ prefix
        if($cmd[0] -eq "dir") {
            Write-Debug "Adding dir $($cmd[1]) to filesystem."
            [void]$filesystem.add("/$($cwd + $cmd[1] -join '/')", @{})
        } else {
            Write-Debug "Adding file $($cmd[1]) size $($cmd[0]) to /$($cwd -join '/')"
            [void]$filesystem["/$($cwd -join '/')"].add($cmd[1], $cmd[0])
        }
    }
}

function recursively_get_subfolder_size {
    [CmdletBinding()]
    param (
        $this_dir
    )
    #start off with the local dir files
    $total_dir_size = ($filesystem[$this_dir].values | Measure-Object -Sum).Sum
    Write-Debug "Local size of $this_dir is $total_dir_size"
    foreach($dir in $filesystem.GetEnumerator()) {
        if($dir.name -eq $this_dir) { #ignore root
            continue
        } elseif($dir.name -like "$this_dir*") {
            Write-Debug "Checking subdir $($dir.name) of $this_dir"
            $total_dir_size += recursively_get_subfolder_size($dir.key)
        }
    }
    Write-Debug "Total size (including local) of $this_dir is $total_dir_size"
    return $total_dir_size
}

$total_size_of_dirs_over_100k = 0
$script:closest_size_path = ''
$used_space = ($filesystem.values.values | Measure-Object -Sum).Sum
$script:addl_required_space = 30000000 - (70000000 - $used_space)
$script:closest_size_ge_addl_requred_space = 70000000 #must be smaller than this!

foreach($dir in $filesystem.GetEnumerator()) {
    $dirsize = recursively_get_subfolder_size($dir.name)
    if($dirsize -le 100000) {
        $total_size_of_dirs_over_100k += $dirsize
        Write-Debug "Dir $($dir.Name) is $dirsize, adding to <=100K total ($total_size_of_dirs_over_100k)"
    } else {        
        Write-Debug "Dir $($dir.Name) is $dirsize."
    }
    $true_size = (($filesystem.GetEnumerator() | where {$_.key -like "$($dir.name)*"}).Value.values | measure -sum).sum
    if($true_size -ge $addl_required_space -and $true_size -lt $closest_size_ge_addl_requred_space){
        Write-Debug "Dir $($dir.Name) ($true_size) is a better candidate for removal."
        $closest_size_ge_addl_requred_space = $true_size
        $closest_size_path = $dir.Name
    }
}

Write-Output "Total disk size used is: $used_space"
Write-Output "Total size of all dirs <=100K is $total_size_of_dirs_over_100k"
Write-Output "$addl_required_space is required, best dir to remove is $closest_size_path, size $closest_size_ge_addl_requred_space"


