SELECT 
  id, 
  qwiz_id, 
  question
FROM 
  questions
WHERE 
  id = $1;