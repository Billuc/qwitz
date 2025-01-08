SELECT 
  q.id AS question_id, 
  q.qwiz_id, 
  q.question, 
  a.id AS answer_id, 
  a.answer, 
  a.correct 
FROM 
  questions q
LEFT JOIN 
  answers a 
ON 
  q.id = a.question_id
WHERE
  q.qwiz_id = $1;