SELECT id, question_id, answer, correct
FROM answers
WHERE question_id = $1;