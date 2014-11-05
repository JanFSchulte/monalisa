void sim(Int_t nev=100) {
  AliSimulation simu;
  simu.SetMakeSDigits("TRD TOF PHOS HMPID EMCAL MUON FMD ZDC PMD T0 VZERO");
  simu.SetMakeDigitsFromHits("ITS TPC");
  simu.SetWriteRawData("ALL","raw.root",kTRUE);
  simu.SetDefaultStorage("alien://Folder=/alice/simulation/2008/v4-10-Release/Residual/?cacheFold=/tmp/CDBCache?operateDisconnected=kFALSE");

  simu.SetQA(kFALSE) ;

  TStopwatch timer;
  timer.Start();
  simu.Run(nev);
  timer.Stop();
  timer.Print();
}
