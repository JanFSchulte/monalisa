void sim(Int_t nev=200) {

  AliSimulation simulator;
  simulator.SetMakeSDigits("TRD TOF PHOS HMPID EMCAL MUON FMD ZDC PMD T0 VZERO");
  simulator.SetMakeDigitsFromHits("ITS TPC");
  simulator.SetWriteRawData("ALL","raw.root",kTRUE);
simulator.SetDefaultStorage("alien://Folder=/alice/simulation/2008/v4-12-Release/Full/");
  simulator.SetRunHLT("");
  simulator.SetQA(kFALSE);
 
  TStopwatch timer;
  timer.Start();
  simulator.Run(nev);
  timer.Stop();
  timer.Print();
}
