Bool_t CheckESD(const char* gAliceFileName = "galice_rec.root",
                const char* esdFileName = "AliESDs.root")
{

  AliCDBManager *fCDBManager = AliCDBManager::Instance();
  fCDBManager->SetDefaultStorage("alien://Folder=/alice/simulation/2008/v4-10-Release/Ideal/");

  AliMUONDataInterface dRec(gAliceFileName);
  Int_t sx, sy, dev, sdev, lpt, hpt, trigy, circ, event;
  Int_t nTracks;
  UShort_t x1pat, x2pat, x3pat, x4pat;
  Bool_t triggerLocalMatched[243], bmatch;

  TFile* outputFile = TFile::Open("check.root", "recreate");
  if (!outputFile || !outputFile->IsOpen()) {
    Error("CheckESD", "opening output file check.root failed");
    return kFALSE;
  }
  TTree *treeCheck = new TTree("LocalTrigger","LocalTrigger not matched to rec tracks");
  treeCheck->Branch("event", &event,  "event/I");
  treeCheck->Branch("circ",  &circ,  "circ/I");
  treeCheck->Branch("stripx",&sx,    "sx/I");
  treeCheck->Branch("stripy",&sy,    "sy/I");
  treeCheck->Branch("dev",   &dev,   "dev/I");
  treeCheck->Branch("lpt",   &lpt,   "lpt/I");
  treeCheck->Branch("hpt",   &hpt,   "hpt/I");
  treeCheck->Branch("x1pat", &x1pat, "x1pat/s");
  treeCheck->Branch("x2pat", &x2pat, "x2pat/s");
  treeCheck->Branch("x3pat", &x3pat, "x3pat/s");
  treeCheck->Branch("x4pat", &x4pat, "x4pat/s");
  treeCheck->Branch("match", &bmatch,"bmatch/b");

  // open run loader and load gAlice, kinematics and header
  AliRunLoader* runLoader = AliRunLoader::Open(gAliceFileName);
  if (!runLoader) {
    Error("CheckESD", "getting run loader from file %s failed",
            gAliceFileName);
    return kFALSE;
  }

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

    event = iEvent;

    runLoader->GetEvent(iEvent);

    // get the event summary data
    tree->GetEvent(iEvent);
    if (!esd) {
      Error("CheckESD", "no ESD object found for event %d", iEvent);
      return kFALSE;
    }

    // mark local triggers matched to reconstructed tracks
    for (Int_t ib = 0; ib < 243; ib++) triggerLocalMatched[ib] = kFALSE;
    nTracks = esd->GetNumberOfMuonTracks();
    for(Int_t iTracks = 0; iTracks < nTracks; iTracks++) {
      AliESDMuonTrack* muonTrack = esd->GetMuonTrack(iTracks);
      if (muonTrack->GetMatchTrigger()) {
        triggerLocalMatched[muonTrack->LoCircuit()] = kTRUE;
      }
    }

    // loop of local trigger boards
    AliMUONVTriggerStore *triggerStore = dRec.TriggerStore(iEvent);
    for (Int_t ib = 1; ib <= 234; ib++) {
      AliMUONLocalTrigger *triggerLocal = triggerStore->FindLocal(ib);

      dev   = triggerLocal->LoDev();
      sdev  = triggerLocal->LoSdev();
      trigy = triggerLocal->LoTrigY();
      sy   = triggerLocal->LoStripY();

      // skip local boards which have not triggered in x or y
      if ((sdev == 1 && dev == 0) || (trigy == 1 && sy == 15)) {
        continue;
      }

      Int_t sign = 0;
      if ( !sdev &&  dev ) sign=-1;
      if ( !sdev && !dev ) sign= 0;
      if (  sdev == 1 )    sign=+1;
      dev *= sign;
      dev += 15;

      circ = triggerLocal->LoCircuit();
      sx   = triggerLocal->LoStripX();
      lpt  = triggerLocal->LoLpt();
      hpt  = triggerLocal->LoHpt();

      // trigger x-patterns
      x1pat = GetInt(triggerLocal->GetX1Pattern());
      x2pat = GetInt(triggerLocal->GetX2Pattern());
      x3pat = GetInt(triggerLocal->GetX3Pattern());
      x4pat = GetInt(triggerLocal->GetX4Pattern());

      if (!triggerLocalMatched[circ]) {
        bmatch = kFALSE;
      } else {
        bmatch = kTRUE;
      }

      treeCheck->Fill();

    }

  }

  // write the output to a file
  outputFile->cd();
  treeCheck->Write();
  outputFile->Close();
  delete outputFile;

  delete esd;
  esdFile->Close();
  delete esdFile;

  delete runLoader;

  // result of check
  Info("CheckESD", "check of ESD was successfull");
  return kTRUE;
}

Int_t GetInt(UShort_t short) {

  Int_t vint = 0;
  for (Int_t i = 0; i < 16; i++) {
    vint += ((short >> i) & 1 ) << i;
  }

  return vint;

}
