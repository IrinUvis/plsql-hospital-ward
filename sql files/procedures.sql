select * from doctors;
select * from drugs;
select * from patients;
select * from prescriptions;
select * from specializations;
select * from visits;
drop table doctors;
drop table drugs;
drop table patients;
drop table prescriptions;
drop table specializations;
drop table  visits;
set serveroutput on;



select * from visits a inner join patients b on a.patient_id=b.patient_id inner join prescriptions c on a.visit_id=c.visit_id inner join drugs d on c.drug_id=d.drug_id;




create or replace procedure visit_outcome(doc_id in doctors.doctor_id%type, vis_id in visits.visit_id%type, pt_id in patients.patient_id%type, drg_n in drugs.drug_name%type, enddat in prescriptions.end_date%type, daily_am in prescriptions.daily_amount%type)
is
doc doctors.doctor_id%type;
no_doc exception;
pragma exception_init(no_doc,100);


drg drugs%rowtype;
no_drg exception;
pragma exception_init(no_drg,100);

vis visits%rowtype;
no_vis exception;
pragma exception_init(no_vis,100);
pat_id patients.patient_id%type;



is_found_rec boolean := false;

cursor c is select * from visits a inner join patients b on a.patient_id=b.patient_id inner join prescriptions c on a.visit_id=c.visit_id inner join drugs d on c.drug_id=d.drug_id where (c.end_date is null or c.end_date< sysdate) and d.drug_name=drg_n and c.daily_amount!=daily_am;


drug_record drugs%rowtype;

begin
--check if doc_id is valid
select doctor_id into doc from doctors where doctor_id=doc_id;
if doc is null then
raise no_doc;
end if;

--check if drug name is valid
select * into drg from drugs where drug_name=drg_n;
if drg.drug_id is null then
raise no_drg;
end if;

--check if visit id is valid
select * into vis from visits where visit_id=vis_id;
if vis.visit_id is null then
raise no_vis;
end if;

--check if patient has this drug prescribed and end_date is null or before today. If yes then ends and gives new one.
for rec in c 
loop
    is_found_rec := true;
    dbms_output.put_line('Patient is currently taking this drug in daily amount of '|| rec.daily_amount);
    update prescriptions set end_date=sysdate where prescription_id=rec.prescription_id;
    insert into prescriptions values(rec.prescription_id, rec.drug_id, rec.visit_id, sysdate, enddat, daily_am);
    dbms_output.put_line('Successfuly done');
end loop;



if not is_found_rec then

select * into drug_record from drugs where drug_name=drg_n;
insert into prescriptions values(rec.prescription_id, drug_record.drug_name, vis_id, sysdate, enddat, daily_am);
dbms_output.put_line('Successfully done');
end if;

exception
when no_doc then
dbms_output.put_line('No doctor');

when no_vis then
dbms_output.put_line('No visit planned');

when no_drg then
dbms_output.put_line('No such drug in hospital pharmacy');

end;






--show patient's history
create or replace procedure show_patients_history(pat_id in patients.patient_id%type)
is
cursor history is select * from patients a inner join visits b on a.patient_id = b.patient_id inner join doctors c on c.doctor_id=b.doctor_id inner join specializations d on c.specialization_id=d.specialization_id inner join prescriptions e on e.visit_id=b.visit_id inner join drugs f on e.drug_id=f.drug_id where a.patient_id=pat_id;
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

exec show_patients_history('00000000000');

exec show_patients_history('06311195765');


select * from patients a inner join visits b on a.patient_id = b.patient_id inner join doctors c on c.doctor_id=b.doctor_id inner join specializations d on c.specialization_id=d.specialization_id inner join prescriptions e on e.visit_id=b.visit_id inner join drugs f on e.drug_id=f.drug_id;



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

