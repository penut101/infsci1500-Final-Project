-- Sample data for an empty database after schema.sql.
-- These placeholder hashes are not credentials and cannot be used to sign in.
-- Insert related rows in a transaction. If an insert fails, run ROLLBACK instead of COMMIT.
START TRANSACTION;

-- Explicit IDs make the sample foreign-key relationships easy to follow.
INSERT INTO accounts (account_id, email, password_hash, role) VALUES
    (1, 'jordan@example.com', 'sample-only', 'applicant'),
    (2, 'maya@example.com', 'sample-only', 'applicant'),
    (3, 'alex@example.com', 'sample-only', 'applicant'),
    (4, 'staff@example.com', 'sample-only', 'staff');

-- Applicant account IDs refer to the accounts inserted above.
INSERT INTO applicants (applicant_id, account_id, full_name, address, phone) VALUES
    (1, 1, 'Jordan Lee', '123 Main St', NULL),
    (2, 2, 'Maya Patel', '45 Oak Ave', NULL),
    (3, 3, 'Alex Rivera', '8 Park St', NULL);

-- The staff member is used in the sample decision history.
INSERT INTO staff (staff_id, account_id, full_name) VALUES
    (1, 4, 'Admissions Staff');

-- Programs provide the degree level used in the statistics query.
INSERT INTO programs (program_id, name, degree_level) VALUES
    (1, 'Computer Science', 'undergraduate'),
    (2, 'Data Science', 'graduate'),
    (3, 'Information Science', 'undergraduate');

-- Each row connects an applicant and a program with a year and current status.
INSERT INTO applications (application_id, applicant_id, program_id, apply_year, status) VALUES
    (1, 1, 1, 2026, 'pending'),
    (2, 2, 2, 2026, 'accepted'),
    (3, 3, 3, 2026, 'rejected');

-- These bounds describe the sample score scales.
INSERT INTO test_types (test_type_id, name, min_score, max_score) VALUES
    (1, 'SAT', 400, 1600),
    (2, 'TOEFL', 0, 120),
    (3, 'GRE', 260, 340);

-- Scores link applications to test types using the IDs above.
INSERT INTO test_scores (application_id, test_type_id, score) VALUES
    (1, 1, 1420),
    (2, 3, 320),
    (3, 1, 1300);

-- Record the sample decisions that changed from pending.
INSERT INTO status_history (application_id, staff_id, previous_status, new_status) VALUES
    (2, 1, 'pending', 'accepted'),
    (3, 1, 'pending', 'rejected');

-- Save the inserts when they have all succeeded.
COMMIT;

