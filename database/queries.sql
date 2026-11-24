-- Replace 2026 with the year to analyze.

-- Search and browse applications. An empty search string matches all names.
-- Enter part of a name, address, or program between the quotes to filter.
SET @search = '';
SELECT a.application_id, p.full_name, p.address, pr.name AS program,
       pr.degree_level, a.apply_year, a.status
FROM applications AS a
JOIN applicants AS p ON p.applicant_id = a.applicant_id
JOIN programs AS pr ON pr.program_id = a.program_id
WHERE p.full_name LIKE CONCAT('%', @search, '%')
   OR p.address LIKE CONCAT('%', @search, '%')
   OR pr.name LIKE CONCAT('%', @search, '%')
ORDER BY p.full_name, a.application_id;

-- Admission percentage uses all applications in the year, including pending.
-- COUNT gives the number of applications; the boolean expression counts
-- accepted rows. The percentage is rounded to one decimal place.
SELECT apply_year, COUNT(*) AS application_count,
       SUM(status = 'accepted') AS accepted_count,
       ROUND(100.0 * SUM(status = 'accepted') / COUNT(*), 1) AS admission_percentage
FROM applications
WHERE apply_year = 2026
GROUP BY apply_year;

-- Keep test types separate because their score scales differ.
-- Join scores to applications and programs, then average each level/test group.
SELECT p.degree_level, t.name AS test_type, COUNT(*) AS score_count,
       ROUND(AVG(s.score), 2) AS average_score
FROM test_scores AS s
JOIN test_types AS t ON t.test_type_id = s.test_type_id
JOIN applications AS a ON a.application_id = s.application_id
JOIN programs AS p ON p.program_id = a.program_id
WHERE a.apply_year = 2026
GROUP BY p.degree_level, t.name
ORDER BY p.degree_level, t.name;
