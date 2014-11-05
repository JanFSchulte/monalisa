void rewrite_syswatch()
{
  tree = AliSysInfo::MakeTree("syswatch.log");

  TFile::Open("syswatch.root", "RECREATE");
  tree->Write("syswatch");
  gFile->Close();
}
