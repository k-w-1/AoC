$strategy_guide = Get-Content input.txt

$total_score = 0;
    
# A Rock     1
# B Paper    2
# C Scissors 3
# X loose    0
# Y tie      6
# Z win      3

foreach($line in $strategy_guide) {
    switch($line.substring(2,1)) {
        "X" {
            $total_score += 0 #outcome score (loose) 
            switch($line.substring(0,1)) {
                "A" {$total_score += 3} #rock -> scissors
                "B" {$total_score += 1} #paper -> rock
                "C" {$total_score += 2} #scissors -> paper
            }
            
        }
        "Y" { 
            $total_score += 3 #outcome score (tie) 
            switch($line.substring(0,1)) {
                "A" {$total_score += 1} #rock -> rock
                "B" {$total_score += 2} #paper -> paper
                "C" {$total_score += 3} #scissors -> scissors
            }
        }
        "Z" {
            $total_score += 6 #outcome score (win) 
            switch($line.substring(0,1)) {
                "A" {$total_score += 2} #rock -> paper
                "B" {$total_score += 3} #paper -> scissors
                "C" {$total_score += 1} #scissors -> rock
            }
        }
    }
}

echo "Total score: $total_score"