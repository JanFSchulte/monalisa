// Config file MUON + ITS (for vertex) + VZERO + FMD for PDC07
// Tuned for p+p min bias and quarkonia production, heavy quark production 
// from AliGenCorrHF(AliGenMUONCocktailpp)
// Remember to define the directory and option
// gAlice->SetConfigFunction("Config('$HOME','box');");
// april 3rd: added L3 magnet 

TDatime dt;
static Int_t    seed = dt.Get();
static Int_t    runNumber= 0; 

void Config(char directory[100]="", char option[6]="trgAll")
{
    
  // Get settings from environment variables
    ProcessEnvironmentVars();

  //=====================================================================
  //  Libraries required by geant321
    gSystem->Load("libgeant321.so");
    new TGeant3TGeo("C++ Interface to Geant3");
  //=======================================================================

  // Output every 100 tracks
    ((TGeant3*)gMC)->SetSWIT(4,100);

  //  Create the output file    
    Text_t filename[100];
    sprintf(filename,"%sgalice.root",directory);

    AliRunLoader* rl=0x0;
    rl = AliRunLoader::Open(
	filename, AliConfig::GetDefaultEventFolderName(), "recreate");
    if (rl == 0x0) {
	gAlice->Fatal("Config.C","Can not instatiate the Run Loader");
	return;
    }
    rl->SetCompressionLevel(2);
    rl->SetNumberOfEventsPerFile(500);
    gAlice->SetRunLoader(rl);

  //=======================================================================
  // Set the trigger configuration - not needed here for MUON in
  // stand-alone mode
  // gAlice->SetTriggerDescriptor("p-p");
  // cout<<"Trigger configuration is set to  p-p"<<endl;

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

    if (!strcmp(option,"trg2mu")) {
	AliGenMUONCocktailpp *gener = new AliGenMUONCocktailpp();
	gener->SetPtRange(0.,100.);
	gener->SetYRange(-4.,-2.4);
	gener->SetPhiRange(0., 360.);
	gener->SetMuonMultiplicity(2);  
	gener->SetMuonPtCut(0.5);
	gener->SetMuonThetaRange(171.,178.);      
	gener->SetOrigin(0.,0.,0.); 
	gener->SetSigma(0.,0.,5.);
	gener->SetVertexSmear(kPerEvent);
	gener->Init(); 
    }
 
    if (!strcmp(option,"trg1mu")) {
	AliGenMUONCocktailpp *gener = new AliGenMUONCocktailpp();
	gener->SetPtRange(0.,100.);
	gener->SetYRange(-4.,-2.4);
	gener->SetPhiRange(0., 360.);
	gener->SetMuonMultiplicity(1);  
	gener->SetMuonPtCut(0.5);
	gener->SetMuonThetaRange(171.,178.);      
	gener->SetOrigin(0.,0.,0.); 
	gener->SetSigma(0.,0.,5.);
	gener->SetVertexSmear(kPerEvent);
	gener->Init(); 
    }

    if (!strcmp(option,"trgAll")) {
	AliGenMUONCocktailpp *gener = new AliGenMUONCocktailpp();
	gener->SetPtRange(0.,100.);
	gener->SetYRange(-4.,-2.4);
	gener->SetPhiRange(0., 360.);
	gener->SetOrigin(0.,0.,0.); 
	gener->SetSigma(0.,0.,5.3);
	gener->SetVertexSmear(kPerEvent);
	gener->Init();
    }

    if (!strcmp(option,"trg1muF")) {
	AliGenMUONCocktailpp *gener = new AliGenMUONCocktailpp();
	gener->SetDecayModePythia(kAllMuonic);
	gener->SetPtRange(0.,100.);
	gener->SetYRange(-4.,-2.4);
	gener->SetPhiRange(0., 360.);
	gener->SetMuonMultiplicity(1);  
	gener->SetMuonPtCut(0);
	gener->SetMuonPCut(4);
	gener->SetMuonThetaRange(171.,178.);      
	gener->SetOrigin(0.,0.,0.); 
	gener->SetSigma(0.,0.,5.3);
	gener->SetVertexSmear(kPerEvent);
	gener->Init(); 
    }

  //============================================================= 
  // Field (L3 0.5 T) outside dimuon spectrometer
    AliMagFMaps* field = new AliMagFMaps("Maps","Maps", 2, 1., 10., AliMagFMaps::k5kG);
    field->SetL3ConstField(0); // Using const. field in the barrel 
    rl->CdGAFile();
    gAlice->SetField(field);

    Int_t   iITS = 1;
    Int_t   iFMD = 1;
    Int_t   iVZERO = 1;

  //=================== Alice BODY parameters =============================
    AliBODY *BODY = new AliBODY("BODY","Alice envelop");
  //=================== ABSO parameters ============================
    AliABSO *ABSO = new AliABSOv3("ABSO", "Muon Absorber");
  //=================== DIPO parameters ============================
    AliDIPO *DIPO = new AliDIPOv3("DIPO", "Dipole version 3");
  //================== HALL parameters ============================
    AliHALL *HALL = new AliHALLv3("HALL", "Alice Hall");
  //================== The L3 Magnet ==============================
    AliMAG *MAG = new AliMAG("MAG", "Magnet");
  //=================== PIPE parameters ============================
    AliPIPE *PIPE = new AliPIPEv3("PIPE", "Beam Pipe");
  //=================== SHIL parameters ============================
    AliSHIL *SHIL = new AliSHILv3("SHIL", "Shielding Version 3");
  //=================== ITS parameters =============================
    if(iITS) {
	AliITSvPPRasymmFMD *ITS  = new AliITSvPPRasymmFMD("ITS","New ITS PPR detailed version with asymmetric services");
    }      
 //=================== FMD parameters =============================
    if(iFMD) {
	AliFMD *FMD = new AliFMDv1("FMD", "normal FMD");
    }
 //=================== VZERO parameters =============================
    if (iVZERO) {
	AliVZERO *VZERO = new AliVZEROv7("VZERO", "normal VZERO");
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
    if (gSystem->Getenv("CONFIG_RUN_TYPE")) {
      for (Int_t iRun = 0; iRun < kRunMax; iRun++) {
	if (strcmp(gSystem->Getenv("CONFIG_RUN_TYPE"), pprRunName[iRun])==0) {
	  srun = (PprRun_t)iRun;
	  cout<<"Run type set to "<<pprRunName[iRun]<<endl;
	}
      }
    }
}
