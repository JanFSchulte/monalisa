//
// Configuration for the Physics Data Challenge 2006
//
// Physics Run composition (Presented by A.Dainese, 21/03/06 
//
// Assuming inel = 70 mb (PPR v.1, p.64)
//
// 84.98% of MSEL=0 events (including diffractive) with 
// QQbar switched off (these events will include injected J/psi) => kPyMbNoHvq
// 
// 14.14% of MSEL=1 events with ccbar (in 4 subsamples) => kCharmpp14000wmi 
//     bin 1 25% (3.535%): 2.76 < pthard < 3 GeV/c 
//     bin 2 40% (5.656%): 3 < pthard < 4 GeV/c 
//     bin 3 29% (4.101%): 4 < pthard < 8 GeV/c 
//     bin 4 6%  (0.848%):  pthard > 8 GeV/c 
//
// 0.73% of MSEL=1 events with bbbar (in 4 subsamples) => kBeautypp14000wmi
//     bin 1 5%  (0.037%):   2.76 < pthard < 4 GeV/c
//     bin 2 31% (0.226%):  4 < pthard < 6 GeV/c
//     bin 3 28% (0.204%):  6 < pthard < 8 GeV/c
//     bin 4 36% (0.263%):  pthard >8 GeV/c
//
// 0.075% of MSEL=0 events with QQbar switched off and 1 Omega-    => kPyOmegaMinus
// 0.075% of MSEL=0 events with QQbar switched off and 1 OmegaBar+ => kPyOmegaPlus

// One can use the configuration macro in compiled mode by
// root [0] gSystem->Load("libgeant321");
// root [0] gSystem->SetIncludePath("-I$ROOTSYS/include -I$ALICE_ROOT/include\
//                   -I$ALICE_ROOT -I$ALICE/geant3/TGeant3");
// root [0] .x grun.C(1,"Config_PDC06.C++")

#if !defined(__CINT__) || defined(__MAKECINT__)
#include <Riostream.h>
#include <TRandom.h>
#include <TDatime.h>
#include <TSystem.h>
#include <TVirtualMC.h>
#include <TGeant3TGeo.h>
#include "EVGEN/AliGenCocktail.h"
#include "EVGEN/AliGenParam.h"
#include "EVGEN/AliGenMUONlib.h"
#include "STEER/AliRunLoader.h"
#include "STEER/AliRun.h"
#include "STEER/AliConfig.h"
#include "PYTHIA6/AliDecayerPythia.h"
#include "PYTHIA6/AliGenPythia.h"
#include "STEER/AliMagFMaps.h"
#include "STRUCT/AliBODY.h"
#include "STRUCT/AliMAG.h"
#include "STRUCT/AliABSOv3.h"
#include "STRUCT/AliDIPOv3.h"
#include "STRUCT/AliHALLv3.h"
#include "STRUCT/AliFRAMEv2.h"
#include "STRUCT/AliSHILv3.h"
#include "STRUCT/AliPIPEv3.h"
#include "ITS/AliITSgeom.h"
#include "ITS/AliITSvPPRasymmFMD.h"
#include "TPC/AliTPCv2.h"
#include "TOF/AliTOFv6T0.h"
#include "HMPID/AliHMPIDv2.h"
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


enum PDC06Proc_t 
{
//--- Heavy Flavour Production ---
  kCharmPbPb5500,  kCharmpPb8800,  kCharmpp14000,  kCharmpp14000wmi,
  kD0PbPb5500,     kD0pPb8800,     kD0pp14000,
  kDPlusPbPb5500,  kDPluspPb8800,  kDPluspp14000,
  kBeautyPbPb5500, kBeautypPb8800, kBeautypp14000, kBeautypp14000wmi, 
// -- Pythia Mb
  kPyMbNoHvq, kPyOmegaPlus, kPyOmegaMinus, kRunMax
};

const char * pprRunName[] = {
  "kCharmPbPb5500",  "kCharmpPb8800",  "kCharmpp14000",  "kCharmpp14000wmi",
  "kD0PbPb5500",     "kD0pPb8800",     "kD0pp14000",
  "kDPlusPbPb5500",  "kDPluspPb8800",  "kDPluspp14000",
  "kBeautyPbPb5500", "kBeautypPb8800", "kBeautypp14000", "kBeautypp14000wmi", 
  "kPyMbNoHvq", "kPyOmegaPlus", "kPyOmegaMinus"
};


//--- Decay Mode ---
enum DecayHvFl_t 
{
  kNature,  kHadr, kSemiEl, kSemiMu, kBtoJPSItoEle
};
//--- Rapidity Cut ---
enum YCut_t
{
  kFull, kBarrel, kMuonArm
};
//--- Magnetic Field ---
enum Mag_t
{
    k2kG, k4kG, k5kG
};

//--- Trigger config ---
enum TrigConf_t
{
    kDefaultPPTrig, kDefaultPbPbTrig
};

const char * TrigConfName[] = {
    "p-p","Pb-Pb"
};

enum PprGeo_t
  {
    kHoles, kNoHoles
  };

//--- Functions ---
AliGenPythia *PythiaHVQ(PDC06Proc_t proc);
AliGenerator *MbCocktail();
AliGenerator *PyMbTriggered(Int_t pdg);
void ProcessEnvironmentVars();

// This part for configuration
static PDC06Proc_t   proc     = kPyMbNoHvq;
static DecayHvFl_t   decHvFl  = kNature; 
static YCut_t        ycut     = kFull;
static Mag_t         mag      = k5kG; 
static TrigConf_t    trig     = kDefaultPPTrig; // default pp trigger configuration
static PprGeo_t geo = kHoles;
static Int_t         runNumber= 0; 
//========================//
// Set Random Number seed //
//========================//
TDatime dt;
static UInt_t seed    = dt.Get();

// nEvts = -1  : you get 1 QQbar pair and all the fragmentation and 
//               decay chain
// nEvts = N>0 : you get N charm / beauty Hadrons 
Int_t nEvts = -1; 
// stars = kTRUE : all heavy resonances and their decay stored
//       = kFALSE: only final heavy hadrons and their decays stored
Bool_t stars = kTRUE;

// To be used only with kCharmpp14000wmi and kBeautypp14000wmi
// To get a "reasonable" agreement with MNR results, events have to be 
// generated with the minimum ptHard set to 2.76 GeV.
// To get a "perfect" agreement with MNR results, events have to be 
// generated in four ptHard bins with the following relative 
// normalizations:
//  CHARM
// 2.76-3 GeV: 25%
//    3-4 GeV: 40%
//    4-8 GeV: 29%
//     >8 GeV:  6%
//  BEAUTY
// 2.76-4 GeV:  5% 
//    4-6 GeV: 31%
//    6-8 GeV: 28%
//     >8 GeV: 36%
Float_t ptHardMin =  2.76;
Float_t ptHardMax = -1.;


// Comment line
static TString comment;

void Config()
{
 

  // Get settings from environment variables
  ProcessEnvironmentVars();

  // libraries required by geant321
#if defined(__CINT__)
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

  // Run number
  gAlice->SetRunNumber(runNumber);
  
  // Set the trigger configuration
  gAlice->SetTriggerDescriptor(TrigConfName[trig]);
  cout<<"Trigger configuration is set to  "<<TrigConfName[trig]<<endl;

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
  switch(decHvFl) {
  case kNature:
    decayer->SetForceDecay(kAll);
    break;
  case kHadr:
    decayer->SetForceDecay(kHadronicD);
    break;
  case kSemiEl:
    decayer->SetForceDecay(kSemiElectronic);
    break;
  case kSemiMu:
    decayer->SetForceDecay(kSemiMuonic);
    break;
  case kBtoJPSItoEle:
    decayer->SetForceDecay(kBJpsiDiElectron);
    break;
  }
  decayer->Init();
  gMC->SetExternalDecayer(decayer);

  //=========================//
  // Generator Configuration //
  //=========================//
  AliGenerator* gener = 0x0;
  
  if (proc <=   kBeautypp14000wmi) {
      AliGenPythia *pythia = PythiaHVQ(proc);
      // FeedDown option
      pythia->SetFeedDownHigherFamily(kFALSE);
      // Stack filling option
      if(!stars) pythia->SetStackFillOpt(AliGenPythia::kParentSelection);
      // Set Count mode
      if(nEvts>0) pythia->SetCountMode(AliGenPythia::kCountParents);
      //
      // DECAYS
      //  
      switch(decHvFl) {
      case kNature:
	  pythia->SetForceDecay(kAll);
	  break;
      case kHadr:
	  pythia->SetForceDecay(kHadronicD);
	  break;
      case kSemiEl:
	  pythia->SetForceDecay(kSemiElectronic);
	  break;
      case kSemiMu:
	  pythia->SetForceDecay(kSemiMuonic);
	  break;
      case kBtoJPSItoEle:
	  pythia->SetForceDecay(kBJpsiDiElectron);
	  break;
      }
      //
      // GEOM & KINE CUTS
      //
      pythia->SetMomentumRange(0,99999999);
      pythia->SetPhiRange(0., 360.);
      pythia->SetThetaRange(0,180);
      switch(ycut) {
      case kFull:
	  pythia->SetYRange(-999,999);
	  break;
      case kBarrel:
	  pythia->SetYRange(-2,2);
	  break;
      case kMuonArm:
	  pythia->SetYRange(1,6);
	  break;
      }
      gener = pythia;
  } else if (proc == kPyMbNoHvq) {
      gener = MbCocktail();
  } else if (proc == kPyOmegaMinus) {
      gener = PyMbTriggered(3334);
  } else if (proc == kPyOmegaPlus) {
      gener = PyMbTriggered(-3334);
  }
  
  

  // PRIMARY VERTEX

  gener->SetOrigin(0., 0., 0.);    // vertex position

  // Size of the interaction diamond
  // Longitudinal
  Float_t sigmaz  = 7.55 / TMath::Sqrt(2.); // [cm]

  // Transverse
  Float_t betast  = 10;                 // beta* [m]
  Float_t eps     = 3.75e-6;            // emittance [m]
  Float_t gamma   = 7000. / 0.938272;   // relativistic gamma [1]
  Float_t sigmaxy = TMath::Sqrt(eps * betast / gamma) / TMath::Sqrt(2.) * 100.;  // [cm]
  printf("\n \n Diamond size x-y: %10.3e z: %10.3e\n \n", sigmaxy, sigmaz);
    
  gener->SetSigma(sigmaxy, sigmaxy, sigmaz);      // Sigma in (X,Y,Z) (cm) on IP position
  gener->SetCutVertexZ(3.);        // Truncate at 3 sigma
  gener->SetVertexSmear(kPerEvent);

  gener->Init();

  // FIELD

  if (mag == k2kG) {
    comment = comment.Append(" | L3 field 0.2 T");
  } else if (mag == k4kG) {
    comment = comment.Append(" | L3 field 0.4 T");
  } else if (mag == k5kG) {
    comment = comment.Append(" | L3 field 0.5 T");
  }
  printf("\n \n Comment: %s \n \n", comment.Data());
    
  AliMagFMaps* field = new AliMagFMaps("Maps","Maps", 2, 1., 10., mag);
  field->SetL3ConstField(0); //Using const. field in the barrel
  rl->CdGAFile();
  gAlice->SetField(field);    



  Int_t iABSO  = 1;
  Int_t iACORDE   = 0;
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
  Int_t iHMPID  = 1;
  Int_t iSHIL  = 1;
  Int_t iT0 = 1;
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
        if (geo == kHoles) {
	  FRAME->SetHoles(1);
	} else {
	  FRAME->SetHoles(0);
	}
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

	AliITSvPPRasymmFMD *ITS  = new AliITSvPPRasymmFMD("ITS","New ITS PPR detailed version with asymmetric services");
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
        AliHMPID *HMPID = new AliHMPIDv2("HMPID", "normal HMPID");

    }


    if (iZDC)
    {
        //=================== ZDC parameters ============================

        AliZDC *ZDC = new AliZDCv2("ZDC", "normal ZDC");
    }

    if (iTRD)
    {
        //=================== TRD parameters ============================

        AliTRD *TRD = new AliTRDv1("TRD", "TRD slow simulator");
        if (geo == kHoles) {
          AliTRDgeometry *geoTRD = TRD->GetGeometry();
          //Holes for PHOS
          geoTRD->SetSMstatus(13,0);
          geoTRD->SetSMstatus(14,0);
          geoTRD->SetSMstatus(15,0);
        }
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
        AliEMCAL *EMCAL = new AliEMCALv2("EMCAL", "SHISH_77_TRD1_2X2_FINAL_110DEG");
    }

     if (iACORDE)
    {
        //=================== ACORDE parameters ============================
        AliACORDE *ACORDE = new AliACORDEv0("ACORDE", "normal ACORDE");
    }

     if (iVZERO)
    {
        //=================== VZERO parameters ============================
        AliVZERO *VZERO = new AliVZEROv7("VZERO", "normal VZERO");
    }
}

//           PYTHIA

AliGenPythia *PythiaHVQ(PDC06Proc_t proc) {
//*******************************************************************//
// Configuration file for charm / beauty generation with PYTHIA      //
//                                                                   //
// The parameters have been tuned in order to reproduce the inclusive//
// heavy quark pt distribution given by the NLO pQCD calculation by  //
// Mangano, Nason and Ridolfi.                                       //
//                                                                   //
// For details and for the NORMALIZATION of the yields see:          //
//   N.Carrer and A.Dainese,                                         //
//   "Charm and beauty production at the LHC",                       //
//   ALICE-INT-2003-019, [arXiv:hep-ph/0311225];                     //
//   PPR Chapter 6.6, CERN/LHCC 2005-030 (2005).                     //
//*******************************************************************//
  AliGenPythia * gener = 0x0;

  switch(proc) {
  case kCharmPbPb5500:
      comment = comment.Append(" Charm in Pb-Pb at 5.5 TeV");
      gener = new AliGenPythia(nEvts);
      gener->SetProcess(kPyCharmPbPbMNR);
      gener->SetStrucFunc(kCTEQ4L);
      gener->SetPtHard(2.1,-1.0);
      gener->SetEnergyCMS(5500.);
      gener->SetNuclei(208,208);
      break;
  case kCharmpPb8800:
      comment = comment.Append(" Charm in p-Pb at 8.8 TeV");
      gener = new AliGenPythia(nEvts);
      gener->SetProcess(kPyCharmpPbMNR);
      gener->SetStrucFunc(kCTEQ4L);
      gener->SetPtHard(2.1,-1.0);
      gener->SetEnergyCMS(8800.);
      gener->SetProjectile("P",1,1);
      gener->SetTarget("Pb",208,82);
      break;
  case kCharmpp14000:
      comment = comment.Append(" Charm in pp at 14 TeV");
      gener = new AliGenPythia(nEvts);
      gener->SetProcess(kPyCharmppMNR);
      gener->SetStrucFunc(kCTEQ4L);
      gener->SetPtHard(2.1,-1.0);
      gener->SetEnergyCMS(14000.);
      break;
  case kCharmpp14000wmi:
      comment = comment.Append(" Charm in pp at 14 TeV with mult. interactions");
      gener = new AliGenPythia(-1);
      gener->SetProcess(kPyCharmppMNRwmi);
      gener->SetStrucFunc(kCTEQ5L);
      gener->SetPtHard(ptHardMin,ptHardMax);
      gener->SetEnergyCMS(14000.);
      break;
  case kD0PbPb5500:
      comment = comment.Append(" D0 in Pb-Pb at 5.5 TeV");
      gener = new AliGenPythia(nEvts);
      gener->SetProcess(kPyD0PbPbMNR);
      gener->SetStrucFunc(kCTEQ4L);
      gener->SetPtHard(2.1,-1.0);
      gener->SetEnergyCMS(5500.);
      gener->SetNuclei(208,208);
      break;
  case kD0pPb8800:
      comment = comment.Append(" D0 in p-Pb at 8.8 TeV");
      gener = new AliGenPythia(nEvts);
      gener->SetProcess(kPyD0pPbMNR);
      gener->SetStrucFunc(kCTEQ4L);
      gener->SetPtHard(2.1,-1.0);
      gener->SetEnergyCMS(8800.);
      gener->SetProjectile("P",1,1);
      gener->SetTarget("Pb",208,82);
      break;
  case kD0pp14000:
      comment = comment.Append(" D0 in pp at 14 TeV");
      gener = new AliGenPythia(nEvts);
      gener->SetProcess(kPyD0ppMNR);
      gener->SetStrucFunc(kCTEQ4L);
      gener->SetPtHard(2.1,-1.0);
      gener->SetEnergyCMS(14000.);
      break;
  case kDPlusPbPb5500:
      comment = comment.Append(" DPlus in Pb-Pb at 5.5 TeV");
      gener = new AliGenPythia(nEvts);
      gener->SetProcess(kPyDPlusPbPbMNR);
      gener->SetStrucFunc(kCTEQ4L);
      gener->SetPtHard(2.1,-1.0);
      gener->SetEnergyCMS(5500.);
      gener->SetNuclei(208,208);
      break;
  case kDPluspPb8800:
      comment = comment.Append(" DPlus in p-Pb at 8.8 TeV");
      gener = new AliGenPythia(nEvts);
      gener->SetProcess(kPyDPluspPbMNR);
      gener->SetStrucFunc(kCTEQ4L);
      gener->SetPtHard(2.1,-1.0);
      gener->SetEnergyCMS(8800.);
      gener->SetProjectile("P",1,1);
      gener->SetTarget("Pb",208,82);
      break;
  case kDPluspp14000:
      comment = comment.Append(" DPlus in pp at 14 TeV");
      gener = new AliGenPythia(nEvts);
      gener->SetProcess(kPyDPlusppMNR);
      gener->SetStrucFunc(kCTEQ4L);
      gener->SetPtHard(2.1,-1.0);
      gener->SetEnergyCMS(14000.);
      break;
  case kBeautyPbPb5500:
      comment = comment.Append(" Beauty in Pb-Pb at 5.5 TeV");
      gener = new AliGenPythia(nEvts);
      gener->SetProcess(kPyBeautyPbPbMNR);
      gener->SetStrucFunc(kCTEQ4L);
      gener->SetPtHard(2.75,-1.0);
      gener->SetEnergyCMS(5500.);
      gener->SetNuclei(208,208);
      break;
  case kBeautypPb8800:
      comment = comment.Append(" Beauty in p-Pb at 8.8 TeV");
      gener = new AliGenPythia(nEvts);
      gener->SetProcess(kPyBeautypPbMNR);
      gener->SetStrucFunc(kCTEQ4L);
      gener->SetPtHard(2.75,-1.0);
      gener->SetEnergyCMS(8800.);
      gener->SetProjectile("P",1,1);
      gener->SetTarget("Pb",208,82);
      break;
  case kBeautypp14000:
      comment = comment.Append(" Beauty in pp at 14 TeV");
      gener = new AliGenPythia(nEvts);
      gener->SetProcess(kPyBeautyppMNR);
      gener->SetStrucFunc(kCTEQ4L);
      gener->SetPtHard(2.75,-1.0);
      gener->SetEnergyCMS(14000.);
      break;
  case kBeautypp14000wmi:
      comment = comment.Append(" Beauty in pp at 14 TeV with mult. interactions");
      gener = new AliGenPythia(-1);
      gener->SetProcess(kPyBeautyppMNRwmi);
      gener->SetStrucFunc(kCTEQ5L);
      gener->SetPtHard(ptHardMin,ptHardMax);
      gener->SetEnergyCMS(14000.);
      break;
  }

  return gener;
}

AliGenerator* MbCocktail()
{
      comment = comment.Append(" pp at 14 TeV: Pythia low-pt, no heavy quarks + J/Psi from parameterisation");
      AliGenCocktail * gener = new AliGenCocktail();
      gener->UsePerEventRates();
 
//    Pythia

      AliGenPythia* pythia = new AliGenPythia(-1); 
      pythia->SetMomentumRange(0, 999999.);
      pythia->SetThetaRange(0., 180.);
      pythia->SetYRange(-12.,12.);
      pythia->SetPtRange(0,1000.);
      pythia->SetProcess(kPyMb);
      pythia->SetEnergyCMS(14000.);
      pythia->SwitchHFOff();
      
//   J/Psi parameterisation

      AliGenParam* jpsi = new AliGenParam(1, AliGenMUONlib::kJpsi, "CDF scaled", "Jpsi");
      jpsi->SetPtRange(0.,100.);
      jpsi->SetYRange(-8., 8.);
      jpsi->SetPhiRange(0., 360.);
      jpsi->SetForceDecay(kAll);

      gener->AddGenerator(jpsi,   "J/Psi", 8.e-4);      
      gener->AddGenerator(pythia, "Pythia", 1.);
      
      return gener;
}

AliGenerator* PyMbTriggered(Int_t pdg)
{
    AliGenPythia* pythia = new AliGenPythia(-1); 
    pythia->SetMomentumRange(0, 999999.);
    pythia->SetThetaRange(0., 180.);
    pythia->SetYRange(-12.,12.);
    pythia->SetPtRange(0,1000.);
    pythia->SetProcess(kPyMb);
    pythia->SetEnergyCMS(14000.);
    pythia->SetTriggerParticle(pdg, 0.9);
    return pythia;
}

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
      // pp 14 wmi with b, B forced to Jpsi, Jpsi forced to ee
      decHvFl = kBtoJPSItoEle;
      proc = kBeautypp14000wmi;
      {
	// Define ptHardMin,ptHardMax
	// The array below contains the cumulative probability
	// for the different pthard bins
	Double_t probPtBeauty[] = {0.0,0.05,0.36,0.64,1.0};	
	Int_t iPt = TMath::BinarySearch(5,probPtBeauty,gRandom->Rndm());
	switch (iPt) {
	case 0:
	  ptHardMin = 2.76;
	  ptHardMax = 4.0;
	  break;
	case 1:
	  ptHardMin = 4.0;
	  ptHardMax = 6.0;
	  break;
	case 2:
	  ptHardMin = 6.0;
	  ptHardMax = 8.0;
	  break;
	case 3:
	  ptHardMin = 8.0;
	  ptHardMax = -1.0;
	  break;
	default:
	  cout << "ProcessEnvironmentVars: Wrong pthard bin" << endl;
	}
      }
      cout<<"Run type set to "<<pprRunName[proc]<<endl;
      cout<<"Decay set to kBtoJPSItoEle"<<endl;
      cout<<"ptHard limits: "<<ptHardMin<<" to " <<ptHardMax<<endl;
    }
    
}




