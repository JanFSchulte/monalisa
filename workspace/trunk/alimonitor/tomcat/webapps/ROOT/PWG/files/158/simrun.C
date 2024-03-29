// #define VERBOSEARGS
// simrun.C
{
  // extract the run and event variables

  int nrun = 0;
  int nevent = 0;
  int seed = 0;

  char sseed[1024];
  char srun[1024];
  char sevent[1024];
  char sprocess[1024];
  char sfield[1024];
  char senergy[1024];

  sprintf(srun,"");
  sprintf(sevent,"");
  sprintf(sprocess,"");
  sprintf(sfield,"");
  sprintf(senergy,"");

  for (int i=0; i< gApplication->Argc();i++){
#ifdef VERBOSEARGS
    printf("Arg %d:  %s\n",i,gApplication->Argv(i));
#endif
    if (!(strcmp(gApplication->Argv(i),"--run")))
      nrun = atoi(gApplication->Argv(i+1));
    sprintf(srun,"%d",nrun);
    if (!(strcmp(gApplication->Argv(i),"--event")))
      nevent = atoi(gApplication->Argv(i+1));
    sprintf(sevent,"%d",nevent);
    if (!(strcmp(gApplication->Argv(i),"--process")))
      sprintf(sprocess, gApplication->Argv(i+1));
    if (!(strcmp(gApplication->Argv(i),"--field")))
      sprintf(sfield,gApplication->Argv(i+1));
    if (!(strcmp(gApplication->Argv(i),"--energy")))
      sprintf(senergy,gApplication->Argv(i+1));
  }

  seed = nrun * 100000 + nevent;
  sprintf(sseed,"%d",seed);

  if (seed==0) {
    fprintf(stderr,"!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!\n");
    fprintf(stderr,"!!!!  WARNING! Seeding variable for MC is 0          !!!!\n");
    fprintf(stderr,"!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!\n");
  } else {
    fprintf(stdout,"!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!\n");
    fprintf(stdout,"!!!  MC Seed is %d \n",seed);
    fprintf(stdout,"!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!\n");
  }

// set the seed environment variable
  gSystem->Setenv("CONFIG_SEED",sseed);
  gSystem->Setenv("CONFIG_RUN_TYPE",sprocess); // kPythia6 or kPhojet
  gSystem->Setenv("CONFIG_FIELD",sfield);      // kNoField or k5kG
  gSystem->Setenv("CONFIG_ENERGY",senergy);    // 900, 7000 or 10000 (GeV)
  gSystem->Setenv("DC_RUN",srun); // Not used in Config.C
  gSystem->Setenv("DC_EVENT",sevent); // Not used in Config.C


  gSystem->Setenv("ALIMDC_RAWDB1","./mdc1");
  gSystem->Setenv("ALIMDC_RAWDB2","./mdc2");
  gSystem->Setenv("ALIMDC_TAGDB","./mdc1/tag");
  gSystem->Setenv("ALIMDC_RUNDB","./mdc1/meta");
  cout<< "SIMRUN:: Run " << gSystem->Getenv("DC_RUN") << " Event " << gSystem->Getenv("DC_EVENT")
	  << " Generator "    << gSystem->Getenv("CONFIG_RUN_TYPE")
	  << " Field " << gSystem->Getenv("CONFIG_FIELD")
	  << " Energy " << gSystem->Getenv("CONFIG_ENERGY")
	  << endl;

  gSystem->Exec("cp $ALICE_ROOT/.rootrc .rootrc");
  gSystem->Exec("aliroot -b -q sim.C 2>&1 | tee sim.log");
  gSystem->Exec("aliroot -b -q rec.C 2>&1 | tee rec.log");
  gSystem->Exec("aliroot -b -q tag.C 2>&1 | tee tag.log");
  gSystem->Exec("aliroot -b -q CheckESD.C 2>&1 | tee check.log");
  gSystem->Exec("aliroot -b -q CreateAODfromESD.C 2>&1 | tee aod.log");

}
