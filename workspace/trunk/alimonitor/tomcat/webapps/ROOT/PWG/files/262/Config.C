// One can use the configuration macro in compiled mode by
// root [0] gSystem->Load("libgeant321");
// root [0] gSystem->SetIncludePath("-I$ROOTSYS/include -I$ALICE_ROOT/include\
//                   -I$ALICE_ROOT -I$ALICE/geant3/TGeant3");
// root [0] .x grun.C(1,"ConfigPPR.C++")

#if !defined(__CINT__) || defined(__MAKECINT__)
#include <Riostream.h>
#include <TRandom.h>
#include <TSystem.h>
#include <TVirtualMC.h>
#include <TGeant3TGeo.h>
#include <TPDGCode.h>
#include <TF1.h>
#include "STEER/AliRunLoader.h"
#include "STEER/AliRun.h"
#include "STEER/AliConfig.h"
#include "STEER/AliGenerator.h"
#include "STEER/AliLog.h"
#include "PYTHIA6/AliDecayerPythia.h"
#include "EVGEN/AliGenHIJINGpara.h"
#include "THijing/AliGenHijing.h"
#include "EVGEN/AliGenCocktail.h"
#include "EVGEN/AliGenSlowNucleons.h"
#include "EVGEN/AliSlowNucleonModelExp.h"
#include "EVGEN/AliGenParam.h"
#include "EVGEN/AliGenMUONlib.h"
#include "EVGEN/AliGenSTRANGElib.h"
#include "EVGEN/AliGenMUONCocktail.h"
#include "EVGEN/AliGenCocktail.h"
#include "EVGEN/AliGenGeVSim.h"
#include "EVGEN/AliGeVSimParticle.h"
#include "PYTHIA6/AliGenPythia.h"
#include "STEER/AliMagF.h"
#include "STRUCT/AliBODY.h"
#include "STRUCT/AliMAG.h"
#include "STRUCT/AliABSOv3.h"
#include "STRUCT/AliDIPOv3.h"
#include "STRUCT/AliHALLv3.h"
#include "STRUCT/AliFRAMEv2.h"
#include "STRUCT/AliSHILv3.h"
#include "STRUCT/AliPIPEv3.h"
#include "ITS/AliITSv11Hybrid.h"
#include "TPC/AliTPCv2.h"
#include "TOF/AliTOFv6T0.h"
#include "HMPID/AliHMPIDv3.h"
#include "ZDC/AliZDCv3.h"
#include "TRD/AliTRDv1.h"
#include "FMD/AliFMDv1.h"
#include "MUON/AliMUONv1.h"
#include "PHOS/AliPHOSv1.h"
#include "PMD/AliPMDv1.h"
#include "T0/AliT0v1.h"
#include "EMCAL/AliEMCALv2.h"
#include "ACORDE/AliACORDEv1.h"
#include "VZERO/AliVZEROv7.h"
#endif

enum PprRun_t 
{
    test50,
    kParam_8000,   kParam_4000,  kParam_2000, 
    kHijing_cent1, kHijing_cent2, 
    kHijing_per1,  kHijing_per2, kHijing_per3, kHijing_per4,  kHijing_per5,
    kHijing_jj25,  kHijing_jj50, kHijing_jj75, kHijing_jj100, kHijing_jj200, 
    kHijing_gj25,  kHijing_gj50, kHijing_gj75, kHijing_gj100, kHijing_gj200,
    kHijing_pA, kPythia6, 
    kPythia6Jets20_24,   kPythia6Jets24_29,   kPythia6Jets29_35,
    kPythia6Jets35_42,   kPythia6Jets42_50,   kPythia6Jets50_60,
    kPythia6Jets60_72,   kPythia6Jets72_86,   kPythia6Jets86_104,
    kPythia6Jets104_125, kPythia6Jets125_150, kPythia6Jets150_180,
    kD0PbPb5500, kCharmSemiElPbPb5500, kBeautySemiElPbPb5500,
    kCocktailTRD, kPyJJ, kPyGJ, 
    kMuonCocktailCent1, kMuonCocktailPer1, kMuonCocktailPer4, 
    kMuonCocktailCent1HighPt, kMuonCocktailPer1HighPt, kMuonCocktailPer4HighPt,
    kMuonCocktailCent1Single, kMuonCocktailPer1Single, kMuonCocktailPer4Single,
    kFlow_2_2000, kFlow_10_2000, kFlow_6_2000, kFlow_6_5000,
    kHIJINGplus, kStarlight, kRunMax
};

const char* pprRunName[] = {
    "test50",
    "kParam_8000",   "kParam_4000",  "kParam_2000", 
    "kHijing_cent1", "kHijing_cent2", 
    "kHijing_per1",  "kHijing_per2", "kHijing_per3", "kHijing_per4",  
    "kHijing_per5",
    "kHijing_jj25",  "kHijing_jj50", "kHijing_jj75", "kHijing_jj100", 
    "kHijing_jj200", 
    "kHijing_gj25",  "kHijing_gj50", "kHijing_gj75", "kHijing_gj100", 
    "kHijing_gj200", "kHijing_pA", "kPythia6", 
    "kPythia6Jets20_24",   "kPythia6Jets24_29",   "kPythia6Jets29_35",
    "kPythia6Jets35_42",   "kPythia6Jets42_50",   "kPythia6Jets50_60",
    "kPythia6Jets60_72",   "kPythia6Jets72_86",   "kPythia6Jets86_104",
    "kPythia6Jets104_125", "kPythia6Jets125_150", "kPythia6Jets150_180",
    "kD0PbPb5500", "kCharmSemiElPbPb5500", "kBeautySemiElPbPb5500",
    "kCocktailTRD", "kPyJJ", "kPyGJ", 
    "kMuonCocktailCent1", "kMuonCocktailPer1", "kMuonCocktailPer4",  
    "kMuonCocktailCent1HighPt", "kMuonCocktailPer1HighPt", "kMuonCocktailPer4HighPt",
    "kMuonCocktailCent1Single", "kMuonCocktailPer1Single", "kMuonCocktailPer4Single",
    "kFlow_2_2000", "kFlow_10_2000", "kFlow_6_2000", "kFlow_6_5000", "kHIJINGplus", "kStarlight"
};

enum PprTrigConf_t
{
    kDefaultPPTrig, kDefaultPbPbTrig
};

const char * pprTrigConfName[] = {
    "p-p","Pb-Pb"
};

// This part for configuration    

static PprRun_t srun = kStarlight;
static AliMagF::BMap_t smag = AliMagF::k5kG;
static AliMagF::BeamType_t beamType = AliMagF::kBeamTypeAA;

// Geterator, field, beam energy
// static AliMagF::Mag_t         mag      =  AliMagF::k5kG;
static Float_t       energy   = 2760.0; // energy in CMS
static Float_t       beamenergy = 1380.0; // energy of beam - needed for field map
static Int_t         runNumber = 0;
static Int_t         eventNumber = 0;
static PprTrigConf_t strig = kDefaultPbPbTrig; // default pp trigger configuration
static UInt_t seed = 0;  
//========================//
// Set Random Number seed //
//========================//
// TDatime dt;
// static UInt_t seed    = dt.Get();

// Comment line 
static TString  comment;

// Functions
Float_t EtaToTheta(Float_t arg);
AliGenerator* GeneratorFactory(PprRun_t srun);
void ProcessEnvironmentVars();

void Config()
{
    // ThetaRange is (0., 180.). It was (0.28,179.72) 7/12/00 09:00
    // Theta range given through pseudorapidity limits 22/6/2001

    // Get settings from environment variables
    ProcessEnvironmentVars();

    Int_t NEventsPerSegment = 100; 

    // Set Random Number seed
    //    gRandom->SetSeed(sseed);
    gRandom->SetSeed(seed);
    cout<<"Seed for random number generation= "<<gRandom->GetSeed()<<endl; 

   // libraries required by geant321
#if defined(__CINT__)
    gSystem->Load("liblhapdf");
    gSystem->Load("libEGPythia6");
    gSystem->Load("libpythia6");
    gSystem->Load("libAliPythia6");
    gSystem->Load("libgeant321");
    
#endif

    new     TGeant3TGeo("C++ Interface to Geant3");

    AliRunLoader* rl=0x0;

    AliLog::Message(AliLog::kInfo, "Creating Run Loader", "", "", "Config()"," ConfigPPR.C", __LINE__);

    rl = AliRunLoader::Open("galice.root",
			    AliConfig::GetDefaultEventFolderName(),
			    "recreate");
    if (rl == 0x0)
      {
	gAlice->Fatal("Config.C","Can not instatiate the Run Loader");
	return;
      }
    // Added these 2 (JN 120511) 
    rl->LoadKinematics("RECREATE"); 
    rl->MakeTree("E"); 
    // 

    rl->SetCompressionLevel(2);
    rl->SetNumberOfEventsPerFile(NEventsPerSegment);
    gAlice->SetRunLoader(rl);

    // Set the trigger configuration
    AliSimulation::Instance()->SetTriggerConfig(pprTrigConfName[strig]);
    cout<<"Trigger configuration is set to  "<<pprTrigConfName[strig]<<endl;
    // This is from CM 3-Jun-2011 
    // AliSimulation::Instance()->SetTriggerConfig("");

    //
    // Set External decayer
    AliDecayer *decayer = new AliDecayerPythia();
    decayer->SetForceDecay(kAll);
    decayer->Init();
    gMC->SetExternalDecayer(decayer);

    //
    //=======================================================================
    //
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

    // Generator Configuration
    AliGenerator* gener = GeneratorFactory(srun);

    AliGenReaderTreeK* reader = new AliGenReaderTreeK();
    reader->SetFileName("galice.root");
    reader->AddDir("./input");
    AliGenExtFile* ext = (AliGenExtFile*) gener;		
    ext->SetReader(reader);		
    ext->Init();
    printf("eventNumber = %5d \n", eventNumber);
    Int_t off = (eventNumber - 1) * NEventsPerSegment;	
    printf("offset is %5d \n", off); 
    for (Int_t i = 0; i < off; i++) reader->NextEvent();		

    if (smag == AliMagF::k2kG) {
	comment = comment.Append(" | L3 field 0.2 T");
    } else if (smag == AliMagF::k5kG) {
	comment = comment.Append(" | L3 field 0.5 T");
    }
     
    printf("\n \n Comment: %s \n \n", comment.Data());
    
// Field
    TGeoGlobalMagField::Instance()->SetField
      (new AliMagF("Maps","Maps", -1., -1., smag,beamType,beamenergy));
    rl->CdGAFile();
//
    Int_t   iABSO   = 1;
    Int_t   iDIPO   = 1;
    Int_t   iFMD    = 0;
    Int_t   iFRAME  = 1;
    Int_t   iHALL   = 1;
    Int_t   iITS    = 1;
    Int_t   iMAG    = 1;
    Int_t   iMUON   = 0;
    Int_t   iPHOS   = 0;
    Int_t   iPIPE   = 1;
    Int_t   iPMD    = 0;
    Int_t   iHMPID  = 0;
    Int_t   iSHIL   = 1;
    Int_t   iT0     = 0;
    Int_t   iTOF    = 1;
    Int_t   iTPC    = 1;
    Int_t   iTRD    = 1;
    Int_t   iZDC    = 0;
    Int_t   iEMCAL  = 1;
    Int_t   iVZERO  = 1;
    Int_t   iACORDE    = 0;

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
    //=================== PHOS parameters ===========================

    if (iPHOS)
    {
        AliPHOS *PHOS = new AliPHOSv1("PHOS", "IHEP");
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
        //  AliEMCAL *EMCAL = new AliEMCALv2("EMCAL", "EMCAL_COMPLETE");
        AliEMCAL *EMCAL = new AliEMCALv1("EMCAL", "EMCAL_FIRSTYEARV1");    
    }

     if (iACORDE)
    {
        //=================== ACORDE parameters ============================
        AliACORDE *ACORDE = new AliACORDEv1("ACORDE", "normal ACORDE");
    }

     if (iVZERO)
    {
        //=================== VZERO parameters ============================
        AliVZERO *VZERO = new AliVZEROv7("VZERO", "normal VZERO");
    }
 
             
}

Float_t EtaToTheta(Float_t arg){
  return (180./TMath::Pi())*2.*atan(exp(-arg));
}


AliGenerator* GeneratorFactory(PprRun_t srun) {
  
  AliGenerator * gGener = 0x0;
  switch (srun) {
  case kStarlight:
    {
      AliGenExtFile* gener = new AliGenExtFile(-1);
      //      AliGenReaderSL* reader = new AliGenReaderSL();
      //      reader->SetFileName("starlight_rho0.out"); 
      //      reader->SetFormat(3);
      //      gener->SetReader(reader);
      //      gGener = gener;
      gener->SetVertexSmear(kPerEvent);      	
      gener->SetEnergyCMS(energy); 
      gener->SetProjectile("A", 208, 82); 
      gener->SetTarget    ("A", 208, 82); 
      gGener = gener; 
    }
    break;
    default: break;
  }
  
  return gGener;
}


void ProcessEnvironmentVars()
{
    // Run type
    if (gSystem->Getenv("CONFIG_RUN_TYPE")) {
      for (Int_t iRun = 0; iRun < kRunMax; iRun++) {
	if (strcmp(gSystem->Getenv("CONFIG_RUN_TYPE"), pprRunName[iRun])==0) {
	  srun = (PprRun_t)iRun;
	  cout<<"Run type set to "<<pprRunName[iRun]<<endl;
	}
      }
    }

    // Field
    //    if (gSystem->Getenv("CONFIG_FIELD")) {
    //      for (Int_t iField = 0; iField < kFieldMax; iField++) {
    //	if (strcmp(gSystem->Getenv("CONFIG_FIELD"), pprField[iField])==0) {
    //	  mag = (Mag_t)iField;
    //	  cout<<"Field set to "<<pprField[iField]<<endl;
    //	}
    //      }
    //    }

    // Energy
    if (gSystem->Getenv("CONFIG_ENERGY")) {
      energy = atoi(gSystem->Getenv("CONFIG_ENERGY"));
      cout<<"Energy set to "<<energy<<" GeV"<<endl;
    }

    // Random Number seed
    if (gSystem->Getenv("CONFIG_SEED")) {
      seed = atoi(gSystem->Getenv("CONFIG_SEED"));
    }

    // Run number
    if (gSystem->Getenv("DC_RUN")) {
      runNumber = atoi(gSystem->Getenv("DC_RUN"));
    }
    // Event number
    if (gSystem->Getenv("DC_EVENT")) {
      eventNumber = atoi(gSystem->Getenv("DC_EVENT"));
    }

}
