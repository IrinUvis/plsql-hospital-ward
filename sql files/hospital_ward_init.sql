------------
-- TABLES --
------------ 
CREATE TABLE specializations (
    specialization_id VARCHAR2(10) NOT NULL,
    specialization_name VARCHAR2(15) NOT NULL,
    min_salary NUMBER(8, 2),  
    max_salary NUMBER(8, 2),
    CONSTRAINT pk_specializations
        PRIMARY KEY (specialization_id)
);

CREATE TABLE patients (
    patient_id VARCHAR2(11) NOT NULL, 
    first_name VARCHAR2(20) NOT NULL,  
    last_name VARCHAR2(20) NOT NULL,
    gender CHAR(1) NOT NULL, 
    date_of_birth DATE NOT NULL,
    phone_number NUMBER(9) CHECK (phone_number BETWEEN 111111111 AND 999999999),
    CONSTRAINT pk_patients
        PRIMARY KEY (patient_id)
);

CREATE TABLE doctors (
    doctor_id NUMBER(6) NOT NULL,
    specialization_id VARCHAR2(10) NOT NULL,
    first_name VARCHAR2(20) NOT NULL,
    last_name VARCHAR2(20) NOT NULL,
    gender CHAR(1) NOT NULL, 
    date_of_birth DATE NOT NULL,
    phone_number NUMBER(9) CHECK (phone_number BETWEEN 111111111 AND 999999999), 
    hire_date DATE NOT NULL,   
    salary NUMBER(8, 2), 
    CONSTRAINT pk_doctors
        PRIMARY KEY (doctor_id),
    CONSTRAINT fk_specializations_doctor
        FOREIGN KEY (specialization_id)
        REFERENCES specializations(specialization_id)
);

CREATE TABLE visits (
    visit_id NUMBER(6) NOT NULL,
    doctor_id NUMBER(6) NOT NULL,
    patient_id VARCHAR2(11) NOT NULL,
    registration_date DATE, 
    discharge_date DATE,
    CONSTRAINT pk_visits
        PRIMARY KEY (visit_id),
    CONSTRAINT fk_doctors_visit
        FOREIGN KEY (doctor_id)
        REFERENCES doctors(doctor_id),
    CONSTRAINT fk_patients_visit
        FOREIGN KEY (patient_id)
        REFERENCES patients(patient_id)
);

CREATE TABLE drugs (
    drug_id NUMBER(6) NOT NULL,
    drug_name VARCHAR2(20) NOT NULL,
    drug_description VARCHAR2(200), 
    dosage_method VARCHAR2(50),
    CONSTRAINT pk_drugs
        PRIMARY KEY (drug_id)
);

CREATE TABLE prescriptions (
    prescription_id NUMBER(6) NOT NULL,
    drug_id NUMBER(6) NOT NULL,
    visit_id NUMBER(6) NOT NULL,
    start_date DATE,
    end_date DATE,
    daily_amount NUMBER(2),
    CONSTRAINT pk_prescriptions
        PRIMARY KEY (prescription_id),
    CONSTRAINT fk_drugs_prescription
        FOREIGN KEY (drug_id)
        REFERENCES drugs(drug_id),
    CONSTRAINT fk_visits_prescription
        FOREIGN KEY (visit_id)
        REFERENCES visits(visit_id)
);

--------------
-- TRIGGERS --
--------------

-- 1. Check if the gender maches the value indicated by the pesel
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
/

-- 2. If the discharge date is earlier than the registration, react 
CREATE OR REPLACE TRIGGER visit_dates_trg BEFORE INSERT OR UPDATE ON visits
FOR EACH ROW 
BEGIN
    IF :NEW.registration_date IS NULL THEN
        :NEW.registration_date := SYSDATE;
    ELSIF :NEW.registration_date > :NEW.discharge_date THEN
        :NEW.discharge_date := :NEW.registration_date;
        dbms_output.put_line('The discharge date was incorrect and it was changed to ' || :NEW.registration_date ||'. If you think that another date should be set, please update it.');
    END IF;
END;
/
    
-- 3. Check if the salary is between the range for the given specialization
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
/

-- 4. Check and put proper birth date based on the pesel
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
/
-------------
-- INSERTS --
-------------

-- SPECIALIZATIONS (5) --
INSERT INTO specializations (
    specialization_id, specialization_name, min_salary, max_salary) 
    VALUES (
    'ALRG', 'Allergology', 8000, 12000);

INSERT INTO specializations (
    specialization_id, specialization_name, min_salary, max_salary) 
    VALUES (
    'DRMTLG', 'Dermatology', 9000, 12000);
    
INSERT INTO specializations (
    specialization_id, specialization_name, min_salary, max_salary) 
    VALUES (
    'NRLG', 'Neurology', 10000, 18000);

INSERT INTO specializations (
    specialization_id, specialization_name, min_salary, max_salary) 
    VALUES (
    'OPTMLG', 'Opthalmology', 7000, 14000);

INSERT INTO specializations (
    specialization_id, specialization_name, min_salary, max_salary) 
    VALUES (
    'PDTR', 'Pediatrics', 9000, 14000); 

-- PATIENTS (15) --
INSERT INTO patients (
    patient_id, first_name, last_name, gender, date_of_birth, phone_number)
    VALUES (
    '06311195765', 'Nita', 'Kirk', 'F', '11-NOV-2006', 123456789);

INSERT INTO patients (
    patient_id, first_name, last_name, gender, date_of_birth, phone_number)
    VALUES (
    '90030725158', 'Kennedy', 'Castro', 'M', '07-MAR-1990', 123837287);

INSERT INTO patients (
    patient_id, first_name, last_name, gender, date_of_birth, phone_number)
    VALUES (
    '70070997328', 'Carolyn', 'Leonard', 'F', '09-JUL-1970', 987236432);

INSERT INTO patients (
    patient_id, first_name, last_name, gender, date_of_birth, phone_number)
    VALUES (
    '76112994322', 'Ella', 'Hart', 'F', '29-NOV-1976', 190630213);

INSERT INTO patients (
    patient_id, first_name, last_name, gender, date_of_birth, phone_number)
    VALUES (
    '02321071419', 'Steven', 'Mccullough', 'M', '10-DEC-2002', 123085462);

INSERT INTO patients (
    patient_id, first_name, last_name, gender, date_of_birth, phone_number)
    VALUES (
    '98071691256', 'Alan', 'Gilliam', 'M', '16-JUL-1998', 209012345);

INSERT INTO patients (
    patient_id, first_name, last_name, gender, date_of_birth, phone_number)
    VALUES (
    '99112799315', 'Lev', 'Best', 'M', '27-NOV-1999', 172607232);

INSERT INTO patients (
    patient_id, first_name, last_name, gender, date_of_birth, phone_number)
    VALUES (
    '07240566718', 'David', 'Roberts', 'M', '05-APR-2007', 187293231);

INSERT INTO patients (
    patient_id, first_name, last_name, gender, date_of_birth, phone_number)
    VALUES (
    '90070717823', 'Heather', 'Spears', 'F', '07-JUL-1990', 908072083);

INSERT INTO patients (
    patient_id, first_name, last_name, gender, date_of_birth, phone_number)
    VALUES (
    '00212967263', 'Alexa', 'Willis', 'F', '29-JAN-2000', 120830421);

INSERT INTO patients (
    patient_id, first_name, last_name, gender, date_of_birth, phone_number)
    VALUES (
    '77060359843', 'Liberty', 'Ellison', 'F', '03-JUN-1977', 987127654);

INSERT INTO patients (
    patient_id, first_name, last_name, gender, date_of_birth, phone_number)
    VALUES (
    '96042141876', 'Daquan', 'Harper', 'M', '21-APR-1996', 191182034);

INSERT INTO patients (
    patient_id, first_name, last_name, gender, date_of_birth, phone_number)
    VALUES (
    '84062395649', 'Idona', 'Jennings', 'F', '23-JUN-1984', 128795463);

INSERT INTO patients (
    patient_id, first_name, last_name, gender, date_of_birth, phone_number)
    VALUES (
    '91092863279', 'Hakeem', 'William', 'M', '28-SEP-1991', 987654321);

INSERT INTO patients (
    patient_id, first_name, last_name, gender, date_of_birth, phone_number)
    VALUES (
    '80082048978', 'Jerome', 'Saunders', 'M', '20-AUG-1980', 123098765);

-- DOCTORS (10) --
INSERT INTO doctors (
    doctor_id, specialization_id, first_name, last_name, gender, date_of_birth, phone_number, hire_date, salary)
    VALUES (
    100, 'NRLG', 'Mariam', 'Navaro', 'F', '15-FEB-1975', 123654789, '12-MAY-2017', 12000);

INSERT INTO doctors (
    doctor_id, specialization_id, first_name, last_name, gender, date_of_birth, phone_number, hire_date, salary)
    VALUES (
    101, 'PDTR', 'Hanna', 'Sandoval', 'F', '15-APR-1994', 901234567, '12-JUN-2020', 10000);

INSERT INTO doctors (
    doctor_id, specialization_id, first_name, last_name, gender, date_of_birth, phone_number, hire_date, salary)
    VALUES (
    102, 'PDTR', 'Helen', 'Le', 'F', '15-NOV-1974', 890123456, '15-MAY-2012', 11000);         

INSERT INTO doctors (
    doctor_id, specialization_id, first_name, last_name, gender, date_of_birth, phone_number, hire_date, salary)
    VALUES (
    103, 'PDTR', 'Hakeem', 'Neal', 'M', '15-DEC-1974', 789012345, '17-APR-1998', 14000); 

INSERT INTO doctors (
    doctor_id, specialization_id, first_name, last_name, gender, date_of_birth, phone_number, hire_date, salary)
    VALUES (
    104, 'PDTR', 'Xander', 'Ellis', 'F', '17-OCT-1974', 678901234, '09-OCT-1999', 13000); 

INSERT INTO doctors (
    doctor_id, specialization_id, first_name, last_name, gender, date_of_birth, phone_number, hire_date, salary)
    VALUES (
    105, 'DRMTLG', 'Xenos', 'Wilder', 'F', '22-MAR-1974', 567890123, '07-FEB-2018', 10500); 

INSERT INTO doctors (
    doctor_id, specialization_id, first_name, last_name, gender, date_of_birth, phone_number, hire_date, salary)
    VALUES (
    106, 'DRMTLG', 'Regan', 'Hall', 'F', '09-FEB-1974', 456789012, '05-FEB-2013', 11000); 

INSERT INTO doctors (
    doctor_id, specialization_id, first_name, last_name, gender, date_of_birth, phone_number, hire_date, salary)
    VALUES (
    107, 'DRMTLG', 'Ignacia', 'Reyes', 'F', '28-MAY-1974', 345678901, '03-DEC-2015', 10000); 

INSERT INTO doctors (
    doctor_id, specialization_id, first_name, last_name, gender, date_of_birth, phone_number, hire_date, salary)
    VALUES (
    108, 'ALRG', 'Reuben', 'Mays', 'F', '11-OCT-1979', 234567890, '27-DEC-2001', 9500); 
                         
INSERT INTO doctors (
    doctor_id, specialization_id, first_name, last_name, gender, date_of_birth, phone_number, hire_date, salary)
    VALUES (
    109, 'ALRG', 'Nora', 'Perkins', 'F', '15-OCT-1977', 123456789, '21-DEC-2005', 9000);

-- VISITS (10) --     
INSERT INTO visits (
    visit_id, doctor_id, patient_id, registration_date, discharge_date)
    VALUES (
    100, 101, '06311195765', '08-JAN-2021', '10-FEB-2021');

INSERT INTO visits (
    visit_id, doctor_id, patient_id, registration_date)
    VALUES (
    101, 101, '90030725158', '27-MAR-2019');

INSERT INTO visits (
    visit_id, doctor_id, patient_id, registration_date)
    VALUES (
    102, 103, '70070997328', '12-MAY-2018');

INSERT INTO visits (
    visit_id, doctor_id, patient_id, registration_date)
    VALUES (
    103, 104, '76112994322', '08-DEC-2020');

INSERT INTO visits (
    visit_id, doctor_id, patient_id, registration_date)
    VALUES (
    104, 105, '02321071419', '08-OCT-2020');

INSERT INTO visits (
    visit_id, doctor_id, patient_id, registration_date)
    VALUES (
    105, 102, '98071691256', '08-NOV-2019');

INSERT INTO visits (
    visit_id, doctor_id, patient_id, registration_date, discharge_date)
    VALUES (
    106, 100, '99112799315', '09-NOV-2021', '09-DEC-2021');

INSERT INTO visits (
    visit_id, doctor_id, patient_id, registration_date, discharge_date)
    VALUES (
    107, 109, '07240566718', '03-FEB-2021', '08-FEB-2021');

INSERT INTO visits (
    visit_id, doctor_id, patient_id, registration_date, discharge_date)
    VALUES (
    108, 108, '90070717823', '07-FEB-2021', '08-FEB-2021');

INSERT INTO visits (
    visit_id, doctor_id, patient_id, registration_date, discharge_date)
    VALUES (
    109, 107, '00212967263', '01-JAN-2021', '09-APR-2021');

-- DRUGS (8) --
INSERT INTO drugs (
    drug_id, drug_name, drug_description, dosage_method) 
    VALUES (
    100, 'Cezera', 'Cezera helps to cope with allergy for grasses and birch', 'swallow');

INSERT INTO drugs (
    drug_id, drug_name, drug_description, dosage_method) 
    VALUES (
    101, 'Zinnat', 'Death to bacteries', 'swallow');

INSERT INTO drugs (
    drug_id, drug_name, drug_description, dosage_method) 
    VALUES (
    102, 'Augmenti', 'Death to bacteries', 'swallow');

INSERT INTO drugs (
    drug_id, drug_name, drug_description, dosage_method) 
    VALUES (
    103, 'Dexametazon', 'Helps to increase immunity', 'swallow');

INSERT INTO drugs (
    drug_id, drug_name, drug_description, dosage_method) 
    VALUES (
    104, 'Flixonaze Nasule', 'Helps with occlusion of nose', 'instill');

INSERT INTO drugs (
    drug_id, drug_name, drug_description, dosage_method) 
    VALUES (
    105, 'Valtrikon', 'Helps to keep the pressure down', 'swallow');

INSERT INTO drugs (
    drug_id, drug_name, drug_description, dosage_method) 
    VALUES (
    106, 'Dexilan', 'Helps with stomach pain', 'swallow');

INSERT INTO drugs (
    drug_id, drug_name, drug_description, dosage_method) 
    VALUES (
    107, 'Rosvera', 'Helps to lower cholesterol level', 'inject');

-- PRESCRIPTIONS (6) - --
INSERT INTO prescriptions (
    prescription_id, drug_id, visit_id, start_date, end_date, daily_amount)
    VALUES (
    100, 100, 100, '11-FEB-2021', '25-FEB-2021', 2);

INSERT INTO prescriptions (
    prescription_id, drug_id, visit_id, start_date, end_date, daily_amount)
    VALUES (
    101, 101, 100, '11-FEB-2021', '25-FEB-2021', 1);

INSERT INTO prescriptions (
    prescription_id, drug_id, visit_id)
    VALUES (
    102, 104, 103);

INSERT INTO prescriptions (
    prescription_id, drug_id, visit_id)
    VALUES (
    103, 106, 105);

INSERT INTO prescriptions (
    prescription_id, drug_id, visit_id, start_date, end_date, daily_amount)
    VALUES (
    104, 106, 108, '08-FEB-2021', '15-FEB-2021', 2);

INSERT INTO prescriptions (
    prescription_id, drug_id, visit_id, start_date, end_date, daily_amount)
    VALUES (
    105, 107, 108, '08-FEB-2021', '22-FEB-2021', 3);

INSERT INTO prescriptions (
    prescription_id, drug_id, visit_id, start_date, end_date, daily_amount)
    VALUES (
    106, 101, 102, '05-JAN-2021', '12-JAN-2021', 2);
