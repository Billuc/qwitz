--- migration:up
CREATE TABLE qwizes(
    id UUID PRIMARY KEY,
    name TEXT NOT NULL,
    owner UUID NOT NULL
);

--- migration:down
DROP TABLE qwizes;

--- migration:end