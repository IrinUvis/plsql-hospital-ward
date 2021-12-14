set serveroutput on;

--trigger 1, check if the gender maches the value indicated by the pesel
CREATE OR REPLACE TRIGGER pesel_check BEFORE INSERT OR UPDATE ON Patients
FOR EACH ROW
DECLARE
l_gender_number NUMBER;
BEGIN
    l_gender_number := SUBSTR(:NEW.patient_id, -2, 1);
    IF MOD(l_gender_number, 2) = 0 AND :NEW.gender != 'F' THEN
        :NEW.gender := 'F';
    ELSIF MOD(l_gender_number, 2) = 1 AND :NEW.gender != 'M' THEN
        :NEW.gender := 'M';
    END IF;
END;

--test
    --the 'F' should be changed to 'M'
    insert into Patients patients (
    patient_id, first_name, last_name, gender, date_of_birth, phone_number)
    VALUES ('12301378910', 'y', 'z', 'F', '07-JUL-1990', 123456789);

select * from patients;
rollback;

--trigger 2: if the discharge date is earlier than the registration, react 
CREATE OR REPLACE TRIGGER visit_dates_trg BEFORE INSERT OR UPDATE ON visits
FOR EACH ROW 
BEGIN
    IF :NEW.registration_date IS NULL THEN
        :NEW.registration_date := SYSDATE;
    ELSIF :NEW.registration_date > :NEW.discharge_date THEN
        :NEW.discharge_date := :NEW.registration_date;
    END IF;
END;

--test
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
    
--trigger 3: check if the salary is between the range for the given specialization
CREATE OR REPLACE TRIGGER salary_check BEFORE INSERT OR UPDATE ON Doctors
FOR EACH ROW
DECLARE 
max_sal Specializations.max_salary%TYPE;
min_sal specializations.min_salary%TYPE;   
BEGIN
    SELECT max_salary, min_salary INTO max_sal, min_sal FROM Specializations WHERE specialization_id = :NEW.specialization_id;
    IF :NEW.salary > max_sal THEN
        :NEW.salary := max_sal;
    ELSIF :NEW.salary < min_sal THEN
        :NEW.salary := min_sal;
    END IF;
END;

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

--trigger 4: check and put proper birth date based on the pesel
CREATE OR REPLACE TRIGGER check_birth_date_trg BEFORE INSERT OR UPDATE ON Patients
FOR EACH ROW
DECLARE
l_date patients.date_of_birth%TYPE;
l_str_date VARCHAR2(6);
BEGIN
    l_str_date := substr(:NEW.patient_id, 0, 6);
    IF SUBSTR(l_str_date, 3, 1) > 1 THEN
        l_str_date := REGEXP_REPLACE(l_str_date, SUBSTR(l_str_date, 3, 1), '1', 3, 1);
    END IF;
    l_date := TO_DATE(l_str_date, 'YYMMDD');
    IF :NEW.date_of_birth != l_date THEN
        :NEW.date_of_birth := l_date;
    END IF;
END;


--try to insert person who was (will be?) born in 2083 and is a male 
 insert into Patients patients (
    patient_id, first_name, last_name, gender, date_of_birth, phone_number)
    VALUES ('83223178910', 'x', 'y', 'F', '07-JUL-1990', 123456789);
select * from Patients where first_name = 'x';
rollback;