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
    100, 'NRLG', 'Mariam', 'Navaro', 'F', '15-FEB-197', 123654789, '12-MAY-2017', 12000);

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
    drug_id, drug_name, drug_description, dosage_method, serial_number) 
    VALUES (
    100, 'Cezera', 'Cezera helps to cope with allergy for grasses and birch', 'swallow', 123456);

INSERT INTO drugs (
    drug_id, drug_name, drug_description, dosage_method, serial_number) 
    VALUES (
    101, 'Zinnat', 'Death to bacteries', 'swallow', 123123);

INSERT INTO drugs (
    drug_id, drug_name, drug_description, dosage_method, serial_number) 
    VALUES (
    102, 'Augmenti', 'Death to bacteries', 'swallow', 231231);

INSERT INTO drugs (
    drug_id, drug_name, drug_description, dosage_method, serial_number) 
    VALUES (
    103, 'Dexametazon', 'Helps to increase immunity', 'swallow', 534134);

INSERT INTO drugs (
    drug_id, drug_name, drug_description, dosage_method, serial_number) 
    VALUES (
    104, 'Flixonaze Nasule', 'Helps with occlusion of nose', 'instill', 123124);

INSERT INTO drugs (
    drug_id, drug_name, drug_description, dosage_method, serial_number) 
    VALUES (
    105, 'Valtrikon', 'Helps to keep the pressure down', 'swallow', 756345);

INSERT INTO drugs (
    drug_id, drug_name, drug_description, dosage_method, serial_number) 
    VALUES (
    106, 'Dexilan', 'Helps with stomach pain', 'swallow', 892823);

INSERT INTO drugs (
    drug_id, drug_name, drug_description, dosage_method, serial_number) 
    VALUES (
    107, 'Rosvera', 'Helps to lower cholesterol level', 'inject', 123341);

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
