$title Aelopile

$call gdxxrw 201709_Monthly_Forecast_Input_Data_vE.3.xlsx index=index!a1
$gdxin 201709_Monthly_Forecast_Input_Data_vE.3.gdx

set      t / 1*24 /              ;
Set      dd / 1*365 /            ;
set      d(dd) / 1*30 /          ;

Parameter        Loss_factor     / 0.025 /       ;

set
         i(*)            thermal units ;
$load i
Display i

set
         idat(*)         thermal units characteristics(labels) ;
$load idat
Display idat

parameter
         UntDat(i,idat);
$load UntDat
Display UntDat

set
         istep(*)        marginal cost function steps
$load istep
Display istep

*set
*         t(*)            hours   ;
*$load t
*Display t

*set
*         d(*)            days    ;
*$load d
*Display d

parameter
         EnrPrice(t,i,istep)       ;
$load EnrPrice
Display EnrPrice

parameter
         UntStep(t,i,istep)        ;
$load UntStep
Display UntStep

parameter
         ResPrice(t,i)           ;
$load ResPrice
Display ResPrice

parameter
         P_comm_d(dd,i,t)         ;
$load P_comm_d
Display P_comm_d

parameter
         Maint_d(dd,i)            ;
$load Maint_d
Display Maint_d

parameter
         Derating_d(dd,i)         ;
$load Derating_d
Display Derating_d

*set
*         d(*)            days ;
*$load d

set
         j(*)            thermal units ;
$load j
Display j

set
         jdat(*)         thermal units characteristics(labels) ;
$load jdat
Display jdat

parameter
         HydUntDat(j,jdat);
$load HydUntDat
Display HydUntDat

set
         jstep(*)        marginal cost function steps
$load jstep
Display jstep

parameter
         EnrPrice_h(t,j,jstep)   ;
$load EnrPrice_h
Display EnrPrice_h

parameter
         UntStep_h(t,j,jstep)    ;
$load UntStep_h
Display UntStep_h

parameter
         BidPrice_p(t,j,jstep)   ;
$load BidPrice_p
Display BidPrice_p

parameter
         UntStep_p(t,j,jstep)    ;
$load UntStep_p
Display UntStep_p

parameter
         ResPrice_h(t,j)         ;
$load ResPrice_h
Display ResPrice_h

parameter
         P_h_mand_d(dd,j,t)       ;
$load P_h_mand_d
Display P_h_mand_d

parameter
         Demand_d(dd,t)           ;
$load Demand_d
Display Demand_d

parameter
         SReserve_dn_d(dd,t)      ;
$load SReserve_dn_d
Display SReserve_dn_d

parameter
         SReserve_up_d(dd,t)      ;
$load SReserve_up_d
Display SReserve_up_d

parameter
         FSReserve_dn_d(dd,t)     ;
$load FSReserve_dn_d
Display FSReserve_dn_d

parameter
         FSReserve_up_d(dd,t)     ;
$load FSReserve_up_d
Display FSReserve_up_d

parameter
         RES_d(dd,t)              hourly RES production ;
$load RES_d
Display RES_d

parameters
         LT_Imp_AL_d(dd,t)          hourly LT imports from Albania
         LT_Exp_AL_d(dd,t)          hourly LT exports to Albania
         NTC_IMP_AL_d(dd,t)         hourly NTC Albania
         NTC_EXP_AL_d(dd,t)         hourly NTC Albania              ;
$load LT_Imp_AL_d LT_Exp_AL_d NTC_IMP_AL_d NTC_EXP_AL_d

parameters
         LT_Imp_BG_d(dd,t)          hourly LT imports from Bulgaria
         LT_Exp_BG_d(dd,t)          hourly LT exports to Bulgaria
         NTC_IMP_BG_d(dd,t)         hourly NTC Albania
         NTC_EXP_BG_d(dd,t)         hourly NTC Albania              ;
$load LT_Imp_BG_d LT_Exp_BG_d NTC_IMP_BG_d NTC_EXP_BG_d

parameters
         LT_Imp_FY_d(dd,t)          hourly LT imports from FYROM
         LT_Exp_FY_d(dd,t)          hourly LT exports to FYROM
         NTC_IMP_FY_d(dd,t)         hourly NTC Albania
         NTC_EXP_FY_d(dd,t)         hourly NTC Albania              ;
$load LT_Imp_FY_d LT_Exp_FY_d NTC_IMP_FY_d NTC_EXP_FY_d

parameters
         LT_Imp_IT_d(dd,t)          hourly LT imports from Italy
         LT_Exp_IT_d(dd,t)          hourly LT exports to Italy
         NTC_IMP_IT_d(dd,t)         hourly NTC Albania
         NTC_EXP_IT_d(dd,t)         hourly NTC Albania              ;
$load LT_Imp_IT_d LT_Exp_IT_d NTC_IMP_IT_d NTC_EXP_IT_d

parameters
         LT_Imp_TR_d(dd,t)          hourly LT imports from Turkey
         LT_Exp_TR_d(dd,t)          hourly LT exports to Turkey
         NTC_IMP_TR_d(dd,t)         hourly NTC Albania
         NTC_EXP_TR_d(dd,t)         hourly NTC Albania              ;
$load LT_Imp_TR_d LT_Exp_TR_d NTC_IMP_TR_d NTC_EXP_TR_d

parameters
         Priced_Imp_IT_d(dd,t)      priced imports from Italy
         Priced_Exp_IT_d(dd,t)      priced exports to Italy
         MGP_d(dd,t)                hourly MGP IT price             ;
$load Priced_Imp_IT_d Priced_Exp_IT_d MGP_d

parameters
         Priced_Imp_TR_d(dd,t)      priced imports from Italy
         Priced_Exp_TR_d(dd,t)      priced exports to Italy
         PMUM_d(dd,t)               hourly SGOPF TR price             ;
$load Priced_Imp_TR_d Priced_Exp_TR_d PMUM_d

Sets
         i_fast(i)               subset of fast thermal units
         i_non_fast(i)           subset of non-fast thermal units
         i_reserve(i)            subset of CCGT providing secondary reserve
         j_reserve(j)
;

i_fast(i)        $ ( UntDat(i,"FastUnit") = 0 ) = no                     ;
i_fast(i)        $ ( UntDat(i,"FastUnit") = 1 ) = yes                    ;
i_non_fast(i)    $ ( UntDat(i,"FastUnit") = 0 ) = yes                    ;
i_non_fast(i)    $ ( UntDat(i,"FastUnit") = 1 ) = no                     ;
i_reserve(i)     $ ( UntDat(i,"AGC") = 1 )      = yes                    ;
i_reserve(i)     $ ( UntDat(i,"AGC") = 0 )      = no                     ;
j_reserve(j)     $ ( HydUntDat(j,"AGC") = 1 )   = yes                    ;
j_reserve(j)     $ ( HydUntDat(j,"AGC") = 0 )   = no                     ;

Display i_reserve ;

Parameter
         P_av_d(d,i) ;

P_av_d(d,i)      = Maint_d(d,i) * Derating_d(d,i) ;

Parameters
         Pmin(i)
         Pmax(i)
         Pmin_AGC(i)
         Pmax_AGC(i)
         Pmax_step(i,istep)
         MUT(i)
         MDT(i)
         SDC(i)
         RampRate(i)
         EFORd(i)
         InitialCommStat(i)
         SynchPast(i,t)
         DesynchPast(i,t)
         P_av(i,t)
         Pmin_h(j)
         Pmax_h(j)
         Pmax_p(j)
         Pmin_AGC_h(j)
         Pmax_AGC_h(j)
         RampRate_h(j)
;


Pmin(i)                  =       UntDat(i,"Pmin")        ;
Pmax(i)                  =       UntDat(i,"Pmax")        ;
Pmin_AGC(i)              =       UntDat(i,"Pmin_AGC")    ;
Pmax_AGC(i)              =       UntDat(i,"Pmax_AGC")    ;
MUT(i)                   =       UntDat(i,"MUT")         ;
MDT(i)                   =       UntDat(i,"MDT")         ;
SDC(i)                   =       UntDat(i,"SUC")         ;
EFORd(i)                 =       UntDat(i,"EFORd")       ;
RampRate(i)              =       UntDat(i,"RampRate")    ;

Pmin_h(j)                =       HydUntDat(j,"Pmin")     ;
Pmax_h(j)                =       HydUntDat(j,"Pmax")     ;
Pmax_p(j)                =       HydUntDat(j,"PmaxPump") ;
Pmin_AGC_h(j)            =       HydUntDat(j,"Pmin_AGC") ;
Pmax_AGC_h(j)            =       HydUntDat(j,"Pmax_AGC") ;
RampRate_h(j)            =       HydUntDat(j,"RampRate") ;

*$ontext

Display Pmin, Pmax, Pmin_AGC, Pmax_AGC, MUT, MDT, SDC ;

Parameters
         MGP(t)
         PMUM(t)
         LT_Imp_BG(t)
         LT_Exp_BG(t)
         NTC_Imp_BG(t)
         NTC_Exp_BG(t)
         LT_Imp_AL(t)
         LT_Exp_AL(t)
         NTC_Imp_AL(t)
         NTC_Exp_AL(t)
         LT_Imp_FY(t)
         LT_Exp_FY(t)
         NTC_Imp_FY(t)
         NTC_Exp_FY(t)
         LT_Imp_IT(t)
         LT_Exp_IT(t)
         NTC_Imp_IT(t)
         NTC_Exp_IT(t)
         LT_Imp_TR(t)
         LT_Exp_TR(t)
         NTC_Imp_TR(t)
         NTC_Exp_TR(t)
         Priced_Imp_IT(t)
         Priced_Exp_IT(t)
         Priced_Imp_TR(t)
         Priced_Exp_TR(t)
         P_comm(t,i)
         P_h_mand(t,j)
         RES(t)
         Demand(t)
         SReserve_dn(t)
         SReserve_up(t)
         FSReserve_dn(t)
         FSReserve_up(t)
;

variables
         Total_Cost
         P               (i,t)
         P_h             (j,t)
         P_p             (j,t)
         P_step          (i,istep,t)
         P_step_h        (j,jstep,t)
         P_step_p        (j,jstep,t)
         SecRes_dn       (i,t)
         SecRes_up       (i,t)
         SecRes_dn_h     (j,t)
         SecRes_up_h     (j,t)
         FSecRes_dn      (i,t)
         FSecRes_up      (i,t)
         FSecRes_dn_h    (j,t)
         FSecRes_up_h    (j,t)
         u               (i,t)
         u_h             (j,t)
         u_AGC_up        (i,t)
         u_AGC_dn        (i,t)
         u_AGC_up_h      (j,t)
         u_AGC_dn_h      (j,t)
         y               (i,t)
         z               (i,t)
         P_Imp_IT        (t)
         P_Exp_IT        (t)
         P_Imp_TR        (t)
         P_Exp_TR        (t)
         P_Imp_AL        (t)
         P_Imp_FY        (t)
         ST_Imp_AL       (t)
         ST_Imp_BG       (t)
         ST_Imp_FY       (t)
         ED              (t)
         RD_up           (t)
         RD_dn           (t)
         FRD_up          (t)
         FRD_dn          (t)
;

Positive Variables
         P
         P_h
         P_p
         P_step
         P_step_h
         P_step_p
         SecRes_dn
         SecRes_up
         SecRes_dn_h
         SecRes_up_h
         FSecRes_dn
         FSecRes_up
         FSecRes_dn_h
         FSecRes_up_h
         P_Imp_IT
         P_Exp_IT
         P_Imp_TR
         P_Exp_TR
         P_Imp_AL
         P_Imp_FY
         ST_Imp_AL
         ST_Imp_BG
         ST_Imp_FY
         ED
         RD_up
         RD_dn
         FRD_up
         FRD_dn
;

Binary Variables
         u
         u_h
         u_AGC_up
         u_AGC_dn
         u_AGC_up_h
         u_AGC_dn_h
         y
         z
;

*$offtext

Parameters
         ED_Cost
         RD_Cost
         FRD_Cost
;

ED_Cost  = 1000000 ;
RD_Cost  = 1000000 ;
FRD_Cost = 1000000 ;

Equations

         Cost
         Hourly_Demand                   (t)
         Secondary_Reserve_Down          (t)
         Secondary_Reserve_Up            (t)
         Fast_Secondary_Down             (t)
         Fast_Secondary_Up               (t)

         Power_Output                    (i,t)
         Tech_Max                        (i,t)
         Tech_Min                        (i,t)
         Tech_Step_Max                   (i,istep,t)
         SR_down                         (i,t)
         SR_up                           (i,t)
         FSR_Up                          (i,t)
         FSR_Down                        (i,t)
         FSR_SR_Up                       (i,t)
         FSR_SR_Down                     (i,t)
         AGC_logic_up                    (i,t)
         AGC_logic_dn                    (i,t)
         Minimum_Up_Time_1               (i,t)
         Minimum_Up_Time_2               (i,t)
         Minimum_Down_Time_1             (i,t)
         Minimum_Down_Time_2             (i,t)
         SU_SD_Logical_1                 (i,t)
         SU_SD_Logical_2                 (i,t)
         SU_SD_Logical_1_Initial         (i)

         LT_Import_Limit_AL              (t)
         LT_Import_Limit_FY              (t)
         Priced_Import_Limit_IT          (t)
         Priced_Export_Limit_IT          (t)
         Priced_Import_Limit_TR          (t)
         Priced_Export_Limit_TR          (t)
         NTC_Limit_IT_Exp                (t)
         NTC_Limit_IT_Imp                (t)
         NTC_Limit_TR_Exp                (t)
         NTC_Limit_TR_Imp                (t)
         NTC_Limit_AL_Imp                (t)
         NTC_Limit_BG_Imp                (t)
         NTC_Limit_FY_Imp                (t)

         Power_Output_h                  (j,t)
         Tech_Step_Max_h                 (j,jstep,t)
         Power_Output_p                  (j,t)
         Tech_Step_Max_p                 (j,jstep,t)
         Tech_Max_H                      (j,t)
         Tech_Max_P                      (j,t)
         SR_Down_h                       (j,t)
         SR_Up_h                         (j,t)
         FSR_Up_h                        (j,t)
         FSR_Down_h                      (j,t)
         FSR_SR_Up_h                     (j,t)
         FSR_SR_Down_h                   (j,t)
         Tech_Max_h                      (j,t)
         Tech_Min_h                      (j,t)
         AGC_logic_up_h                  (j,t)
         AGC_logic_dn_h                  (j,t)

;

alias (i,ii)
alias (t,tt)
;

Parameter
         EM_Imp_Cost     ;

EM_Imp_Cost = 80        ;

****************************************
**** OBJECTIVE & SYSTEM CONSTRAINTS ****
****************************************



Cost                     ..      Total_Cost =e= Sum( i, Sum( t, Sum( istep, P_step(i,istep,t)*EnrPrice(t,i,istep) ) + z(i,t)*SDC(i) ) )

                                                 + Sum( j, Sum( t, Sum( jstep, P_step_h(j,jstep,t)*EnrPrice_h(t,j,jstep) ) ) )

                                                 + Sum( (i,t), ResPrice(t,i) * ( SecRes_dn(i,t) + SecRes_up(i,t) ) )

                                                 + Sum( (j,t), ResPrice_h(t,j) * ( SecRes_dn_h(j,t) + SecRes_up_h(j,t) ) )

                                                 + Sum( t, P_Imp_IT(t)*( MGP(t) + 2 ) + P_Imp_TR(t)*( PMUM(t) + 2 ) )

                                                 + Sum( t, ( ST_Imp_AL(t) + ST_Imp_BG(t) + ST_Imp_FY(t) )*EM_Imp_Cost )

                                                 - Sum( j, Sum( t, Sum( jstep, P_step_p(j,jstep,t)*BidPrice_p(t,j,jstep) ) ) )

                                                 - Sum( t, P_Exp_IT(t)*( MGP(t) - 2 ) + P_Exp_TR(t)*( PMUM(t) - 2 ) )

                                                 + Sum( t, ED_Cost*ED(t) + RD_Cost*RD_up(t) + RD_Cost*RD_dn(t) + FRD_Cost*FRD_up(t) + FRD_Cost*FRD_dn(t) )       ;

Hourly_Demand(t)         ..      Sum( i, P(i,t) ) + Sum( j, P_h(j,t) ) - Sum( j, P_p(j,t) )

                                 + LT_Imp_BG(t) + ST_Imp_BG(t) + P_Imp_AL(t) + ST_Imp_AL(t) + P_Imp_FY(t) + ST_Imp_FY(t)

                                 + LT_Imp_IT(t) + P_Imp_IT(t) + LT_Imp_TR(t) + P_Imp_TR(t)

                                 - LT_Exp_BG(t) - LT_Exp_AL(t) - LT_Exp_FY(t) - LT_Exp_IT(t) - P_Exp_IT(t) - LT_Exp_TR(t) - P_Exp_TR(t)

                                 + Sum( i, P_comm(t,i) ) + Sum( j, P_h_mand(t,j) ) + RES(t) + ED(t)

                                 =e= (1 + Loss_factor) * Demand(t)   ;

Secondary_Reserve_Down(t) ..     Sum(i_reserve, SecRes_dn(i_reserve,t) ) + Sum(j_reserve, SecRes_dn_h(j_reserve,t) ) + RD_dn(t)

                                 =g= SReserve_dn(t)      ;

Secondary_Reserve_Up(t)  ..      Sum(i_reserve, SecRes_up(i_reserve,t) ) + Sum(j_reserve, SecRes_up_h(j_reserve,t) ) + RD_up(t)

                                 =g= SReserve_up(t)      ;

Fast_Secondary_Down(t)   ..      Sum(i_reserve, FSecRes_up(i_reserve,t) ) + Sum(j_reserve, FSecRes_up_h(j_reserve,t) ) + FRD_dn(t)

                                 =g= FSReserve_dn(t)     ;

Fast_Secondary_Up(t)   ..        Sum(i_reserve, FSecRes_dn(i_reserve,t) ) + Sum(j_reserve, FSecRes_dn_h(j_reserve,t) ) + FRD_up(t)

                                 =g= FSReserve_up(t)     ;

*Tertiary_Reserve(t)      ..      Sum(i, TerRes(i,t) ) + Sum(j, TerRes_h(j,t) )

*                                 =g= TReserve(t)         ;

*Tertiary_Reserve(d,t)    ..      Sum(i_non_fast, (1-EFORd(i_non_fast)/70)*Pmax(i_non_fast)*u(i_non_fast,d,t) - Sum(istep, P_step(i_non_fast,istep,d,t) ) )

*                                 + Sum(i_fast, (1-EFORd(i_fast)/70)*Pmax(i_fast)*u_av(i_fast,d) - Sum(istep, P_step(i_fast,istep,d,t) ) )

*                                 + Sum(j, Pmax_h(j)*u_av_h(j,d) - P_h(j,d,t) ) + Sum(j, P_p(j,d,t) )

*                                 + RD(d,t)

*                                 =g= 0.1*Demand(d,t)   ;


**** READY TO BE ADDED - INITIAL CONDITIONS NEEDED ****

*Ramp_up(i,t)             ..      P(i,t)

*                                 =l= P(i,t-1) + 60*RampRate(i) * u(i,t-1) + Pmin(i) * y(i,t)     ;

*Ramp_dn(i,t)             ..      P(i,t)

*                                 =g= P(i,t-1) - 60*RampRate(i) * u(i,t) + Pmin(i) * z(i,t)       ;

*Ramp_up_h(j,t)           ..      P_h(j,t)

*                                 =l= P_h(j,t-1) + 60*RampRate_h(j) * u_h(j,t-1) + Pmin_h(j) * y_h(j,t)     ;

*Ramp_dn_h(j,t)           ..      P_h(j,t)

*                                 =g= P_h(j,t-1) - 60*RampRate_h(j) * u_h(j,t) + Pmin_h(j) * z_h(j,t)       ;

*****************************
**** THERMAL CONSTRAINTS ****
*****************************



Power_Output(i,t)        ..      P(i,t) =e= Sum(istep, P_step(i,istep,t) )       ;

Tech_Step_Max(i,istep,t)

                         ..      P_step(i,istep,t) =l= UntStep(t,i,istep)        ;

SR_Down(i,t) $ i_reserve(i)

                         ..      SecRes_dn(i,t)

                                 =l= 15 * RampRate(i) * u_AGC_dn(i,t)    ;

SR_Up(i,t) $ i_reserve(i)

                         ..      SecRes_up(i,t)

                                 =l= 15 * RampRate(i) * u_AGC_up(i,t)    ;

FSR_Up(i,t) $ i_reserve(i)

                         ..      FSecRes_up(i,t)

                                 =l= RampRate(i) * u_AGC_up(i,t)         ;

FSR_Down(i,t) $ i_reserve(i)

                         ..      FSecRes_dn(i,t)

                                 =l= RampRate(i) * u_AGC_dn(i,t)         ;

FSR_SR_Up(i,t) $ i_reserve(i)

                         ..      FSecRes_up(i,t)

                                 =l= SecRes_up(i,t)                      ;

FSR_SR_Down(i,t) $ i_reserve(i)

                         ..      FSecRes_dn(i,t)

                                 =l= SecRes_dn(i,t)                      ;

Tech_Max(i,t)            ..      P(i,t) + SecRes_up(i,t)

                                 =l= Pmax(i) * ( u(i,t) - u_AGC_up(i,t) ) + Pmax_AGC(i) * u_AGC_up(i,t)        ;

Tech_Min(i,t)            ..      P(i,t) - SecRes_dn(i,t)

                                 =g= Pmin(i) * ( u(i,t) - u_AGC_dn(i,t) ) + Pmin_AGC(i) * u_AGC_dn(i,t)        ;

AGC_logic_up(i,t) $ i_reserve(i)

                         ..      u_AGC_up(i,t)

                                 =l= u(i,t)      ;

AGC_logic_dn(i,t) $ i_reserve(i)

                         ..      u_AGC_dn(i,t)

                                 =l= u(i,t)      ;

Minimum_Up_Time_1(i,t) $ ( ( ord(t)<MUT(i) ) AND ( Pmax(i)>0 ) )

                         ..      u(i,t)

                                 =g= Sum(tt$ (ord(tt)<=ord(t)), y(i,tt) ) + SynchPast(i,t)                       ;

Minimum_Up_Time_2(i,t) $ ( ( ord(t)>=MUT(i) ) AND ( Pmax(i)>0 ) )

                         ..      u(i,t)

                                 =g= Sum(tt$ (ord(tt)>=(ord(t)-MUT(i)+1) and ord(tt)<=ord(t)), y(i,tt) )         ;

Minimum_Down_Time_1(i,t) $ ( ( ord(t)<MDT(i) ) AND ( Pmax(i)>0 ) )

                         ..      1 - u(i,t)

                                 =g= Sum(tt$ (ord(tt)<=ord(t)), z(i,tt) ) + DesynchPast(i,t)                     ;

Minimum_Down_Time_2(i,t) $ ( ( ord(t)>=MDT(i) ) AND ( Pmax(i)>0 ) )

                         ..      1 - u(i,t)

                                 =g= Sum(tt$ (ord(tt)>=(ord(t)-MDT(i)+1) and ord(tt)<=ord(t)), z(i,tt) )         ;

SU_SD_Logical_1(i,t) $ ( (ord(t)>1) )

                         ..      u(i,t) - u(i,t-1)

                                 =e= y(i,t) - z(i,t)                                                             ;

SU_SD_Logical_1_Initial(i) $ ( Pmax(i)>0 )

                         ..      u(i,"1") - InitialCommStat(i)

                                 =e= y(i,"1") - z(i,"1")                                                         ;

SU_SD_Logical_2(i,t)

                         ..      y(i,t) + z(i,t)

                                 =l= 1                                                                           ;



*************************************
**** INTERCONNECTION CONSTRAINTS ****
*************************************


LT_Import_Limit_AL(t)            ..      P_Imp_AL(t) =l= LT_Imp_AL(t)            ;

LT_Import_Limit_FY(t)            ..      P_Imp_FY(t) =l= LT_Imp_FY(t)            ;

Priced_Import_Limit_IT(t)        ..      P_Imp_IT(t) =l= Priced_Imp_IT(t)        ;

Priced_Export_Limit_IT(t)        ..      P_Exp_IT(t) =l= Priced_Exp_IT(t)        ;

Priced_Import_Limit_TR(t)        ..      P_Imp_TR(t) =l= Priced_Imp_TR(t)        ;

Priced_Export_Limit_TR(t)        ..      P_Exp_TR(t) =l= Priced_Exp_TR(t)        ;

NTC_Limit_IT_Exp(t)              ..      P_Exp_IT(t) - P_Imp_IT(t) + LT_Exp_IT(t) - LT_Imp_IT(t) =l= NTC_Exp_IT(t)       ;

NTC_Limit_IT_Imp(t)              ..      P_Imp_IT(t) - P_Exp_IT(t) + LT_Imp_IT(t) - LT_Exp_IT(t) =l= NTC_Imp_IT(t)       ;

NTC_Limit_TR_Exp(t)              ..      P_Exp_TR(t) - P_Imp_TR(t) + LT_Exp_TR(t) - LT_Imp_TR(t) =l= NTC_Exp_TR(t)       ;

NTC_Limit_TR_Imp(t)              ..      P_Imp_TR(t) - P_Exp_TR(t) + LT_Imp_TR(t) - LT_Exp_TR(t) =l= NTC_Imp_TR(t)       ;

NTC_Limit_AL_Imp(t)              ..      P_Imp_AL(t) + ST_Imp_AL(t) - LT_Exp_AL(t) =l= NTC_Imp_AL(t)     ;

NTC_Limit_BG_Imp(t)              ..      LT_Imp_BG(t) + ST_Imp_BG(t) - LT_Exp_BG(t) =l= NTC_Imp_BG(t)    ;

NTC_Limit_FY_Imp(t)              ..      P_Imp_FY(t) + ST_Imp_FY(t) - LT_Exp_FY(t) =l= NTC_Imp_FY(t)     ;



***************************
**** HYDRO CONSTRAINTS ****
***************************



Power_Output_h(j,t)              ..      P_h(j,t) =e= Sum(jstep, P_step_h(j,jstep,t) )   ;

Tech_Step_Max_h(j,jstep,t)       ..      P_step_h(j,jstep,t) =l= UntStep_h(t,j,jstep)    ;

Power_Output_p(j,t)              ..      P_p(j,t) =e= Sum(jstep, P_step_p(j,jstep,t) )   ;

Tech_Step_Max_p(j,jstep,t)       ..      P_step_p(j,jstep,t) =l= UntStep_p(t,j,jstep)    ;

Tech_Max_P(j,t)                  ..      P_p(j,t) =l= Pmax_p(j)                          ;

SR_Down_h(j,t) $ j_reserve(j)

                                 ..      SecRes_dn_h(j,t)

                                         =l= 15 * RampRate_h(j) * u_AGC_dn_h(j,t)        ;

SR_Up_h(j,t) $ j_reserve(j)

                                 ..      SecRes_up_h(j,t)

                                         =l= 15 * RampRate_h(j) * u_AGC_up_h(j,t)        ;

FSR_Up_h(j,t) $ j_reserve(j)

                                 ..      FSecRes_up_h(j,t)

                                         =l= RampRate_h(j) * u_AGC_up_h(j,t)             ;

FSR_Down_h(j,t) $ j_reserve(j)

                                 ..      FSecRes_dn_h(j,t)

                                         =l= RampRate_h(j) * u_AGC_dn_h(j,t)             ;

FSR_SR_Up_h(j,t) $ j_reserve(j)

                                 ..      FSecRes_up_h(j,t)

                                         =l= SecRes_up_h(j,t)                            ;

FSR_SR_Down_h(j,t) $ j_reserve(j)

                                 ..      FSecRes_dn_h(j,t)

                                         =l= SecRes_dn_h(j,t)                            ;

Tech_Max_h(j,t)                  ..      P_h(j,t) + P_h_mand(t,j) + SecRes_up_h(j,t)

                                         =l= Pmax_h(j) * ( u_h(j,t) - u_AGC_up_h(j,t) ) + Pmax_AGC_h(j) * u_AGC_up_h(j,t)      ;

Tech_Min_h(j,t)                  ..      P_h(j,t) + P_h_mand(t,j) - SecRes_dn_h(j,t)

                                         =g= Pmin_h(j) * ( u_h(j,t) - u_AGC_dn_h(j,t) ) + Pmin_AGC_h(j) * u_AGC_dn_h(j,t)      ;

AGC_logic_up_h(j,t) $ j_reserve(j)

                                 ..      u_AGC_up_h(j,t)

                                         =l= u_h(j,t)    ;

AGC_logic_dn_h(j,t) $ j_reserve(j)

                                 ..      u_AGC_dn_h(j,t)

                                         =l= u_h(j,t)    ;

*Reservoir(j,d)                   ..      V(j,d) =e=  V(j,d--1) + Inflow(j,d) - sc(j)* E_h(j,d) - Sp(j,d) + 0.75* sc(j)* E_p(j,d)

*                                                + coupled(j)* ( sc(j-1)*E_h(j-1,d) + sp(j-1,d) - 0.75 *sc(j-1)* E_p(j-1,d) )       ;

*Volume_Constraint(j,d)           ..      V(j,d) =l= Vmax(j)                      ;

*Daily_Production(j,d)            ..      E_h(j,d) =e= sum(t,P_h(j,d,t))          ;

*Daily_Pumping(j,d)               ..      E_p(j,d) =e= sum(t,P_p(j,d,t))          ;


model DAS /all/       ;

DAS.optfile   = 1     ;

file opt /cplex.opt/     ;
put opt  ;
put
         ' threads 7' /
         ' startalg 4' /
         ' lpmethod 4' /
*         ' barooc 1' /
;

*    ' threads 2 ' /
*    ' mipthreads 2 ' /
*    ' startalg 4 ' /
*    ' barthreads 2 '/     ;
putclose opt;

option solprint=Off;
option reslim=120;
option limcol=0;
option limrow=0;
option MIP=cplex;
option iterlim=1000000;
option optcr=0.001;
*option threads=4;

*P_p.fx(j,t)  $ ( ord(t) > 7 ) = 0 ;


***********************************
*** INITIAL CONDITIONS AT t = 1 ***
***********************************

*InitialCommStat(i)       =       UntDat(i,"InitStat")    ;
*SynchPast(i,t)           =       UntDat(i,"Must_Run")    ;
*DesynchPast(i,t)         =       UntDat(i,"Must_Hold")   ;

InitialCommStat(i)       =       1 ;
SynchPast(i,t)           =       0 ;
DesynchPast(i,t)         =       0 ;


Variables
         P_f             (d,i,t)
         P_h_f           (d,j,t)
         P_p_f           (d,j,t)
         SecRes_dn_f     (d,i,t)
         SecRes_up_f     (d,i,t)
         SecRes_dn_h_f   (d,j,t)
         SecRes_up_h_f   (d,j,t)
         FSecRes_dn_f    (d,i,t)
         FSecRes_up_f    (d,i,t)
         FSecRes_dn_h_f  (d,j,t)
         FSecRes_up_h_f  (d,j,t)
         u_f             (d,i,t)
         u_h_f           (d,j,t)
         u_AGC_up_f      (d,i,t)
         u_AGC_dn_f      (d,i,t)
         u_AGC_up_h_f    (d,j,t)
         u_AGC_dn_h_f    (d,j,t)
         y_f             (d,i,t)
         z_f             (d,i,t)
         P_Imp_IT_f      (d,t)
         P_Exp_IT_f      (d,t)
         P_Imp_TR_f      (d,t)
         P_Exp_TR_f      (d,t)
         P_Imp_AL_f      (d,t)
         P_Exp_AL_f      (d,t)
         P_Imp_FY_f      (d,t)
         P_Exp_FY_f      (d,t)
         P_Imp_BG_f      (d,t)
         P_Exp_BG_f      (d,t)
         Emergency_Imp_f (d,t)
         Total_Net_Imp   (d,t)
         Total_Imp       (d,t)
         Total_Exp       (d,t)
         ED_f            (d,t)
         RD_up_f         (d,t)
         RD_dn_f         (d,t)
         FRD_up_f        (d,t)
         FRD_dn_f        (d,t)
         SMP             (d,t)
;

Parameter
              EnrPrice_init(t,i,istep)  ;

EnrPrice_init(t,i,istep) = EnrPrice(t,i,istep) ;

Parameter
         Running_time(i)
;

Running_time(i) = 0 ;

loop(d,

         Pmax(i)         = P_av_d(d,i)*UntDat(i,"Pmax")          ;
         Pmax_AGC(i)     = P_av_d(d,i)*UntDat(i,"Pmax_AGC")      ;

*         Display Pmax ;

         MGP(t)          = MGP_d(d,t)                    ;
         PMUM(t)         = PMUM_d(d,t)                   ;

         LT_Imp_BG(t)    = LT_Imp_BG_d(d,t)              ;
         LT_Exp_BG(t)    = LT_Exp_BG_d(d,t)              ;
         NTC_Imp_BG(t)   = NTC_Imp_BG_d(d,t)             ;
         NTC_Exp_BG(t)   = NTC_Exp_BG_d(d,t)             ;

         LT_Imp_AL(t)    = LT_Imp_AL_d(d,t)              ;
         LT_Exp_AL(t)    = LT_Exp_AL_d(d,t)              ;
         NTC_Imp_AL(t)   = NTC_Imp_AL_d(d,t)             ;
         NTC_Exp_AL(t)   = NTC_Exp_AL_d(d,t)             ;

         LT_Imp_FY(t)    = LT_Imp_FY_d(d,t)              ;
         LT_Exp_FY(t)    = LT_Exp_FY_d(d,t)              ;
         NTC_Imp_FY(t)   = NTC_Imp_FY_d(d,t)             ;
         NTC_Exp_FY(t)   = NTC_Exp_FY_d(d,t)             ;

         LT_Imp_IT(t)    = LT_Imp_IT_d(d,t)              ;
         LT_Exp_IT(t)    = LT_Exp_IT_d(d,t)              ;
         NTC_Imp_IT(t)   = NTC_Imp_IT_d(d,t)             ;
         NTC_Exp_IT(t)   = NTC_Exp_IT_d(d,t)             ;

         LT_Imp_TR(t)    = LT_Imp_TR_d(d,t)              ;
         LT_Exp_TR(t)    = LT_Exp_TR_d(d,t)              ;
         NTC_Imp_TR(t)   = NTC_Imp_TR_d(d,t)             ;
         NTC_Exp_TR(t)   = NTC_Exp_TR_d(d,t)             ;

         Priced_Imp_IT(t)= Priced_Imp_IT_d(d,t)          ;
         Priced_Exp_IT(t)= Priced_Exp_IT_d(d,t)          ;
         Priced_Imp_TR(t)= Priced_Imp_TR_d(d,t)          ;
         Priced_Exp_TR(t)= Priced_Exp_TR_d(d,t)          ;

         P_comm(t,i)     = P_comm_d(d,i,t)               ;
         P_h_mand(t,j)   = P_h_mand_d(d,j,t)             ;
         RES(t)          = RES_d(d,t)                    ;
         Demand(t)       = 0.985 * Demand_d(d,t)         ;
         SReserve_dn(t)  = SReserve_dn_d(d,t)            ;
         SReserve_up(t)  = SReserve_up_d(d,t)            ;
         FSReserve_dn(t) = FSReserve_dn_d(d,t)           ;
         FSReserve_up(t) = FSReserve_up_d(d,t)           ;

         Total_Cost.l    = 0     ;
         ED.l(t)         = 0     ;
         RD_up.l(t)      = 0     ;
         RD_dn.l(t)      = 0     ;
         FRD_up.l(t)     = 0     ;
         FRD_dn.l(t)     = 0     ;

*         P.fx(i,t) $ ( P_av_d(d,i) = 0 )                 = 0 ;
*         u.fx(i,t) $ ( P_av_d(d,i) = 0 )                 = 0 ;

         P.fx(i,t) $ ( Sum(tt, P_comm(tt,i) ) > 0 )      = 0 ;
         u_AGC_up.fx(i,t) $ ( UntDat(i,"AGC") = 0 )      = 0 ;
         u_AGC_dn.fx(i,t) $ ( UntDat(i,"AGC") = 0 )      = 0 ;
         u_AGC_up_h.fx(j,t) $ ( HydUntDat(j,"AGC") = 0 ) = 0 ;
         u_AGC_dn_h.fx(j,t) $ ( HydUntDat(j,"AGC") = 0 ) = 0 ;

         ST_Imp_AL.up(t) = 30    ;
         ST_Imp_FY.up(t) = 40    ;
         ST_Imp_BG.up(t) = 30    ;

         SOLVE DAS using MIP minimizing Total_Cost ;

*         Display P_Imp_AL.l, LT_Imp_AL ;

         EnrPrice(t,i,istep) = EnrPrice_init(t,i,istep) ;

         Running_time(i) = 0 ;
$ontext
         if ( P.l("HERON_CC","24") > 0,

                   Running_time("HERON_CC")      = Sum(t $ ( ord(t) >= card(t) - MUT("HERON_CC") + 1 ), u.l("HERON_CC",t) )      ;

                   EnrPrice(t,"HERON_CC",istep) $ ( ( ord(t) >= MUT("HERON_CC") - Running_time("HERON_CC") + 1 )

                                                         and ( ord(t) < MUT("HERON_CC") - Running_time("HERON_CC") + 24 ) ) = 150 ;

         ) ;

         if ( P.l("ELPEDISON_THISVI","24") > 0,

                   Running_time("ELPEDISON_THISVI")      = Sum(t $ ( ord(t) >= card(t) - MUT("ELPEDISON_THISVI") + 1 ), u.l("ELPEDISON_THISVI",t) )      ;

                   EnrPrice(t,"ELPEDISON_THISVI",istep) $ ( ( ord(t) >= MUT("ELPEDISON_THISVI") - Running_time("ELPEDISON_THISVI") + 1 )

                                                         and ( ord(t) < MUT("ELPEDISON_THISVI") - Running_time("ELPEDISON_THISVI") + 24 ) ) = 150 ;

         ) ;

         if ( P.l("ELPEDISON_THESS","24") > 0,

                   Running_time("ELPEDISON_THESS")      = Sum(t $ ( ord(t) >= card(t) - MUT("ELPEDISON_THESS") + 1 ), u.l("ELPEDISON_THESS",t) )      ;

                   EnrPrice(t,"ELPEDISON_THESS",istep) $ ( ( ord(t) >= MUT("ELPEDISON_THESS") - Running_time("ELPEDISON_THESS") + 1 )

                                                         and ( ord(t) < MUT("ELPEDISON_THESS") - Running_time("ELPEDISON_THESS") + 24 ) ) = 150 ;

         ) ;

         if ( P.l("PROTERGIA_CC","24") > 0,

                   Running_time("PROTERGIA_CC")      = Sum(t $ ( ord(t) >= card(t) - MUT("PROTERGIA_CC") + 1 ), u.l("PROTERGIA_CC",t) )      ;

                   EnrPrice(t,"PROTERGIA_CC",istep) $ ( ( ord(t) >= MUT("PROTERGIA_CC") - Running_time("PROTERGIA_CC") + 1 )

                                                         and ( ord(t) < MUT("PROTERGIA_CC") - Running_time("PROTERGIA_CC") + 5 ) ) = 150 ;

         ) ;

         if ( P.l("KORINTHOS_POWER","24") > 0,

                   Running_time("KORINTHOS_POWER")      = Sum(t $ ( ord(t) >= card(t) - MUT("KORINTHOS_POWER") + 1 ), u.l("KORINTHOS_POWER",t) )      ;

                   EnrPrice(t,"KORINTHOS_POWER",istep) $ ( ( ord(t) >= MUT("KORINTHOS_POWER") - Running_time("KORINTHOS_POWER") + 1 )

                                                         and ( ord(t) < MUT("KORINTHOS_POWER") - Running_time("KORINTHOS_POWER") + 5 ) ) = 150 ;

         ) ;

$offtext
         InitialCommStat(i)       = 0 ;
         SynchPast(i,t)           = 0 ;
         DesynchPast(i,t)         = 0 ;

         InitialCommStat(i)      = u.l(i,"24") ;
         InitialCommStat(i) $ (InitialCommStat(i)<1) = 0 ;

         loop(i,

              loop ( t $ ( ord(t) <= MUT(i) - 1 ),

                     SynchPast(i,t) = Sum( tt $ ( ord(tt) >= 24 - MUT(i) + ord(t) + 1 ), y.l(i,tt) )    ;

              ) ;

         ) ;

         SynchPast(i,t) $ (SynchPast(i,t)<1) = 0 ;

         loop(i,

              loop ( t $ ( ord(t) <= MDT(i) - 1 ),

                     DesynchPast(i,t) = Sum( tt $ ( ord(tt) >= 24 - MDT(i) + ord(t) + 1 ), z.l(i,tt) )    ;

              ) ;

         ) ;

         DesynchPast(i,t) $ (DesynchPast(i,t)<1) = 0 ;

*         Display InitialCommStat, SynchPast, DesynchPast ;
*         Display P.l ;

         P_f.fx             (d,i,t) = P.l           (i,t)                   ;
         P_h_f.fx           (d,j,t) = P_h.l         (j,t)                   ;
         P_p_f.fx           (d,j,t) = P_p.l         (j,t)                   ;
         SecRes_dn_f.fx     (d,i,t) = SecRes_dn.l   (i,t)                   ;
         SecRes_up_f.fx     (d,i,t) = SecRes_up.l   (i,t)                   ;
         SecRes_dn_h_f.fx   (d,j,t) = SecRes_dn_h.l (j,t)                   ;
         SecRes_up_h_f.fx   (d,j,t) = SecRes_up_h.l (j,t)                   ;
         FSecRes_dn_f.fx    (d,i,t) = FSecRes_dn.l  (i,t)                   ;
         FSecRes_up_f.fx    (d,i,t) = FSecRes_up.l  (i,t)                   ;
         FSecRes_dn_h_f.fx  (d,j,t) = FSecRes_dn_h.l(j,t)                   ;
         FSecRes_up_h_f.fx  (d,j,t) = FSecRes_up_h.l(j,t)                   ;
         u_f.fx             (d,i,t) = u.l           (i,t)                   ;
         u_h_f.fx           (d,j,t) = u_h.l         (j,t)                   ;
         u_AGC_up_f.fx      (d,i,t) = u_AGC_up.l    (i,t)                   ;
         u_AGC_dn_f.fx      (d,i,t) = u_AGC_dn.l    (i,t)                   ;
         u_AGC_up_h_f.fx    (d,j,t) = u_AGC_up_h.l  (j,t)                   ;
         u_AGC_dn_h_f.fx    (d,j,t) = u_AGC_dn_h.l  (j,t)                   ;
         y_f.fx             (d,i,t) = y.l           (i,t)                   ;
         z_f.fx             (d,i,t) = z.l           (i,t)                   ;

         P_Imp_IT_f.fx      (d,t)   = LT_Imp_IT(t) + P_Imp_IT.l(t)          ;
         P_Exp_IT_f.fx      (d,t)   = LT_Exp_IT(t) + P_Exp_IT.l(t)          ;
         P_Imp_TR_f.fx      (d,t)   = LT_Imp_TR(t) + P_Imp_TR.l(t)          ;
         P_Exp_TR_f.fx      (d,t)   = LT_Exp_TR(t) + P_Exp_TR.l(t)          ;
         P_Imp_AL_f.fx      (d,t)   = P_Imp_AL.l(t) + ST_Imp_AL.l(t)        ;
         P_Exp_AL_f.fx      (d,t)   = LT_Exp_AL(t)                          ;
         P_Imp_FY_f.fx      (d,t)   = P_Imp_FY.l(t) + ST_Imp_FY.l(t)        ;
         P_Exp_FY_f.fx      (d,t)   = LT_Exp_FY(t)                          ;
         P_Imp_BG_f.fx      (d,t)   = LT_Imp_BG(t) + ST_Imp_BG.l(t)         ;
         P_Exp_BG_f.fx      (d,t)   = LT_Exp_BG(t)                          ;

         Emergency_Imp_f.fx (d,t)   = ST_Imp_BG.l(t) + ST_Imp_FY.l(t) + ST_Imp_AL.l(t) ;

         Total_Imp.fx       (d,t)   = P_Imp_AL_f.l(d,t) + P_Imp_BG_f.l(d,t) + P_Imp_FY_f.l(d,t) + P_Imp_IT_f.l(d,t) + P_Imp_TR_f.l(d,t)  ;
         Total_Exp.fx       (d,t)   = P_Exp_AL_f.l(d,t) + P_Exp_BG_f.l(d,t) + P_Exp_FY_f.l(d,t) + P_Exp_IT_f.l(d,t) + P_Exp_TR_f.l(d,t)  ;

         Total_Net_Imp.fx   (d,t)   = P_Imp_AL_f.l(d,t) + P_Imp_BG_f.l(d,t) + P_Imp_FY_f.l(d,t) + P_Imp_IT_f.l(d,t) + P_Imp_TR_f.l(d,t)
                                      - P_Exp_AL_f.l(d,t) - P_Exp_BG_f.l(d,t) - P_Exp_FY_f.l(d,t) - P_Exp_IT_f.l(d,t) - P_Exp_TR_f.l(d,t) ;

         ED_f.fx            (d,t)   = ED.l          (t)                     ;
         RD_up_f.fx         (d,t)   = RD_up.l       (t)                     ;
         RD_dn_f.fx         (d,t)   = RD_dn.l       (t)                     ;
         FRD_up_f.fx        (d,t)   = FRD_up.l      (t)                     ;
         FRD_dn_f.fx        (d,t)   = FRD_dn.l      (t)                     ;

         SMP.fx             (d,t)   = Hourly_Demand.m(t)                    ;

) ;


Parameters
         Average_SMP
         Lignite
         CCGT
         Oil
         OCGT
         CHP
         Hydro
         RES_y
         Pumping
         Net_Imp
         Emergency_Imp
         EDeficit
         RDeficit
         FRDeficit
         Daily_Demand            (d)
         Daily_Losses            (d)
         Daily_RES               (d)
         Daily_Average_SMP       (d)
         Daily_Lignite           (d)
         Daily_CCGT              (d)
         Daily_Oil               (d)
         Daily_OCGT              (d)
         Daily_CHP               (d)
         Daily_Hydro             (d)
         Daily_Pumping           (d)
         Daily_Net_Imp           (d)
         Daily_P_Output          (i,d)
         Daily_P_SU              (i,d)
         Daily_P_Comm            (i,d)
;

Average_SMP      = Sum( (d,t), SMP.l(d,t) ) / ( card(d) * card(t) )                                                                ;
Lignite          = Sum( i $ ( UntDat(i,"Type") = 1 ), Sum( (d,t), P_f.l(d,i,t) + P_comm_d(d,i,t) ) )                               ;
Oil              = Sum( i $ ( UntDat(i,"Type") = 2 ), Sum( (d,t), P_f.l(d,i,t) + P_comm_d(d,i,t) ) )                               ;
CCGT             = Sum( i $ ( UntDat(i,"Type") = 3 ), Sum( (d,t), P_f.l(d,i,t) + P_comm_d(d,i,t) ) )                               ;
OCGT             = Sum( i $ ( UntDat(i,"Type") = 4 ), Sum( (d,t), P_f.l(d,i,t) + P_comm_d(d,i,t) ) )                               ;
CHP              = Sum( i $ ( UntDat(i,"Type") = 5 ), Sum( (d,t), P_f.l(d,i,t) + P_comm_d(d,i,t) ) )                               ;
Hydro            = Sum( (j,d,t), P_h_f.l(d,j,t) + P_h_mand_d(d,j,t) )                                                              ;
Pumping          = Sum( (j,d,t), P_p_f.l(d,j,t) )                                                                                  ;
RES_y            = Sum( (d,t), RES_d(d,t) )                                                                                        ;
Emergency_Imp    = Sum( (d,t), Emergency_Imp_f.l(d,t) )                                                                            ;
EDeficit         = Sum( (d,t), ED_f.l(d,t) )                                                                                       ;
RDeficit         = Sum( (d,t), RD_up_f.l(d,t) + RD_dn_f.l(d,t) )                                                                   ;
FRDeficit        = Sum( (d,t), FRD_up_f.l(d,t) + FRD_dn_f.l(d,t) )                                                                 ;

Net_Imp          = Sum( (d,t), P_Imp_AL_f.l(d,t) + P_Imp_BG_f.l(d,t) + P_Imp_FY_f.l(d,t) + P_Imp_IT_f.l(d,t) + P_Imp_TR_f.l(d,t)

                               - P_Exp_AL_f.l(d,t) - P_Exp_BG_f.l(d,t) - P_Exp_FY_f.l(d,t) - P_Exp_IT_f.l(d,t) - P_Exp_TR_f.l(d,t) )       ;


Daily_Average_SMP(d)     = Sum(t, SMP.l(d,t) ) / card(t)                                                         ;
Daily_P_Output(i,d)      = Sum(t, P_f.l(d,i,t) + P_comm_d(d,i,t) )                                               ;
Daily_P_SU(i,d)          = Sum(t, y_f.l(d,i,t) )                                                                 ;
Daily_P_Comm(i,d)        = Sum(t, u_f.l(d,i,t) )                                                                 ;
Daily_Lignite(d)         = Sum( i $ ( UntDat(i,"Type") = 1 ), Sum(t, P_f.l(d,i,t) + P_comm_d(d,i,t) ) )          ;
Daily_Oil(d)             = Sum( i $ ( UntDat(i,"Type") = 2 ), Sum(t, P_f.l(d,i,t) + P_comm_d(d,i,t) ) )          ;
Daily_CCGT(d)            = Sum( i $ ( UntDat(i,"Type") = 3 ), Sum(t, P_f.l(d,i,t) + P_comm_d(d,i,t) ) )          ;
Daily_OCGT(d)            = Sum( i $ ( UntDat(i,"Type") = 4 ), Sum(t, P_f.l(d,i,t) + P_comm_d(d,i,t) ) )          ;
Daily_CHP(d)             = Sum( i $ ( UntDat(i,"Type") = 5 ), Sum(t, P_f.l(d,i,t) + P_comm_d(d,i,t) ) )          ;
Daily_Hydro(d)           = Sum( (j,t), P_h_f.l(d,j,t) + P_h_mand_d(d,j,t) )                                      ;
Daily_Pumping(d)         = Sum( (j,t), P_p_f.l(d,j,t) )                                                          ;
Daily_Demand(d)          = Sum(t, Demand_d(d,t) )                                                                ;
Daily_Losses(d)          = Sum(t, Loss_factor * Demand_d(d,t) )                                                  ;
Daily_RES(d)             = Sum(t, RES_d(d,t) )                                                                   ;

Daily_Net_Imp(d)         = Sum( t, P_Imp_AL_f.l(d,t) + P_Imp_BG_f.l(d,t) + P_Imp_FY_f.l(d,t) + P_Imp_IT_f.l(d,t) + P_Imp_TR_f.l(d,t)

                               - P_Exp_AL_f.l(d,t) - P_Exp_BG_f.l(d,t) - P_Exp_FY_f.l(d,t) - P_Exp_IT_f.l(d,t) - P_Exp_TR_f.l(d,t) )       ;


Display  Average_SMP, Lignite, CCGT, Oil, OCGT, CHP, Hydro, RES_y, Pumping, Net_Imp, Emergency_Imp, EDeficit, RDeficit, FRDeficit ;

execute_unload 'midTEMPS_Results_Monthly' P_f, P_h_f, P_p_f, SecRes_dn_f, SecRes_up_f, SecRes_dn_h_f, SecRes_up_h_f, FSecRes_dn_f, FSecRes_up_f,

                                  FSecRes_dn_h_f, FSecRes_up_h_f, u_f, u_h_f, u_AGC_up_f, u_AGC_dn_f, u_AGC_up_h_f, u_AGC_dn_h_f, y_f,

                                  z_f, P_Imp_IT_f, P_Exp_IT_f, P_Imp_TR_f, P_Exp_TR_f, P_Imp_AL_f, P_Exp_AL_f, P_Imp_FY_f, P_Exp_FY_f,

                                  P_Imp_BG_f, P_Exp_BG_f, Emergency_Imp_f, ED_f, RD_up_f, RD_dn_f, FRD_up_f, FRD_dn_f, Total_Imp.l, Total_Exp.l, Total_Net_Imp.l, SMP

                                  Daily_Demand, Daily_Losses, Daily_RES, Daily_Average_SMP, Daily_Lignite, Daily_CCGT, Daily_Oil, Daily_OCGT, Daily_CHP, Daily_Hydro,

                                  Daily_Pumping, Daily_Net_Imp, Daily_P_Output, Daily_P_SU, Daily_P_Comm

;
*$ontext
execute 'gdxxrw.exe midTEMPS_Results_Monthly.gdx SQ=N var=SMP.l rng=SMP!a1'                                ;
execute 'gdxxrw.exe midTEMPS_Results_Monthly.gdx SQ=N var=P_f.l rng=ThermalOutput!a1'                      ;
execute 'gdxxrw.exe midTEMPS_Results_Monthly.gdx SQ=N var=P_h_f.l rng=HydroOutput!a1'                      ;
execute 'gdxxrw.exe midTEMPS_Results_Monthly.gdx SQ=N var=P_p_f.l rng=Pumping!a1'                          ;
execute 'gdxxrw.exe midTEMPS_Results_Monthly.gdx SQ=N var=Total_Net_Imp.l rng=NetImports!a1'               ;
execute 'gdxxrw.exe midTEMPS_Results_Monthly.gdx SQ=N var=Total_Imp.l rng=Imports!a1'                      ;
execute 'gdxxrw.exe midTEMPS_Results_Monthly.gdx SQ=N var=Total_Exp.l rng=Exports!a1'                      ;
execute 'gdxxrw.exe midTEMPS_Results_Monthly.gdx SQ=Y var=SecRes_dn_f.l rng=ThermalSecResDn!a1'            ;
execute 'gdxxrw.exe midTEMPS_Results_Monthly.gdx SQ=Y var=SecRes_up_f.l rng=ThermalSecResUp!a1'            ;
execute 'gdxxrw.exe midTEMPS_Results_Monthly.gdx SQ=Y var=SecRes_dn_h_f.l rng=HydroSecResDn!a1'            ;
execute 'gdxxrw.exe midTEMPS_Results_Monthly.gdx SQ=Y var=SecRes_up_h_f.l rng=HydroSecResUp!a1'            ;
*execute 'gdxxrw.exe midTEMPS_Results_Monthly.gdx SQ=N var=FSecRes_dn_f.l rng=ThermalFastSecResDn!a1'       ;
*execute 'gdxxrw.exe midTEMPS_Results_Monthly.gdx SQ=N var=FSecRes_up_f.l rng=ThermalFastSecResUp!a1'       ;
*execute 'gdxxrw.exe midTEMPS_Results_Monthly.gdx SQ=N var=FSecRes_dn_h_f.l rng=HydroFastSecResDn!a1'       ;
*execute 'gdxxrw.exe midTEMPS_Results_Monthly.gdx SQ=N var=FSecRes_up_h_f.l rng=HydroFastSecResUp!a1'       ;
execute 'gdxxrw.exe midTEMPS_Results_Monthly.gdx SQ=N var=u_f.l rng=ThermalCommitment!a1'                  ;
execute 'gdxxrw.exe midTEMPS_Results_Monthly.gdx SQ=N var=u_h_f.l rng=HydroCommitment!a1'                  ;
*execute 'gdxxrw.exe midTEMPS_Results_Monthly.gdx SQ=N var=u_AGC_up_f.l rng=ThermalAGCup!a1'                ;
*execute 'gdxxrw.exe midTEMPS_Results_Monthly.gdx SQ=N var=u_AGC_dn_f.l rng=ThermalAGCdn!a1'                ;
*execute 'gdxxrw.exe midTEMPS_Results_Monthly.gdx SQ=N var=u_AGC_up_h_f.l rng=HydroAGCup!a1'                ;
*execute 'gdxxrw.exe midTEMPS_Results_Monthly.gdx SQ=N var=u_AGC_dn_h_f.l rng=HydroAGCdn!a1'                ;
execute 'gdxxrw.exe midTEMPS_Results_Monthly.gdx SQ=N var=y_f.l rng=ThermalStartUp!a1'                     ;
execute 'gdxxrw.exe midTEMPS_Results_Monthly.gdx SQ=N var=z_f.l rng=ThermalShutDown!a1'                    ;
execute 'gdxxrw.exe midTEMPS_Results_Monthly.gdx SQ=Y par=Daily_P_Output rng=DailyThermalOut!a1'           ;
execute 'gdxxrw.exe midTEMPS_Results_Monthly.gdx SQ=Y par=Daily_P_SU rng=DailyThermalSU!a1'                ;
execute 'gdxxrw.exe midTEMPS_Results_Monthly.gdx SQ=Y par=Daily_P_Comm rng=DailyThermalComm!a1'            ;
execute 'gdxxrw.exe midTEMPS_Results_Monthly.gdx SQ=Y par=Daily_Demand rng=Demand!a1'                      ;
execute 'gdxxrw.exe midTEMPS_Results_Monthly.gdx SQ=Y par=Daily_Losses rng=Losses!a1'                      ;
execute 'gdxxrw.exe midTEMPS_Results_Monthly.gdx SQ=Y par=Daily_RES rng=RES!a1'                            ;
execute 'gdxxrw.exe midTEMPS_Results_Monthly.gdx SQ=Y par=Daily_Average_SMP rng=Average_SMP!a1'            ;
execute 'gdxxrw.exe midTEMPS_Results_Monthly.gdx SQ=Y par=Daily_Lignite rng=Lignite!a1'                    ;
execute 'gdxxrw.exe midTEMPS_Results_Monthly.gdx SQ=Y par=Daily_CCGT rng=CCGT!a1'                          ;
execute 'gdxxrw.exe midTEMPS_Results_Monthly.gdx SQ=Y par=Daily_Oil rng=Oil!a1'                            ;
execute 'gdxxrw.exe midTEMPS_Results_Monthly.gdx SQ=Y par=Daily_OCGT rng=OCGT!a1'                          ;
execute 'gdxxrw.exe midTEMPS_Results_Monthly.gdx SQ=Y par=Daily_CHP rng=CHP!a1'                            ;
execute 'gdxxrw.exe midTEMPS_Results_Monthly.gdx SQ=Y par=Daily_Hydro rng=Hydro!a1'                        ;
execute 'gdxxrw.exe midTEMPS_Results_Monthly.gdx SQ=Y par=Daily_Pumping rng=Daily_Pumping!a1'              ;
execute 'gdxxrw.exe midTEMPS_Results_Monthly.gdx SQ=Y par=Daily_Net_Imp rng=Net_Imp!a1'                    ;
execute 'gdxxrw.exe midTEMPS_Results_Monthly.gdx SQ=Y var=P_Imp_IT_f.l rng=IMP_IT!a1'                      ;
execute 'gdxxrw.exe midTEMPS_Results_Monthly.gdx SQ=Y var=P_Exp_IT_f.l rng=EXP_IT!a1'                      ;
execute 'gdxxrw.exe midTEMPS_Results_Monthly.gdx SQ=Y var=P_Imp_TR_f.l rng=IMP_TR!a1'                      ;
execute 'gdxxrw.exe midTEMPS_Results_Monthly.gdx SQ=Y var=P_Exp_TR_f.l rng=EXP_TR!a1'                      ;
execute 'gdxxrw.exe midTEMPS_Results_Monthly.gdx SQ=Y var=P_Imp_AL_f.l rng=IMP_AL!a1'                      ;
execute 'gdxxrw.exe midTEMPS_Results_Monthly.gdx SQ=Y var=P_Exp_AL_f.l rng=EXP_AL!a1'                      ;
execute 'gdxxrw.exe midTEMPS_Results_Monthly.gdx SQ=Y var=P_Imp_FY_f.l rng=IMP_FY!a1'                      ;
execute 'gdxxrw.exe midTEMPS_Results_Monthly.gdx SQ=Y var=P_Exp_FY_f.l rng=EXP_FY!a1'                      ;
execute 'gdxxrw.exe midTEMPS_Results_Monthly.gdx SQ=Y var=P_Imp_BG_f.l rng=IMP_BG!a1'                      ;
execute 'gdxxrw.exe midTEMPS_Results_Monthly.gdx SQ=Y var=P_Exp_BG_f.l rng=EXP_BG!a1'                      ;
execute 'gdxxrw.exe midTEMPS_Results_Monthly.gdx SQ=Y var=Emergency_Imp_f.l rng=IMP_Emergency!a1'          ;
execute 'gdxxrw.exe midTEMPS_Results_Monthly.gdx SQ=Y var=ED_f.l rng=EnergyDeficit!a1'                     ;
execute 'gdxxrw.exe midTEMPS_Results_Monthly.gdx SQ=Y var=RD_up_f.l rng=SRupDeficit!a1'                    ;
execute 'gdxxrw.exe midTEMPS_Results_Monthly.gdx SQ=Y var=RD_dn_f.l rng=SRdnDeficit!a1'                    ;
execute 'gdxxrw.exe midTEMPS_Results_Monthly.gdx SQ=Y var=FRD_up_f.l rng=FSRupDeficit!a1'                  ;
execute 'gdxxrw.exe midTEMPS_Results_Monthly.gdx SQ=Y var=FRD_dn_f.l rng=FSRdnDeficit!a1'                  ;
*$offtext
