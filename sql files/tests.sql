set serveroutput on;

--1. test procedure that shows patient's history
DECLARE
p_id Patients.patient_id%TYPE;
BEGIN
    select patient_id into p_id from patients where last_name = 'Kirk';
    hospital_package.show_patients_history(p_id);
END;

--2. average stay test
DECLARE
    v_temp NUMBER;
    v_specialization specializations.specialization_name%TYPE := 'Allergology';
BEGIN
    v_temp := hospital_package.specialization_average_stay_f(v_specialization);
    DBMS_OUTPUT.PUT_LINE('Average stay at ' || v_specialization || ' is ' || v_temp || ' days. ');
END;

--3. average dose per day
DECLARE
    v_temp NUMBER := 0;
    v_drug_name drugs.drug_name%TYPE := 'Zinnat';
    v_min_age NUMBER := 0;
    v_max_age NUMBER := 100;
BEGIN
    v_temp := hospital_package.avg_drug_dose_for_given_age_group_f(v_drug_name, v_min_age, v_max_age);
    DBMS_OUTPUT.PUT_LINE('An average dose of ' || v_drug_name || ' for patients from the group age between '
    || v_min_age || ' and ' || v_max_age || ' is ' || v_temp);
END;

--4. raise_salary procedure
SELECT * FROM Doctors WHERE specialization_id = 'ALRG';
exec hospital_package.raise_salary('ALRG',1);
SELECT * FROM Doctors WHERE specialization_id = 'ALRG';
rollback;

--5. visits outcome
select * from prescriptions;
EXECUTE hospital_package.visit_outcome(198,'Zellec','25-FEB-21',2);
rollback;

--6. gender from PESEL trigger
--'F' should be changed to 'M'
insert into Patients patients (
patient_id, first_name, last_name, gender, date_of_birth, phone_number)
VALUES ('12301378910', 'y', 'z', 'F', '07-JUL-1990', 123456789);

select * from patients;
rollback;

--7. visit date trigger
INSERT INTO visits (
    visit_id, doctor_id, patient_id, registration_date, discharge_date)
    VALUES (
    820384, 100, 99112799315, '09-NOV-21', '08-SEP-21');
    
    select * from Visits where visit_id = 820384;
    
    update visits set discharge_date = '08-OCT-07' where visit_id = 820384;

    rollback;
    
    --check if the date is really inserted when the value is not provided
    INSERT INTO visits (
    visit_id, doctor_id, patient_id)
    VALUES (
    820386, 100, 99112799315);
    select * from visits where visit_id = 820386;
    rollback;
    
--8. salary range trigger
--test 1: number too small
select * from specializations where specialization_id = 'NRLG';
INSERT INTO doctors (
    doctor_id, specialization_id, first_name, last_name, gender, date_of_birth, phone_number, hire_date, salary)
    VALUES (
    10001, 'NRLG', 'Mariam', 'Navaro', 'F', '15-FEB-1975', 123654789, '12-MAY-2017', 6000);
select * from doctors where doctor_id = 10001;
rollback;

--test 2: number too high
select * from specializations where specialization_id = 'NRLG';
INSERT INTO doctors (
    doctor_id, specialization_id, first_name, last_name, gender, date_of_birth, phone_number, hire_date, salary)
    VALUES (
    10001, 'NRLG', 'Mariam', 'Navaro', 'F', '15-FEB-1975', 123654789, '12-MAY-2017', 40000);
select * from doctors where doctor_id = 10001;
rollback;
--9. birth date from PESEL trigger

--try to insert person who was (will be?) born in 2083 and is a male 
 insert into Patients patients (
    patient_id, first_name, last_name, gender, date_of_birth, phone_number)
    VALUES ('83223178910', 'x', 'y', 'F', '07-JUL-1990', 123456789);
select * from Patients where first_name = 'x';
rollback;