* If the following packages are not installed, un-comment and run the below lines
* ssc install unique
* ssc install labutil

* Change directory to where the .csv files are; example directory below

cd "E:\Wikidata\Raw"

* Define directory where the figures will be saved

global fig "E:\Wikidata\Figures"

* Change font

graph set window fontface "Times New Roman"

* Import .csv files into Stata 

ls
local filelist: dir . files "*.csv"
foreach file of local filelist {
	import delimited "`file'", encoding(utf8) clear
	local name=upper(substr("`file'",10,3))
	save "Raw `name'.dta", replace
}


* Create files by sector of notability for each country separately

local filelist: dir . files "Raw*.dta"

foreach file of local filelist {

	* Politicians

	use "`file'", clear
	
	gen cat=""
	foreach i in politician diplomat military suffragist activist soldier suffragette "civil servant" {
		replace cat="Politics & Government" if strpos(occupationcode,"`i'")>0
	}
	keep if cat=="Politics & Government"
	split personcode, parse("/entity/")
	rename personcode2 id
	keep if dob_year_actual~=.
	rename dob_year_actual yob
	keep id sex yob
	duplicates drop id, force
	gen P=1
	collapse (sum) P, by(yob sex)
	tab sex
	keep if inlist(sex,"male","female")
	reshape wide P, i(yob) j(sex) string
	replace Pfemale=0 if Pfemale==.
	replace Pmale=0 if Pmale==.
	tempfile politicians
	save `politicians'
	
	* Artists and entertainers

	use "`file'", clear
	gen cat=""
	foreach i in actor singer author screenwriter writer composer painter novelist film musician jazz artist ///
		theater choreographer dancer guitarist poet photographer pianist rapper conductor sculptor comedian ///
		cinematographer playwright saxophonist television cartoonist publisher model "record producer" ///
		"radio personality" trumpeter violinist drummer Playmate "beauty pageant" percussionist illustrator ///
		bandleader animator printmaker YouTuber podcaster essayist blogger "disc jockey" drawer magician ///
		mandolinist librettist banjoist columnist "news presenter" clarinetist bassist cellist vocalist ///
		"stunt performer" presenter "circus performer" announcer {
		replace cat="Arts & Entertainment" if strpos(occupationcode,"`i'")>0
	}
	keep if cat=="Arts & Entertainment"
	split personcode, parse("/entity/")
	rename personcode2 id
	keep if dob_year_actual~=.
	rename dob_year_actual yob
	keep id sex yob
	duplicates drop id, force
	gen E=1
	collapse (sum) E, by(yob sex)
	tab sex
	keep if inlist(sex,"male","female")
	reshape wide E, i(yob) j(sex) string
	replace Efemale=0 if Efemale==.
	replace Emale=0 if Emale==.
	tempfile entertainers
	save `entertainers'
	
	* Athletes

	use "`file'", clear
	gen cat=""
		foreach i in football baseball basketball tennis swimmer athlete athletics sports golfer boxer wrestler rower coach ///
		"ice hockey" volleyball "racing driver" "racing automobile driver" cyclist sprinter "figure skater" fencer ///
		"poker player" karateka "chess player" "marathon runner" judoka bobsledder surfer NASCAR "water polo" ///
		"sport shooter" "Formula One" "speed skater" "rugby union player" "motorcycle racer" lacrosse "alpine skier" ///
		referee {
		replace cat="Sports" if strpos(occupationcode,"`i'")>0
	}
	keep if cat=="Sports"
	split personcode, parse("/entity/")
	rename personcode2 id
	keep if dob_year_actual~=.
	rename dob_year_actual yob
	keep id sex yob
	duplicates drop id, force
	gen A=1
	collapse (sum) A, by(yob sex)
	tab sex
	keep if inlist(sex,"male","female")
	reshape wide A, i(yob) j(sex) string
	replace Afemale=0 if Afemale==.
	replace Amale=0 if Amale==.
	tempfile athletes
	save `athletes'
	
	* Other professionals

	use "`file'", clear
	gen cat=""
	foreach i in lawyer judge engineer journalist architect physician surgeon banker businessperson entrepreneur ///
		"business executive" "aircraft pilot" translator nurse farmer astronaut financier manager editor designer ///
		chef rancher jurist dentist programmer merchant "chief executive officer" "social worker" philanthropist {
		replace cat="Professional" if strpos(occupationcode,"`i'")>0
	}
	foreach i in professor historian teacher physicist mathematician economist psychologist chemist inventor ///
		academic philosopher anthropologist zoologist theologian botanist scientist biologist sociologist ///
		astronomer librarian geologist researcher paleontologist psychiatrist biographer linguist ///
		geneticist ornithologist statistician priest musicologist missionary "music pedagogue" entomologist ///
		educator explorer "literary critic" "classical scholar" rabbi archaeologist pharmacist pastor ///
		mycologist pathologist naturalist environmentalist neurologist {
		replace cat="Science & Education" if strpos(occupationcode,"`i'")>0
	}
	keep if cat=="Professional" | cat=="Science & Education"
	split personcode, parse("/entity/")
	rename personcode2 id
	keep if dob_year_actual~=.
	rename dob_year_actual yob
	keep id sex yob
	duplicates drop id, force
	gen S=1
	collapse (sum) S, by(yob sex)
	tab sex
	keep if inlist(sex,"male","female")
	reshape wide S, i(yob) j(sex) string
	replace Sfemale=0 if Sfemale==.
	replace Smale=0 if Smale==.
	tempfile professionals
	save `professionals'


	* All

	use "`file'", clear
	split personcode, parse("/entity/")
	rename personcode2 id
	keep if dob_year_actual~=.
	rename dob_year_actual yob
	keep id sex yob
	duplicates drop id, force
	gen N=1
	collapse (sum) N, by(yob sex)
	tab sex
	keep if inlist(sex,"male","female")
	reshape wide N, i(yob) j(sex) string
	replace Nfemale=0 if Nfemale==.
	replace Nmale=0 if Nmale==.

	merge 1:1 yob using `politicians'
	drop _merge
	replace Pmale=0 if Pmale==.
	replace Pfemale=0 if Pfemale==.
	
	merge 1:1 yob using `entertainers'
	drop _merge
	replace Emale=0 if Emale==.
	replace Efemale=0 if Efemale==.
	
	merge 1:1 yob using `athletes'
	drop _merge
	replace Amale=0 if Amale==.
	replace Afemale=0 if Afemale==.
	
	merge 1:1 yob using `professionals'
	drop _merge
	replace Smale=0 if Smale==.
	replace Sfemale=0 if Sfemale==.

	local name=upper(substr("`file'",5,3))
	gen country="`name'"
	order country
	save "Summary `name'.dta", replace

}

* Analysis of the thirty countries

clear
local filelist: dir . files "Summary*.dta"
foreach file of local filelist {
	append using "`file'"
}

unique country

collapse (sum) N* P* E* A* S*, by(yob)


foreach i in N P E A S {
	gen `i'=`i'male+`i'female
	gen r`i'female=`i'female/`i'*100
	gen s`i'=`i'/N*100
}

total N
gen lnN=ln(N)

reg lnN yob if yob<=1960
predict lnNhat
gen Nhat=exp(lnNhat)
nlcom _b[yob]*100

#del ;
twoway
	(lfit lnN yob if yob<=1960, lcolor(red))
	(line lnN yob, lcolor(midgreen)  )
	,
	ylabel(`=ln(250)' "250" `=ln(500)' "500" `=ln(1000)' "1,000" `=ln(2000)' "2,000" 
	`=ln(4000)' "4,000" `=ln(8000)' "8,000" `=ln(16000)' "16,000" 
	, glcolor(black) glwidth(.1) glpattern(shortdash) angle(0) labsize(4))
	xlabel(1700(50)2000, angle(0) nogrid labsize(4)) 
	xtitle("Year of birth" , size(4) height(6))
	legend(off) 
	plotregion(fcolor(gs14) lcolor(black))
	graphregion(color(white)  margin(0 3 0 1))
	ytitle("Wikipedia entries", size(4))
	xsize(4) 
	;
graph export "$fig\2021-06 Fig 1.png", as(png) height(1200) replace;
#del cr

reg rN yob if inrange(yob,1700,1810), r
reg rN yob if inrange(yob,1810,1935), r
reg rN yob if inrange(yob,1935,1985), r

#del ;
twoway
	(lfit rN yob if inrange(yob,1700,1810), lcolor(red) lwidth(.3))
	(lfit rN yob if inrange(yob,1810,1935), lcolor(red) lwidth(.3) )
	(lfit rN yob if inrange(yob,1935,1985), lcolor(red) lwidth(.3) )
	(line rN yob,  lcolor(midblue%80) )
	,
	xline(1810 1935 1985, lcolor(black) lpattern(shortdash) lwidth(.2))
	ylabel(#8, gmax glcolor(black) glwidth(.1) glpattern(shortdash) angle(0) labsize(4) format(%6.0fc))
	ytitle("% of Wikipedia entries", size(4))
	xlabel(1700(50)2000, angle(0) nogrid labsize(4)) 
	xtitle("Year of birth" , size(4) height(6))
	legend(off)
	plotregion(fcolor(gs14) lcolor(black))
	graphregion(color(white) margin(0 3 0 1))
	xsize(4)
	;
graph export "$fig\2021-06 Fig 2.png", as(png) height(1200) replace;
#del cr

* Creating bins that have at least 250 individuals

foreach j in N P E A S {

sort yob
gen cum=sum(`j')
gen x=0
replace x=x+1 if (cum[_n-1]<250 | cum[_n-1]==.)

forval i=2/300 {
	drop cum
	sort yob
	gen cum=sum(`j') if x==0
	sort yob
	replace x=x+`i' if x==0 & (cum[_n-1]<250 | cum[_n-1]==.)
}

bysort x: egen sum`j'=sum(`j')
bysort x: egen sum`j'female=sum(`j'female)
gen sumr`j'female=sum`j'female/sum`j'*100
drop cum x  

}

foreach j in N P E A S {

	gen l`j'=. 
	gen u`j'=.

	forval i=1700/2000 {
		
		levelsof sum`j' if yob==`i' , local(N)
		levelsof sum`j'female if yob==`i' , local(F)
		capture cii proportions `N' `F', agresti level(99)
		replace l`j'=r(lb)*100 if yob==`i' 
		replace u`j'=r(ub)*100 if yob==`i' 
	}

}

label var sN "Total"
label var sP "Politics"
label var sE "Entertainment"
label var sA "Sports"
label var sS "Other professions"

gen sO=sN-(sP+sA+sE+sS)
sum sO

#del ;
twoway
	(line sP sE sA sS yob if yob <1960, sort lcolor(red midgreen midblue yellow) lwidth(.4 ..))
	(line sP sE sA sS yob if yob>=1960, sort lcolor(red midgreen midblue yellow) lwidth(.4 ..) lpattern(shortdash ..))
	,
	xline(1960, lcolor(black) lpattern(shortdash) lwidth(.2) )
	ylabel(#8, glcolor(black) glwidth(.1) glpattern(shortdash) angle(0) labsize(4) format(%6.0fc))
	ytitle("% of Wikipedia entries", size(4))
	xlabel(1700(50)2000, angle(0) nogrid labsize(4)) 
	xtitle("Year of birth" , size(4) height(6))
	legend(ring(0) pos(11) symxsize(4) cols(1) size(4) order(1 2 3 4)  )
	plotregion(fcolor(gs14) lcolor(black) margin(1 1 0 4)) 
	graphregion(color(white) margin(0 4 0 1) )
	xsize(4)
;
graph export "$fig\2021-06 Fig 3.png", as(png) height(1200) replace;
#del cr

scalar Min=250

label var sumrN "Total"
label var sumrP "Politics"
label var sumrE "Entertainment"
label var sumrA "Sports"
label var sumrS "Other professions"

#del ;
twoway
	(rarea uP lP yob if sumP>=Min, bcolor(red%15))
	(line sumrPfemale yob if sumP>=Min, lcolor(red))
	(rarea uE lE yob if sumE>=Min, bcolor(midgreen%15))
	(line sumrEfemale yob if sumE>=Min, lcolor(midgreen))
	(rarea uA lA yob if sumA>=Min, bcolor(midblue%15))
	(line sumrAfemale yob if sumA>=Min, lcolor(midblue))
	(rarea uS lS yob if sumS>=Min, bcolor(yellow%15))
	(line sumrSfemale yob if sumS>=Min, lcolor(yellow))
	,
	ylabel(0(10)60, glcolor(black) glwidth(.1) glpattern(shortdash) angle(0) labsize(4))
	ytitle("% of Wikipedia entries that are female", size(4))
	xlabel(1700(50)2000, angle(0) nogrid labsize(4)) 
	xtitle("Year of birth", size(4) height(6))
	legend(symxsize(4) pos(11) ring(0) size(4) cols(1) order(2 4 6 8 /*10*/) )
	plotregion(fcolor(gs14) lcolor(black) margin(1 1 0 0)) 
	graphregion(color(white) margin(0 4 0 1) ) 
	xsize(4)
;
graph export "$fig\2021-06 Fig 4.png", as(png) height(1200) replace;
#del cr


* Analysis by country and long periods

* Entries by country

clear

* Assumes that the "countries_by_population.xlsx" file is in the directory
* "E:\Wikidata"; change this directory accordingly

import excel "E:\Wikidata\countries_by_population.xlsx", sheet("Sheet1") cellrange(A3:H32)
split B, parse("[")
rename (H B1) (country name)
keep name country
tempfile names
save `names'

clear
local filelist: dir . files "Summary*.dta"
foreach file of local filelist {
	append using "`file'"
}

gen N=Nmale+Nfemale
collapse (sum) N, by(country)
merge m:1 country using `names'
drop _merge
egen total=sum(N)
gen percent=N/total*100
gsort -N
gen cumpercent=sum(percent)
sort N
gen x=_n
gen _country=name+" {stMono:"+country+"}"
labmask x, values(_country)

gen lnN=ln(N)
gen z=ln(300)

#del ;
twoway
	(rbar lnN z x, hor barwidth(.8) bcolor(midblue%50))
	,
	ylabel(1(1)30, nogrid val angle(0) labsize(3)) 
	xscale(alt) 
	xlabel(
	`=ln(500)' "500" `=ln(1000)' "1,000" `=ln(2000)' "2,000" 
	`=ln(4000)' "4,000" `=ln(8000)' "8,000" `=ln(16000)' "16,000" 
	`=ln(32000)' "32,000" `=ln(64000)' "64,000" `=ln(128000)' "128,000" 
	`=ln(264000)' "264,000" 
	, grid glcolor(black) glwidth(.1) glpattern(shortdash) angle(-45) labsize(4))
	ytitle("")
	xtitle("Number of Wikipedia entries", size(4.5))
	xsize(3.5)
	plotregion(fcolor(gs14) lcolor(black) margin(0 1 1 1)) 
	graphregion(color(white) margin(0 1 1 2) ) 
;
graph export "$fig\2021-06 Fig 5.png", as(png) height(1200) replace;
#del cr

clear
local filelist: dir . files "Summary*.dta"
foreach file of local filelist {
	append using "`file'"
}

* Calculation of "missing" notable women

total Nfemale Nmale
display 258418+1198433
display 258418/(258418+1198433)
display (258418+1198433)*.5-258418

* Trend by country

gen period=1 if inrange(yob,1700,1799)
replace period=2 if inrange(yob,1800,1899)
replace period=3 if inrange(yob,1900,1949)
replace period=4 if inrange(yob,1950,2000)

collapse (sum) N* P* A* E* S*, by(country period)
reshape long N P A E S, i(country period) j(gender) string
rename (N P A E S) (vN vP vA vE vS)
reshape long v, i(country period gender) j(sector) string
reshape wide v, i(country period sector) j(gender) string
rename v* *
gen total=male+female
gen ratio=female/total*100

keep if total>=250
keep if sector=="N"

keep country period total ratio
reshape wide total ratio, i(country) j(period)

gen _1=1 if ratio1~=.
gen _2=2 if ratio1~=.
gen _3=3 if ratio1~=.
gen _4=4 if ratio1~=.

replace _2=6 if ratio1==. & ratio2~=.
replace _3=7 if ratio1==. & ratio2~=.
replace _4=8 if ratio1==. & ratio2~=.

replace _3=10 if ratio1==. & ratio2==. 
replace _4=11 if ratio1==. & ratio2==. 

gen move1=0
replace move1=1 if inlist(country,"MEX","BRA")
replace move1=2 if inlist(country,"ITA")

gen move2=0
replace move2=1 if inlist(country,"TRK")

gen move3=0
replace move3=1 if inlist(country,"THA","NGA")

gen move4=0
replace move4=1 if inlist(country,"MEX","RUS","FRA","EGY","ETH")


gen _country="{stMono:"+country+"}"

global S 1.7
global G 4.3

#del ;
twoway 
	(pcspike ratio1 _1 ratio2 _2 , lcolor(midblue))
	(pcspike ratio2 _2 ratio3 _3 , lcolor(red))
	(pcspike ratio3 _3 ratio4 _4 , lcolor(midgreen))
	
	(scatter ratio1 _1 if move1==0, msymbol(o) mcol(gs10) msize(.5) mlab(_country) mlabsize($S) mlabcolor(black) mlabpos(9))
	(scatter ratio1 _1 if move1==1, msymbol(o) mcol(gs10) msize(.5) mlab(_country) mlabsize($S) mlabcolor(black) mlabpos(9) mlabgap($G))
	(scatter ratio1 _1 if move1==2, msymbol(o) mcol(gs10) msize(.5) mlab(_country) mlabsize($S) mlabcolor(black) mlabpos(9) mlabgap(8))
	
	(scatter ratio2 _2 if ratio1==. & move2==0, msymbol(o) mcol(gs10) msize(.5) mlab(_country) mlabsize($S) mlabcolor(black) mlabpos(9))
	(scatter ratio2 _2 if ratio1==. & move2==1, msymbol(o) mcol(gs10) msize(.5) mlab(_country) mlabsize($S) mlabcolor(black) mlabpos(9) mlabgap($G))
	
	(scatter ratio3 _3 if ratio2==. & move3==0, msymbol(o) mcol(gs10) msize(.5) mlab(_country) mlabsize($S) mlabcolor(black) mlabpos(9))
	(scatter ratio3 _3 if ratio2==. & move3==1, msymbol(o) mcol(gs10) msize(.5) mlab(_country) mlabsize($S) mlabcolor(black) mlabpos(9) mlabgap($G))
	
	(scatter ratio4 _4 if move4==0, msymbol(o) mcol(gs10) msize(.5) mlab(_country) mlabsize($S) mlabcolor(black))
	(scatter ratio4 _4 if move4==1, msymbol(o) mcol(gs10) msize(.5) mlab(_country) mlabsize($S) mlabcolor(black) mlabgap($G))
,
	xscale(range(-1 12.5))
	ylabel(0(10)40, nogmax glcolor(black) glwidth(.1) glpattern(shortdash) angle(0) labsize(4))
	ytitle("% of Wikipedia entries that are female", size(4))
	xlabel(1 "1700-99" 2 "1800-99" 3 "1900-49" 4 "1950-2000"
	6 "1800-99" 7 "1900-49" 8 "1950-2000"
	10 "1900-49" 11 "1950-2000", angle(-45))
	xtitle("Year of birth", size(4) )
	plotregion(fcolor(gs14) lcolor(black) margin(1 1 0 0)) 
	graphregion(color(white) margin(0 2 0 2) ) 
	legend(off)
	xsize(4)
	;
	graph export "$fig\2021-06 Fig 6.png", as(png) height(1200) replace;
#del cr	

gen d1_4=ratio4-ratio1
br country d1_4 if ratio1~=.

* female representation among beauty pageant contestants, models, and pornographic actors in the US

quietly {

foreach i in "beauty pageant contestant" "model" "pornographic actor" {

use "Raw USA.dta", clear
keep if occupationcode=="`i'"
split personcode, parse("/entity/")
rename personcode2 id
keep if dob_year_actual~=.
rename dob_year_actual yob
gen gender="other"
replace gender=sex if inlist(sex,"male","female")
keep id gender yob 
duplicates drop id, force

noisily display "`i'"
noisily table gender, c(n yob median yob p10 yob) row

}
}

display 543/547
display 2725/3467
display 1502/1929

