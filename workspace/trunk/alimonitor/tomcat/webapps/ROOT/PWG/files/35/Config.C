// One can use the configuration macro in compiled mode by
// root [0] gSystem->Load("libgeant321");
// root [0] gSystem->SetIncludePath("-I$ROOTSYS/include -I$ALICE_ROOT/include\
//                   -I$ALICE_ROOT -I$ALICE/geant3/TGeant3");
// root [0] .x grun.C(1,"Config.C++")

#if !defined(__CINT__) || defined(__MAKECINT__)
#include <Riostream.h>
#include <TRandom.h>
#include <TSystem.h>
#include <TVirtualMC.h>
#include <TGeant3TGeo.h>
#include "STEER/AliRunLoader.h"
#include "STEER/AliRun.h"
#include "STEER/AliConfig.h"
#include "PYTHIA6/AliDecayerPythia.h"
#include "EVGEN/AliGenCocktail.h"
#include "EVGEN/AliGenHIJINGpara.h"
#include "STEER/AliMagFMaps.h"
#include "STRUCT/AliBODY.h"
#include "STRUCT/AliMAG.h"
#include "STRUCT/AliABSOv0.h"
#include "STRUCT/AliDIPOv2.h"
#include "STRUCT/AliHALL.h"
#include "STRUCT/AliFRAMEv2.h"
#include "STRUCT/AliSHILv2.h"
#include "STRUCT/AliPIPEv0.h"
#include "ITS/AliITSvPPRasymmFMD.h"
#include "TPC/AliTPCv2.h"
#include "TOF/AliTOFv5T0.h"
#include "HMPID/AliHMPIDv1.h"
#include "ZDC/AliZDCv2.h"
#include "TRD/AliTRDv1.h"
#include "FMD/AliFMDv1.h"
#include "MUON/AliMUONv1.h"
#include "PHOS/AliPHOSv1.h"
#include "PMD/AliPMDv1.h"
#include "T0/AliT0v1.h"
#include "EMCAL/AliEMCALv2.h"
#include "ACORDE/AliACORDEv0.h"
#include "VZERO/AliVZEROv7.h"
#endif

Float_t EtaToTheta(Float_t arg);

//--- Magnetic Field ---
enum Mag_t
{
  kNoField, k5kG, kFieldMax
};

const char * pprField[] = {
  "kNoField", "k5kG"
};

void ProcessEnvironmentVars();

// Geterator, field, beam energy
static Mag_t         mag      = k5kG;

//========================//
// Set Random Number seed //
//========================//
TDatime dt;
static UInt_t seed    = dt.Get();

// Comment line
static TString comment;

void Config()
{
  // ThetaRange is (0., 180.). It was (0.28,179.72) 7/12/00 09:00
  // Theta range given through pseudorapidity limits 22/6/2001
  ProcessEnvironmentVars();
  
  // Set Random Number seed
  gRandom->SetSeed(seed);
  AliLog::Message(AliLog::kInfo, Form("Seed for random number generation = %d",gRandom->GetSeed()), "Config.C", "Config.C", "Config()","Config.C", __LINE__);

   // libraries required by geant321
#if defined(__CINT__)
    gSystem->Load("libgeant321");
#endif

    gSystem->Load("libEGPythia6.so");
    gSystem->Load("libpythia6.so");
    gSystem->Load("libAliPythia6.so");

    new     TGeant3TGeo("C++ Interface to Geant3");

    AliRunLoader* rl=0x0;

    AliLog::Message(AliLog::kInfo, "Creating Run Loader", "Config.C", "Config.C", "Config()"," Config.C", __LINE__);

    rl = AliRunLoader::Open("galice.root",
			    AliConfig::GetDefaultEventFolderName(),
			    "recreate");
    if (rl == 0x0)
      {
	gAlice->Fatal("Config.C","Can not instatiate the Run Loader");
	return;
      }
    rl->SetCompressionLevel(2);
    rl->SetNumberOfEventsPerFile(3);
    gAlice->SetRunLoader(rl);

    // Set the trigger configuration
    gAlice->SetTriggerDescriptor("Pb-Pb");
    cout<<"Trigger configuration is set to  Pb-Pb"<<endl;

    //
    // Set External decayer
    TVirtualMCDecayer *decayer = new AliDecayerPythia();

    decayer->SetForceDecay(kAll);
    decayer->Init();
    gMC->SetExternalDecayer(decayer);
    //=======================================================================
    // ************* STEERING parameters FOR ALICE SIMULATION **************
    // --- Specify event type to be tracked through the ALICE setup
    // --- All positions are in cm, angles in degrees, and P and E in GeV


    gMC->SetProcess("DCAY",1);
    gMC->SetProcess("PAIR",1);
    gMC->SetProcess("COMP",1);
    gMC->SetProcess("PHOT",1);
    gMC->SetProcess("PFIS",0);
    gMC->SetProcess("DRAY",0);
    gMC->SetProcess("ANNI",1);
    gMC->SetProcess("BREM",1);
    gMC->SetProcess("MUNU",1);
    gMC->SetProcess("CKOV",1);
    gMC->SetProcess("HADR",1);
    gMC->SetProcess("LOSS",2);
    gMC->SetProcess("MULS",1);
    gMC->SetProcess("RAYL",1);

    Float_t cut = 1.e-3;        // 1MeV cut by default
    Float_t tofmax = 1.e10;

    gMC->SetCut("CUTGAM", cut);
    gMC->SetCut("CUTELE", cut);
    gMC->SetCut("CUTNEU", cut);
    gMC->SetCut("CUTHAD", cut);
    gMC->SetCut("CUTMUO", cut);
    gMC->SetCut("BCUTE",  cut); 
    gMC->SetCut("BCUTM",  cut); 
    gMC->SetCut("DCUTE",  cut); 
    gMC->SetCut("DCUTM",  cut); 
    gMC->SetCut("PPCUTM", cut);
    gMC->SetCut("TOFMAX", tofmax); 

    AliGenCocktail *gener = new AliGenCocktail();
    gener->SetPhiRange(0, 360);
    // Set pseudorapidity range from -8 to 8.
    Float_t thmin = EtaToTheta(1);   // theta min. <---> eta max
    Float_t thmax = EtaToTheta(-1);  // theta max. <---> eta min 
    gener->SetThetaRange(thmin,thmax);

    // PRIMARY VERTEX
    //
    gener->SetOrigin(0., 0., 0.);    // vertex position
    //
    //
    // Size of the interaction diamond
    // Longitudinal
    Float_t sigmaz  = 7.55 / TMath::Sqrt(2.); // [cm]
    //
    // Transverse
    Float_t betast  = 10;                 // beta* [m]
    Float_t eps     = 3.75e-6;            // emittance [m]
    Float_t gamma   = 7000. / 0.938272;   // relativistic gamma [1]
    Float_t sigmaxy = TMath::Sqrt(eps * betast / gamma) / TMath::Sqrt(2.) * 100.;  // [cm]
    printf("\n \n Diamond size x-y: %10.3e z: %10.3e\n \n", sigmaxy, sigmaz);
    
    gener->SetSigma(sigmaxy, sigmaxy, sigmaz);      // Sigma in (X,Y,Z) (cm) on IP position
    gener->SetCutVertexZ(3.);        // Truncate at 3 sigma
    gener->SetVertexSmear(kPerEvent);

    gSystem->Load("libTTherminator.so");

    AliGenTherminator *genther = new AliGenTherminator();
    genther->SetFileName("event.out");
    genther->SetEventNumberInFile(1);
    genther->SetTemperature(0.145);
    genther->SetMiuI(-0.0009);
    genther->SetMiuS(0.000);
    genther->SetMiuB(0.0008);
    genther->SetAlfaRange(8.0);
    genther->SetRapRange(4.0);
    genther->SetTau(9.74);
    genther->SetRhoMax(7.74);
    // Select the Lhyquid hydrodynamics hypersurface
    genther->SetModel("Lhyquid3D");
    // for LHC initial conditions centrality 20-30%
    genther->SetLhyquidSet("LHC500C2030");
    gener->AddGenerator(genther, "THERMINATOR LHYQUID3D", 1);
    gener->Init();

    // 
    // Activate this line if you want the vertex smearing to happen
    // track by track
    //
    //gener->SetVertexSmear(perTrack); 

    // FIELD
    //
    AliMagWrapCheb* field = 0x0;
    if (mag == kNoField) {
      comment = comment.Append(" | L3 field 0.0 T");
      field = new AliMagWrapCheb("Maps","Maps", 2, 0., 10., AliMagWrapCheb::k2kG);
    } else if (mag == k5kG) {
      comment = comment.Append(" | L3 field 0.5 T");
      field = new AliMagWrapCheb("Maps","Maps", 2, 1., 10., AliMagWrapCheb::k5kG);
    }
    printf("\n \n Comment: %s \n \n", comment.Data());
    
    rl->CdGAFile();
    gAlice->SetField(field);    
    
    Int_t   iABSO  =  1;
    Int_t   iDIPO  =  1;
    Int_t   iFMD   =  0;
    Int_t   iFRAME =  1;
    Int_t   iHALL  =  1;
    Int_t   iITS   =  1;
    Int_t   iMAG   =  1;
    Int_t   iMUON  =  0;
    Int_t   iPHOS  =  0;
    Int_t   iPIPE  =  1;
    Int_t   iPMD   =  0;
    Int_t   iHMPID  =  0;
    Int_t   iSHIL  =  1;
    Int_t   iT0 =  0;
    Int_t   iTOF   =  1;
    Int_t   iTPC   =  1;
    Int_t   iTRD   =  1;
    Int_t   iZDC   =  0;
    Int_t   iEMCAL =  0;
    Int_t   iACORDE   =  0;
    Int_t   iVZERO =  0;

    //=================== Alice BODY parameters =============================
    AliBODY *BODY = new AliBODY("BODY", "Alice envelop");


    if (iMAG)
    {
        //=================== MAG parameters ============================
        // --- Start with Magnet since detector layouts may be depending ---
        // --- on the selected Magnet dimensions ---
        AliMAG *MAG = new AliMAG("MAG", "Magnet");
    }


    if (iABSO)
    {
        //=================== ABSO parameters ============================
        AliABSO *ABSO = new AliABSOv3("ABSO", "Muon Absorber");
    }

    if (iDIPO)
    {
        //=================== DIPO parameters ============================

        AliDIPO *DIPO = new AliDIPOv3("DIPO", "Dipole version 3");
    }

    if (iHALL)
    {
        //=================== HALL parameters ============================

        AliHALL *HALL = new AliHALLv3("HALL", "Alice Hall");
    }


    if (iFRAME)
    {
        //=================== FRAME parameters ============================

        AliFRAMEv2 *FRAME = new AliFRAMEv2("FRAME", "Space Frame");
	FRAME->SetHoles(1);
    }

    if (iSHIL)
    {
        //=================== SHIL parameters ============================

        AliSHIL *SHIL = new AliSHILv3("SHIL", "Shielding Version 3");
    }


    if (iPIPE)
    {
        //=================== PIPE parameters ============================

        AliPIPE *PIPE = new AliPIPEv3("PIPE", "Beam Pipe");
    }
 
    if (iITS)
    {
        //=================== ITS parameters ============================

	AliITS *ITS  = new AliITSv11Hybrid("ITS","ITS v11Hybrid");
    }

    if (iTPC)
    {
      //============================ TPC parameters =====================

        AliTPC *TPC = new AliTPCv2("TPC", "Default");
    }


    if (iTOF) {
        //=================== TOF parameters ============================

	AliTOF *TOF = new AliTOFv6T0("TOF", "normal TOF");
    }


    if (iHMPID)
    {
        //=================== HMPID parameters ===========================

        AliHMPID *HMPID = new AliHMPIDv3("HMPID", "normal HMPID");

    }


    if (iZDC)
    {
        //=================== ZDC parameters ============================

        AliZDC *ZDC = new AliZDCv3("ZDC", "normal ZDC");
    }

    if (iTRD)
    {
        //=================== TRD parameters ============================

        AliTRD *TRD = new AliTRDv1("TRD", "TRD slow simulator");
        AliTRDgeometry *geoTRD = TRD->GetGeometry();
	// Partial geometry: modules at 0,8,9,17
	// starting at 3h in positive direction
        geoTRD->SetSMstatus(1,0);
	geoTRD->SetSMstatus(2,0);
	geoTRD->SetSMstatus(3,0);
	geoTRD->SetSMstatus(4,0);
        geoTRD->SetSMstatus(5,0);
	geoTRD->SetSMstatus(6,0);
        geoTRD->SetSMstatus(7,0);
        geoTRD->SetSMstatus(10,0);
        geoTRD->SetSMstatus(11,0);
        geoTRD->SetSMstatus(12,0);
        geoTRD->SetSMstatus(13,0);
        geoTRD->SetSMstatus(14,0);
        geoTRD->SetSMstatus(15,0);
        geoTRD->SetSMstatus(16,0);
    }

    if (iFMD)
    {
        //=================== FMD parameters ============================

	AliFMD *FMD = new AliFMDv1("FMD", "normal FMD");
   }

    if (iMUON)
    {
        //=================== MUON parameters ===========================
        // New MUONv1 version (geometry defined via builders)

        AliMUON *MUON = new AliMUONv1("MUON", "default");
    }

    if (iPHOS)
    {
        //=================== PHOS parameters ===========================

        AliPHOS *PHOS = new AliPHOSv1("PHOS", "IHEP");
        //Set simulation parameters different from the default ones.
        AliPHOSSimParam* simEmc = AliPHOSSimParam::GetInstance() ;
  
        // APD noise of warm (+20C) PHOS:
        // a2 = a1*(Y1/Y2)*(M1/M2), where a1 = 0.012 is APD noise at -25C,
        // Y1 = 4.3 photo-electrons/MeV, Y2 = 1.7 p.e/MeV - light yields at -25C and +20C,
        // M1 = 50, M2 = 50 - APD gain factors chosen for t1 = -25C and t2 = +20C,
        // Y = MeanLightYield*APDEfficiency.

        Float_t apdNoise = 0.012*2.5; 
        simEmc->SetAPDNoise(apdNoise);

        //Raw Light Yield at +20C
        simEmc->SetMeanLightYield(18800);

        //ADC channel width at +18C.
        simEmc->SetADCchannelW(0.0125);
    }


    if (iPMD)
    {
        //=================== PMD parameters ============================

        AliPMD *PMD = new AliPMDv1("PMD", "normal PMD");
    }

    if (iT0)
    {
        //=================== T0 parameters ============================
        AliT0 *T0 = new AliT0v1("T0", "T0 Detector");
    }

    if (iEMCAL)
    {
        //=================== EMCAL parameters ============================

        AliEMCAL *EMCAL = new AliEMCALv2("EMCAL", "SHISH_77_TRD1_2X2_FINAL_110DEG");
    }

     if (iACORDE)
    {
        //=================== ACORDE parameters ============================

        AliACORDE *ACORDE = new AliACORDEv1("ACORDE", "normal ACORDE");
    }

     if (iVZERO)
    {
        //=================== ACORDE parameters ============================

        AliVZERO *VZERO = new AliVZEROv7("VZERO", "normal VZERO");
    }

     AliLog::Message(AliLog::kInfo, "End of Config", "Config.C", "Config.C", "Config()"," Config.C", __LINE__);

}

Float_t EtaToTheta(Float_t arg){
  return (180./TMath::Pi())*2.*atan(exp(-arg));
}

void ProcessEnvironmentVars()
{
    // Field
    if (gSystem->Getenv("CONFIG_FIELD")) {
      for (Int_t iField = 0; iField < kFieldMax; iField++) {
	if (strcmp(gSystem->Getenv("CONFIG_FIELD"), pprField[iField])==0) {
	  mag = (Mag_t)iField;
	  cout<<"Field set to "<<pprField[iField]<<endl;
	}
      }
    }

    // Random Number seed
    if (gSystem->Getenv("CONFIG_SEED")) {
      seed = atoi(gSystem->Getenv("CONFIG_SEED"));
    }
}

