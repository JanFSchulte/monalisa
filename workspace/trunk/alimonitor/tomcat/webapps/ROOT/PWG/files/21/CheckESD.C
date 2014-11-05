Bool_t CheckESD(const char* gAliceFileName = "galice.root", 
		const char* esdFileName = "AliESDs.root")
{
  // open run loader and load gAlice, kinematics and header
  AliRunLoader* runLoader = AliRunLoader::Open(gAliceFileName);
  if (!runLoader) {
    Error("CheckESD", "getting run loader from file %s failed", 
	    gAliceFileName);
    return kFALSE;
  }
  runLoader->LoadgAlice();
  gAlice = runLoader->GetAliRun();
  if (!gAlice) {
    Error("CheckESD", "no galice object found");
    return kFALSE;
  }
  runLoader->LoadKinematics();
  runLoader->LoadHeader();

  // open the ESD file
  TFile* esdFile = TFile::Open(esdFileName);
  if (!esdFile || !esdFile->IsOpen()) {
    Error("CheckESD", "opening ESD file %s failed", esdFileName);
    return kFALSE;
  }
  AliESDEvent * esd = new AliESDEvent;
  TTree* tree = (TTree*) esdFile->Get("esdTree");
  if (!tree) {
    Error("CheckESD", "no ESD tree found");
    return kFALSE;
  }
  esd->ReadFromTree(tree);

  // loop over events
  for (Int_t iEvent = 0; iEvent < runLoader->GetNumberOfEvents(); iEvent++) {
    runLoader->GetEvent(iEvent);

    // get the event summary data
    tree->GetEvent(iEvent);
    if (!esd) {
      Error("CheckESD", "no ESD object found for event %d", iEvent);
      return kFALSE;
    }

  }

  // write the output histograms to a file
  TFile* outputFile = TFile::Open("check.root", "recreate");
  if (!outputFile || !outputFile->IsOpen()) {
    Error("CheckESD", "opening output file check.root failed");
    return kFALSE;
  }
  outputFile->Close();
  delete outputFile;

  delete esd;
  esdFile->Close();
  delete esdFile;

  runLoader->UnloadHeader();
  runLoader->UnloadKinematics();
  delete runLoader;

  // result of check
  Info("CheckESD", "check of ESD was successfull");
  return kTRUE;
}
