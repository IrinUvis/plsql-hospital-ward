set serveroutput on;

--trigger 1, check if the pesel has correct syntax
CREATE OR REPLACE TRIGGER pesel_check BEFORE INSERT OR UPDATE ON Patients
FOR EACH ROW
BEGIN
    IF LENGTH(:NEW.patient_id) != 11 THEN
        raise_application_error(-20001, 'PESEL should contain exactly 11 digits. Insert aborted.');
    END IF;
END;

--test
    --correct - should be inserted
    insert into Patients patients (
    patient_id, first_name, last_name, gender, date_of_birth, phone_number)
    VALUES (12345678910, 'x', 'y', 'm', '07-JUL-1990', 123456789);
    --should be aborted
    insert into Patients patients (
    patient_id, first_name, last_name, gender, date_of_birth, phone_number)
    VALUES (11, 'x', 'y', 'm', '07-JUL-1990', 123456789);
select * from patients;
rollback;

--trigger 2
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
    rollback;
    update visits set discharge_date = '08-OCT-07' where visit_id = 820384;
    delete from visits where visit_id = 820384;
    
    --check if the date is really inserted
    INSERT INTO visits (
    visit_id, doctor_id, patient_id)
    VALUES (
    820386, 100, 99112799315);
    select * from visits where visit_id = 820386;
    rollback;
    
--trigger 3 
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

--test 1
select * from specializations where specialization_id = 'NRLG';
INSERT INTO doctors (
    doctor_id, specialization_id, first_name, last_name, gender, date_of_birth, phone_number, hire_date, salary)
    VALUES (
    10001, 'NRLG', 'Mariam', 'Navaro', 'F', '15-FEB-197', 123654789, '12-MAY-2017', 6000);
select * from doctors where doctor_id = 10001;
rollback;

--test 2
select * from specializations where specialization_id = 'NRLG';
INSERT INTO doctors (
    doctor_id, specialization_id, first_name, last_name, gender, date_of_birth, phone_number, hire_date, salary)
    VALUES (
    10001, 'NRLG', 'Mariam', 'Navaro', 'F', '15-FEB-197', 123654789, '12-MAY-2017', 40000);
select * from doctors where doctor_id = 10001;
rollback;