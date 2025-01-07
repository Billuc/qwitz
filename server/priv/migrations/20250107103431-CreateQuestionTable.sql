--- migration:up
CREATE TABLE questions(
    id UUID PRIMARY KEY,
    question TEXT NOT NULL,
    qwiz_id UUID NOT NULL REFERENCES qwizes(id)
);

--- migration:down
DROP TABLE questions;

--- migration:end