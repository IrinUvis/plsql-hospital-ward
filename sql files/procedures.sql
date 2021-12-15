
set serveroutput on;

  
create or replace procedure visit_outcome(vis_id in visits.visit_id%type, drg_n in drugs.drug_name%type, enddat in prescriptions.end_date%type, daily_am in prescriptions.daily_amount%type)
is

no_data exception;
pragma exception_init(no_data,100);

vis visits%rowtype; --do zczytania czy wizyta istnieje

prescr_max_id prescriptions.prescription_id%type;
is_found_rec boolean := false; --czy powinien wykonac czesc w ifie po loopie

cursor c is   select * from prescriptions where visit_id in (select visit_id from visits where patient_id in (select patient_id from visits where visit_id=vis_id)) and end_date<sysdate and drug_id in (select drug_id from drugs where drug_name=drg_n); --czy temu pacjentowi podczas jakiejkolwiek wizyty zostala wystawiona receptaa na ten lek i czy data waznosci jest aktualna
drug_record drugs%rowtype; --do zczytania czy istnieje lek

begin

--czy wizyta istnieje i czy lek istnieje
select * into drug_record from drugs where drug_name=drg_n;
if vis.visit_id is null or drug_record.drug_id is null then
raise no_data;
end if;



--get max_id of prescription (do wstawienia przy insercie)
select max(prescription_id) into prescr_max_id from prescriptions;




--jezeli w kursorze jest recepta
for rec in c 
loop
    is_found_rec := true;
    dbms_output.put_line('Patient is currently taking this drug in daily amount of '|| rec.daily_amount);
    update prescriptions set end_date=sysdate where prescription_id=rec.prescription_id;
    insert into prescriptions(prescription_id , drug_id, visit_id, start_date, end_date, daily_amount) values(prescr_max_id +1, drug_record.drug_id, vis_id, sysdate, enddat, daily_am);
    dbms_output.put_line('Successfuly done');
end loop;


--jezeli nie ma recepty wystawionej
if not is_found_rec then


insert into prescriptions(prescription_id , drug_id, visit_id, start_date, end_date, daily_amount) values(prescr_max_id +1, drug_record.drug_id, vis_id, sysdate, enddat, daily_am);
dbms_output.put_line('Successfully done');

end if;



exception
when no_data then
dbms_output.put_line('Incorect input data.');

end;



exec visit_outcome(198,'dupa','25-FEB-21',2);



--show patient's history
create or replace procedure show_patients_history(pat_id in patients.patient_id%type)
is
cursor history is select * from patients a inner join visits b on a.patient_id = b.patient_id inner join doctors c on c.doctor_id=b.doctor_id inner join specializations d on  c.specialization_id=d.specialization_id inner join prescriptions e on e.visit_id=b.visit_id inner join drugs f on e.drug_id=f.drug_id where a.patient_id=pat_id;
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
    if rec.discharge_date is null then
    dbms_output.put_line('Patient has a visit from ' || rec.Registration_date || ' - until now and has been served by '|| rec.specialization_name ||'. During visit patient was prescribed for '|| rec.drug_name || ' with dosage '|| rec.daily_amount || ' for time between ' || rec.start_date || ' - ' || rec.end_date );

    else
    dbms_output.put_line('Patient had a visit between ' || rec.Registration_date || ' - ' || rec.discharge_date ||' and has been served by '|| rec.specialization_name || '. During visit patient was prescribed for '|| rec.drug_name ||  ' with dosage '|| rec.daily_amount || ' for time between ' || rec.start_date || ' - ' || rec.end_date );

    end if;
    
         

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











create or replace procedure raise_salary(spec_id in doctors.specialization_id%type, proc in number)


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

exec raise_salary('ALRG',1);

