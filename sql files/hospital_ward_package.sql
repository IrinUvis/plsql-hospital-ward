CREATE OR REPLACE PACKAGE hospital_package IS

    FUNCTION specialization_average_stay_f(specialization_name_in IN specializations.specialization_name%TYPE)
    RETURN NUMBER;
    
    FUNCTION avg_drug_dose_for_given_age_group_f(drug_name_in IN drugs.drug_name%TYPE, min_age_in IN NUMBER, max_age_in IN NUMBER)
    RETURN NUMBER;
    
    PROCEDURE show_patients_history(pat_id IN patients.patient_id%TYPE);
    
    PROCEDURE raise_salary(spec_id IN doctors.specialization_id%TYPE, proc IN number);
    
    PROCEDURE visit_outcome(vis_id IN visits.visit_id%TYPE, drg_n IN drugs.drug_name%TYPE, enddat IN prescriptions.end_date%TYPE, daily_am IN prescriptions.daily_amount%TYPE);
    
END hospital_package;
/
CREATE OR REPLACE PACKAGE BODY hospital_package IS 

    --1.
    FUNCTION specialization_average_stay_f
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

--2. 
    FUNCTION avg_drug_dose_for_given_age_group_f
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

--3.
    PROCEDURE show_patients_history(pat_id IN patients.patient_id%TYPE)
    IS
        CURSOR history IS 
            SELECT * FROM patients a 
            INNER JOIN visits b ON a.patient_id = b.patient_id 
            INNER JOIN doctors c ON c.doctor_id=b.doctor_id 
            INNER JOIN specializations d ON  c.specialization_id=d.specialization_id 
            INNER JOIN prescriptions e ON e.visit_id=b.visit_id 
            INNER JOIN drugs f ON e.drug_id=f.drug_id 
            WHERE a.patient_id=pat_id;
            
            is_found_rec BOOLEAN := false;
            pat patients%ROWTYPE;

            e EXCEPTION;
            no_rec EXCEPTION;
            pragma exception_init(e,100);

    BEGIN
        SELECT * INTO pat FROM patients WHERE patient_id=pat_id;
        
        IF pat.patient_id IS NULL THEN
            RAISE e; 
        ELSE
            dbms_output.put_line('Patient: ' || pat.first_name || ' ' || pat.last_name);
            dbms_output.put_line('Date_of_birth: ' || pat.date_of_birth);
            IF pat.gender='F' THEN
                dbms_output.put_line('Gender: Female');
            ELSE
                dbms_output.put_line('Gender: Male');
            END IF;
                dbms_output.put_line('Phone number: ' || pat.phone_number);
        END IF;

        FOR rec IN history
        LOOP  
            is_found_rec := true;
            IF rec.discharge_date IS NULL THEN
                dbms_output.put_line('Patient has a visit from ' || rec.Registration_date || ' - until now and has been served by '|| rec.specialization_name ||'. During visit patient was prescribed for '|| rec.drug_name || ' with dosage '|| rec.daily_amount || ' for time between ' || rec.start_date || ' - ' || rec.end_date );
            ELSE
                dbms_output.put_line('Patient had a visit between ' || rec.Registration_date || ' - ' || rec.discharge_date ||' and has been served by '|| rec.specialization_name || '. During visit patient was prescribed for '|| rec.drug_name ||  ' with dosage '|| rec.daily_amount || ' for time between ' || rec.start_date || ' - ' || rec.end_date );
            END IF; 
        END LOOP; 

         IF NOT is_found_rec THEN 
            RAISE no_rec;
         END IF;

    EXCEPTION
        WHEN e THEN
            dbms_output.put_line('failed');
        
        WHEN no_rec THEN
            dbms_output.put_line('Patient has no history');
    END;

--4.
    PROCEDURE raise_salary(spec_id IN doctors.specialization_id%TYPE, proc IN number)
    IS 
        is_found_rec BOOLEAN := false;    
        CURSOR c IS SELECT * FROM doctors a inner join specializations b ON a.specialization_id=b.specialization_id WHERE a.specialization_id=spec_id;
        new_max_sal_from_doc  doctors.salary%TYPE;  
        new_max_sal_from_spec doctors.salary%TYPE; 
    BEGIN    
        FOR rec IN c
        LOOP  
            is_found_rec := true;
    
            IF rec.gender = 'F' THEN
                dbms_output.put_line('Doctor '|| rec.first_name || ' '|| rec.last_name || ' had ' || rec.salary|| '. Now she will have '|| rec.salary*(1+proc/100));
            ELSE
                dbms_output.put_line('Doctor '|| rec.first_name || ' '|| rec.last_name || ' had ' || rec.salary|| '. Now he will have '|| rec.salary*(1+proc/100));
            END IF;
        END LOOP; 

        IF NOT is_found_rec THEN 
            dbms_output.put_line('No doctors in provided specialization');
        END IF;
 
 
        UPDATE doctors SET salary=salary*(1+proc/100) WHERE specialization_id=spec_id;
        SELECT MAX(salary) INTO new_max_sal_from_doc FROM doctors WHERE specialization_id=spec_id;
        SELECT MAX(max_salary) INTO new_max_sal_from_spec FROM specializations WHERE specialization_id=spec_id;
        
        IF new_max_sal_from_doc>new_max_sal_from_spec THEN
            UPDATE specializations SET max_salary=new_max_sal_from_doc WHERE specialization_id=spec_id;
        END IF;

    END;

--5.
    PROCEDURE visit_outcome(vis_id IN visits.visit_id%TYPE, drg_n IN drugs.drug_name%TYPE, enddat IN prescriptions.end_date%TYPE, daily_am IN prescriptions.daily_amount%TYPE)
    IS
        no_data EXCEPTION;
        pragma exception_init(no_data,100);
        
        vis visits%ROWTYPE; 
        
        prescr_max_id prescriptions.prescription_id%TYPE;
        is_found_rec BOOLEAN := false; 
        
        CURSOR c IS   
            SELECT * FROM prescriptions WHERE visit_id IN (SELECT visit_id FROM visits WHERE patient_id IN (SELECT patient_id FROM visits WHERE visit_id = vis_id)) 
            AND end_date < SYSDATE AND drug_id IN (SELECT drug_id FROM drugs WHERE drug_name = drg_n); 
        drug_record drugs%ROWTYPE; 
   BEGIN
        SELECT * INTO drug_record FROM drugs WHERE drug_name=drg_n;
        IF vis.visit_id IS NULL OR drug_record.drug_id IS NULL THEN
            RAISE no_data;
        END IF;
        SELECT MAX(prescription_id) INTO prescr_max_id FROM prescriptions;

        FOR rec IN c 
        LOOP
            is_found_rec := true;
            dbms_output.put_line('Patient is currently taking this drug IN daily amount of '|| rec.daily_amount);
            UPDATE prescriptions SET end_date=SYSDATE WHERE prescription_id=rec.prescription_id;
            INSERT INTO prescriptions(prescription_id , drug_id, visit_id, start_date, end_date, daily_amount) VALUES(prescr_max_id +1, drug_record.drug_id, vis_id, SYSDATE, enddat, daily_am);
            dbms_output.put_line('Successfully done');
        END LOOP;

        IF NOT is_found_rec THEN
            INSERT INTO prescriptions(prescription_id , drug_id, visit_id, start_date, end_date, daily_amount) VALUES(prescr_max_id +1, drug_record.drug_id, vis_id, SYSDATE, enddat, daily_am);
            dbms_output.put_line('Successfully done');
        END IF;
    EXCEPTION
        WHEN no_data THEN
            dbms_output.put_line('Incorrect input data.');
    END;

END hospital_package;
