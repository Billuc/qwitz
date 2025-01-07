--- migration:up
CREATE TABLE answers(
    id UUID PRIMARY KEY,
    answer TEXT NOT NULL,
    correct BOOL NOT NULL,
    question_id UUID NOT NULL REFERENCES questions(id)
);

--- migration:down
DROP TABLE answers;

--- migration:end