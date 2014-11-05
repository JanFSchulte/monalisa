void sim(Int_t nev=500) {

    AliSimulation MuonSim;
    MuonSim.SetMakeTrigger("MUON");
    MuonSim.SetMakeSDigits("MUON ITS VZERO");
    MuonSim.SetMakeDigits("MUON ITS VZERO FMD");
    MuonSim.SetWriteRawData("MUON ITS VZERO FMD","raw.root",kTRUE);
    MuonSim.SetDefaultStorage("alien://Folder=/alice/simulation/2008/v4-10-Release/Ideal/"); 
    MuonSim.SetSpecificStorage("MUON/Calib/TriggerLut","alien://Folder=/alice/cern.ch/user/b/bogdan/prod2008/cdb/");

    TStopwatch timer;
    timer.Start();
    MuonSim.Run(nev);
    timer.Stop();
    timer.Print();

}
