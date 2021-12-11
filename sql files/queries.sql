-- 1. Display doctor_id, last_name and specialization_name of these doctors 
-- who had less appointments than the average number of appointments for a doctor

SELECT d.doctor_id, d.last_name, s.specialization_name
FROM doctors d
JOIN visits v ON v.doctor_id = d.doctor_id
JOIN specializations s ON s.specialization_id = d.specialization_id
GROUP BY d.doctor_id, d.last_name, s.specialization_name
HAVING COUNT(*) < (SELECT AVG(COUNT(v.visit_id))
                    FROM visits v
                    JOIN doctors d ON v.doctor_id = d.doctor_id
                    GROUP BY d.doctor_id);
                    
-- 2. For each patient show patient_id and the total number of visits in 2019
SELECT p.patient_id, COUNT(v.visit_id) TotalNumber
FROM patients p
LEFT JOIN visits v ON v.patient_id = p.patient_id
WHERE TO_CHAR(registration_date,'YYYY') = '2019'
GROUP BY p.patient_id;

-- 3. For each prescription (having information about the drug dose)
-- show patient last_name, drug name and its total amount to be taken
SELECT pa.last_name, d.drug_name, (pr.end_date - pr.start_date) * daily_amount total_amount
FROM prescriptions pr
JOIN drugs d ON d.drug_id = pr.drug_id
JOIN visits v ON v.visit_id = pr.visit_id
JOIN patients pa ON pa.patient_id = v.patient_id
WHERE pr.end_date - pr.start_date IS NOT NULL;

-- 4. Display two average drug's daily amounts - prescribed by men and women. Consider Zinnat. 
SELECT d.gender, AVG(p.daily_amount) average_amount
FROM doctors d
JOIN visits v ON v.doctor_id = d.doctor_id
JOIN prescriptions p ON p.visit_id = v.visit_id
JOIN drugs d ON d.drug_id = p.drug_id
WHERE d.drug_name = 'Zinnat'
GROUP BY d.gender;

-- 5. Display doctors who are younger than the average age at which doctors were hired in the hospital
SELECT d.first_name, d.last_name, ROUND((SYSDATE - d.date_of_birth) / 365.242199, 1) age, d.salary
FROM doctors d
WHERE ROUND((SYSDATE - d.date_of_birth) / 365.242199, 1) < (SELECT ROUND(AVG(SUM((d.hire_date - d.date_of_birth) / 365.242199)))
                                                            FROM doctors d
                                                            GROUP BY d.doctor_id);
                                                            
-- 6. Show list of patients with specialization names of doctors who they had visits with
SELECT p.patient_id, p.first_name, p.last_name, p.phone_number, s.specialization_name
FROM patients p
JOIN visits v ON v.patient_id = p.patient_id
JOIN doctors d ON d.doctor_id = v.doctor_id
JOIN specializations s ON s.specialization_id = d.specialization_id
ORDER BY p.last_name DESC, p.first_name ASC, s.specialization_name ASC;

-- 7. Display number of visits, which took place for each specialization
SELECT s.specialization_name, COUNT(v.visit_id) visits_number
FROM specializations s, doctors d, visits v
WHERE s.specialization_id = d.specialization_id AND d.doctor_id = v.doctor_id
GROUP BY s.specialization_name
ORDER BY s.specialization_name;

-- 8. Display specialization_name with doctor's id, last_name and salary of those doctors
-- who earn the most in specific specialization

-- one unnecesarry row appears... why?

SELECT s.specialization_name, d.doctor_id, d.last_name, d.salary
FROM doctors d
JOIN specializations s ON s.specialization_id = d.specialization_id
WHERE d.salary IN (SELECT MAX(d.salary)
                FROM doctors d
                RIGHT JOIN specializations s ON s.specialization_id = d.specialization_id
                GROUP BY s.specialization_name);

-- 9. Display patients registered in the hospital ward on the day of the week 
-- on which the highest number of patients were registered

SELECT v.patient_id, p.first_name, p.last_name, p.gender
FROM visits v
JOIN patients p ON p.patient_id = v.patient_id
WHERE TO_CHAR(registration_date, 'D') = (SELECT TO_CHAR(registration_date, 'D')
                                    FROM visits
                                    GROUP BY TO_CHAR(registration_date, 'D')
                                    HAVING COUNT(*) = (SELECT MAX(COUNT(*)) 
                                                        FROM visits
                                                        GROUP BY TO_CHAR(registration_date,'DAY')));
                                                        
-- 10. Display names and hire dates of all doctors who were hired
-- after Regan Hall. 
SELECT d.first_name, d.last_name, d.hire_date
FROM doctors d
WHERE d.hire_date > (SELECT d.hire_date 
                    FROM doctors d
                    WHERE d.first_name = 'Regan' AND d.last_name = 'Hall')
ORDER BY d.last_name, d.first_name, d.hire_date;
