--- migration:up
ALTER TABLE questions DROP CONSTRAINT questions_qwiz_id_fkey;
ALTER TABLE questions ADD FOREIGN KEY (qwiz_id) REFERENCES qwizes(id) ON DELETE CASCADE;
ALTER TABLE answers DROP CONSTRAINT answers_question_id_fkey;
ALTER TABLE answers ADD FOREIGN KEY (question_id) REFERENCES questions(id) ON DELETE CASCADE;

--- migration:down
ALTER TABLE questions DROP CONSTRAINT questions_qwiz_id_fkey;
ALTER TABLE questions ADD FOREIGN KEY (qwiz_id) REFERENCES qwizes(id) ON DELETE NO ACTION;
ALTER TABLE answers DROP CONSTRAINT answers_question_id_fkey;
ALTER TABLE answers ADD FOREIGN KEY (question_id) REFERENCES questions(id) ON DELETE NO ACTION;

--- migration:end