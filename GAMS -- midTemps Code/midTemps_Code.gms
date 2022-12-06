
$eolcom //

$include "C:/midTemps/GMS/midTEMPS_Sets.gms"
$include "C:/midTemps/GMS/midTEMPS_Tables.gms"
$include "C:/midTemps/GMS/midTEMPS_Parameters.gms"
$include "C:/midTemps/GMS/midTEMPS_Scalars.gms"
$include "C:/midTemps/GMS/midTEMPS_ReportFiles.gms"


Set utype                                                "Unit types"                           / Lignite , Hydro , CCGT , OCGT , CHP / ;
Set q                                                    "Set of Quarters"                      / Q1 , Q2 , Q3 , Q4 / ;
Set s                                                    "Set of Semesters"                     / S1 , S2 / ;
Set mt                                                   "Monthly trading periods"              / mt1 * mt744 / ;
Set yt                                                   "Yearly trading periods"               / yt1 * yt8760 / ;


Set mh                                                   "Set of monthly hours"                 / 1 * 744 / ;
Set g_lig(g)                                             "Subset of lignite units" ;
Set g_gas(g)                                             "Subset of gas units" ;
Set g_CCGT(g)                                            "Subset of CCGT gas units" ;
Set g_OCGT(g)                                            "Subset of OCGT gas units" ;
Set g_CHP(g)                                             "Subset of CHP gas units" ;
Set g_CCGT_PPC(g)                                        "Subset of PPC gas units"              / ALIVERI5 , LAVRIO4 , LAVRIO5 , KOMOTINI , MEGALOPOLI_V / ;
Set g_CCGT_IPP(g)                                        "Subset of IPP gas units"              / HERON1 , HERON2 , HERON3 , HERON_CC , ELPEDISON_THESS , ELPEDISON_THISVI , PROTERGIA_CC , KORINTHOS_POWER / ;
Set g_CCGT_IPPred(g_CCGT_IPP)                            "Reduced subset of IPP gas units"      / HERON_CC , ELPEDISON_THESS , ELPEDISON_THISVI , PROTERGIA_CC , KORINTHOS_POWER / ;

    g_lig(g_thr) $ ( Data_ThermalUnits(g_thr,'Type') = 1 )       = yes ;
    g_gas(g_thr) $ ( Data_ThermalUnits(g_thr,'Type') = 3 or
                     Data_ThermalUnits(g_thr,'Type') = 4 )       = yes ;
    g_CCGT(g_thr) $ ( Data_ThermalUnits(g_thr,'Type') = 3 )      = yes ;
    g_OCGT(g_thr) $ ( Data_ThermalUnits(g_thr,'Type') = 4 )      = yes ;
    g_CHP(g_thr) $ ( Data_ThermalUnits(g_thr,'Type') = 5 )       = yes ;

*display g_lig , g_CCGT , g_OCGT , g_CHP ;



Parameter LFZ(lz,t)                                      "Loss zone factor in trading period t, in p.u." ;
Parameter Pgen(g,t,b)                                    "Submitted price of block b of generating units' g priced energy offer in trading period t, in �/MWh" ;
Parameter Qgen(g,t,b)                                    "Submitted quantity of block b of generating units' g priced energy offer in trading period t, in �/MWh" ;
Parameter Pini(g,t)                                      "Generating unit initial power output" ;
Parameter Tini(g)                                        "Generating unit initial time" ;
Parameter Uini(g,t)                                      "Generating unit initial status" ;
Parameter U_ini(g)                                       "Generating unit initial status" ;
Parameter Pini24(g) ;
Parameter LossLevels(zlf)                                "Loss levels, in MWh" ;
Parameter LossFactors(zlf,lz)                            "Zonal Loss Factors, in p.u." ;
Parameter LF(lz,t)                                       "Hourly loss factor of loss zone lz in trading period t, in p.u." ;
Parameter index(t)                                       "Time-based loss level index" ;
Parameter loLoad(t)                                      "Load lower bound, in MW" ;
Parameter upLoad(t)                                      "Load upper bound, in MW" ;
Parameter loLossFactor(lz,t)                             "Loss factor lower bound, in p.u." ;
Parameter upLossFactor(lz,t)                             "Loss factor upper bound, in p.u." ;
Parameter Ii2lz(i,lz)                                    "Import agent to loss zone incidence matrix, if equal to 1" ;
Parameter Ig2lz(g,lz)                                    "Generating unit to loss zone incidence matrix, if equal to 1" ;
Parameter GLFgen(g,t)                                    "Generation loss factor of generating unit g in trading period t, in p.u." ;
Parameter GLFimp(i,t)                                    "Generation loss factor of import agent i in trading period t, in p.u." ;
Parameter UT(g)                                          "Minimum up time of generating unit g, in hrs" ;
Parameter DT(g)                                          "Minimum down time of generating unit g, in hrs" ;
Parameter Prsv1(g,t)                                     "Primary reserve price offer of generating unit g in trading period t, in �/MW" ;
Parameter Prsv2(g,t)                                     "Secondary reserve range price offer of generating unit g in trading period t, in �/MW" ;
Parameter SUC(g)                                         "Start-up cost, in �" ;
Parameter SDC(g)                                         "Shut-down cost, in �" ;
Parameter R1(g)                                          "Maximum primary reserve contribution of generating unit g, in MW" ;
Parameter R2(g)                                          "Maximum secondary reserve contribution of generating unit g, in MW" ;
Parameter R3S(g)                                         "Maximum tertiary spinning reserve contribution of generating unit g, in MW" ;
Parameter R3NS(g)                                        "Maximum tertiary non-spinning reserve contribution of generating unit g, in MW" ;
Parameter Pmin(g)                                        "Minimum power output of generating unit g, in MW" ;
Parameter Pmax(g)                                        "Maximum power output of generating unit g, in MW" ;
Parameter Pmin_AGC(g)                                    "Minimum power output under AGC of generating unit g, in MW" ;
Parameter Pmax_AGC(g)                                    "Maximum power output under AGC of generating unit g, in MW" ;
Parameter RU(g)                                          "Generating unit g ramp-up rate, in MW/min" ;
Parameter RD(g)                                          "Generating unit g ramp-up rate, in MW/min" ;
Parameter RU_AGC(g)                                      "Generating unit g ramp-up rate, in MW/min" ;
Parameter RD_AGC(g)                                      "Generating unit g ramp-up rate, in MW/min" ;
Parameter Igen(a,g)                                      "Thermal unit g incidence matrix, if equal to 1" ;
Parameter Iimp(a,i)                                      "Bidding area a to import agent i incidence matrix, if equal to 1" ;
Parameter Iexp(a,e)                                      "Bidding area a to export agent e incidence matrix, if equal to 1" ;
Parameter ILa(a,t)                                       "Inelastic load in bidding area a and trading period t, in MWh" ;
Parameter Itd2tm(td,tm)                                  "Trading day to trading month incidence matrix, if equal to 1" ;
Parameter TdMonth(td)                                    "Month per trading day" ;
Parameter TdYear(td)                                     "Year per trading day" ;
Parameter TdNameID(td)                                   "Trading day name ID" ;
Parameter aDPM(tm)                                       "Accumulated trading days per trading month" ;
Parameter Iwkd2wkt(wkd,wkt)                              "Week day to week day type incidence matrix, if equal to 1" ;
Parameter MandatoryHydro(tm,g,t,wkt)                     "Mandatory hydro production per trading month tm,generating unit g, trading period t and weekday type wkt, in MWh" ;
Parameter Comm(g)                                        "Parameter denoting that generating unit g is in commissioning, if equal to 1" ;
Parameter UnitType(g)                                    "Unit type" ;
*
*
*
     Pgen(g_thr,t,b)                             = Pgen_thr(g_thr,t,b) ;
     Pgen(g_hdr,t,b)                             = Pgen_hdr(g_hdr,t,b) ;
*
     Qgen(g_thr,t,b)                             = Qgen_thr(g_thr,t,b) ;
     Qgen(g_hdr,t,b)                             = Qgen_hdr(g_hdr,t,b) ;
*
     Prsv1(g_thr,t)                              = Prsv1_thr(g_thr,t) ;
     Prsv1(g_hdr,t)                              = Prsv1_hdr(g_hdr,t) ;
     Prsv2(g_thr,t)                              = Prsv2_thr(g_thr,t) ;
     Prsv2(g_hdr,t)                              = Prsv2_hdr(g_hdr,t) ;
*
     Pini(g,t)                                   = 0.0 ;
     Pini(g_thr,'1') $ ( Tini_thr(g_thr) > 0 )   = Pini_thr(g_thr) ;
     Pini(g_hdr,'1') $ ( Tini_hdr(g_hdr) > 0 )   = Pini_hdr(g_hdr) ;
     //
     Pini24(g_thr)                               = Pini_thr(g_thr) ;
     Pini24(g_hdr)                               = Pini_hdr(g_hdr) ;
*
     Tini(g_thr)                                 = Tini_thr(g_thr) ;
     Tini(g_hdr)                                 = Tini_hdr(g_hdr) ;
*
     Uini(g,t)                                   = 0.0 ;
     Uini(g_thr,'1')                             = Uini_thr(g_thr) ;
     Uini(g_hdr,'1')                             = Uini_hdr(g_hdr) ;
     //
     U_ini(g_thr)                                = Uini_thr(g_thr) ;
     U_ini(g_hdr)                                = Uini_hdr(g_hdr) ;
*
     UT(g_thr)                                   = Data_ThermalUnits(g_thr,'MUT') ;
     UT(g_hdr)                                   = 1 ;
     DT(g_thr)                                   = Data_ThermalUnits(g_thr,'MDT') ;
     DT(g_hdr)                                   = 1 ;
*
     SUC(g_thr)                                  = 0 ;
     SDC(g_thr)                                  = Data_ThermalUnits(g_thr,'SUC') ;
*
     R1(g_thr)                                   = Data_ThermalUnits(g_thr,'R1') ;
     R2(g_thr)                                   = Data_ThermalUnits(g_thr,'R2') ;
     R3S(g_thr)                                  = Data_ThermalUnits(g_thr,'R3S') ;
     R3NS(g_thr)                                 = Data_ThermalUnits(g_thr,'R3NS') ;
     R1(g_hdr)                                   = Data_HydroUnits(g_hdr,'R1') ;
     R2(g_hdr)                                   = Data_HydroUnits(g_hdr,'R2') ;
     R3S(g_hdr)                                  = Data_HydroUnits(g_hdr,'R3S') ;
     R3NS(g_hdr)                                 = Data_HydroUnits(g_hdr,'R3NS') ;
*
     Pmin(g_thr)                                 = Data_ThermalUnits(g_thr,'Pmin') ;
     Pmax(g_thr)                                 = Data_ThermalUnits(g_thr,'Pmax') ;
     Pmin_AGC(g_thr)                             = Data_ThermalUnits(g_thr,'Pmin_AGC') ;
     Pmax_AGC(g_thr)                             = Data_ThermalUnits(g_thr,'Pmax_AGC') ;
     Pmin(g_hdr)                                 = Data_HydroUnits(g_hdr,'Pmin') ;
     Pmax(g_hdr)                                 = Data_HydroUnits(g_hdr,'Pmax') ;
     Pmin_AGC(g_hdr)                             = Data_HydroUnits(g_hdr,'Pmin_AGC') ;
     Pmax_AGC(g_hdr)                             = Data_HydroUnits(g_hdr,'Pmax_AGC') ;
*
     RU(g_thr)                                   = Data_ThermalUnits(g_thr,'RampRate') ;
     RU(g_hdr)                                   = Data_HydroUnits(g_hdr,'RampRate') ;
     RD(g_thr)                                   = Data_ThermalUnits(g_thr,'RampRate') ;
     RD(g_hdr)                                   = Data_HydroUnits(g_hdr,'RampRate') ;
     RU_AGC(g_thr)                               = Data_ThermalUnits(g_thr,'RampRate_AGC') ;
     RU_AGC(g_hdr)                               = Data_HydroUnits(g_hdr,'RampRate_AGC') ;
     RD_AGC(g_thr)                               = Data_ThermalUnits(g_thr,'RampRate_AGC') ;
     RD_AGC(g_hdr)                               = Data_HydroUnits(g_hdr,'RampRate_AGC') ;
*
     LossLevels(zlf)                             = Data_ZonalLossFactors(zlf,'Load') ;
     LossFactors(zlf,'LFZ1')                     = Data_ZonalLossFactors(zlf,'LFZ1') ;
     LossFactors(zlf,'LFZ2')                     = Data_ZonalLossFactors(zlf,'LFZ2') ;
     LossFactors(zlf,'LFZ3')                     = Data_ZonalLossFactors(zlf,'LFZ3') ;
     LossFactors(zlf,'LFZ4')                     = Data_ZonalLossFactors(zlf,'LFZ4') ;
     LossFactors(zlf,'LFZ5')                     = Data_ZonalLossFactors(zlf,'LFZ5') ;
*
     Ig2lz(g_thr,lz)                             = Igthr2lz(g_thr,lz) ;
     Ig2lz(g_hdr,lz)                             = Ighdr2lz(g_hdr,lz) ;
     Ii2lz(i,lz)                                 = Sum ( inter , Ii2inter(i,inter) * Iinter2lz(inter,lz) ) ;
*
     Igen(a,g_thr)                               = Igthr(g_thr,a) ;
     Igen(a,g_hdr)                               = Ighdr(g_hdr,a) ;
     Iimp(a,i)                                   = Sum ( inter , Ii2inter(i,inter) * Iinter2a(inter,a) ) ;
     Iexp(a,e)                                   = Sum ( inter , Ie2inter(e,inter) * Iinter2a(inter,a) ) ;
*
     aDPM(tm)                                    = 0 ;
     loop ( tm ,
                aDPM(tm) = DPM(tm) + aDPM(tm-1)
          ) ;
*
     Itd2tm(td,tm) = 0 ;
     loop ( td ,
                loop ( tm ,
                           if ( ( ord(td) > aDPM(tm-1) ) and ( ord(td) <= aDPM(tm) ) , Itd2tm(td,tm) = 1 ; ) ;
                     ) ;
          ) ;
     TdMonth(td)                                 = Sum ( tm , Itd2tm(td,tm) * MonthID(tm) ) ;
     TdYear(td)                                  = Sum ( tm , Itd2tm(td,tm) * MonthYear(tm) ) ;
     TdNameID(td)                                = 0 ;
     TdNameID(td)                                = Sum ( wkd , Itd2wkd(td,wkd) * ord(wkd) ) ;
*
     Iwkd2wkt(wkd,wkt)                           = 0 ;
     Iwkd2wkt('Monday','Weekday')                = 1 ;
     Iwkd2wkt('Tuesday','Weekday')               = 1 ;
     Iwkd2wkt('Wednesday','Weekday')             = 1 ;
     Iwkd2wkt('Thursday','Weekday')              = 1 ;
     Iwkd2wkt('Friday','Weekday')                = 1 ;
     Iwkd2wkt('Saturday','Weekend')              = 1 ;
     Iwkd2wkt('Sunday','Weekend')                = 1 ;
*
*     MandatoryHydro(tm,g_hdr,t,'Weekday')        = MandatoryHydro_Weekday(tm,g_hdr,t) ;
*     MandatoryHydro(tm,g_hdr,t,'Weekend')        = MandatoryHydro_Weekend(tm,g_hdr,t) ;
     MandatoryHydro(tm,g_hdr,t,'Weekday')        = 0 ;
     MandatoryHydro(tm,g_hdr,t,'Weekend')        = 0 ;
*
     UnitType(g_thr)                             = Data_ThermalUnits(g_thr,'Type') ;
     UnitType(g_hdr)                             = 2 ;

*display Pgen , Qgen , Pini , Tini , Uini , Ii2lz , Pdem , Qdem , UT , DT , Prsv1 , Prsv2 , SUC , SDC , R1 , R2 , R3S , R3NS ;
*display Pmin , Pmax , Pmin_AGC , Pmax_AGC , RU , RD , RU_AGC , RD_AGC , Igen , Iimp , Iexp ;
*display aDPM ;



Parameter Pgen(g,t,b)                                    "Price part of the generator's g submitted priced energy offer, in �/MWh" ;
Parameter Qgen(g,t,b)                                    "Quantity part of the generator's g submitted priced energy offer, in �/MWh" ;
Parameter Pimp(i,t,b)                                    "Price part of step b of import agent's i offer in trading period t, in �/MWh" ;
Parameter Qimp(i,t,b)                                    "Quantity part of step b of import agent's i offer in trading period t, in �/MWh" ;
Parameter Pexp(e,t,b)                                    "Price part of step b of export agent's e bid in trading period t, in �/MWh" ;
Parameter Qexp(e,t,b)                                    "Quantity part of step b of export agent's e bid in trading period t, in �/MWh" ;

Parameter LD(t)                                          "System load, in MWh" ;
Parameter RES(a,t)                                       "RES injection in bidding area a and trading periot t, in MWh" ;
Parameter RR1(t)                                         "Primary reserve requirement in trading period t, in MW" ;
Parameter RR2up(t)                                       "Secondary upward reserve requirement in trading period t, in MW" ;
Parameter RR2dn(t)                                       "Secondary downward reserve requirement in trading period t, in MW" ;
Parameter FRR2up(t)                                      "Fast secondary upward reserve requirement in trading period t, in MW" ;
Parameter FRR2dn(t)                                      "Fast secondary downward reserve requirement in trading period t, in MW" ;
Parameter RR3(t)                                         "Tertiary reserve requirement in trading period t, in MW" ;
*
Parameter FP_CO2                                         "CO2 forward price, in �/Tn" ;
Parameter FP_NG                                          "Natural gas forward price, in $/MWh-th" ;
Parameter FP_NG_IPP                                      "IPPs' natural gas forward price, in $/MWh-th" ;
Parameter FP_NG_TTF                                      "TTF natural gas forward price, in $/MWh-th" ;
Parameter FP_FX                                          "FX forward price, in �/$" ;
*
Parameter DailyThrCommissioningSchedule(g_thr,cid)       "Daily thermal commissioning schedule" ;
Parameter DailyHdrCommissioningSchedule(g_hdr,cid)       "Daily hydro commissioning schedule" ;
Parameter Pmand(g,t)                                     "Mandatory production of generating unit g in trading period t, in MWh" ;
Parameter Pmand_hydro(g,t)                               "Mandatory production of generating unit g in trading period t due to mandatory hydro generation, in MWh" ;
Parameter Pmand_comm(g,t)                                "Mandatory production of generating unit g in trading period t due to commissioning status, in MWh" ;
Parameter Availability(g)                                "Unit availability" ;
*
Parameter NTCimp(inter,t)                                "Net Transfer Capacity for imports in interconnection inter and trading period t, in MWh" ;
Parameter NTCexp(inter,t)                                "Net Transfer Capacity for exports in interconnection inter and trading period t, in MWh" ;
*
Parameter IniUpHours(g)                                  "Initial mandatory up hours, in hrs" ;
Parameter IniDnHours(g)                                  "Initial mandatory down hours, in hrs" ;
Parameter Tini_p(g)                                      "Positive Tini parameter, in hrs" ;
Parameter Tini_n(g)                                      "Negative Tini parameter, in hrs" ;
Parameter Usu(g)                                         "Binary parameter denoting that generating unit g has started up during the examined day" ;
Parameter Usd(g)                                         "Binary parameter denoting that generating unit g has started up during the examined day" ;
*
*
     Pimp(i,t,b) = 0 ;
     Qimp(i,t,b) = 0 ;
     Pexp(e,t,b) = 0 ;
     Qexp(e,t,b) = 0 ;








* Reporting Parameters
Parameter MCP(a,t)                                       "Market Clearing Price in bidding area a and trading period t, in �/MWh" ;
Parameter MCPdav(td,t)                                   "Daily average MCP in trading period t, in �/MWh" ;
Parameter MCPmav(tm,t)                                   "Monthly average MCP in trading period t, in �/MWh" ;
Parameter MCPav                                          "Average market Clearing Price in bidding area a and trading period t, in �/MWh" ;
Parameter MCPm(tm)                                       "Monthly average Market Clearing Price, in �/MWh" ;
Parameter MCPq(q)                                        "Quarterly average Market Clearing Price, in �/MWh" ;
Parameter MCPs(s)                                        "Semesterly average Market Clearing Price, in �/MWh" ;
Parameter MCPy                                           "Monthly average Market Clearing Price, in �/MWh" ;
Parameter PRR1(t)                                        "Primary reserve clearing price in trading period t, in �/MWh" ;
Parameter PRR2up(t)                                      "Secondary upward reserve clearing price in trading period t, in �/MWh" ;
Parameter PRR2dn(t)                                      "Secondary downward reserve clearing price in trading period t, in �/MWh" ;
Parameter Losses(t)                                      "Losses in trading period t, in MWh" ;
Parameter LoadAndLosses(t)                               "Total load declarations and losses in trading period t, in MWh" ;
Parameter Daily_Imports(inter,t)                         "Daily imports per interconnection inter and trading period t, in MWh" ;
Parameter Daily_Exports(inter,t)                         "Daily exports per interconnection inter and trading period t, in MWh" ;
Parameter PiniReport(g,td)                               "Pini daily report, in MWh" ;
Parameter TiniReport(g,td)                               "Pini daily report, in MWh" ;
Parameter MAVCd(g)                                       "Daily minimum average variable cost of generating unit g, in �/MWh" ;
Parameter MAVC(g,tm)                                     "Monthly minimum average variable cost of generating unit g, in �/MWh" ;
Parameter Total_Demand                                   "Total demand, in MWh" ;
Parameter Total_Losses   ;
Parameter Total_Pumping ;
Parameter Total_Lignite ;
Parameter Total_CCGT ;
Parameter Total_OCGT ;
Parameter Total_CHP ;
Parameter Total_Hydro ;
Parameter Total_RES ;
Parameter Total_Imports ;
Parameter Total_Exports ;
Parameter Total_NetImports ;
Parameter Total_MCP ;
*
Parameter Daily_Demand(td)                               "Daily demand consumption, in MWh" ;
Parameter Daily_Losses(td)                               "Daily losses, in MWh" ;
Parameter Daily_Pumping(td)                              "Daily pumping consumption, in MWh" ;
Parameter Daily_Lignite(td)                              "Daily lignite production, in MWh" ;
Parameter Daily_CCGT(td)                                 "Daily CCGT production, in MWh" ;
Parameter Daily_OCGT(td)                                 "Daily OCGT production, in MWh" ;
Parameter Daily_CHP(td)                                  "Daily CHP production, in MWh" ;
Parameter Daily_Hydro(td)                                "Daily hydro production, in MWh" ;
Parameter Daily_RES(td)                                  "Daily RES production, in MWh" ;
Parameter Daily_TotImports(td)                           "Daily imports, in MWh" ;
Parameter Daily_TotExports(td)                           "Daily exports, in MWh" ;
Parameter Daily_TotNetImports(td)                        "Daily net imports, in MWh" ;
Parameter Daily_HydroMandatory(td)                       "Daily hydro mandatory production, in MWh" ;
Parameter Daily_ShutDowns(td,g)                          "Daily shut-downs per generating unit" ;
Parameter Daily_Dispatch(td,g)                           "Daily dispatch per generating unit, in MWh" ;
Parameter Daily_TotalImports(td,t)                       "Daily total imports in trading period t, in MWh" ;
Parameter Daily_TotalExports(td,t)                       "Daily total exports in trading period t, in MWh" ;
Parameter Daily_TotalNetImports(td,t)                    "Daily total net imports in trading period t, in MWh" ;
*
Parameter MinOfferPPC(t)                                 "Minimum offer of PPC units" ;
Parameter PgenPPC(g_CCGT_PPC,t,b)                        "Price component of the finally submitted PPCP offer" ;
Parameter PgenIPP(g_CCGT_IPP,t,b)                        "Price component of the finally submitted IPP offer" ;



     PiniReport(g,td)            = 0 ;
     TiniReport(g,td)            = 0 ;
     MAVC(g,tm)                  = 300 ;
     Total_Demand                = 0 ;
     Total_Losses                = 0 ;
     Total_Pumping               = 0 ;
     Total_Lignite               = 0 ;
     Total_CCGT                  = 0 ;
     Total_OCGT                  = 0 ;
     Total_CHP                   = 0 ;
     Total_Hydro                 = 0 ;
     Total_RES                   = 0 ;
     Total_Imports               = 0 ;
     Total_Exports               = 0 ;
     Total_NetImports            = 0 ;
     Total_MCP                   = 0 ;
     Daily_HydroMandatory(td)    = 0 ;
     Daily_TotalImports(td,t)    = 0 ;
     Daily_TotalExports(td,t)    = 0 ;
     Daily_TotalNetImports(td,t) = 0 ;

     MCPm(tm)                    = 0 ;
     MCPq(q)                     = 0 ;
     MCPs(s)                     = 0 ;
     MCPy                        = 0 ;



$include "C:/midTemps/GMS/midTemps_Variables.gms"

$include "C:/midTemps/GMS/midTemps_Equations.gms"

$include "C:/midTemps/GMS/midTemps_PeakShaving.gms"


loop ( td ,
*   $ ( ord(td) < 3 )
         PiniReport(g,td)                                = Pini(g,'1') ;
         TiniReport(g,td)                                = Tini(g) ;
*


         LD(t)                                           = Data_SystemLoad(td,t) ;
         ILa(a,t)                                        = round ( DLF(a) * LD(t) , 3 ) ;
         RES(a,t)                                        = Data_BiddingAreas(a,'ResFactor') * Data_RES(td,t) ;
         RR1(t)                                          = Data_RR1(td,t) ;
         RR2up(t)                                        = Data_RR2up(td,t) ;
         RR2dn(t)                                        = Data_RR2dn(td,t) ;
         FRR2up(t)                                       = Data_FRR2up(td,t) ;
         FRR2dn(t)                                       = Data_FRR2dn(td,t) ;
         RR3(t)                                          = Data_RR3(td,t) ;
         loop ( t , if ( LD(t) = 0 , LD(t) = LD(t-1) ; ) ; ) ;
*
         Pmax(g_thr)                                     = round ( ThermalDerating(td,g_thr) * Data_ThermalUnits(g_thr,'Pmax') , 0 ) ;
         Availability(g_thr)                             = ThrAvailability(td,g_thr) ;
         Availability(g_hdr)                             = 1 ;
         MinOfferPPC(t)                                  = 300 ;

display ThermalDerating , Pmax ;
*
*
*        Calculation of the daily zonal loss factors and generation/import GLFs ----------------------------------------------------------------------------------------------------
         loop( t ,
                  loop ( zlf ,
                            if ( LD(t) >= LossLevels(zlf) and LD(t) < LossLevels(zlf+1) ,
                                                                                         index(t) = ord(zlf) ;
                               ) ;
                       ) ;
             ) ;
         loLoad(t)                                       = Sum ( zlf $ ( ord(zlf) = index(t) ) , LossLevels(zlf) ) ;
         upLoad(t)                                       = Sum ( zlf $ ( ord(zlf) = index(t) + 1 ) , LossLevels(zlf) ) ;
         loLossFactor(lz,t)                              = Sum ( zlf $ ( ord(zlf) = index(t) ) , LossFactors(zlf,lz)  ) ;
         upLossFactor(lz,t)                              = Sum ( zlf $ ( ord(zlf) = index(t) + 1 ) , LossFactors(zlf,lz)  ) ;
         LF(lz,t)                                        = ( LD(t) - loLoad(t) ) * ( upLossFactor(lz,t) - loLossFactor(lz,t) ) / ( upLoad(t) - loLoad(t) ) + loLossFactor(lz,t) ;
*
         GLFgen(g,t)                                     = Sum ( lz , Ig2lz(g,lz) * LF(lz,t) ) ;
         GLFimp(i,t)                                     = Sum ( lz , Ii2lz(i,lz) * LF(lz,t) ) ;
         //
         GLFgen(g,t) $ ( Flag_IncludeLosses = 0 )        = 1 ;
         GLFimp(i,t) $ ( Flag_IncludeLosses = 0 )        = 1 ;
*
*
*
*        Forward prices calculation ------------------------------------------------------------------------------------------------------------------------------------------------
         FP_CO2                                          = Sum ( tm , Itd2tm(td,tm) * FW_CO2(tm) ) ;
         FP_NG                                           = Sum ( tm , Itd2tm(td,tm) * FW_NG(tm) ) ;
         FP_NG_IPP                                       = Sum ( tm , Itd2tm(td,tm) * FW_NG_IPP(tm) ) ;
         FP_NG_TTF                                       = Sum ( tm , Itd2tm(td,tm) * FW_NG_TTF(tm) ) ;
         FP_FX                                           = Sum ( tm , Itd2tm(td,tm) * FW_FX(tm) ) ;
*
*        Daily offers initialization -----------------------------------------------------------------------------------------------------------------------------------------------
         Pgen(g_thr,t,b)                                 = Pgen_thr(g_thr,t,b) ;
         Pgen(g_lig,t,b) $ ( Pgen(g_lig,t,b) > 0 )       = max ( Round ( min ( Pgen(g_lig,t,b) + 1.1 * ( FP_CO2 - CO2ini ) , 3000 ) , 3 ) - Thr_Price_Adjustment(td,g_lig) , 0 );


         if ( Flag_DiffOffers = 0 ,
              Pgen(g_gas,t,b) $ ( Pgen(g_gas,t,b) > 0 )  = max ( Round ( min ( Pgen(g_gas,t,b) + 0.375 * ( FP_CO2 - CO2ini ) + 2 * ( FP_NG - NGini ) , 3000 ) , 3 ) - Thr_Price_Adjustment(td,g_gas) , 0 ) ;
            ) ;

         if ( Flag_DiffOffers = 1 ,
*             PPC Adjustments
              Pgen(g_CCGT_PPC,t,b) $ ( Pgen(g_CCGT_PPC,t,b) > 0 )  = max ( Round ( min ( Pgen(g_CCGT_PPC,t,b) + 0.375 * ( FP_CO2 - CO2ini ) + 2 * ( FP_NG - NGini ) , 3000 ) , 3 ) - Thr_Price_Adjustment(td,g_CCGT_PPC) , 0 ) ;
*
*             IPP Adjustments
              Pgen(g_CCGT_IPP,t,"B1") $ ( Pgen(g_CCGT_IPP,t,"B1") > 0 )
                                                                   = max ( Round ( min ( Pgen(g_CCGT_IPP,t,"B1") + 0.375 * ( FP_CO2    - CO2ini   )
                                                                                                                 + 2     * ( FP_NG_TTF - NGTTFini ) , 3000 ) , 3 )
                                                                                   - Thr_Price_Adjustment(td,g_CCGT_IPP) , 0 ) ;

              Pgen(g_CCGT_IPP,t,b) $ ( Pgen(g_CCGT_IPP,t,b) > 0 and ord(b) > 1 )
                                                                   = max ( Round ( min ( Pgen(g_CCGT_IPP,t,b) + 0.375 * ( FP_CO2    - CO2ini   )
                                                                                                              + 2     * ( FP_NG_IPP - NGIPPini ) , 3000 ) , 3 )
                                                                                   - Thr_Price_Adjustment(td,g_CCGT_IPP)
                                                                                   , 0 ) ;
            ) ;


         Pgen(g_hdr,t,b)                                 = Pgen_hdr(g_hdr,t,b) ;
*
         Qgen(g_thr,t,b)                                 = Qgen_thr(g_thr,t,b) ;
         Qgen(g_hdr,t,b)                                 = Qgen_hdr(g_hdr,t,b) ;
*
*         Qgen(g_thr,t,b)                                 = Qgen(g_thr,t,b) * ThrAvailability(td,g_thr) ;
         Pgen(g_thr,t,b) $ ( Availability(g_thr) = 0 )   = 300 ;
*         Pgen(g_thr,t,b) $ ( Flag_IncludeOutages = 1 and Daily_Outages(td,g_thr) = 0 )   = 300 ;
*
*        Find the PPC minimum offer from gas units and change the third block of the IPPs' unit offer
         if ( Flag_MinOfferPPC = 1 ,
*                                   Identify the minimum PPC offer
                                    loop ( t ,
                                    loop ( g_CCGT_PPC ,
                                    loop ( b          ,
                                                       if ( Pgen(g_CCGT_PPC,t,b) > 0 ,
                                                                                      MinOfferPPC(t) = min ( MinOfferPPC(t) , Pgen(g_CCGT_PPC,t,b) ) ;
                                                          ) ;

                                         ) ;
                                         ) ;
                                         ) ;
*                                   Update the 3rd block of the IPPs' price offers based on the minimum PPC offer
                                    loop ( t          ,
                                    loop ( g_CCGT_IPP ,
                                                       if ( Pgen(g_CCGT_IPP,t,"B2") < MinOfferPPC(t) and
                                                            Qgen(g_CCGT_IPP,t,"B3") > 0                  ,
                                                                                                          Pgen(g_CCGT_IPP,t,"B3") = MinOfferPPC(t) - Thr_Price_BidUp(td,g_CCGT_IPP) ;
                                                          ) ;
                                         ) ;
                                         ) ;

            ) ;

         PgenPPC(g_CCGT_PPC,t,b)         = Pgen(g_CCGT_PPC,t,b) ;
         PgenIPP(g_CCGT_IPPred,t,b)      = Pgen(g_CCGT_IPPred,t,b) ;
         display MinOfferPPC , PgenPPC, PgenIPP , Pgen ;



*
*
*        Commissioning status calculation ------------------------------------------------------------------------------------------------------------------------------------------
         DailyThrCommissioningSchedule(g_thr,cid) = 0 ;
         DailyHdrCommissioningSchedule(g_hdr,cid) = 0 ;
*
         loop ( g_thr ,
                       loop ( cid ,
                                   if ( ( ThrCommissioningSchedule(td,g_thr) <> 0 ) and ( Igthr2cid(g_thr,cid) = ThrCommissioningSchedule(td,g_thr) ) , DailyThrCommissioningSchedule(g_thr,cid) = 1 ) ;
                            ) ;
              ) ;
         loop ( g_hdr ,
                       loop ( cid ,
                                   if ( ( HdrCommissioningSchedule(td,g_hdr) <> 0 ) and ( Ighdr2cid(g_hdr,cid) = HdrCommissioningSchedule(td,g_hdr) ) , DailyHdrCommissioningSchedule(g_hdr,cid) = 1 ) ;
                            ) ;
              ) ;
*
         Pmand_comm(g_thr,t)                                     = Sum ( cid , DailyThrCommissioningSchedule(g_thr,cid) * ThrCommissioningProfile(g_thr,cid,t) ) ;
         Pmand_comm(g_hdr,t)                                     = Sum ( cid , DailyHdrCommissioningSchedule(g_hdr,cid) * HdrCommissioningProfile(g_hdr,cid,t) ) ;
         MandatoryHydro(tm,g_hdr,t,wkt)                          = min ( MandatoryHydro(tm,g_hdr,t,wkt) , Pmax(g_hdr) ) ;
         Pmand_hydro(g_hdr,t)                                    = Sum ( wkd , Itd2wkd(td,wkd) * Sum ( tm , Itd2tm(td,tm) * Sum ( wkt , Iwkd2wkt(wkd,wkt) * MandatoryHydro(tm,g_hdr,t,wkt) ) ) ) ;
         //
         if ( Flag_PerformPeakShaving = 1 ,
                                           Pmand_hydro(g_hdr,t)  = FinalHydroSchedule(td,g_hdr,t) ;
                                           Pgen(g_hdr,t,b)       = 300 ;
            ) ;
*
         Pmand(g,t)                                              = Pmand_comm(g,t) + Pmand_hydro(g,t) ;
*
         loop ( g_thr , if ( Sum ( cid , DailyThrCommissioningSchedule(g_thr,cid) ) > 0 , Comm(g_thr) = 1 ; else Comm(g_thr) = 0 ; ) ; ) ;



*
*
*
*        Net-Transfer Capacity calculation -----------------------------------------------------------------------------------------------------------------------------------------
         NTCimp('ALBANIA',t)                                                     = Sum ( tm , Itd2tm(td,tm) * Data_ImportsNTC(tm,'ALBANIA') ) ;
         NTCimp('FYROM',t)                                                       = Sum ( tm , Itd2tm(td,tm) * Data_ImportsNTC(tm,'FYROM') ) ;
         NTCimp('BULGARIA',t)                                                    = Sum ( tm , Itd2tm(td,tm) * Data_ImportsNTC(tm,'BULGARIA') ) ;
         NTCimp('TURKEY',t)                                                      = Sum ( tm , Itd2tm(td,tm) * Data_ImportsNTC(tm,'TURKEY') ) ;
         NTCimp('ITALY',t)                                                       = Sum ( tm , Itd2tm(td,tm) * Data_ImportsNTC(tm,'ITALY') ) ;
         //
         NTCimp(inter,t)                                                         = NTCimp(inter,t) * ImpAvailability(td,inter) ;
*
         NTCexp('ALBANIA',t)                                                     = Sum ( tm , Itd2tm(td,tm) * Data_ExportsNTC(tm,'ALBANIA') ) ;
         NTCexp('FYROM',t)                                                       = Sum ( tm , Itd2tm(td,tm) * Data_ExportsNTC(tm,'FYROM') ) ;
         NTCexp('BULGARIA',t)                                                    = Sum ( tm , Itd2tm(td,tm) * Data_ExportsNTC(tm,'BULGARIA') ) ;
         NTCexp('TURKEY',t)                                                      = Sum ( tm , Itd2tm(td,tm) * Data_ExportsNTC(tm,'TURKEY') ) ;
         NTCexp('ITALY',t)                                                       = Sum ( tm , Itd2tm(td,tm) * Data_ExportsNTC(tm,'ITALY') ) ;
         //
         NTCexp(inter,t)                                                         = NTCexp(inter,t) * ExpAvailability(td,inter) ;
*
*
*
         // Imports & exports initialization ---------------------------------------------------------------------------------------------------------------------------------------
         // Long-Term imports and exports ******************************************************************************************************************************************
         Pimp('IMP_ALBANIA_LT',t,'B1')                                           = Sum ( tm , Itd2tm(td,tm) * PrImpAL(tm) ) ;
         Pimp('IMP_FYROM_LT',t,'B1')                                             = Sum ( tm , Itd2tm(td,tm) * PrImpFY(tm) ) ;
         Pimp('IMP_BULGARIA_LT',t,'B1')                                          = Sum ( tm , Itd2tm(td,tm) * PrImpBG(tm) ) ;
         Pimp('IMP_TURKEY_LT',t,'B1')                                            = Sum ( tm , Itd2tm(td,tm) * PrImpTR(tm) ) ;
         Pimp('IMP_ITALY_LT',t,'B1')                                             = Sum ( tm , Itd2tm(td,tm) * PrImpIT(tm) ) ;
         //
         Qimp('IMP_ALBANIA_LT',t,b)                                              = 0 ;
         Qimp('IMP_FYROM_LT',t,b)                                                = 0 ;
         Qimp('IMP_BULGARIA_LT',t,b)                                             = 0 ;
         Qimp('IMP_TURKEY_LT',t,b)                                               = 0 ;
         Qimp('IMP_ITALY_LT',t,b)                                                = 0 ;
         //
         Qimp('IMP_ALBANIA_LT',t,'B1')                                           = ImportsAL(td,t) ;
         Qimp('IMP_FYROM_LT',t,'B1')                                             = ImportsFY(td,t) ;
         Qimp('IMP_BULGARIA_LT',t,'B1')                                          = ImportsBG(td,t) ;
         Qimp('IMP_TURKEY_LT',t,'B1')                                            = ImportsTR(td,t) ;
         Qimp('IMP_ITALY_LT',t,'B1')                                             = ImportsIT(td,t) ;
         //
         Pexp('EXP_ALBANIA_LT',t,'B1')                                           = Sum ( tm , Itd2tm(td,tm) * PrExpAL(tm) ) ;
         Pexp('EXP_FYROM_LT',t,'B1')                                             = Sum ( tm , Itd2tm(td,tm) * PrExpFY(tm) ) ;
         Pexp('EXP_BULGARIA_LT',t,'B1')                                          = Sum ( tm , Itd2tm(td,tm) * PrExpBG(tm) ) ;
         Pexp('EXP_TURKEY_LT',t,'B1')                                            = Sum ( tm , Itd2tm(td,tm) * PrExpTR(tm) ) ;
         Pexp('EXP_ITALY_LT',t,'B1')                                             = Sum ( tm , Itd2tm(td,tm) * PrExpIT(tm) ) ;
*
         Qexp('EXP_ALBANIA_LT',t,b)                                              = 0 ;
         Qexp('EXP_FYROM_LT',t,b)                                                = 0 ;
         Qexp('EXP_BULGARIA_LT',t,b)                                             = 0 ;
         Qexp('EXP_TURKEY_LT',t,b)                                               = 0 ;
         Qexp('EXP_ITALY_LT',t,b)                                                = 0 ;
*
         Qexp('EXP_ALBANIA_LT',t,'B1')                                           = ExportsAL(td,t) ;
         Qexp('EXP_FYROM_LT',t,'B1')                                             = ExportsFY(td,t) ;
         Qexp('EXP_BULGARIA_LT',t,'B1')                                          = ExportsBG(td,t) ;
         Qexp('EXP_TURKEY_LT',t,'B1')                                            = ExportsTR(td,t) ;
         Qexp('EXP_ITALY_LT',t,'B1')                                             = ExportsIT(td,t) ;
         //
         // Short-Term imports and exports *****************************************************************************************************************************************
*
         Qimp('IMP_ALBANIA_ST',t,b)                                              = 0 ;
         Qimp('IMP_FYROM_ST',t,b)                                                = 0 ;
         Qimp('IMP_BULGARIA_ST',t,b)                                             = 0 ;
         Qimp('IMP_TURKEY_ST',t,b)                                               = 0 ;
         Qimp('IMP_ITALY_ST',t,b)                                                = 0 ;
*
         Qexp('EXP_ALBANIA_ST',t,b)                                              = 0 ;
         Qexp('EXP_FYROM_ST',t,b)                                                = 0 ;
         Qexp('EXP_BULGARIA_ST',t,b)                                             = 0 ;
         Qexp('EXP_TURKEY_ST',t,b)                                               = 0 ;
         Qexp('EXP_ITALY_ST',t,b)                                                = 0 ;
*
         Qimp('IMP_ALBANIA_ST',t,'B1')                                           = max ( Sum ( tm , Itd2tm(td,tm) * Data_ImpQuantitiesST(tm,'ALBANIA') )  - ImportsAL(td,t) , 0 ) ;
         Qimp('IMP_FYROM_ST',t,'B1')                                             = max ( Sum ( tm , Itd2tm(td,tm) * Data_ImpQuantitiesST(tm,'FYROM') )    - ImportsFY(td,t) , 0 ) ;
         Qimp('IMP_BULGARIA_ST',t,'B1')                                          = max ( Sum ( tm , Itd2tm(td,tm) * Data_ImpQuantitiesST(tm,'BULGARIA') ) - ImportsBG(td,t) , 0 ) ;
         Qimp('IMP_TURKEY_ST',t,'B1')                                            = max ( Sum ( tm , Itd2tm(td,tm) * Data_ImpQuantitiesST(tm,'TURKEY') )   - ImportsTR(td,t) , 0 ) ;
         Qimp('IMP_ITALY_ST',t,'B1')                                             = max ( Sum ( tm , Itd2tm(td,tm) * Data_ImpQuantitiesST(tm,'ITALY') )    - ImportsIT(td,t) , 0 ) ;
*
         Qexp('EXP_ALBANIA_ST',t,'B1')                                           = max ( Sum ( tm , Itd2tm(td,tm) * Data_ExpQuantitiesST(tm,'ALBANIA') )  - ExportsAL(td,t) , 0 ) ;
         Qexp('EXP_FYROM_ST',t,'B1')                                             = max ( Sum ( tm , Itd2tm(td,tm) * Data_ExpQuantitiesST(tm,'FYROM') )    - ExportsFY(td,t) , 0 ) ;
         Qexp('EXP_BULGARIA_ST',t,'B1')                                          = max ( Sum ( tm , Itd2tm(td,tm) * Data_ExpQuantitiesST(tm,'BULGARIA') ) - ExportsBG(td,t) , 0 ) ;
         Qexp('EXP_TURKEY_ST',t,'B1')                                            = max ( Sum ( tm , Itd2tm(td,tm) * Data_ExpQuantitiesST(tm,'TURKEY') )   - ExportsTR(td,t) , 0 ) ;
         Qexp('EXP_ITALY_ST',t,'B1')                                             = max ( Sum ( tm , Itd2tm(td,tm) * Data_ExpQuantitiesST(tm,'ITALY') )    - ExportsIT(td,t) , 0 ) ;
*
         Pimp('IMP_ALBANIA_ST',t,'B1')  $ ( Qimp('IMP_ALBANIA_ST',t,'B1') > 0 )  = 300 ;
         Pimp('IMP_FYROM_ST',t,'B1')    $ ( Qimp('IMP_FYROM_ST',t,'B1') > 0 )    = MCP_HUPX(td,t) + 3 ;
         Pimp('IMP_BULGARIA_ST',t,'B1') $ ( Qimp('IMP_BULGARIA_ST',t,'B1') > 0 ) = MCP_OPCOM(td,t) + 3 ;
         Pimp('IMP_TURKEY_ST',t,'B1')   $ ( Qimp('IMP_TURKEY_ST',t,'B1') > 0 )   = MCP_Epias(td,t) + 3 ;
         Pimp('IMP_ITALY_ST',t,'B1')    $ ( Qimp('IMP_ITALY_ST',t,'B1') > 0 )    = MCP_GME(td,t) + 3 ;
*
         Pexp('EXP_ALBANIA_ST',t,'B1')  $ ( Qexp('EXP_ALBANIA_ST',t,'B1') > 0 )  = 0 ;
         Pexp('EXP_FYROM_ST',t,'B1')    $ ( Qexp('EXP_FYROM_ST',t,'B1') > 0 )    = MCP_HUPX(td,t) - 3 ;
         Pexp('EXP_BULGARIA_ST',t,'B1') $ ( Qexp('EXP_BULGARIA_ST',t,'B1') > 0 ) = MCP_OPCOM(td,t) - 3 ;
         Pexp('EXP_TURKEY_ST',t,'B1')   $ ( Qexp('EXP_TURKEY_ST',t,'B1') > 0 )   = MCP_Epias(td,t) - 3 ;
         Pexp('EXP_ITALY_ST',t,'B1')    $ ( Qexp('EXP_ITALY_ST',t,'B1') > 0 )    = MCP_GME(td,t) - 3 ;
*
*
*
         // Pre-Optimization Flag Activation
         If ( Flag_ShutDownCost = 0 , SDC(g) = 0 ; ) ;
         //
         If ( Flag_ReserveRequirements = 0 ,
                                            RR1(t)       = 0 ;
                                            RR2up(t)     = 0 ;
                                            RR2dn(t)     = 0 ;
                                            FRR2up(t)    = 0 ;
                                            FRR2dn(t)    = 0 ;
                                            RR3(t)       = 0 ;
            ) ;





*
*        Variables Initialization
         IniUpHours(g)                                                   = 0 ;
         IniDnHours(g)                                                   = 0 ;
*

         loop ( g , If ( Tini(g) > 0 , IniUpHours(g) = max ( 0 , UT(g) - Tini(g) ) ) ; ) ;
         loop ( g , If ( Tini(g) < 0 , IniDnHours(g) = max ( 0 , DT(g) + Tini(g) ) ) ; ) ;




         //display Tini , IniUpHours , IniDnHours ;

*
         u.lo(g,t)                                                       = 0 ;
         u.up(g,t)                                                       = 1 ;
         y.lo(g,t)                                                       = 0 ;
         y.up(g,t)                                                       = 1 ;
         z.lo(g,t)                                                       = 0 ;
         z.up(g,t)                                                       = 1 ;

         u.fx(g,t) $ ( ord(t) <= IniUpHours(g) and Tini(g) > 0 )                         = 1 ;
         y.fx(g,t) $ ( ord(t) <= IniUpHours(g) and Tini(g) > 0 )                         = 0 ;
         z.fx(g,t) $ ( ord(t) <= IniUpHours(g) and Tini(g) > 0 )                         = 0 ;


         u.fx(g,t) $ ( ord(t) <= IniDnHours(g) and Tini(g) < 0 )                         = 0 ;


*



         u_AGC.fx(g_thr,t) $ ( Data_ThermalUnits(g_thr,'AGC') = 0 )      = 0 ;
         u_AGC.fx(g_hdr,t) $ ( Data_HydroUnits(g_hdr,'AGC') = 0 )        = 0 ;
*



         rc1.fx(g_hdr,t)                                                 = 0 ;
         rc2up.fx(g_thr,t) $ ( Data_ThermalUnits(g_thr,'AGC') = 0 )      = 0 ;
         rc2up.fx(g_hdr,t) $ ( Data_HydroUnits(g_hdr,'AGC') = 0 )        = 0 ;
         rc2dn.fx(g_thr,t) $ ( Data_ThermalUnits(g_thr,'AGC') = 0 )      = 0 ;
         rc2dn.fx(g_hdr,t) $ ( Data_HydroUnits(g_hdr,'AGC') = 0 )        = 0 ;
         rc1.fx(g,t)       $ ( Comm(g) = 1 )                             = 0 ;
         rc2up.fx(g,t)     $ ( Comm(g) = 1 )                             = 0 ;
         rc2up.fx(g,t)     $ ( Comm(g) = 1 )                             = 0 ;
         rc3S.fx(g,t)      $ ( Comm(g) = 1 )                             = 0 ;
         rc3NS.fx(g,t)     $ ( Comm(g) = 1 )                             = 0 ;
         pg.up(g,t)                                                      = Pmax(g) ;


         //display Pini24 , Uini ;
*





*        ACTIVATION OF THE LP-METHOD =========================================
         if ( OptMethod = 2 ,
                             Pmin(g)                                                     = 0 ;
                             Pmin_AGC(g)                                                 = 0 ;
                             Pmax_AGC(g)                                                 = Pmax(g) ;
                             //
                             u.fx(g,t)                                                   = 1 ;
                             y.fx(g,t)                                                   = 0 ;
                             z.fx(g,t)                                                   = 0 ;
                             //
                             u_AGC.fx(g_thr,t) $ ( Data_ThermalUnits(g_thr,'AGC') = 0 )  = 0 ;
                             u_AGC.fx(g_hdr,t) $ ( Data_HydroUnits(g_hdr,'AGC') = 0 )    = 0 ;
                             u_AGC.fx(g_thr,t) $ ( Data_ThermalUnits(g_thr,'AGC') = 1 )  = 1 ;
                             u_AGC.fx(g_hdr,t) $ ( Data_HydroUnits(g_hdr,'AGC') = 1 )    = 1 ;
                             u_3NS.fx(g,t)                                               = 1 ;
                             //
                             rc1.fx(g_hdr,t)                                             = 0 ;
                             rc2up.fx(g_thr,t) $ ( Data_ThermalUnits(g_thr,'AGC') = 0 )  = 0 ;
                             rc2up.fx(g_hdr,t) $ ( Data_HydroUnits(g_hdr,'AGC') = 0 )    = 0 ;
                             rc2dn.fx(g_thr,t) $ ( Data_ThermalUnits(g_thr,'AGC') = 0 )  = 0 ;
                             rc2dn.fx(g_hdr,t) $ ( Data_HydroUnits(g_hdr,'AGC') = 0 )    = 0 ;
                             rc1.fx(g,t)       $ ( Comm(g) = 1 )                         = 0 ;
                             rc2up.fx(g,t)     $ ( Comm(g) = 1 )                         = 0 ;
                             rc2up.fx(g,t)     $ ( Comm(g) = 1 )                         = 0 ;
                             rc3S.fx(g,t)      $ ( Comm(g) = 1 )                         = 0 ;
                             rc3NS.fx(g,t)     $ ( Comm(g) = 1 )                         = 0 ;
            ) ;


*        EX-ANTE REPORTS -----------------------------------------------------
$include "C:/midTemps/GMS/midTemps_ExAnteReports.gms"
*
*
*
*        MODEL ---------------------------------------------------------------
         midTemps.optca = 100 ;
         midTemps.optcr = 0.0001 ;

* === Create option file for solver options
$onecho > cplex.opt
threads 8
relaxfixedinfeas 1
$offecho
* Include the solver option file
midTemps.optfile = 1;



         option limrow = 0 ;
         option limcol = 0 ;
         option solprint = off ;

         solve midTemps minimizing cost using mip ;

         display Pmand , td , a_Pmand.l , pg.l , Pmin , Pmax ;


         Uini(g,t)                                       = 0 ;
         Uini(g,'1')                                     = u.l(g,'24') ;
         Pini(g,'1')                                     = pg.l(g,'24') ;
         U_ini(g)                                        = u.l(g,'24') ;

         Pini24(g) = pg.l(g,'24') ;

         Tini_p(g)                                       = 0 ;
         Tini_n(g)                                       = 0 ;

         loop ( g ,
                   loop ( t ,
                             if ( pg.l(g,t) > 0 , Tini_p(g) = Tini_p(g) + 1 ; Tini_n(g) = 0 ; ) ;
                             if ( pg.l(g,t) = 0 , Tini_n(g) = Tini_n(g) + 1 ; Tini_p(g) = 0 ; ) ;
                        ) ;
              ) ;
         Tini(g) = Tini_p(g) - Tini_n(g) ;

         //display Uini , Tini , Pini , a_Pmax1.l , a_Pmax2.l , a_Pmin.l , rc2dn.l , Pmax , Pmin ;
*
*
*
*
         MCP(a,t)                                        = 0 ;
         MCP(a,t)                                        = Area_Power_Balance.m(a,t) ;
         MCPdav(td,t)                                    = Sum(a,MCP(a,t))/card(a) ;
*
         MCPav                                           = Sum(t,(Sum(a,MCP(a,t))/card(a)))/card(t) ;
         PRR1(t)                                         = Primary_Reserve_Requirement.m(t) ;
         PRR2up(t)                                       = Upward_Secondary_Reserve_Requirement.m(t) ;
         PRR2dn(t)                                       = Downward_Secondary_Reserve_Requirement.m(t) ;
         MAVCd(g)                                        = smin ( (t,b) $ ( Qgen(g,t,b) > 0 ) , Pgen(g,t,b) ) ;
         //
*         loop ( g , if (

         //
         Losses(t)                                       = Sum ( g , ( 1 - GLFgen(g,t) ) * pg.l(g,t) ) + Sum ( i , ( 1 - GLFimp(i,t) ) * Sum ( b , qi.l(i,t,b) ) ) ;
         LoadAndLosses(t)                                = Sum ( a , ILa(a,t) ) + Losses(t) ;
         Daily_Imports(inter,t)                          = Sum ( i , Ii2inter(i,inter) * Sum ( b , qi.l(i,t,b) ) ) ;
         Daily_Exports(inter,t)                          = Sum ( e , Ie2inter(e,inter) * Sum ( b , qe.l(e,t,b) ) ) ;
         //
         Total_Demand                                    = Total_Demand     + Sum ( (a,t) , ILa(a,t) ) ;
         Total_Losses                                    = Total_Losses     + Sum ( t , Losses(t) ) ;
         Total_Pumping                                   = Total_Pumping    + Sum ( (d,b,t) , qd.l(d,t,b) ) ;
         Total_Lignite                                   = Total_Lignite    + Sum ( (g_Lig,t) , pg.l(g_Lig,t) ) ;
         Total_CCGT                                      = Total_CCGT       + Sum ( (g_CCGT,t) , pg.l(g_CCGT,t) ) ;
         Total_OCGT                                      = Total_OCGT       + Sum ( (g_OCGT,t) , pg.l(g_OCGT,t) ) ;
         Total_CHP                                       = Total_CHP        + Sum ( (g_CHP,t) , pg.l(g_CHP,t) ) ;
         Total_Hydro                                     = Total_Hydro      + Sum ( (g_hdr,t) , pg.l(g_hdr,t) ) ;
         Total_RES                                       = Total_RES        + Sum ( (a,t) , RES(a,t) ) ;
         Total_Imports                                   = Total_Imports    + Sum ( (i,b,t) , qi.l(i,t,b) ) ;
         Total_Exports                                   = Total_Exports    + Sum ( (e,b,t) , qe.l(e,t,b) ) ;
         Total_NetImports                                = Total_NetImports + Sum ( (i,b,t) , qi.l(i,t,b) ) - Sum ( (e,b,t) , qe.l(e,t,b) ) ;
         Total_MCP                                       = Total_MCP        + MCPav ;





         Daily_Demand(td)                                = Sum ( (a,t) , ILa(a,t) ) ;
         Daily_Losses(td)                                = Sum ( t , Losses(t) ) ;
         Daily_Pumping(td)                               = Sum ( (d,b,t) , qd.l(d,t,b) ) ;
         Daily_Lignite(td)                               = Sum ( (g_Lig,t) , pg.l(g_Lig,t) ) ;
         Daily_CCGT(td)                                  = Sum ( (g_CCGT,t) , pg.l(g_CCGT,t) ) ;
         Daily_OCGT(td)                                  = Sum ( (g_OCGT,t) , pg.l(g_OCGT,t) ) ;
         Daily_CHP(td)                                   = Sum ( (g_CHP,t) , pg.l(g_CHP,t) ) ;
         Daily_Hydro(td)                                 = Sum ( (g_hdr,t) , pg.l(g_hdr,t) ) ;
         Daily_RES(td)                                   = Sum ( (a,t) , RES(a,t) ) ;
         Daily_TotImports(td)                            = Sum ( (i,b,t) , qi.l(i,t,b) ) ;
         Daily_TotExports(td)                            = Sum ( (e,b,t) , qe.l(e,t,b) ) ;
         Daily_TotNetImports(td)                         = Sum ( (i,b,t) , qi.l(i,t,b) ) - Sum ( (e,b,t) , qe.l(e,t,b) ) ;
         //
         Daily_HydroMandatory(td)                        = Sum ( (g_hdr,t) , Pmand_hydro(g_hdr,t) ) ;
         Daily_ShutDowns(td,g)                           = Sum ( t , z.l(g,t) ) ;
         Daily_Dispatch(td,g)                            = Sum ( t , pg.l(g,t) ) ;
         Daily_TotalImports(td,t)                        = Sum ( (i,b) , qi.l(i,t,b) ) ;
         Daily_TotalExports(td,t)                        = Sum ( (e,b) , qe.l(e,t,b) ) ;
         Daily_TotalNetImports(td,t)                     = Daily_TotalImports(td,t) - Daily_TotalExports(td,t) ;





*        REPORTING -----------------------------------------------------------
$include "C:/midTemps/GMS/midTemps_Reports.gms"
*
     ) ;


Total_MCP                = Total_MCP / card(td) ;
MCPmav(tm,t)             = Sum ( td , Itd2tm(td,tm) * MCPdav(td,t) ) / DPM(tm) ;
MCPm(tm)                 = Sum ( (td,t) , Itd2tm(td,tm) * MCPdav(td,t) ) / ( DPM(tm) * card(t) ) ;

Scalar counter / 0 / ;

loop ( q ,
          counter = 0 ;
          loop ( tm $ ( ( ord(tm) >= ( ord(q) - 1 ) * 3 + 1 ) and ( ord(tm) <= ( ord(q) - 1 ) * 3 + 3 ) ) ,
                                                                                                           MCPq(q) = MCPq(q) + MCPm(tm)
                                                                                                           if ( MCPm(tm) > 0 , counter = counter + 1 ; ) ;
               ) ;
          if ( counter > 0 , MCPq(q) = MCPq(q) / counter ; ) ;
     ) ;

loop ( s ,
          counter = 0 ;
          loop ( q $ ( ( ord(q) >= ( ord(s) - 1 ) * 2 + 1 ) and ( ord(q) <= ( ord(s) - 1 ) * 2 + 2 ) ) ,
                                                                                                           MCPs(s) = MCPs(s) + MCPq(q)
                                                                                                           if ( MCPq(q) > 0 , counter = counter + 1 ; ) ;
               ) ;
          if ( counter > 0 , MCPs(s) = MCPs(s) / counter ; ) ;
     ) ;




File Monthly_CommitmentSchedule  / 'C:\midTemps\Reports\Monthly_CommitmentSchedule.txt' / ;
Monthly_CommitmentSchedule.pw = 10000 ;

File Aggregated_Results          / 'C:\midTemps\Reports\Aggregated_Results.txt' / ;
Aggregated_Results.pw = 10000 ;

File GMS_Printing                / 'C:\midTemps\Reports\GMS_Printing.gms' / ;
GMS_Printing.pw = 10000 ;





Put Daily_InitialConditions

loop ( td , Put ',' Put td.tl:0:0 ) ; Put /
loop ( g ,
          Put g.tl:0:0 loop ( td , Put ',' Put PiniReport(g,td):15:3 ) ; Put /
     ) ;
Put /
loop ( g ,
          Put g.tl:0:0 loop ( td , Put ',' Put TiniReport(g,td):15:3 ) ; Put /
     ) ;

Putclose Daily_InitialConditions
*
*
*
Put Aggregated_Results

Put 'FORECAST PERIOD' Put ',' Put '-' Put /
Put /
Put 'AVERAGE SMP [�/MWh]' Put ',' Put Total_MCP:15:3 Put /
Put /
Put 'ENERGY MIX' Put ',' Put 'VOLUME [MWh]' Put /
Put 'Demand'     Put ',' Put Total_Demand:15:2 Put /
Put 'Losses'     Put ',' Put Total_Losses:15:2 Put /
Put 'Pumping'    Put ',' Put Total_Pumping:15:2 Put /
Put 'Exports'    Put ',' Put Total_Exports:15:2 Put /
Put 'SUM'        Put ',' Put (Total_Demand+Total_Losses+Total_Pumping+Total_Exports):15:2 Put /
*
Put 'Lignite'    Put ',' Put Total_Lignite:15:2 Put /
Put 'CCGT'       Put ',' Put Total_CCGT:15:2 Put /
Put 'OCGT'       Put ',' Put Total_OCGT:15:2 Put /
Put 'CHP'        Put ',' Put Total_CHP:15:2 Put /
Put 'Hydro'      Put ',' Put Total_Hydro:15:2 Put /
Put 'RES'        Put ',' Put Total_RES:15:2 Put /
Put 'Imports'    Put ',' Put Total_Imports:15:2 Put /
Put 'SUM'        Put ',' Put (Total_Lignite+Total_CCGT+Total_OCGT+Total_CHP+Total_Hydro+Total_RES+Total_Imports):15:2 Put /

Putclose Aggregated_Results
*
*
*
* MONTHLY AVERAGE SMP
Put MonthlyAverageSMP

Put 'ID' Put ',' Put 'Month' loop ( t , Put ',' Put t.tl:0:0 ) Put ',' Put 'Average' Put /
loop ( tm ,
           Put ord(tm) Put ',' loop ( tmn $ ( ord(tmn) = ord(tm) ) , Put tmn.tl:0:0 ) loop ( t , Put ',' Put MCPmav(tm,t):15:3 ) ; Put ',' Put (Sum(t,MCPmav(tm,t))/card(t)):15:3 Put /
     ) ;

Putclose MonthlyAverageSMP ;
*
*
*
* MANDATORY HYDRO
*Put HydroMandatory
*
*Put 'Year' Put ',' Put 'Month' Put ',' Put 'Weekday' Put ',' Put 'Weekend' Put ',' Put 'Total'
*
*loop ( tm ,
*           Put /
*           Put tm.tl:0:0 Put ','
*           loop ( tmn $ ( ord(tmn) = ord(tm) ) , Put tmn.tl:0:0 ) ; Put ','
*           Put Sum((g_hdr,t),MandatoryHydro_Weekday(tm,g_hdr,t)):15:3 Put ','
*           Put Sum((g_hdr,t),MandatoryHydro_Weekend(tm,g_hdr,t)):15:3 Put ','
*           Put Sum(td,Itd2tm(td,tm)*Daily_HydroMandatory(td)):15:3
*     ) ;
*Put /
*Put ',' Put ',' Put ',' Put 'Total' Put ',' Put Sum(td,Daily_HydroMandatory(td)):15:3
*
*Putclose HydroMandatory ;
*
*
*
* MONTHLY DISPATCH
Put MonthlyDispatch

Put 'Unit / Month' loop ( tm , loop ( tmn $ ( ord(tmn) = ord(tm) ) , Put ',' Put tmn.tl:0:0 ) ) ; Put ',' Put 'Total' Put /
loop ( g ,
          Put g.tl:0:0 loop ( tm , Put ',' Put Sum(td,Itd2tm(td,tm)*Daily_Dispatch(td,g)):15:3 ) ;
          Put ',' Put Sum(td,Daily_Dispatch(td,g)):15:3 Put /
     ) ;

Putclose MonthlyDispatch
*
*
*
* MONTHLY SHUT DOWNS
Put MonthlyShutDowns

Put 'Unit / Month' loop ( tm , loop ( tmn $ ( ord(tmn) = ord(tm) ) , Put ',' Put tmn.tl:0:0 ) ) ; Put ',' Put 'Total' Put /
loop ( g ,
          Put g.tl:0:0 loop ( tm , Put ',' Put Sum(td,Itd2tm(td,tm)*Daily_ShutDowns(td,g)):15:3 ) ;
          Put ',' Put Sum(td,Daily_ShutDowns(td,g)):15:3 Put /
     ) ;

Putclose MonthlyShutDowns
*
*
*
* MONTHLY SMP
Put MonthlySMP

loop ( tm ,
           loop ( tmn $ ( ord(tm) = ord(tmn) ) , Put tmn.tl:0:0 ) ;
           Put ','
           Put MCPm(tm):15:3
           Put /
     ) ;

Putclose MonthlySMP
*
*
*
* QUARTERLY SMP
Put QuarterlySMP

loop ( q ,
           Put q.tl:0:0
           Put ','
           Put MCPq(q):15:3
           Put /
     ) ;

Putclose QuarterlySMP
*
*
*
* SEMESTERLY SMP
Put SemesterlySMP

loop ( s ,
           Put s.tl:0:0
           Put ','
           Put MCPs(s):15:3
           Put /
     ) ;

Putclose SemesterlySMP
*
*
*
* MONTHLY VOLUMES
Put MonthlyVolumes

Put ',' Put 'Dem'  Put ',' Put 'Los' Put ',' Put 'Pmp' Put ',' Put 'Lig' Put ',' Put 'CCGT'
Put ',' Put 'OCGT' Put ',' Put 'CHP' Put ',' Put 'Hdr' Put ',' Put 'RES'
Put ',' Put 'Imp'  Put ',' Put 'Exp' Put ',' Put 'NImp'
Put /

loop ( tm ,
           loop ( tmn $ ( ord(tm) = ord(tmn) ) , Put tmn.tl:3:0 ) ;
           Put ',' Put Sum(td,Itd2tm(td,tm)*Daily_Demand(td)):25:3
           Put ',' Put Sum(td,Itd2tm(td,tm)*Daily_Losses(td)):25:3
           Put ',' Put Sum(td,Itd2tm(td,tm)*Daily_Pumping(td)):25:3
           Put ',' Put Sum(td,Itd2tm(td,tm)*Daily_Lignite(td)):25:3
           Put ',' Put Sum(td,Itd2tm(td,tm)*Daily_CCGT(td)):25:3
           Put ',' Put Sum(td,Itd2tm(td,tm)*Daily_OCGT(td)):25:3
           Put ',' Put Sum(td,Itd2tm(td,tm)*Daily_CHP(td)):25:3
           Put ',' Put Sum(td,Itd2tm(td,tm)*Daily_Hydro(td)):25:3
           Put ',' Put Sum(td,Itd2tm(td,tm)*Daily_RES(td)):25:3
           Put ',' Put Sum(td,Itd2tm(td,tm)*Daily_TotImports(td)):25:3
           Put ',' Put Sum(td,Itd2tm(td,tm)*Daily_TotExports(td)):25:3
           Put ',' Put Sum(td,Itd2tm(td,tm)*Daily_TotNetImports(td)):25:3
           Put /
     ) ;

Putclose MonthlyVolumes
*
*
*
* MINIMUM AVERAGE VARIABLE COST
Put MinimumAverageVariableCost

loop ( g ,
          Put g.tl:0:0
          Put ',' Put MAVCd(g)
*          loop ( tm , Put ',' Put MAVC(g,tm) ) ;
          Put /
    ) ;

Putclose MinimumAverageVariableCost













Scalar chdim / 10 / ;
Scalar iter ;

Put GMS_Printing

Put 'Table GLF(g,t)'   Put /
*Put '                    ' loop ( t , Put ' ' Put t.tl:>chdim ) ; Put /
For ( iter = 1 to 20 , Put ' ' ) ; loop ( t , Put ' ' Put t.tl:>chdim ) ; Put /

loop ( g ,
          Put g.tl:<20 loop ( t , Put ' ' Put GLFgen(g,t):>chdim:6 ) ; Put /
     ) ;
Put ';'

Putclose GMS_Printing



//display Qimp , Pimp , Qexp , Pexp ;

display Pgen , Qgen , Pmax , Pmin , Availability ;
