void sim(Int_t nev=100) {

    AliSimulation MuonSim;
    MuonSim.SetMakeTrigger("MUON");
    MuonSim.SetMakeSDigits("MUON ITS VZERO");
    MuonSim.SetMakeDigits("MUON ITS VZERO FMD");
    MuonSim.SetWriteRawData("MUON ITS VZERO FMD","raw.root",kTRUE);
    MuonSim.SetDefaultStorage("alien://Folder=/alice/simulation/2007/PDC07_v4-07-Rev-01/Ideal/CDB/?cacheFold=/tmp/CDBCache"); 

    TStopwatch timer;
    timer.Start();
    MuonSim.Run(nev);
    timer.Stop();
    timer.Print();

}
