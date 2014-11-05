void sim() {
  Int_t nev = -1;
  Int_t run = 0;
  const char *fname;
	//	char fnaneopt[1024];
  const char *esdname;
	const char *trgname;
  const char *embrun;
  const char *fnameopt;
	
  if (gSystem->Getenv("DC_RUN")) {
    run = atoi(gSystem->Getenv("DC_RUN"));
  } 
  if (gSystem->Getenv("DC_RAWFILE")) {
    fname = gSystem->Getenv("DC_RAWFILE");
  } else {
		printf("DC_RAWFILE is not set and is needed!!!");
		return;
	}
  if (gSystem->Getenv("DC_ESDFILE")) {
    esdname = gSystem->Getenv("DC_ESDFILE");
  } else {
		printf("DC_ESDFILE is not set and is needed!!!");
		return;
	}
  if (gSystem->Getenv("DC_NEVENTS")) {
    nev = atoi(gSystem->Getenv("DC_NEVENTS"));
		//    gSystem->Exec("echo ${DC_NEVENTS} > ${DC_NEVENTS}_${DC_NEVENTS}_0_${DC_NEVENTS}.stat"); // moved after selection!
  } 
	if (gSystem->Getenv("DC_TRGNAME")) {
    trgname = gSystem->Getenv("DC_TRGNAME");
		printf("Looking for %s\n",trgname);
  } else {
		printf("DC_TRGNAME not set, will embedd in all events!!!");
		return;
	}
  if (gSystem->Getenv("CONFIG_EMBEDDING")) {
    embrun = gSystem->Getenv("CONFIG_EMBEDDING");
	} else {
		printf("CONFIG_EMBEDDING is not set and is needed");
		return;
	}
	TString sfname(fname);
	
  printf("sim.C: running in %s mode on run %d for %d events\n",embrun,run,nev);
	printf("sim.C: rawfile %s and esdfile %s \n",sfname.Data(),esdname);
	
  AliSimulation simulator;
  
  // BACKGROUND: Convert raw data to SDigits
  if (!(strcmp(embrun,"kBackground"))){
		
    AliCDBManager *cdbm = AliCDBManager::Instance();
    cdbm->SetDefaultStorage("alien://Folder=/alice/data/2011/OCDB");     
    cdbm->SetRun(run);
		
		AliGRPManager grpM;
    grpM.ReadGRPEntry();
    grpM.SetMagField();
    printf("Field is locked now. It cannot be changed in Config.C\n");
		
    simulator.SetMakeSDigits("MUON ITS");
		
		// only physics events
		sfname += "?EventType=7";
		
		// select one trigger ...
		if (trgname){
			AliCDBEntry *grp_ctp = cdbm->Get("GRP/CTP/Config",run);
			AliTriggerConfiguration *trg_conf = (AliTriggerConfiguration *)grp_ctp->GetObject();
			trg_conf->Print();
			TObjArray trg_masks = trg_conf->GetClasses(); // Reference!!!
			std::vector<unsigned char> triggerconfs;
			for(Int_t iobj = 0; iobj < trg_masks.GetEntriesFast(); iobj++){
				AliTriggerClass *trg_class = (AliTriggerClass*)trg_masks.UncheckedAt(iobj);
				AliTriggerCluster *trg_clust = (AliTriggerCluster *)trg_class->GetCluster();
//				printf("%s %s \n",trg_class->GetName(),trgname);
				if(TString(trg_class->GetName()).Contains(trgname)){
					printf("We will embed into events containing this trigger name(mask): %s(%d)\n",trg_class->GetName(),trg_class->GetMask());
					char triggerbuf[256];
					sprintf(triggerbuf, "?Trigger=%d", trg_class->GetMask());
					sfname += triggerbuf;					
					//					triggerconfs.push_back(trg_class->GetMask());
				}
			}
			
			//			Int_t itrg = 0;
			//			printf("Number of Trigger Clusters including MUON: %d\n", (Int_t)triggerconfs.size());
			//    for(std::vector<unsigned char>::iterator it = triggerconfs.begin(); it < triggerconfs.end(); it++)
			//      printf("Trigger Mask %d for MUON: %d\n", itrg++, *it);
			//    filestring += "?EventType=7";
			//    char triggerbuf[256];
			//    Int_t triggerval = 0;
			//    for(std::vector<unsigned char>::iterator it = triggerconfs.begin(); it < triggerconfs.end(); it++)
			//      triggerval += *it;
			//    sprintf(triggerbuf, "?Trigger=%d", triggerval);
			//    filestring += triggerbuf; // This line does the trigger selection. It has to be uncommented if one wants to apply trigger selection
		}
		printf("Filename: %s\n", sfname.Data());
		
		Int_t iSelEvents = simulator.ConvertRaw2SDigits(sfname.Data(),esdname,nev);
		gSystem->Setenv("DC_NEVENTS",Form("%d",iSelEvents));
		gSystem->Exec("echo $DC_NEVENTS > selev.log");
		//			gSystem->Exec("echo ${DC_NEVENTS} > ${DC_NEVENTS}_${DC_NEVENTS}_0_${DC_NEVENTS}.stat"); // done in simrun.C
		gSystem->Exec("echo in sim.C $DC_NEVENTS");
		return;
	}
	
	// Signal: pure signal 
	if (!(strcmp(embrun,"kSignal"))){
		
		if (!gSystem->Getenv("DC_NEVENTS")) {
			printf("DC_NEVENTS is not set and is needed at this step!!!");
			return;
		} 
		
		AliCDBManager *cdbm = AliCDBManager::Instance();
		cdbm->SetDefaultStorage("alien://Folder=/alice/data/2011/OCDB");     
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
		simulator.SetMakeSDigits("MUON ITS");    
		simulator.EmbedInto("Background/galice.root",1);
		// THE OCDB PART
		simulator.SetDefaultStorage("alien://Folder=/alice/data/2011/OCDB");
		
		// Read GRP Data from RAW
		simulator.SetSpecificStorage("GRP/GRP/Data","alien://Folder=/alice/data/2011/OCDB");    
	}
	
	simulator.SetRunSimulation(kTRUE);
	simulator.SetMakeDigits("MUON ITS");
	simulator.SetRunHLT("");
	//  simulator.SetRunHLT("libAliHLTMUON.so chains=dHLT-sim");
	simulator.SetRunQA(":");
	//  simulator.SetRunQA("MUON:ALL");    
	
	//  Mag.field from OCDB
	simulator.UseMagFieldFromGRP();
	
	// THE OCDB PART
	
	// MUON
//	simulator.SetSpecificStorage("MUON/Calib/Gains","alien://Folder=/alice/simulation/2008/v4-15-Release/Ideal/"); 
	simulator.SetSpecificStorage("MUON/Align/Data","alien://Folder=/alice/simulation/2008/v4-15-Release/Full/"); 
	
	// MUON Trigger
// 	simulator.SetSpecificStorage("MUON/Calib/GlobalTriggerCrateConfig","alien://folder=/alice/simulation/2008/v4-15-Release/Ideal");
// 	simulator.SetSpecificStorage("MUON/Calib/LocalTriggerBoardMasks","alien://folder=/alice/simulation/2008/v4-15-Release/Ideal");
// 	simulator.SetSpecificStorage("MUON/Calib/RegionalTriggerConfig","alien://folder=/alice/simulation/2008/v4-15-Release/Ideal");
// 	simulator.SetSpecificStorage("MUON/Calib/TriggerEfficiency","alien://folder=/alice/simulation/2008/v4-15-Release/Full");
	
	// The rest
	
	simulator.Run(nev);
	
}
