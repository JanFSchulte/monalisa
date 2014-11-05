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
#include "STEER/AliMagWrapCheb.h"
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
  kFlow_5_2000
};

const char* pprRunName[] = {
  "kFlow_5_2000"
};

enum PprRad_t
{
  kGluonRadiation
};

enum PprMag_t
{
  k5kG
};

enum PprTrigConf_t
{
  kDefaultPbPbTrig
};

const char * pprTrigConfName[] = {
"Pb-Pb"
};

// This part for configuration    

static PprRun_t srun = kFlow_5_2000;
static PprRad_t srad = kGluonRadiation;
static PprMag_t smag = k5kG;
static Int_t    sseed = 0; // use the current time
static PprTrigConf_t strig = kDefaultPbPbTrig; 

// Comment line 
static TString  comment;

// Functions
Float_t EtaToTheta(Float_t arg);
AliGenerator* GeneratorFactory(PprRun_t srun);
AliGenGeVSim* GeVSimStandard(Float_t, Float_t);
void ProcessEnvironmentVars();

void Config()
{
    // ThetaRange is (0., 180.). It was (0.28,179.72) 7/12/00 09:00
    // Theta range given through pseudorapidity limits 22/6/2001

    // Get settings from environment variables
    ProcessEnvironmentVars();

    // Set Random Number seed
    gRandom->SetSeed(sseed);
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

  // Output every 100 tracks
  ((TGeant3*)gMC)->SetSWIT(4,100);

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
    rl->SetCompressionLevel(2);
    rl->SetNumberOfEventsPerFile(2);
    gAlice->SetRunLoader(rl);

    // Set the trigger configuration
    gAlice->SetTriggerDescriptor(pprTrigConfName[strig]);
    cout<<"Trigger configuration is set to  "<<pprTrigConfName[strig]<<endl;

    //
    // Set External decayer
    AliDecayer *decayer = new AliDecayerPythia();


    switch (srun) {
    default:
      decayer->SetForceDecay(kAll);
      break;
    }
    decayer->Init();
    gMC->SetExternalDecayer(decayer);
    //
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
    gener->SetOrigin(0, 0, 0);    // vertex position
    gener->SetSigma(0, 0, 5.3);   // Sigma in (X,Y,Z) (cm) on IP position
    gener->SetCutVertexZ(1.);     // Truncate at 1 sigma
    gener->SetVertexSmear(kPerEvent); 
    gener->SetTrackingFlag(1);
    gener->Init();
    
     if (smag == k5kG) {
	comment = comment.Append(" | L3 field 0.5 T");
    }
    
    
    if (srad == kGluonRadiation)
    {
	comment = comment.Append(" | Gluon Radiation On");
	
    }

    printf("\n \n Comment: %s \n \n", comment.Data());
    
    
// Field
    AliMagWrapCheb* field = new AliMagWrapCheb("Maps","Maps", 2, 1., 10., smag);
    rl->CdGAFile();
    gAlice->SetField(field);    
//
    Int_t   iABSO   = 0;
    Int_t   iDIPO   = 0;
    Int_t   iFMD    = 0;
    Int_t   iFRAME  = 1;
    Int_t   iHALL   = 0;
    Int_t   iITS    = 1;
    Int_t   iMAG    = 0;
    Int_t   iMUON   = 0;
    Int_t   iPHOS   = 0;
    Int_t   iPIPE   = 1;
    Int_t   iPMD    = 0;
    Int_t   iHMPID  = 0;
    Int_t   iSHIL   = 0;
    Int_t   iT0     = 1;
    Int_t   iTOF    = 1;
    Int_t   iTPC    = 1;
    Int_t   iTRD    = 1;
    Int_t   iZDC    = 0;
    Int_t   iEMCAL  = 0;
    Int_t   iVZERO  = 0;
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
	AliTRDgeometry *geoTRD = TRD->GetGeometry();
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
        AliEMCAL *EMCAL = new AliEMCALv2("EMCAL", "EMCAL_COMPLETE");
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
    Int_t isw = 3;
    //  if (srad == kNoGluonRadiation) isw = 0;
    

    AliGenerator * gGener = 0x0;
    switch (srun) {
         case kFlow_5_2000:
    {
	comment = comment.Append(" Flow with dN/deta  = 2000, vn = 5%");
	gGener = GeVSimStandard(2000., 5.);
    }
    break;
    default: break;
    }
    return gGener;
}


AliGenGeVSim* GeVSimStandard(Float_t mult, Float_t vn)
{
    AliGenGeVSim* gener = new AliGenGeVSim(0);
//
// Mult is the number of charged particles in |eta| < 0.5
// Vn is in (%)
//
// Sigma of the Gaussian dN/deta
    Float_t sigma_eta  = 2.75;
//
// Maximum eta
    Float_t etamax     = 3.50;
//
//
// Scale from multiplicity in |eta| < 0.5 to |eta| < |etamax|	
    Float_t mm = mult * (TMath::Erf(etamax/sigma_eta/sqrt(2.)) / TMath::Erf(0.5/sigma_eta/sqrt(2.))); 
//
// Scale from charged to total multiplicity
// 
    mm *= 1.587;
//
// Vn 
    vn /= 100.;    	 
//
// Define particles
//
//
// 84% Pions (28% pi+, 28% pi-, 28% p0)              T = 250 MeV
    AliGeVSimParticle *pp =  new AliGeVSimParticle(kPiPlus,  1, 0.28 * mm, 0.25, sigma_eta) ;
    AliGeVSimParticle *pm =  new AliGeVSimParticle(kPiMinus, 1, 0.28 * mm, 0.25, sigma_eta) ;
    AliGeVSimParticle *p0 =  new AliGeVSimParticle(kPi0,     1, 0.28 * mm, 0.25, sigma_eta) ;
//
//  9% Kaons (1% K0short, 1% K0long, 3.5% K+, 3.5% K-)   T = 300 MeV
    AliGeVSimParticle *ks =  new AliGeVSimParticle(kK0Short, 1, 0.01 * mm, 0.30, sigma_eta) ;
    AliGeVSimParticle *kl =  new AliGeVSimParticle(kK0Long,  1, 0.01 * mm, 0.30, sigma_eta) ;
    AliGeVSimParticle *kp =  new AliGeVSimParticle(kKPlus,   1, 0.035 * mm, 0.30, sigma_eta) ;
    AliGeVSimParticle *km =  new AliGeVSimParticle(kKMinus,  1, 0.035 * mm, 0.30, sigma_eta) ;
//
// 10% Protons / Neutrons (5% Protons, 5% ProtonBar)  T = 250 MeV
    AliGeVSimParticle *pr =  new AliGeVSimParticle(kProton,  1, 0.025 * mm, 0.25, sigma_eta) ;
    //  AliGeVSimParticle *ne =  new AliGeVSimParticle(kNeutron, 1, 0.025 * mm, 0.25, sigma_eta) ;
 AliGeVSimParticle *ap =  new AliGeVSimParticle(kProtonBar,  1, 0.025 * mm, 0.25, sigma_eta) ;
//
// 2% Phi  T = 270 MeV
    AliGeVSimParticle *phi =  new AliGeVSimParticle(333/*AliGenSTRANGElib::kPhi*/, 1, 0.02 * mm, 0.35, sigma_eta) ;

    //



// Set Elliptic Flow properties 	

    Float_t pTsaturation = 2. ;

    pp->SetEllipticParam(vn,pTsaturation,0.) ;
    pm->SetEllipticParam(vn,pTsaturation,0.) ;
    p0->SetEllipticParam(vn,pTsaturation,0.) ;
    pr->SetEllipticParam(vn,pTsaturation,0.) ;
    ap->SetEllipticParam(vn,pTsaturation,0.) ;
    ks->SetEllipticParam(vn,pTsaturation,0.) ;
    kl->SetEllipticParam(vn,pTsaturation,0.) ;
    kp->SetEllipticParam(vn,pTsaturation,0.) ;
    km->SetEllipticParam(vn,pTsaturation,0.) ;
    phi->SetEllipticParam(vn,pTsaturation,0.) ;
//
// Set Direct Flow properties	
    pp->SetDirectedParam(vn,1.0,0.) ;
    pm->SetDirectedParam(vn,1.0,0.) ;
    p0->SetDirectedParam(vn,1.0,0.) ;
    pr->SetDirectedParam(vn,1.0,0.) ;
    ap->SetDirectedParam(vn,1.0,0.) ;
    ks->SetDirectedParam(vn,1.0,0.) ;
    kl->SetDirectedParam(vn,1.0,0.) ;
    kp->SetDirectedParam(vn,1.0,0.) ;
    km->SetDirectedParam(vn,1.0,0.) ;
    phi->SetDirectedParam(vn,1.0,0.) ;
//
// Add particles to the list
    gener->AddParticleType(pp) ;
    gener->AddParticleType(pm) ;
    gener->AddParticleType(p0) ;
    gener->AddParticleType(pr) ;
    gener->AddParticleType(ap) ;
    gener->AddParticleType(ks) ;
    gener->AddParticleType(kl) ;
    gener->AddParticleType(kp) ;
    gener->AddParticleType(km) ;
    gener->AddParticleType(phi) ;
//	
// Random Ev.Plane ----------------------------------
    TF1 *rpa = new TF1("gevsimPsiRndm","1", 0, 360);
// --------------------------------------------------
    gener->SetPtRange(0., 9.) ; // Use a resonable range! (used for bin size in numerical integration)
    gener->SetPhiRange(0, 360);
    //
    // Set pseudorapidity range 
    Float_t thmin = EtaToTheta(+etamax);   
    Float_t thmax = EtaToTheta(-etamax);   
    gener->SetThetaRange(thmin,thmax);     
    return gener;
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

    // Random Number seed
    if (gSystem->Getenv("CONFIG_SEED")) {
      sseed = atoi(gSystem->Getenv("CONFIG_SEED"));
    }
}
