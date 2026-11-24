# School Admissions Project

This is our INFSCI 1500 group project. We're building a school admissions system where staff can manage applicant information, test scores, and admission decisions. The system also needs to show application counts by year, admission percentages, and average test scores for undergraduate and graduate applicants.

The finished project needs to run in a browser and use a relational database with SQL. It needs search and browsing, updates, aggregation queries, integrity checks, and at least seven relations. We'll also submit a report and demonstrate the system as a group.

Our current work plan is for Aiden to handle the initial E-R diagram and frontend, Trey to finalize the diagram and work on the database and backend, and Ryan to handle the SQL DDL and final report. The SQL files here are a starting point for the group to review.

## File structure

```text
infsci1500-Final-Project/
├── README.md             Project overview and setup
├── index.html            Admissions page and form
├── styles.css            Page styling
├── app.js                Sample data and page behavior
└── database/
    ├── schema.sql        MySQL tables, keys, indexes, and checks
    ├── seed.sql          Sample database records
    └── queries.sql       Example search and statistics queries
```

## Frontend

The frontend is built with HTML, CSS, and JavaScript. To try it, open `index.html` in a browser. There are no packages to install.

The page can add, edit, display, and search sample applicants by name, address, or degree. It also shows application counts, admission percentages, and average scores by level and test type for a selected year.

The sample records are in `app.js`. Changes only last until the page is refreshed. The form currently has one test score per applicant record. The draft database allows multiple scores per application, so we'll need to adjust the page when we connect it to the backend.

## Backend

The backend hasn't been built yet. The frontend does its own searching and calculations with sample data and isn't connected to MySQL.

The SQL files in `database/` are a draft based on our nine-table whiteboard diagram. We still need to build a server and agree on how the frontend will send and receive data. Database credentials should stay on the server, outside the browser code.

## MySQL setup

You'll need MySQL Server 8.0.16 or later and an account that can create a database and tables. To try the scripts in MySQL Workbench:

1. Connect to your server and create a new, empty database:

   ```sql
   CREATE DATABASE school_admissions;
   USE school_admissions;
   ```

   If a database with that name already exists, choose another name so you don't run the scripts against existing data.

2. Open `database/schema.sql`, make sure the new database is selected as the default schema, and run the script. This creates the nine tables.
3. Open and run `database/seed.sql` once against the same database. If an insert fails, stop execution and run `ROLLBACK;` in the same session before fixing it. Don't continue to `COMMIT;`.
4. Open and run `database/queries.sql` to try the search and statistics queries. You can change `@search` and the year in the file.

With the sample data, the 2026 results should show three applications, one acceptance, a 33.3% admission rate, an undergraduate SAT average of 1360.00, and a graduate GRE average of 320.00.

The schema is meant for a new database, and the seed script is meant to run once on an empty schema. Neither script resets existing data. The sample password hashes are placeholders and can't be used to sign in.

## Decisions to review

- Every applicant and staff record requires an account. An account can be linked to one applicant and one staff record at most. The schema doesn't prevent the same account from appearing in both tables or check that its role matches the record.
- Each application belongs to one applicant and one program. The schema currently allows the same applicant to apply to the same program more than once in a year.
- Programs are either undergraduate or graduate. An application can have multiple scores, including multiple scores for the same test. Each score counts separately in the average.
- The admission percentage includes pending applications in the total.
- The documents table stores a path and document type. It doesn't upload or store the files.

## Still to do

- Agree on the decisions above, score scales, permitted years, and duplicate-application rules before finalizing the schema.
- Build the backend and connect it to MySQL and the frontend. The SQL queries are examples, not API endpoints.
- Validate scores against the selected test type's range and make sure account roles match applicant or staff records. The schema doesn't enforce those cross-table rules.
- Update `applications.status` and add its `status_history` record in the same transaction. Handle concurrent updates so the previous status is recorded correctly.
- Set up authentication with real password hashes, secure database credentials, and document storage before using real accounts or files.
- Test the connected application and its error cases. The schema, seed data, and example queries have been run on MySQL 8.0.46. Invalid status and missing-applicant inserts were rejected.
