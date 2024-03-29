void sim(Int_t nev=200) {

  AliSimulation simu;
  simu.SetMakeSDigits("TRD TOF PHOS HMPID EMCAL MUON FMD ZDC PMD T0 VZERO");
  simu.SetMakeDigitsFromHits("ITS TPC");

  simu.SetDefaultStorage("alien://Folder=/alice/simulation/2008/v4-15-Release/Ideal");

  TStopwatch timer;
  timer.Start();
  simu.Run(nev);
  timer.Stop();
  timer.Print();
}
