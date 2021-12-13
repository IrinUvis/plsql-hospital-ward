set serveroutput on;

-- function calculating avarege length of a hospital stay for patients of a given as a parameter specialization

CREATE OR REPLACE FUNCTION specialization_average_stay_f
    (specialization_name_in IN specializations.specialization_name%TYPE)
    RETURN NUMBER
IS
    v_correctness_check NUMBER := 0;
    v_total_stay NUMBER := 0;
    v_patients_number NUMBER := 0;
    v_days_difference NUMBER := 0;
    
    CURSOR visits_cur IS
    SELECT v.registration_date, v.discharge_date
    FROM visits v
    JOIN patients p ON p.patient_id = v.patient_id
    JOIN doctors d ON d.doctor_id = v.doctor_id
    JOIN specializations s ON s.specialization_id = d.specialization_id
    WHERE s.specialization_name = specialization_name_in;
    
    no_sepcialization_found EXCEPTION;
    no_visits_found EXCEPTION;
    each_patient_start_or_end_date_is_null EXCEPTION;
BEGIN
    SELECT COUNT(*) INTO v_correctness_check
    FROM specializations
    WHERE specialization_name = specialization_name_in;
    
    IF v_correctness_check = 0 THEN
        RAISE no_sepcialization_found;
    END IF;
    v_correctness_check := 0;

    FOR visit IN visits_cur
    LOOP
        IF visit.registration_date IS NULL OR visit.discharge_date IS NULL THEN
            v_correctness_check := v_correctness_check + 1;
            CONTINUE;
        END IF;
        v_patients_number := v_patients_number + 1;
        v_days_difference := visit.discharge_date - visit.registration_date;
        v_total_stay := v_total_stay + v_days_difference;
    END LOOP;
    
    IF v_correctness_check > 0 AND v_patients_number = 0 THEN
        RAISE each_patient_start_or_end_date_is_null;
    ELSIF v_patients_number = 0 THEN
        RAISE no_visits_found;
    END IF;
    
    RETURN v_total_stay / v_patients_number;
EXCEPTION
    WHEN no_sepcialization_found THEN
        DBMS_OUTPUT.PUT_LINE('There is no specialization with given name');
        RETURN 0;
    WHEN each_patient_start_or_end_date_is_null THEN
        DBMS_OUTPUT.PUT_LINE('There is no information on stay lengths for given specialization');
        RETURN 0;
    WHEN no_visits_found THEN
        DBMS_OUTPUT.PUT_LINE('There are no visits registered for given specialization');
        RETURN 0;
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Other unpredicted error occured');
        RETURN 0;
END specialization_average_stay_f;

DECLARE
    v_temp NUMBER;
    v_specialization specializations.specialization_name%TYPE := 'Allergology';
BEGIN
    v_temp := specialization_average_stay_f(v_specialization);
    DBMS_OUTPUT.PUT_LINE('Average stay at ' || v_specialization || ' is ' || v_temp || ' days. ');
END;

-- function calculating average dose per day of a drug with given name for patients from a given age group

CREATE OR REPLACE FUNCTION avg_drug_dose_for_given_age_group_f
    (drug_name_in IN drugs.drug_name%TYPE, min_age_in IN NUMBER, max_age_in IN NUMBER)
    RETURN NUMBER
IS
    v_patients_number NUMBER := 0;
    v_total_drugs_amount NUMBER := 0;
    v_correctness_check NUMBER := 0;
    
    CURSOR drug_dosage_cur IS
    SELECT pr.daily_amount
    FROM prescriptions pr
    JOIN visits v ON v.visit_id = pr.visit_id
    JOIN patients pa ON pa.patient_id = v.patient_id
    JOIN drugs d ON d.drug_id = pr.drug_id
    WHERE ROUND((SYSDATE - pa.date_of_birth) / 365.242199, 0) > min_age_in AND
            ROUND((SYSDATE - pa.date_of_birth) / 365.242199, 1) < max_age_in AND
            d.drug_name = drug_name_in;
            
    no_drug_found EXCEPTION;
    improper_age EXCEPTION;
    each_patient_drug_daily_amount_is_null EXCEPTION;
    no_prescriptions_found EXCEPTION;
    age_value_is_null EXCEPTION;
            
BEGIN
    SELECT COUNT(*) INTO v_correctness_check
    FROM drugs
    WHERE drug_name = drug_name_in;
    
    IF v_correctness_check = 0 THEN
        RAISE no_drug_found;
    END IF;
    v_correctness_check := 0;
    
    IF min_age_in < 0 OR min_age_in > 150 THEN
        RAISE improper_age;
    ELSIF max_age_in < 0 OR max_age_in > 150 THEN
        RAISE improper_age;
    ELSIF min_age_in IS NULL OR max_age_in IS NULL THEN
        RAISE age_value_is_null;
    END IF;

    FOR drug IN drug_dosage_cur
    LOOP
        IF drug.daily_amount IS NULL THEN
        v_correctness_check := v_correctness_check + 1;
            CONTINUE;
        END IF;
        v_patients_number := v_patients_number + 1;
        v_total_drugs_amount := v_total_drugs_amount + drug.daily_amount;
        
    END LOOP;
    
    IF v_correctness_check > 0 AND v_patients_number = 0 THEN
        RAISE each_patient_drug_daily_amount_is_null;
    ELSIF v_patients_number = 0 THEN
        RAISE no_prescriptions_found;
    END IF;
    
    RETURN ROUND(v_total_drugs_amount / v_patients_number, 1);
EXCEPTION
    WHEN no_drug_found THEN
        DBMS_OUTPUT.PUT_LINE('There is no drug with given name');
        RETURN 0;
    WHEN improper_age THEN
        DBMS_OUTPUT.PUT_LINE('Given age limits are improper values. The value cannot exceed the range from 0 to 150. ');
        RETURN 0;
    WHEN each_patient_drug_daily_amount_is_null THEN
        DBMS_OUTPUT.PUT_LINE('There is no information on daily amounts of drugs prescribed for patients from given age range. ');
        RETURN 0;
    WHEN no_prescriptions_found THEN
        DBMS_OUTPUT.PUT_LINE('No prescriptions for given drug were found for patients within the specified age range. ');
        RETURN 0;
    WHEN age_value_is_null THEN
        DBMS_OUTPUT.PUT_LINE('There appeared null value among the given age limits. ');
        RETURN 0;
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Other unpredicted error occured');
        RETURN 0;
END avg_drug_dose_for_given_age_group_f;

DECLARE
    v_temp NUMBER := 0;
    v_drug_name drugs.drug_name%TYPE := 'Zinnat';
    v_min_age NUMBER := 0;
    v_max_age NUMBER := 100;
BEGIN
    v_temp := avg_drug_dose_for_given_age_group_f(v_drug_name, v_min_age, v_max_age);
    DBMS_OUTPUT.PUT_LINE('An average dose of ' || v_drug_name || ' for patients from the group age between '
    || v_min_age || ' and ' || v_max_age || ' is ' || v_temp);
END;
