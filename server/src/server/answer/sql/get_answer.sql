SELECT id, question_id, answer, correct
FROM answers
WHERE id = $1;