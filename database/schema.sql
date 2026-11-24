-- MySQL 8.0.16 or later. Run against a new, empty database.
-- The table names and relationships follow the project's whiteboard.

-- Sign-in details and the account's role are stored separately from personal details.
CREATE TABLE accounts (
    account_id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    email VARCHAR(255) NOT NULL UNIQUE,
    password_hash VARCHAR(255) NOT NULL,
    role VARCHAR(20) NOT NULL,
    CONSTRAINT chk_accounts_role CHECK (role IN ('applicant', 'staff'))
) ENGINE=InnoDB;

-- Each applicant is linked to an account. The unique key prevents two applicants
-- from using the same account. The foreign key requires the account to exist.
CREATE TABLE applicants (
    applicant_id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    account_id INT UNSIGNED NOT NULL,
    full_name VARCHAR(150) NOT NULL,
    address VARCHAR(255) NOT NULL,
    phone VARCHAR(30),
    UNIQUE KEY uq_applicants_account (account_id),
    CONSTRAINT fk_applicants_account FOREIGN KEY (account_id) REFERENCES accounts (account_id)
) ENGINE=InnoDB;

-- Staff accounts are separate from applicant records and can record status changes.
CREATE TABLE staff (
    staff_id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    account_id INT UNSIGNED NOT NULL,
    full_name VARCHAR(150) NOT NULL,
    UNIQUE KEY uq_staff_account (account_id),
    CONSTRAINT fk_staff_account FOREIGN KEY (account_id) REFERENCES accounts (account_id)
) ENGINE=InnoDB;

-- A program's name and degree level identify what an applicant applies to.
CREATE TABLE programs (
    program_id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(150) NOT NULL,
    degree_level VARCHAR(20) NOT NULL,
    CONSTRAINT chk_programs_level CHECK (degree_level IN ('undergraduate', 'graduate')),
    UNIQUE KEY uq_program_name_level (name, degree_level)
) ENGINE=InnoDB;

-- Each application links one applicant to one program for an application year.
-- Its current decision is pending, accepted, or rejected.
CREATE TABLE applications (
    application_id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    applicant_id INT UNSIGNED NOT NULL,
    program_id INT UNSIGNED NOT NULL,
    apply_year SMALLINT UNSIGNED NOT NULL,
    status VARCHAR(20) NOT NULL DEFAULT 'pending',
    CONSTRAINT fk_applications_applicant FOREIGN KEY (applicant_id) REFERENCES applicants (applicant_id),
    CONSTRAINT fk_applications_program FOREIGN KEY (program_id) REFERENCES programs (program_id),
    CONSTRAINT chk_applications_year CHECK (apply_year BETWEEN 1900 AND 2100),
    CONSTRAINT chk_applications_status CHECK (status IN ('pending', 'accepted', 'rejected')),
    -- Helps queries that filter applications by year and status.
    INDEX idx_applications_year_status (apply_year, status)
) ENGINE=InnoDB;

-- Test types store score ranges separately because SAT, TOEFL, and GRE use
-- different scales. The range check only compares the minimum and maximum here.
CREATE TABLE test_types (
    test_type_id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(50) NOT NULL UNIQUE,
    min_score DECIMAL(7, 2) NOT NULL,
    max_score DECIMAL(7, 2) NOT NULL,
    CONSTRAINT chk_test_types_range CHECK (min_score <= max_score)
) ENGINE=InnoDB;

-- An application can have multiple score records, each linked to a test type.
-- The backend must check each score against that test type's range.
CREATE TABLE test_scores (
    score_id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    application_id INT UNSIGNED NOT NULL,
    test_type_id INT UNSIGNED NOT NULL,
    score DECIMAL(7, 2) NOT NULL,
    CONSTRAINT fk_scores_application FOREIGN KEY (application_id) REFERENCES applications (application_id),
    CONSTRAINT fk_scores_type FOREIGN KEY (test_type_id) REFERENCES test_types (test_type_id),
    INDEX idx_scores_application_type (application_id, test_type_id)
) ENGINE=InnoDB;

-- Store document location and type for an application, rather than file contents.
CREATE TABLE documents (
    document_id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    application_id INT UNSIGNED NOT NULL,
    file_path VARCHAR(500) NOT NULL,
    document_type VARCHAR(100) NOT NULL,
    CONSTRAINT fk_documents_application FOREIGN KEY (application_id) REFERENCES applications (application_id)
) ENGINE=InnoDB;

-- Each history record links an application to the staff member who changed it.
-- The backend must update this table and applications.status in one transaction.
CREATE TABLE status_history (
    history_id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    application_id INT UNSIGNED NOT NULL,
    staff_id INT UNSIGNED NOT NULL,
    previous_status VARCHAR(20) NOT NULL,
    new_status VARCHAR(20) NOT NULL,
    changed_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_history_application FOREIGN KEY (application_id) REFERENCES applications (application_id),
    CONSTRAINT fk_history_staff FOREIGN KEY (staff_id) REFERENCES staff (staff_id),
    CONSTRAINT chk_history_previous CHECK (previous_status IN ('pending', 'accepted', 'rejected')),
    CONSTRAINT chk_history_new CHECK (new_status IN ('pending', 'accepted', 'rejected')),
    INDEX idx_history_application_time (application_id, changed_at)
) ENGINE=InnoDB;
