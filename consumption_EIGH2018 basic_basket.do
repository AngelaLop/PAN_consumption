/*==================================================
project:       
Author:        Angela Lopez 
E-email:       alopezsanchez@worldbank.org
url:           
Dependencies:  
----------------------------------------------------
Creation Date:     24 Mar 2022 - 10:19:54
Modification Date:   
Do-file version:    01
References:          
Output:             
==================================================*/

/*==================================================
              0: Program set up
==================================================*/
version 17
drop _all


/*==================================================
              1: paths 
==================================================*/
global path "C:\Users\WB585318\WBG\Javier Romero - Panama"
global input "$path\data\EIGH 2018"
global output "$path\Pedidos info\regional exp"
/*==================================================
              2: 
==================================================*/

use "$input\RESUMEN DE INGRESOS Y GASTOS.dta"



foreach v of varlist _all {
      capture rename `v' `=lower("`v'")'
   }
   
g total =1   
g pondera = factor  
g ipcf = y1pc // ingreso pc hogar
g it = y1 // ingreso total hogar
g iagro = y1122 // ingreso por actividades agropecuarias 
g conum = z1 // gasto total

g agro = 1 if y1122 > 0.00 
g iagro_pc = iagro / tot_personas
*quintiles agro 

	xtile  ipcf_Q5a = ipcf [w=pondera] if agro==1 ,  nquantiles(5)
	tab    ipcf_Q5a [iw=pondera] if agro==1, miss
	pctile ipcf_Q5a_cuts = ipcf [w=pondera] if agro==1 , nquantiles(5)
*deciles
	xtile  ipcf_Q10 = ipcf [w=pondera] ,  nquantiles(10)
	tab ipcf_Q10 [iw=pondera], miss
	pctile ipcf_Q10_cuts = ipcf [w=pondera] , nquantiles(10)

*deciles agro 
	xtile  ipcf_Q10a = ipcf [w=pondera] if agro==1 ,  nquantiles(10)
	tab ipcf_Q10a [iw=pondera] if agro==1, miss
	pctile ipcf_Q10a_cuts = ipcf [w=pondera] if agro==1 , nquantiles(10)
*ventiles	
	xtile  ipcf_Q20 = ipcf [w=pondera] ,  nquantiles(20)
	tab ipcf_Q20 [iw=pondera], miss
	pctile ipcf_Q20_cuts = ipcf [w=pondera] , nquantiles(20)
*food expenditure
	g food_ex = z19a
	g food_ex_pc = food_ex/tot_personas
	
*
egen ex_meet = rsum(_v2 _v3) //gasto en carne
g ex_meet_pc = ex_meet/tot_personas

g ex_grains = _v1
g ex_grains_pc = ex_grains/tot_personas

g ex_legum  = _v7
g ex_legum_pc  = ex_legum/tot_personas

g ex_fat = _v5 	
g ex_fat_pc = ex_fat/tot_personas

* transportation 
g ex_transportation = z14a
g ex_transportation_pc = ex_transportation/tot_personas
	
* total expenditure
	g cons_pc = z1/tot_personas
	g cons = z1
br cons_pc 

* households with food income higher than food spending
g food_income_food_spending = 1 if iagro>food_ex	
g food_income_food_spending_pc = 1 if iagro_pc>food_ex_pc	
	
*merge 1:m id_secuencial using "$input\PERSONAS"
*br activip1 activip ingnetoap y1122 if y1122 > 0.00  
*sort id_secuencial 
  preserve 

tempname pname
tempfile pfile
postfile `pname' str30(country) year str30(indicators quantil income_type) value obs using `pfile', replace
local samples all  


			
			foreach quan of numlist 1/10 {	
				
*•	Share of food expenditures by income per capita ventiles (or deciles, if the former is not possible)
			
				sum food_ex_pc [w=pondera] if ipcf_Q10==`quan'
				local food = `r(mean)'
				
				sum ipcf [w=pondera] if ipcf_Q10==`quan'
				local income = `r(mean)'
				
				local value = (`food'/ `income')*100
				
				sum total [w=pondera] if ipcf_Q10==`quan'
				local hogar = `r(sum_w)'
				
				post `pname' ("pan") (2018) ("food expenditures by income per capita") ("ventil`quan'") ("ipcf") (`value') (`hogar')
				
*•	Share of meet expenditures by income per capita ventiles (or deciles, if the former is not possible)
			
				sum ex_meet_pc [w=pondera] if ipcf_Q10==`quan'
				local food = `r(mean)'
				
				sum ipcf [w=pondera] if ipcf_Q10==`quan'
				local income = `r(mean)'
				
				local value = (`food'/ `income')*100
				
				sum total [w=pondera] if ipcf_Q10==`quan'
				local hogar = `r(sum_w)'
				
				post `pname' ("pan") (2018) ("share of meet expenditures in per capita consumption") ("ventil`quan'") ("ipcf") (`value') (`hogar')
				
*•	Share of grains expenditures by income per capita ventiles (or deciles, if the former is not possible)
			
				sum ex_grains_pc [w=pondera] if ipcf_Q10==`quan'
				local food = `r(mean)'
				
				sum ipcf [w=pondera] if ipcf_Q10==`quan'
				local income = `r(mean)'
				
				local value = (`food'/ `income')*100
				
				sum total [w=pondera] if ipcf_Q10==`quan'
				local hogar = `r(sum_w)'
				
				post `pname' ("pan") (2018) ("share of grains expenditures in per capita consumption") ("ventil`quan'") ("ipcf") (`value') (`hogar')	
				
*•	Share of fat expenditures by income per capita ventiles (or deciles, if the former is not possible)
			
				sum ex_fat_pc [w=pondera] if ipcf_Q10==`quan'
				local food = `r(mean)'
				
				sum ipcf [w=pondera] if ipcf_Q10==`quan'
				local income = `r(mean)'
				
				local value = (`food'/ `income')*100
				
				sum total [w=pondera] if ipcf_Q10==`quan'
				local hogar = `r(sum_w)'
				
				post `pname' ("pan") (2018) ("share of fat expenditures in per capita consumption") ("ventil`quan'") ("ipcf") (`value') (`hogar')				

*•	Share of legumbres expenditures by income per capita ventiles (or deciles, if the former is not possible)
			
				sum ex_legum_pc [w=pondera] if ipcf_Q10==`quan'
				local food = `r(mean)'
				
				sum ipcf [w=pondera] if ipcf_Q10==`quan'
				local income = `r(mean)'
				
				local value = (`food'/ `income')*100
				
				sum total [w=pondera] if ipcf_Q10==`quan'
				local hogar = `r(sum_w)'
				
				post `pname' ("pan") (2018) ("share of legum expenditures in per capita consumption") ("ventil`quan'") ("ipcf") (`value') (`hogar')				

*•	Share of legumbres expenditures by income per capita ventiles (or deciles, if the former is not possible)
			
				sum ex_transportation_pc [w=pondera] if ipcf_Q10==`quan'
				local food = `r(mean)'
				
				sum ipcf [w=pondera] if ipcf_Q10==`quan'
				local income = `r(mean)'
				
				local value = (`food'/ `income')*100
				
				sum total [w=pondera] if ipcf_Q10==`quan'
				local hogar = `r(sum_w)'
				
				post `pname' ("pan") (2018) ("share of transportation expenditures in per capita consumption") ("ventil`quan'") ("ipcf") (`value') (`hogar')						
				
    
*•	Share of food expenditure in the total income 

				sum food_ex [w=pondera] if ipcf_Q10==`quan'
				local food = `r(mean)'
				
				sum it [w=pondera] if ipcf_Q10==`quan'
				local income = `r(mean)'
				
				local value = (`food'/ `income')*100
				
				sum total [w=pondera] if ipcf_Q10==`quan'
				local hogar = `r(sum_w)'
				
				post `pname' ("pan") (2018) ("Share of food expenditure in the total income") ("ventil`quan'") ("ipcf") (`value') (`hogar')
			


*•	Number of households by income per capita ventiles
*•	Income/Consumption ratio
				sum cons_pc [w=pondera] if ipcf_Q10==`quan'
				local food = `r(mean)'
				
				sum ipcf [w=pondera] if ipcf_Q10==`quan'
				local income = `r(mean)'
				
				local value = (`income'/ `food')*100
				
				sum total [w=pondera] if ipcf_Q10==`quan'
				local hogar = `r(sum_w)'
				
				post `pname' ("pan") (2018) ("Income/Consumption ratio") ("ventil`quan'") ("ipcf") (`value') (`hogar')
			

* income max min aver 


				
				sum ipcf [w=pondera] if ipcf_Q10==`quan'
				local max = `r(max)'
				local min = `r(min)'
								
				sum ipcf [w=pondera] if ipcf_Q10==`quan'
				local average = `r(mean)'
				
				post `pname' ("pan") (2018) ("MAx/average") ("ventil`quan'") ("ipcf") (`max') (`average')
				post `pname' ("pan") (2018) ("min/average") ("ventil`quan'") ("ipcf") (`min') (`average')
			
			
			
						
		} // close lp

	

postclose `pname'
use `pfile', clear
format value %15.2fc

export excel using "${output}\Food_Expenditure_Indicators_PAN.xlsx", sh("Results", replace)  firstrow(var)

 restore
   
   