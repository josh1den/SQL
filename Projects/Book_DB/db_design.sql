CREATE TABLE "books" (
  "id" SERIAL PRIMARY KEY,
  "title" VARCHAR(100) NOT NULL,
  "author" VARCHAR(50) NOT NULL,
  "isbn" INTEGER UNIQUE NOT NULL,
  "pages" SMALLINT NOT NULL,
  "genre" VARCHAR(50)
)


CREATE TABLE "books_read" (
  "id" SERIAL PRIMARY KEY,
  "book_id" INTEGER FOREIGN KEY REFERENCES "books" ("id"),
  "start" TIMESTAMP,
  "finish" TIMESTAMP,

)
