//
// Configuration for the single-particle generator for PHOS efficiencies
//


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
#include "PYTHIA6/PythiaProcesses.h"
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
#include "TDPMjet/AliGenDPMjet.h"
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
#include "TRD/AliTRDgeometry.h"
#include "FMD/AliFMDv1.h"
#include "MUON/AliMUONv1.h"
#include "PHOS/AliPHOSv1.h"
#include "PHOS/AliPHOSSimParam.h"
#include "PMD/AliPMDv1.h"
#include "T0/AliT0v1.h"
#include "EMCAL/AliEMCALv2.h"
#include "ACORDE/AliACORDEv1.h"
#include "VZERO/AliVZEROv7.h"
#endif


enum PDC06Proc_t
  {
    kPi02gamma, kEta2gamma, kOmegaPi0Gamma, kOmegaPipPimPi0, kRunMax
  };

const char * pprRunName[] = {
  "kPi02gamma", "kEta2gamma", "kOmegaPi0Gamma", "kOmegaPipPimPi0"
};

enum Detector_t {kPHOS, kEMCAL};

//--- Functions ---
void ProcessEnvironmentVars();

// This part for configuration
static PDC06Proc_t     proc      = kPi02gamma;
static Detector_t      detector  = kEMCAL;
static AliMagF::BMap_t smag      = AliMagF::k5kG;
static Float_t         energy    = 900; // energy in CMS
static Int_t           runNumber = 104000;
//========================//
// Set Random Number seed //
//========================//
TDatime dt;
static UInt_t seed    = dt.Get();

// Comment line
static TString comment;

//-----------------------------------------------------------------------------
void Config()
{

  // Get settings from environment variables
  ProcessEnvironmentVars();

  gSystem->Load("liblhapdf.so");      // Parton density functions
  gSystem->Load("libEGPythia6.so");   // TGenerator interface
  gSystem->Load("libpythia6.so");     // Pythia
  gSystem->Load("libAliPythia6.so");  // ALICE specific implementations


  // libraries required by geant321
#if defined(__CINT__)
  gSystem->Load("liblhapdf");
  gSystem->Load("libEGPythia6");
  gSystem->Load("libpythia6");
  gSystem->Load("libAliPythia6");
  gSystem->Load("libgeant321");
#endif

  new TGeant3TGeo("C++ Interface to Geant3");

  // Output every 100 tracks
  ((TGeant3*)gMC)->SetSWIT(4,100);

  //=======================================================================

  // Run loader
  AliRunLoader* rl=0x0;
  rl = AliRunLoader::Open("galice.root",
			  AliConfig::GetDefaultEventFolderName(),
			  "recreate");
  if (rl == 0x0)
    {
      gAlice->Fatal("Config.C","Can not instatiate the Run Loader");
      return;
    }
  rl->SetCompressionLevel(2);
  rl->SetNumberOfEventsPerFile(1000);
  gAlice->SetRunLoader(rl);

  // Set the trigger configuration
  gAlice->SetTriggerDescriptor("p-p");
  cout<<"Trigger configuration is set to  p-p "<<endl;

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

  //======================//
  // Set External decayer //
  //======================//
  TVirtualMCDecayer* decayer = new AliDecayerPythia();
  // DECAYS
  //

  decayer->Init();
  gMC->SetExternalDecayer(decayer);

  //=========================//
  // Generator Configuration //
  //=========================//
  Double_t phiMin,phiMax,etaMin,etaMax;
  if      (detector == kPHOS ) {
    phiMin = 180. ; phiMax = 360;
    etaMin = -0.25; etaMax = +0.25;
  }
  else if (detector == kEMCAL) {
    phiMin = 35. ; phiMax = 215;
    etaMin = -1.0; etaMax = +1.0;
  }

  AliGenBox *gener = new AliGenBox(1);
  gener->SetMomentumRange(0., 10.);
  gener->SetPhiRange(phiMin,phiMax);
  Float_t thmin = EtaToTheta(etaMax);   // theta min. <---> eta max
  Float_t thmax = EtaToTheta(etaMin);   // theta max. <---> eta min 
  gener->SetThetaRange(thmin,thmax);
 
  if (proc ==   kPi02gamma) {
    gener->SetPart(111);
  } else if (proc == kEta2gamma) {
    gener->SetPart(221);
  } else if (proc == kOmegaPi0Gamma) {
    gener->SetPart(223);
  }

  // PRIMARY VERTEX

  gener->SetOrigin(0., 0., 0.);    // vertex position

  // Size of the interaction diamond
  // Longitudinal
  Float_t sigmaz  = 5.4 / TMath::Sqrt(2.); // [cm]
  if (energy == 900)
    sigmaz  = 10.5 / TMath::Sqrt(2.); // [cm]

  // Transverse
  Float_t betast  = 10;                 // beta* [m]
  Float_t eps     = 3.75e-6;            // emittance [m]
  Float_t gamma   = energy / 2.0 / 0.938272;   // relativistic gamma [1]
  Float_t sigmaxy = TMath::Sqrt(eps * betast / gamma) / TMath::Sqrt(2.) * 100.;  // [cm]
  printf("\n \n Diamond size x-y: %10.3e z: %10.3e\n \n", sigmaxy, sigmaz);

  gener->SetSigma(sigmaxy, sigmaxy, sigmaz);      // Sigma in (X,Y,Z) (cm) on IP position
  gener->SetCutVertexZ(3.);        // Truncate at 3 sigma
  gener->SetVertexSmear(kPerEvent);

  gener->Init();

  comment.Append(pprRunName[proc]);

  if (detector == kPHOS) {
    comment.Append(" in PHOS");
  }
  else if (detector == kEMCAL) {
    comment.Append(" in EMCAL");
  }

  if (smag == AliMagF::k2kG) {
    comment = comment.Append(" | L3 field 0.2 T");
  } else if (smag == AliMagF::k5kG) {
    comment = comment.Append(" | L3 field 0.5 T");
  }

  printf("\n \n Comment: %s \n \n", comment.Data());

  // Field
  TGeoGlobalMagField::Instance()->SetField(new AliMagF("Maps","Maps", -1., -1., smag));

  rl->CdGAFile();

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

      AliITS *ITS  = new AliITSv11Hybrid("ITS","ITS v11Hybrid");
      ITS->DisableStepManager();
    }

  if (iTPC)
    {
      //============================ TPC parameters =====================

      AliTPC *TPC = new AliTPCv2("TPC", "Default");
      TPC->DisableStepManager();
    }


  if (iTOF) {
    //=================== TOF parameters ============================

    AliTOF *TOF = new AliTOFv6T0("TOF", "normal TOF");
    TOF->DisableStepManager();
  }


  if (iHMPID)
    {
      //=================== HMPID parameters ===========================

      AliHMPID *HMPID = new AliHMPIDv3("HMPID", "normal HMPID");
      HMPID->DisableStepManager();

    }


  if (iZDC)
    {
      //=================== ZDC parameters ============================

      AliZDC *ZDC = new AliZDCv3("ZDC", "normal ZDC");
      ZDC->DisableStepManager();
    }

  if (iTRD)
    {
      //=================== TRD parameters ============================

      AliTRD *TRD = new AliTRDv1("TRD", "TRD slow simulator");
      TRD->DisableStepManager();
      AliTRDgeometry *geoTRD = TRD->GetGeometry();
      // Partial geometry: modules at 0,8,9,17
      // Partial geometry: modules at 1,7,10,16 expected for 2009
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

    }

  if (iFMD)
    {
      //=================== FMD parameters ============================

      AliFMD *FMD = new AliFMDv1("FMD", "normal FMD");
      FMD->DisableStepManager();
    }

  if (iMUON)
    {
      //=================== MUON parameters ===========================
      // New MUONv1 version (geometry defined via builders)

      AliMUON *MUON = new AliMUONv1("MUON", "default");
      MUON->DisableStepManager();
    }

  if (iPHOS)
    {
      //=================== PHOS parameters ===========================

      AliPHOS *PHOS = new AliPHOSv1("PHOS", "Modules123");

    }


  if (iPMD)
    {
      //=================== PMD parameters ============================

      AliPMD *PMD = new AliPMDv1("PMD", "normal PMD");
      PMD->DisableStepManager();
    }

  if (iT0)
    {
      //=================== T0 parameters ============================
      AliT0 *T0 = new AliT0v1("T0", "T0 Detector");
      T0->DisableStepManager();
    }

  if (iEMCAL)
    {
      //=================== EMCAL parameters ============================

      //AliEMCAL *EMCAL = new AliEMCALv2("EMCAL", "SHISH_77_TRD1_2X2_FINAL_110DEG");
      AliEMCAL *EMCAL = new AliEMCALv2("EMCAL",   "EMCAL_COMPLETE");
    }

  if (iACORDE)
    {
      //=================== ACORDE parameters ============================

      AliACORDE *ACORDE = new AliACORDEv1("ACORDE", "normal ACORDE");
      ACORDE->DisableStepManager();
    }

  if (iVZERO)
    {
      //=================== ACORDE parameters ============================

      AliVZERO *VZERO = new AliVZEROv7("VZERO", "normal VZERO");
      VZERO->DisableStepManager();
    }
}

//-----------------------------------------------------------------------------
void ProcessEnvironmentVars()
{
  cout << "Processing environment variables" << endl;
  // Random Number seed
  if (gSystem->Getenv("CONFIG_SEED")) {
    seed = atoi(gSystem->Getenv("CONFIG_SEED"));
  }

  gRandom->SetSeed(seed);
  cout<<"Seed for random number generation= "<<seed<<endl;

  // Run Number
  if (gSystem->Getenv("DC_RUN")) {
    runNumber = atoi(gSystem->Getenv("DC_RUN"));
  }
  cout<<"Run number "<<runNumber<<endl;

  // Run type
  if (gSystem->Getenv("DC_RUN_TYPE")) {
    for (Int_t iRun = 0; iRun < kRunMax; iRun++) {
      if (strcmp(gSystem->Getenv("DC_RUN_TYPE"), pprRunName[iRun])==0) {
	proc = (PDC06Proc_t)iRun;
	cout<<"Run type set to "<<pprRunName[iRun]<<endl;
      }
    }
  } else {
    cout << "DC_RUN_TYPE is not defined" << endl;
  }

}

//-----------------------------------------------------------------------------
Float_t EtaToTheta(Float_t arg){
  return (180./TMath::Pi())*2.*atan(exp(-arg));
}
