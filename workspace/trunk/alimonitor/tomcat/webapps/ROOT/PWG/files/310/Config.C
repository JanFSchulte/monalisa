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

void Config()
{

    Int_t NEventsPerSegment = 200; 

    // Read environment variables 
    // Run type
    if (gSystem->Getenv("CONFIG_RUN_TYPE")) {
      for (Int_t iRun = 0; iRun < kRunMax; iRun++) {
	if (strcmp(gSystem->Getenv("CONFIG_RUN_TYPE"), pprRunName[iRun])==0) {
	  srun = (PprRun_t)iRun;
	  cout<<"Run type set to "<<pprRunName[iRun]<<endl;
	}
      }
    }
    // Energy 
    if (gSystem->Getenv("CONFIG_ENERGY")) energy = atoi(gSystem->Getenv("CONFIG_ENERGY"));
    cout<<"Energy set to "<<energy<<" GeV"<<endl;
    // Random seed 
    if (gSystem->Getenv("CONFIG_SEED")) seed = atoi(gSystem->Getenv("CONFIG_SEED"));
    gRandom->SetSeed(seed);
    cout<<"Seed for random number generation= "<<gRandom->GetSeed()<<endl; 
    // Run Number 
    if (gSystem->Getenv("DC_RUN")) runNumber = atoi(gSystem->Getenv("DC_RUN"));
    cout<<"Run Number: "<<runNumber<<endl; 
    // Event Number 
    if (gSystem->Getenv("DC_EVENT")) eventNumber = atoi(gSystem->Getenv("DC_EVENT"));
    cout<<"Event Number: "<<eventNumber<<endl; 

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

    Int_t nrun = 0; 
    if( runNumber == 167806 || runNumber == 168175 || runNumber == 168512 ){
      nrun = 0;
    } elseif ( runNumber == 167807 || runNumber == 168181 || runNumber == 168514 ) {
      nrun = 1;
    } elseif ( runNumber == 167808 || runNumber == 168203 || runNumber == 168777 ) {
      nrun = 2;
    } elseif ( runNumber == 167813 || runNumber == 168204 || runNumber == 168826 ) {
      nrun = 3;
    } elseif ( runNumber == 167818 || runNumber == 168205 || runNumber == 168828 ) {
      nrun = 4;
    } elseif ( runNumber == 167902 || runNumber == 168206 || runNumber == 168984 ) {
      nrun = 5;
    } elseif ( runNumber == 167903 || runNumber == 168207 || runNumber == 168988 ) {
      nrun = 6;
    } elseif ( runNumber == 167915 || runNumber == 168208 || runNumber == 168992 ) {
      nrun = 7;
    } elseif ( runNumber == 167920 || runNumber == 168212 || runNumber == 169035 ) {
      nrun = 8;
    } elseif ( runNumber == 167921 || runNumber == 168213 || runNumber == 169040 ) {
      nrun = 9;
    } elseif ( runNumber == 167985 || runNumber == 168310 || runNumber == 169044 ) {
      nrun = 10;
    } elseif ( runNumber == 167986 || runNumber == 168311 || runNumber == 169045 ) {
      nrun = 11;
    } elseif ( runNumber == 167987 || runNumber == 168318 || runNumber == 169091 ) {
      nrun = 12;
    } elseif ( runNumber == 167988 || runNumber == 168322 || runNumber == 169094 ) {
      nrun = 13;
    } elseif ( runNumber == 168066 || runNumber == 168325 || runNumber == 169099 ) {
      nrun = 14;
    } elseif ( runNumber == 168068 || runNumber == 168341 || runNumber == 169138 ) {
      nrun = 15;
    } elseif ( runNumber == 168069 || runNumber == 168342 || runNumber == 169143 ) {
      nrun = 16;
    } elseif ( runNumber == 168076 || runNumber == 168356 || runNumber == 169144 ) {
      nrun = 17;
    } elseif ( runNumber == 168104 || runNumber == 168361 || runNumber == 169145 ) {
      nrun = 18;
    } elseif (runNumber ==  168105 || runNumber == 168362 || runNumber == 169148 ) {
      nrun = 19;
    } elseif (runNumber ==  168107 || runNumber == 168458 || runNumber == 169156 ) {
      nrun = 20;
    } elseif (runNumber ==  168108 || runNumber == 168460 || runNumber == 169160 ) {
      nrun = 21;
    } elseif (runNumber ==  168115 || runNumber == 168461 || runNumber == 169167 ) {
      nrun = 22;
    } elseif (runNumber ==  168171 || runNumber == 168464 || runNumber == 169236 ) {
      nrun = 23;
    } elseif (runNumber ==  168172 || runNumber == 168467 || runNumber == 169238 ) {
      nrun = 24;
    } elseif (runNumber ==  168173 || runNumber == 168511 ) {
      nrun = 25;
    } else {
      cout<<" Run not found in Config.C!!! "<<endl;
    } 
 
    Int_t off = nrun*20000  + (eventNumber - 1) * NEventsPerSegment;	
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
    Int_t iABSO  = 1;
    Int_t iACORDE= 0;
    Int_t iDIPO  = 1;
    Int_t iEMCAL = 1;
    Int_t iFMD   = 1;
    Int_t iFRAME = 1;
    Int_t iHALL  = 1;
    Int_t iITS   = 1;
    Int_t iMAG   = 1;
    Int_t iMUON  = 1;
    Int_t iPHOS  = 1;
    Int_t iPIPE  = 1;
    Int_t iPMD   = 1;
    Int_t iHMPID = 1;
    Int_t iSHIL  = 1;
    Int_t iT0    = 1;
    Int_t iTOF   = 1;
    Int_t iTPC   = 1;
    Int_t iTRD   = 1;
    Int_t iVZERO = 1;
    Int_t iZDC   = 1;

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

	// AliITS *ITS  = new AliITSv11Hybrid("ITS","ITS v11Hybrid");
	AliITS *ITS  = new AliITSv11("ITS","ITS v11");
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

        // AliTRD *TRD = new AliTRDv1("TRD", "TRD slow simulator");

        AliTRD *TRD = new AliTRDv1("TRD", "TRD slow simulator");
        AliTRDgeometry *geoTRD = TRD->GetGeometry();
	// Partial geometry: modules at 0,1,7,8,9,16,17
	// starting at 3h in positive direction
	geoTRD->SetSMstatus(2,0);
	geoTRD->SetSMstatus(3,0);
	geoTRD->SetSMstatus(4,0);
        geoTRD->SetSMstatus(5,0);
	geoTRD->SetSMstatus(6,0);
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
        // AliMUON *MUON = new AliMUONv1("MUON", "default");

        AliMUON *MUON = new AliMUONv1("MUON", "default");
	// activate trigger efficiency by cells
	MUON->SetTriggerEffCells(1); // not needed if raw masks 
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
        // AliEMCAL *EMCAL = new AliEMCALv1("EMCAL", "EMCAL_FIRSTYEARV1");    

        AliEMCAL *EMCAL = new AliEMCALv2("EMCAL", "EMCAL_FIRSTYEARV1");
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
      // gener->SetVertexSmear(kPerEvent);      	
      // gener->SetEnergyCMS(energy); 

      // Size of the interaction diamond
      // Longitudinal
      Float_t sigmaz  = 5.4 / TMath::Sqrt(2.); // [cm]
  
      //
      // Transverse
      Float_t betast  = 3.5;                      // beta* [m]
      Float_t eps     = 3.75e-6;                   // emittance [m]
      Float_t gamma   = energy / 2.0 / 0.938272;  // relativistic gamma [1]
      Float_t sigmaxy = TMath::Sqrt(eps * betast / gamma) / TMath::Sqrt(2.) * 100.;  // [cm]

      printf("\n \n Diamond size x-y: %10.3e z: %10.3e\n \n", sigmaxy, sigmaz);

      gener->SetSigma(sigmaxy, sigmaxy, sigmaz);      // Sigma in (X,Y,Z) (cm) on IP position
      gener->SetVertexSmear(kPerEvent);

      gener->SetProjectile("A", 208, 82); 
      gener->SetTarget    ("A", 208, 82); 
      gGener = gener; 
    }
    break;
    default: break;
  }
  
  return gGener;
}


