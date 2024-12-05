$day = ([datetime]::NOW).Day
New-Folder "Day $day"
Copy-Item -Path '.\2024\template\Day X solution.ipynb' -Destination "..\Day $day\Day $day solution.ipynb"
Invoke-WebRequest "https://adventofcode.com/2024/day/4/input" -OutFile "..\Day $day\data.txt"