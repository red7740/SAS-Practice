/**************************************************
Q3 test mpg_city in sashelp.cars

Author: Roger Doles

Date: 11/15/17

************************************************/

proc sql;
	select type, freq(type)
	into :g1-:g2, :n1-:n2
	from sashelp.cars
	where type in ('Truck', 'SUV')
	group by type
	;
	%put &g1 &n1;
	%put &g2 &n2;
	quit;

proc surveyselect data=sashelp.cars(keep=type mpg_city) method=urs samprate=100 reps=1000 out=boot outhits;
	where type in ('Truck','SUV');
run;

proc sql;
	create table boot2 as 
	select *, ranuni(3) as random
	from boot
	order by replicate, random
	;
quit;

data boot2;
	set boot2;

	by replicate;

	if first.replicate then c=0;
	c+1;

	if c le &n1 then group=1;
	else group=2;

run;

proc means data=boot2 q3;
	var mpg_city;
	class replicate group; 
	ods output summary=boot_q3;
run;


proc means data=sashelp.cars q3;
	where type in ('Truck','SUV'); 
	class type; 
	var mpg_city;
	ods output summary=original;
run;


data _null_;
	set original;
	call symput('orig',put(MPG_City_Q3,best12.));
run;
%put &orig;

data pvalue;
	set boot_q3 end=last;
	
	if abs(MPG_City_Q3) gt abs(&orig) then c+1;

	if last then do;
		pvalue = c/_n_;
		output;
	end;
	keep pvalue;
run;
