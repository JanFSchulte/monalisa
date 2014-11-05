void sim(Int_t nev=5000) {
  AliLog::SetGlobalLogLevel(AliLog::kError);

  AliSimulation simu;

  // Set run number if defined
  if (gSystem->Getenv("DC_RUN")) {
    Int_t runNumber = atoi(gSystem->Getenv("DC_RUN"));
    simu.SetRunNumber(runNumber);
  }

  simu.SetMakeSDigits("EMCAL");
  simu.SetMakeDigits("EMCAL");
  simu.SetRunHLT("");
  simu.SetMakeTrigger("");
  simu.SetRunQA("EMCAL:ALL");

  simu.SetDefaultStorage("alien://Folder=/alice/simulation/2008/v4-15-Release/Ideal");
  simu.SetSpecificStorage("GRP/GRP/Data","alien://Folder=/alice/cern.ch/user/k/kharlov/production/pi0_2gamma");

  TStopwatch timer;
  timer.Start();
  simu.Run(nev);
  timer.Stop();
  timer.Print();
}
