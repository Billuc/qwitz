SELECT 
  id, 
  qwiz_id, 
  question
FROM 
  questions
WHERE
  qwiz_id = $1;