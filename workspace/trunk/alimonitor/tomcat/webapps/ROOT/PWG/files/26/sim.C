void sim(Int_t nev=100) {
  AliSimulation simu;
  simu.SetMakeSDigits("TRD TOF PHOS HMPID  EMCAL MUON FMD PMD T0 ZDC VZERO");
  simu.SetMakeDigits ("TRD TOF PHOS HMPID  EMCAL MUON FMD PMD T0 ZDC VZERO");
  simu.SetMakeDigitsFromHits("ITS TPC");
  simu.SetWriteRawData("ALL","raw.root",kTRUE);
  simu.SetDefaultStorage("alien://Folder=/alice/simulation/2008/v4-10-Release/Residual/?cacheFold=/tmp/CDBCache?operateDisconnected=kFALSE");
  simu.SetSpecificStorage("EMCAL/*","local://DB");

  simu.SetQA(kFALSE) ;

  TStopwatch timer;
  timer.Start();
  simu.Run(nev);
  WriteXsection();
  timer.Stop();
  timer.Print();
}

WriteXsection()
{
  TPythia6 *pythia = TPythia6::Instance();
  pythia->Pystat(1);
  Double_t xsection = pythia->GetPARI(1);
  Int_t    ntrials  = pythia->GetMSTI(5);

  TTree   *tree   = new TTree("Xsection","Pythia cross section");
  TBranch *branch = tree->Branch("xsection", &xsection, "X/D");
  TBranch *branch = tree->Branch("ntrials" , &ntrials , "X/i");
  tree->Fill();

  TFile *file = new TFile("pyxsec.root","recreate");
  tree->Write();
  file->Close();

  cout << "Pythia cross section: " << xsection
       << ", number of trials: " << ntrials << endl;
}