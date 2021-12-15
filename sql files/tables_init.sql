-- TABELE  

-- specjalizacja
CREATE TABLE specializations (
    specialization_id VARCHAR2(10) NOT NULL,
    specialization_name VARCHAR2(15) NOT NULL,
    min_salary NUMBER(8, 2),  
    max_salary NUMBER(8, 2),
    CONSTRAINT pk_specializations
        PRIMARY KEY (specialization_id)
);

-- pacjent
CREATE TABLE patients (
    patient_id VARCHAR2(11) NOT NULL, -- PESEL trigger czy inna funkcja upewniająca się, że format jest git lub
    first_name VARCHAR2(20) NOT NULL,  -- wstawiająca datę urodzenia zależnie od peselu czy coś?
    last_name VARCHAR2(20) NOT NULL,
    gender CHAR(1) NOT NULL, -- tutaj mozna dac trigger do tworzenia i edycji upewniajacy sie ze ta wartosc to M dla faceta, F dla kobiety
    date_of_birth DATE NOT NULL,
    phone_number NUMBER(9) CHECK (phone_number BETWEEN 111111111 AND 999999999),
    CONSTRAINT pk_patients
        PRIMARY KEY (patient_id)
);

-- lekarz
CREATE TABLE doctors (
    doctor_id NUMBER(6) NOT NULL,
    specialization_id VARCHAR2(10) NOT NULL,
    first_name VARCHAR2(20) NOT NULL,
    last_name VARCHAR2(20) NOT NULL,
    gender CHAR(1) NOT NULL, -- tutaj mozna dac trigger do tworzenia i edycji upewniajacy sie ze ta wartosc to M dla faceta, F dla kobiety
    date_of_birth DATE NOT NULL,
    phone_number NUMBER(9) CHECK (phone_number BETWEEN 111111111 AND 999999999), -- upewnienie sie ze ma 9 cyfr
    hire_date DATE NOT NULL,   
    salary NUMBER(8, 2), -- trigger sprawdzanie czy ustawiany salary miesci sie w widelkach min i max salary dla specjalizacji
    CONSTRAINT pk_doctors
        PRIMARY KEY (doctor_id),
    CONSTRAINT fk_specializations_doctor
        FOREIGN KEY (specialization_id)
        REFERENCES specializations(specialization_id)
);

-- wizyta
CREATE TABLE visits (
    visit_id NUMBER(6) NOT NULL,
    doctor_id NUMBER(6) NOT NULL,
    patient_id VARCHAR2(11) NOT NULL,
    registration_date DATE, -- trigger upewniajacy sie ze discharge_date jest tego samego dnia lub pozniej niz registration_date
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

-- lek
CREATE TABLE drugs (
    drug_id NUMBER(6) NOT NULL,
    drug_name VARCHAR2(20) NOT NULL,
    drug_description VARCHAR2(200), -- nie moglo byc description bo to jakis keyword w plsql
    dosage_method VARCHAR2(50),
    CONSTRAINT pk_drugs
        PRIMARY KEY (drug_id)
);

-- recepta (jeslli nie ma zaleconego leku to wgl nie ma recepty) - taki ukryty many to many
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
