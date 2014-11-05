void sim(Int_t nev=200) {
  AliLog::SetGlobalLogLevel(AliLog::kError);

  AliSimulation simu;
  simu.SetMakeSDigits("TPC TRD TOF PHOS HMPID EMCAL MUON FMD ZDC PMD T0 VZERO");
  simu.SetMakeDigitsFromHits("ITS");

  simu.SetDefaultStorage("alien://Folder=/alice/simulation/2008/v4-15-Release/Ideal");

  TStopwatch timer;
  timer.Start();
  simu.Run(nev);
  timer.Stop();
  timer.Print();
}
