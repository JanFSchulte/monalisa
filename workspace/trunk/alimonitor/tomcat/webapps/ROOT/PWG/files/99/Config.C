// Config file MUON + ITS (for vertex) for PDC06
// Tuned for p+p min biais and quarkonia production (AliGenMUONCocktailpp)
// Remember to define the directory and option
// gAlice->SetConfigFunction("Config('$HOME','box');");
// april 3rd: added L3 magnet 

enum Run_t
{

  ppMBias, pptrg1mu, pptrg2mu, pptrg2muPolA, pptrg2muPolB, pptrg2muPolC, pptrg2muSecret, kRunMax
  
};

const char* runName[] = {
  "ppMBias", "pptrg1mu", "pptrg2mu", "pptrg2muPolA", "pptrg2muPolB", "pptrg2muPolC", "pptrg2muSecret" 
};

static Run_t srun  = ppMBias;
static Int_t sseed = 12345;

void Config()
{
 
  // Get settings from environment variables
  ProcessEnvironmentVars();

  //=====================================================================
  //  Libraries required by geant321
  gSystem->Load("liblhapdf.so");      // Parton density functions
  gSystem->Load("libpythia6.so");     // Pythia
  gSystem->Load("libgeant321.so");
  gSystem->Load("libEG");
  gSystem->Load("libEGPythia6");
  gSystem->Load("libAliPythia6.so");  // ALICE specific implementations
  
  new TGeant3TGeo("C++ Interface to Geant3");
  
  //  Create the output file    
  AliRunLoader* rl=0x0;
  rl = AliRunLoader::Open(
	"galice.root", AliConfig::GetDefaultEventFolderName(), "recreate");
  if (rl == 0x0) {
    gAlice->Fatal("Config.C","Can not instatiate the Run Loader");
    return;
  }
  rl->SetCompressionLevel(2);
  rl->SetNumberOfEventsPerFile(500);
  gAlice->SetRunLoader(rl);

  //=======================================================================
  // Set External decayer
  TVirtualMCDecayer *decayer = new AliDecayerPythia();
  decayer->SetForceDecay(kAll);
  decayer->Init();
  gMC->SetExternalDecayer(decayer);

  //=======================================================================
  // ******* GEANT STEERING parameters FOR ALICE SIMULATION *******
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
  //
  //=======================================================================
  // ************* STEERING parameters FOR ALICE SIMULATION **************
  // Chamber positions
  // From AliMUONConstants class we get :
  //   Position Z (along beam) of the chambers (in cm) 
  //        (from AliMUONConstants class):  
  //    533.5,  546.5,  678.5, 693.5,  964.0, 986.0, 1251.5, 1278.5, 
  //   1416.5, 1443.5,  1610, 1625.,  1710., 1725. 
  //   Internal Radius (in cm)   
  //     36.4,  46.2,  66.0,  80.,  80., 100., 100.    
  //   External Radius (in cm)
  //    183.,  245.,  395.,  560., 563., 850., 900.  
  //=======================================================================

    // The internal generator, for minimum bias
  
    AliGenMUONCocktailpp *gener = new AliGenMUONCocktailpp();
    gener->SetPtRange(0.,1000.);
    gener->SetYRange(-4.,-2.4);
    gener->SetPhiRange(0., 360.);
    gener->SetOrigin(0.,0.,0.); 
    gener->SetSigma(0.,0.,5.3);
    gener->SetVertexSmear(kPerEvent);

    // Special generator trigger conditions, etc.

    switch(srun) {
    case pptrg1mu:
      {
	gener->SetMuonMultiplicity(1);  
	gener->SetMuonPtCut(0.5);
	gener->SetMuonThetaRange(171.,178.);  
      }
      break;
    case pptrg2mu:
      {
	gener->SetMuonMultiplicity(2);  
	gener->SetMuonPtCut(0.5);
	gener->SetMuonThetaRange(171.,178.);  
      }
      break;
    case pptrg2muPolA:
      {
	gener->SetMuonMultiplicity(2);  
	gener->SetMuonPtCut(0.5);
	gener->SetMuonThetaRange(171.,178.);  
        gener->SetResPolarization(0.3,0.3,0.,1.,0.,"kColSop");
      }
      break;
    case pptrg2muPolB:
      {
	gener->SetMuonMultiplicity(2);  
	gener->SetMuonPtCut(0.5);
	gener->SetMuonThetaRange(171.,178.);  
        gener->SetResPolarization(-0.3,-0.3,0.,1.,0.,"kColSop");
      }
      break;
    case pptrg2muPolC:
      {
	gener->SetMuonMultiplicity(2);  
	gener->SetMuonPtCut(0.5);
	gener->SetMuonThetaRange(171.,178.);  
        gener->SetResPolarization(0.,0.,0.,1.,0.,"kColSop");
      }
      break;
    case pptrg2muSecret:
      {
	gener->SetMuonMultiplicity(2);  
	gener->SetMuonPtCut(0.5);
	gener->SetMuonThetaRange(171.,178.);  
        gener->SetCMSEnergy(10);
        gener->SetSigmaReaction(0.0695);
        gener->SetSigmaJPsi(27.4e-6);
        gener->SetSigmaPsiP(6.039e-6);
        gener->SetSigmaUpsilon(0.855e-6);
        gener->SetSigmaUpsilonP(0.218e-6);
        gener->SetSigmaUpsilonPP(0.122e-6);
        gener->SetSigmaCCbar(4.5e-3);
        gener->SetSigmaBBbar(0.33e-3);
        gener->SetSigmaSilent();
      }
      break;
    default: break;
    }

    gener->CreateCocktail();

    // The external generator

    AliGenPythia *pythia = new AliGenPythia(1);
    pythia->SetProcess(kPyMb);
    pythia->SetStrucFunc(kCTEQ5L);
    pythia->SetEnergyCMS(10000.);
    Decay_t dt = gener->GetDecayModePythia();
    pythia->SetForceDecay(dt);
    pythia->SetPtRange(0.,1000.);
    pythia->SetYRange(-8.,8.);
    pythia->SetPhiRange(0.,360.);
    pythia->SetPtHard(2.76,-1.0);
    pythia->SwitchHFOff();
    pythia->Init();

    gener->AddGenerator(pythia,"Pythia",1);
    gener->Init();
    
  //============================================================= 
  // Field (L3 0.5 T) outside dimuon spectrometer
  AliMagF *field = new AliMagF("Maps","Maps", 2, 0., 0., 10., AliMagF::k5kG);
  TGeoGlobalMagField::Instance()->SetField(field);

  Int_t iITS = 1;
  Int_t iFMD = 1;
  Int_t iVZERO = 1;
  Int_t iZDC = 0;
  Int_t iT0 = 0;

  rl->CdGAFile();

  //=================== Alice BODY parameters =============================
  AliBODY *BODY = new AliBODY("BODY","Alice envelop");
  //=================== ABSO parameters ============================
  AliABSO *ABSO = new AliABSOv3("ABSO", "Muon Absorber");
  //=================== DIPO parameters ============================
  AliDIPO *DIPO = new AliDIPOv3("DIPO", "Dipole version 3");
  //================== HALL parameters ============================
  AliHALL *HALL = new AliHALLv3("HALL", "Alice Hall");
  //================== The L3 Magnet ==============================
  AliMAG *MAG = new AliMAG("MAG", "L3 Magnet");
  //=================== PIPE parameters ============================
  AliPIPE *PIPE = new AliPIPEv3("PIPE", "Beam Pipe");
  //=================== SHIL parameters ============================
  AliSHIL *SHIL = new AliSHILv3("SHIL", "Shielding Version 3");
  //=================== ITS parameters =============================
  if(iITS) {
  AliITS *ITS  = new AliITSv11Hybrid("ITS","ITS v11Hybrid");
  }
  //=================== FMD parameters =============================
  if(iFMD) {
  AliFMD *FMD = new AliFMDv1("FMD", "normal FMD");
  }
  //=================== VZERO parameters =============================
  if (iVZERO) {
  AliVZERO *VZERO = new AliVZEROv7("VZERO", "normal VZERO");
  }
  if (iZDC){
  //=================== ZDC parameters ============================
  AliZDC *ZDC = new AliZDCv3("ZDC", "normal ZDC");
  }
  if (iT0) {
  //=================== T0 parameters ============================
  AliT0 *T0 = new AliT0v1("T0", "T0 Detector");
  }


  //=================== MUON Subsystem ===========================
  cout << ">>> Config.C: Creating AliMUONv1 ..."<<endl;

  AliMUON *MUON = new AliMUONv1("MUON","default");
}

Float_t EtaToTheta(Float_t arg){
  return (180./TMath::Pi())*2.*atan(exp(-arg));
}

void ProcessEnvironmentVars()
{
  // Run type
  if (gSystem->Getenv("CONFIG_RUN_TYPE")) {
    for (Int_t iRun = 0; iRun < kRunMax; iRun++) {
      if (strcmp(gSystem->Getenv("CONFIG_RUN_TYPE"), runName[iRun])==0) {
	srun = (Run_t)iRun;
	cout<<"Run type set to "<<runName[iRun]<<endl;
      }
    }
  }
}
