CREATE OR REPLACE PACKAGE hospital_package IS

    FUNCTION specialization_average_stay_f(specialization_name_in IN specializations.specialization_name%TYPE)
    RETURN NUMBER;
    
    FUNCTION avg_drug_dose_for_given_age_group_f(drug_name_in IN drugs.drug_name%TYPE, min_age_in IN NUMBER, max_age_in IN NUMBER)
    RETURN NUMBER;
    
    PROCEDURE show_patients_history(pat_id in patients.patient_id%type);
    
    PROCEDURE raise_salary(spec_id in doctors.specialization_id%type, proc in number);
    
    PROCEDURE visit_outcome(doc_id in doctors.doctor_id%type, vis_id in visits.visit_id%type, pt_id in patients.patient_id%type, drg_n in drugs.drug_name%type, 
    enddat in prescriptions.end_date%type, daily_am in prescriptions.daily_amount%type);
    
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
    procedure show_patients_history(pat_id in patients.patient_id%type)
    is
        cursor history is select * from patients a inner join visits b on a.patient_id = b.patient_id 
        inner join doctors c on c.doctor_id=b.doctor_id 
        inner join specializations d on c.specialization_id=d.specialization_id 
        inner join prescriptions e on e.visit_id=b.visit_id 
        inner join drugs f on e.drug_id=f.drug_id where a.patient_id=pat_id;
        
        is_found_rec boolean := false;
        pat patients%rowtype;

        e exception;
        no_rec exception;
        pragma exception_init(e,100);

    begin
        --check if record pesel is valid
        select * into pat from patients where patient_id=pat_id;
        if pat.patient_id is null then
            raise e;
        else
            dbms_output.put_line('Patient: ' || pat.first_name || ' ' || pat.last_name);
            dbms_output.put_line('Date_of_birth: ' || pat.date_of_birth);
            if pat.gender='F' then
                dbms_output.put_line('Gender: Female');
            else
                dbms_output.put_line('Gender: Male');
            end if;
            dbms_output.put_line('Phone number: ' || pat.phone_number);
        end if;

        FOR rec IN history
        LOOP  
            is_found_rec := true;
            dbms_output.put_line('Tutaj string z info o historii');
        END LOOP; 

        if not is_found_rec then 
            raise no_rec;
        end if;
    exception
        when e then
            dbms_output.put_line('failed');
    
        when no_rec then
            dbms_output.put_line('Patient has no history');
    end;

--4.
    procedure raise_salary(spec_id in doctors.specialization_id%type, proc in number)
    IS 
        is_found_rec boolean := false;    
        CURSOR c is select * from doctors a inner join specializations b on a.specialization_id=b.specialization_id where a.specialization_id=spec_id;
        new_max_sal_from_doc  doctors.salary%type;  
        new_max_sal_from_spec doctors.salary%type; 
    BEGIN    

        FOR rec IN c
        LOOP  
            is_found_rec := true;
    
            if rec.gender = 'F' then
                dbms_output.put_line('Doctor '|| rec.first_name || ' '|| rec.last_name || ' had ' || rec.salary|| '. Now she will have '|| rec.salary*(1+proc/100));
            else
                dbms_output.put_line('Doctor '|| rec.first_name || ' '|| rec.last_name || ' had ' || rec.salary|| '. Now he will have '|| rec.salary*(1+proc/100));
            end if;
        END LOOP; 

        if not is_found_rec then 
            dbms_output.put_line('No doctors in provided specialization');
        end if;
 
 
        update doctors set salary=salary*(1+proc/100) where specialization_id=spec_id;
        select max(salary) into new_max_sal_from_doc from doctors where specialization_id=spec_id;
        select max(max_salary) into new_max_sal_from_spec from specializations where specialization_id=spec_id;
        
        if new_max_sal_from_doc>new_max_sal_from_spec then
            update specializations set max_salary=new_max_sal_from_doc where specialization_id=spec_id;
        end if;

    end;

--5.
    procedure visit_outcome(doc_id in doctors.doctor_id%type, vis_id in visits.visit_id%type, pt_id in patients.patient_id%type, 
    drg_n in drugs.drug_name%type, enddat in prescriptions.end_date%type, daily_am in prescriptions.daily_amount%type)
    is
        doc doctors.doctor_id%type;
        no_data exception;
        pragma exception_init(no_data,100);
        drg drugs%rowtype;
        vis visits%rowtype;
        pat_id patients.patient_id%type;
        prescr_max_id prescriptions.prescription_id%type;
        is_found_rec boolean := false;
        cursor c is 
            select * from visits a inner join patients b on a.patient_id=b.patient_id 
            inner join prescriptions c on a.visit_id=c.visit_id inner join drugs d on c.drug_id=d.drug_id 
            where (c.end_date is null or c.end_date< sysdate) and d.drug_name=drg_n and c.daily_amount!=daily_am;
        drug_record drugs%rowtype;
        
    begin
        select doctor_id into doc from doctors where doctor_id=doc_id;
        select * into drg from drugs where drug_name=drg_n;
        select * into vis from visits where visit_id=vis_id;
        if vis.visit_id is null or drg.drug_id is null or doc is null then
            raise no_data;
        end if;

        --get max_id of prescription
        select max(prescription_id) into prescr_max_id from prescriptions;
        --check if patient has this drug prescribed and end_date is null or before today. If yes then ends and gives new one.
        for rec in c 
        loop
            is_found_rec := true;
            dbms_output.put_line('Patient is currently taking this drug in daily amount of '|| rec.daily_amount);
            update prescriptions set end_date=sysdate where prescription_id=rec.prescription_id;
            insert into prescriptions(prescription_id , drug_id, visit_id, start_date, end_date, daily_amount) values(prescr_max_id +1, drg.drug_id, vis_id, sysdate, enddat, daily_am);
            dbms_output.put_line('Successfuly done');
        end loop;

        if not is_found_rec then 
            select * into drug_record from drugs where drug_name=drg_n;
            insert into prescriptions(prescription_id , drug_id, visit_id, start_date, end_date, daily_amount) values(prescr_max_id +1, drug_record.drug_id, vis_id, sysdate, enddat, daily_am);
            dbms_output.put_line('Successfully done');
        end if;
    exception
        when no_data then
            dbms_output.put_line('Incorect input data.');
    end;

END hospital_package;
