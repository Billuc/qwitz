UPDATE answers
SET 
    answer = $1,
    correct = $2
WHERE id = $3;