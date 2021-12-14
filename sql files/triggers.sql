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
