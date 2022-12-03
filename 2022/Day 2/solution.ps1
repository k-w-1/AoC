$strategy_guide = Get-Content input.txt

$total_score = 0;
    
# A X 1 Rock
# B Y 2 Paper
# C Z 3 Scissors

foreach($line in $strategy_guide) {
    switch($line.substring(2,1)) {
        "X" {
            $total_score += 1 #shape score (rock) 
            switch($line.substring(0,1)) {
                "A" {$total_score += 3} #tie
                "B" {$total_score += 0} #loss
                "C" {$total_score += 6} #win
            }
            
        }
        "Y" { 
            $total_score += 2 #shape score (paper)
            switch($line.substring(0,1)) {
                "A" {$total_score += 6} #win
                "B" {$total_score += 3} #tie
                "C" {$total_score += 0} #loss
            }
        }
        "Z" {
            $total_score += 3 #shape score (scissors)
            switch($line.substring(0,1)) {
                "A" {$total_score += 0} #loss
                "B" {$total_score += 6} #win
                "C" {$total_score += 3} #tie
            }
        }
    }
}

echo "Total score: $total_score"