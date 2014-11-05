void sim(Int_t nev=200) {

  AliLog::SetGlobalLogLevel(AliLog::kError);
  AliSimulation simulator;
  simulator.SetMakeSDigits("TPC TRD TOF FMD T0 VZERO PHOS HMPID EMCAL PMD MUON ZDC");
  simulator.SetMakeDigitsFromHits("ITS");
  simulator.SetDefaultStorage("alien://Folder=/alice/simulation/2008/v4-15-Release/Ideal/");
 
  TStopwatch timer;
  timer.Start();
  simulator.Run(nev);
  timer.Stop();
  timer.Print();
}
