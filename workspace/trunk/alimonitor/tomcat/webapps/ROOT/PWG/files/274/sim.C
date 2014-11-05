void sim() {
  Int_t nev=11;
  Int_t run=137161;
  const char *fname="alien:///alice/data/2010/LHC10h/000137161/raw/10000137161001.10.root";
  const char *esdname="alien:///alice/data/2010/LHC10h/000137161/ESDs/pass2/AliESDs.root";
  const char *embrun="kSignal";

  Int_t nev = 10;

  if (gSystem->Getenv("DC_RUN")) {
    run = atoi(gSystem->Getenv("DC_RUN"));
  }
  if (gSystem->Getenv("DC_RAWFILE")) {
    fname = gSystem->Getenv("DC_RAWFILE");
  }
  if (gSystem->Getenv("DC_ESDFILE")) {
    esdname = gSystem->Getenv("DC_ESDFILE");
  }
  if (gSystem->Getenv("DC_NEVENTS")) {
    nev = atoi(gSystem->Getenv("DC_NEVENTS"));
  } 
  if (gSystem->Getenv("CONFIG_EMBEDDING")) {
    embrun = gSystem->Getenv("CONFIG_EMBEDDING");
}
  
  printf("sim.C: running in %s mode on run %d for %d events\n",embrun,run,nev);
  printf("sim.C: rawfile %s and esdfile %s \n",fname,esdname);

  AliSimulation simulator;
  
  //AliLog::SetGlobalDebugLevel(1);
  //AliLog::SetModuleDebugLevel("STEER",1);

  // BACKGROUND: Convert raw data to SDigits
  if (!(strcmp(embrun,"kBackground"))){

    AliCDBManager *cdbm = AliCDBManager::Instance();
    cdbm->SetDefaultStorage("alien://Folder=/alice/data/2010/OCDB");     
    cdbm->SetRun(run);
		
		AliGRPManager grpM;
    grpM.ReadGRPEntry();
    grpM.SetMagField();
    printf("Field is locked now. It cannot be changed in Config.C\n");
		
//    simulator.SetMakeSDigits("MUON ITS VZERO ZDC");
    simulator.SetMakeSDigits("MUON ITS");

    TStopwatch timer;
    timer.Start();
    simulator.ConvertRaw2SDigits(fname,esdname,nev);
    timer.Stop();
    timer.Print();
    return;
  }
  
  // Signal: pure signal 
  if (!(strcmp(embrun,"kSignal"))){
    AliCDBManager *cdbm = AliCDBManager::Instance();
    cdbm->SetDefaultStorage("alien://Folder=/alice/data/2010/OCDB");     
    cdbm->SetRun(run);

    AliGRPManager grpM;
    grpM.ReadGRPEntry();
    grpM.SetMagField();
    printf("Field is locked now. It cannot be changed in Config.C\n");

    simulator.SetRunGeneration(kFALSE);
    simulator.SetMakeSDigits("");
    simulator.SetMakeDigitsFromHits("");
  }
  // MERGED: Simulate signal and merge with background
  if (!(strcmp(embrun,"kMerged"))){
    simulator.SetRunGeneration(kTRUE);
//    simulator.SetMakeSDigits("MUON ITS VZERO ZDC");    
    simulator.SetMakeSDigits("MUON ITS");    
    simulator.EmbedInto("Background/galice.root",1);
    // THE OCDB PART
    simulator.SetDefaultStorage("alien://Folder=/alice/data/2010/OCDB");
    //  simulator.SetDefaultStorage("alien://Folder=/alice/simulation/2008/v4-15-Release/Ideal/");  
    
    // Read GRP Data from RAW
    simulator.SetSpecificStorage("GRP/GRP/Data","alien://Folder=/alice/data/2010/OCDB");    
  }

  simulator.SetRunSimulation(kTRUE);
  simulator.SetMakeDigits("MUON ITS");
//  simulator.SetMakeDigits("MUON ITS VZERO ZDC");
//  simulator.SetWriteRawData("MUON ITS VZERO ZDC","raw.root",kTRUE);

  simulator.SetRunHLT("");
  //  simulator.SetRunHLT("libAliHLTMUON.so chains=dHLT-sim");
  simulator.SetRunQA(":");
  //  simulator.SetRunQA("MUON:ALL");    

  //  Mag.field from OCDB
  simulator.UseMagFieldFromGRP();

  // THE OCDB PART

// MUON
  simulator.SetSpecificStorage("MUON/Calib/Gains","alien://Folder=/alice/simulation/2008/v4-15-Release/Ideal/");  
  simulator.SetSpecificStorage("MUON/Align/Data","alien://Folder=/alice/cern.ch/user/j/jcastill/LHC10hMisAlignCDB/");
  // MUON Trigger
  simulator.SetSpecificStorage("MUON/Calib/GlobalTriggerCrateConfig","alien://folder=/alice/simulation/2008/v4-15-Release/Ideal");
  simulator.SetSpecificStorage("MUON/Calib/LocalTriggerBoardMasks","alien://folder=/alice/simulation/2008/v4-15-Release/Ideal");
  simulator.SetSpecificStorage("MUON/Calib/RegionalTriggerConfig","alien://folder=/alice/simulation/2008/v4-15-Release/Ideal");
  simulator.SetSpecificStorage("MUON/Calib/TriggerEfficiency","alien://folder=/alice/simulation/2008/v4-15-Release/Full");
	
// The rest

  TStopwatch timer;
  timer.Start();
  simulator.Run(nev);
  timer.Stop();
  timer.Print();


// // Mean vertex from RAW OCDB 
//   simulator.SetSpecificStorage("GRP/Calib/MeanVertexSPD",       "alien://folder=/alice/data/2010/OCDB"); 
//   simulator.SetSpecificStorage("GRP/Calib/MeanVertex",          "alien://folder=/alice/data/2010/OCDB");

// // Clock phase from RAW OCDB 
//   simulator.SetSpecificStorage("GRP/Calib/LHCClockPhase",       "alien://folder=/alice/data/2010/OCDB");
// // ZDC
// //  simulator.SetSpecificStorage("ZDC/Calib/Pedestals","alien://folder=/alice/data/2010/OCDB");

// // VZERO
//   simulator.SetSpecificStorage("VZERO/Calib/Data",             "alien://Folder=/alice/data/2010/OCDB");
//   simulator.SetSpecificStorage("VZERO/Trigger/Data",           "alien://folder=/alice/data/2010/OCDB");
//   simulator.SetSpecificStorage("VZERO/Calib/RecoParam",        "alien://folder=/alice/data/2010/OCDB");
//   simulator.SetSpecificStorage("VZERO/Calib/TimeSlewing",      "alien://folder=/alice/data/2010/OCDB");
//   simulator.SetSpecificStorage("VZERO/Calib/TimeDelays",       "alien://folder=/alice/data/2010/OCDB");

}
