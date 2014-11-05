//#define VERBOSEARGS

{
  // set job and simulation variables as :
  // root run.C  --run <x> --event <y> --bmin <min> --bmax <max> --quench <quench> --qhat <shad> --etamin <etamin> --etamax <etamax> --phimin <phimin> --phimax <phimax>
  // root simRun.C --run 1 --event 10 --bmin 0 --bmax 3 --quench 1 --qhat 1 --etamin -2 --etamax 2 --phimin 0 --phimax 6.283185

  int nrun = 0;
  int nevent = 0;
  int seed = 0;

//   float minpthard = -1;
//   float maxpthard = -1;
//   float minptgammapi0 = 1;

  char sseed[1024];
  char srun[1024];
  char sevent[1024];
  char sbmin[1024];
  char sbmax[1024];
  char setamin[1024];
  char setamax[1024];
  char sphimin[1024];
  char sphimax[1024];
  char squench[1024];
  char sqhat[1024];

  sprintf(sseed,"");
  sprintf(srun,"");
  sprintf(sevent,"");
  sprintf(sbmin,"");
  sprintf(sbmax,"");
  sprintf(setamin,"");
  sprintf(setamax,"");
  sprintf(sphimin,"");
  sprintf(sphimax,"");
  sprintf(squench,"");
  sprintf(sqhat,"");

  for (int i=0; i< gApplication->Argc();i++){
#ifdef VERBOSEARGS
    printf("Arg  %d:  %s\n",i,gApplication->Argv(i));
#endif
    if (!(strcmp(gApplication->Argv(i),"--run")))
      nrun = atoi(gApplication->Argv(i+1));
    sprintf(srun,"%d",nrun);
    if (!(strcmp(gApplication->Argv(i),"--event")))
      nevent = atoi(gApplication->Argv(i+1));
    sprintf(sevent,"%d",nevent);

    if (!(strcmp(gApplication->Argv(i),"--bmin")))
      sprintf(sbmin,gApplication->Argv(i+1));

    if (!(strcmp(gApplication->Argv(i),"--bmax")))
      sprintf(sbmax,gApplication->Argv(i+1));

    if (!(strcmp(gApplication->Argv(i),"--etamin")))
      sprintf(setamin,gApplication->Argv(i+1));

    if (!(strcmp(gApplication->Argv(i),"--etamax")))
      sprintf(setamax,gApplication->Argv(i+1));

    if (!(strcmp(gApplication->Argv(i),"--phimin")))
      sprintf(sphimin,gApplication->Argv(i+1));

    if (!(strcmp(gApplication->Argv(i),"--phimax")))
      sprintf(sphimax,gApplication->Argv(i+1));

    if (!(strcmp(gApplication->Argv(i),"--quench")))
      sprintf(squench,gApplication->Argv(i+1));

    if (!(strcmp(gApplication->Argv(i),"--qhat")))
      sprintf(sqhat,gApplication->Argv(i+1));

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

    fprintf(stdout,"!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!\n");
    fprintf(stdout,"!!!  Run is %d \n",srun);
    fprintf(stdout,"!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!\n");

    fprintf(stdout,"!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!\n");
    fprintf(stdout,"!!!  Event is %d \n",sevent);
    fprintf(stdout,"!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!\n");

    fprintf(stdout,"!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!\n");
    fprintf(stdout,"!!!  b min is %d \n",sbmin);
    fprintf(stdout,"!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!\n");

    fprintf(stdout,"!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!\n");
    fprintf(stdout,"!!!  bmax is %d \n",sbmax);
    fprintf(stdout,"!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!\n");

    fprintf(stdout,"!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!\n");
    fprintf(stdout,"!!!  eta min is %d \n",setamin);
    fprintf(stdout,"!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!\n");

    fprintf(stdout,"!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!\n");
    fprintf(stdout,"!!!  eta max is %d \n",setamax);
    fprintf(stdout,"!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!\n");

    fprintf(stdout,"!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!\n");
    fprintf(stdout,"!!!  phi min is %d \n",sphimin);
    fprintf(stdout,"!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!\n");

    fprintf(stdout,"!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!\n");
    fprintf(stdout,"!!!  phi max is %d \n",sphimax);
    fprintf(stdout,"!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!\n");

    fprintf(stdout,"!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!\n");
    fprintf(stdout,"!!!  Quenching is %d \n",squench);
    fprintf(stdout,"!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!\n");

    fprintf(stdout,"!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!\n");
    fprintf(stdout,"!!!  Shadowing is %d \n",sqhat);
    fprintf(stdout,"!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!\n");


  // set the seed environment variable
  gSystem->Setenv("CONFIG_SEED",sseed);
  gSystem->Setenv("DC_RUN",srun);
  gSystem->Setenv("DC_EVENT",sevent);
  gSystem->Setenv("CONFIG_BMIN",sbmin);//"20");
  gSystem->Setenv("CONFIG_BMAX",sbmax);//"30");
  gSystem->Setenv("QUENCH",squench);
  gSystem->Setenv("QHAT",sqhat);
  gSystem->Setenv("CONFIG_ETAMIN",setamin);//"20");
  gSystem->Setenv("CONFIG_ETAMAX",setamax);//"30");
  gSystem->Setenv("CONFIG_PHIMIN",sphimin);//"20");
  gSystem->Setenv("CONFIG_PHIMAX",sphimax);//"30");
//  gSystem->Setenv("ALIMDC_RAWDB1","./mdc1");
//  gSystem->Setenv("ALIMDC_RAWDB2","./mdc2");
//  gSystem->Setenv("ALIMDC_TAGDB","./mdc1/tag");
//  gSystem->Setenv("ALIMDC_RUNDB","./mdc1/meta");
//  gSystem->Exec("cp $ROOTSYS/etc/system.rootrc .rootrc");
  gSystem->Exec("aliroot -b -q \"sim.C(2)\" > sim.log 2>&1");
  gSystem->Exec("aliroot -b -q rec.C > rec.log 2>&1");
  gSystem->Exec("aliroot -b -q tag.C > tag.log 2>&1");

}
