"""
	creates pset.py and crab_cfg.py for train run
"""

import os, sys, subprocess

def sourceCrab(env):
    """Sometime you want to emulate the action of "source" in bash,
    settings some environment variables. Here is a way to do it."""
   
    
    pipe = subprocess.Popen("source /cvmfs/cms.cern.ch/crab3/crab.sh; env", stdout=subprocess.PIPE, shell=True,env=env)
    output = pipe.communicate()[0]
    env = dict((line.split("=", 1) for line in output.splitlines()))
    
    
    return env


def createCRABcfg(config,pset):
	
	
	
	
	
	repMap = {
		"theJob": Job,
		"ParameterSet": pset,
		"OutputFiles": OutputFiles,
		"datasetpath": DBSpath,
		"numEvents": numEvents,
		"workdir": WorkDir,
		"PublishName": PublishName,
		"customDBSBlock": "#no custom DBS",
		"GRID-AdditionsBlock": ""
	}
	#put CMSSW.increment_seeds=generator,VtxSmeared for production
	repMap.update(settings.getMap())
	repMap.update(settings.crabAdditionsBlocks)
	if "lumiMask" in repMap["Data-AdditionsBlock"]:		
		repMap["nUnits"] = repMap["lumis_per_job"]
		repMap["splitting"] = "LumiBased"
	else:
		repMap["nUnits"] = repMap["nEventsPerJob"]
		repMap["splitting"] = "LumiBased"

	txt = """from WMCore.Configuration import Configuration
config = Configuration()
	
config.section_("General")
	
config.General.requestName = "%(theJob)s"
config.General.workArea = "%(workdir)s"	
config.General.transferOutput = True
config.General.saveLogs = False
	
%(General-AdditionsBlock)s	
	
config.section_("JobType")

config.JobType.pluginName = "Analysis"
config.JobType.psetName = "%(ParameterSet)s"
#config.JobType.inputFiles = 
config.JobType.outputFiles = %(OutputFiles)s
config.JobType.allowNonProductionCMSSW = True
%(JobType-AdditionsBlock)s

config.section_("Data")

config.Data.inputDataset = "%(datasetpath)s"
config.Data.dbsUrl = "%(dbsurl)s"
config.Data.splitting = "%(splitting)s"
config.Data.unitsPerJob = %(nUnits)s
config.Data.totalUnits = %(numEvents)s
config.Data.publication = %(publish)s
config.Data.publishDbsUrl = "%(pubDBSURL)s"
config.Data.publishDataName = "%(theJob)s"
config.Data.ignoreLocality = True
config.Data.outlfn = "%(histogramstoragepath)s/%(theJob)s"

%(Data-AdditionsBlock)s

config.section_("Site")

config.Site.storageSite = "%(StageoutSite)s"
%(Site-AdditionsBlock)s

config.section_("User")

config.User.voGroup = "dcms"
%(User-AdditionsBlock)s

config.section_("Debug")

%(Debug-AdditionsBlock)s

""" % repMap
 	if not os.path.exists(os.path.dirname(crabcfg)):
 		os.makedirs(os.path.dirname(crabcfg))

	f = open(crabcfg, 'w')
	f.write(txt)
	f.close()
	return txt
	

def setupCMSSW(arch,releasepath):

        script = """
		TEMPVAR=`pwd`
        
        export SCRAM_ARCH={scram_arch}
        
        source /cvmfs/cms.cern.ch/cmsset_default.sh
		
		cd {release_path}/src/
		cmsenv
		cd $TEMPVAR; env
        """.format(scram_arch=arch, release_path=releasepath)
        f = open("source_CMSSW.sh", 'w')
        f.write(script)
        f.close()
        p = subprocess.Popen("chmod u+x source_CMSSW.sh", shell=True, stdout=subprocess.PIPE)
                
        p = subprocess.Popen("source /opt/monalisa/workspace/trunk/trainbackend/train-steer/source_CMSSW.sh ;  env", shell=True, stdout=subprocess.PIPE)
        output = p.communicate()[0]
        env = dict((line.split("=", 1) for line in output.splitlines()))
        #~ print env
        return env

def runConfigBuild(config,wagon,env):

	result = ""
	command = wagon.cmsCommand + " " + wagon.macroPath + " " + wagon.parameters
	p = subprocess.Popen("%s"%command ,env=env , shell=True, stdout=subprocess.PIPE)
	output = p.communicate()[0]
	for line in output.splitlines():
		if "created" in line:
			result = line.split(" ")[2]
	if result == "":
		result = "failed"		
	return result


def runTest(pset,env):
	
	import resource
	from time import sleep
	import numpy as np
	from ROOT import TCanvas, TGraph, TF1, TLegend, kBlue, gStyle, gPad, TPad
	
	usage_start = resource.getrusage(resource.RUSAGE_CHILDREN)
	rssList = []
	virtual = []
	other = []
	p = subprocess.Popen(["cmsRun" ,"%s"%pset], stdout=subprocess.PIPE, env=env)
	pid = p.pid
	while True:
		if p.poll() != None:
			break
		p2 = subprocess.Popen("top -b -n 1 | grep %s"%pid,shell=True,stdout=subprocess.PIPE)
		output = p2.communicate()[0]
		if "m" in output.split()[5]:
			rssList.append(output.split()[5].split("m")[0])			
		else:
			rssList.append(output.split()[5]) 
		if "m" in output.split()[4]:
			virtual.append(output.split()[4].split("m")[0])	
		else:
			virtual.append(output.split()[4])
		sleep(1)				

	
	output = p.communicate()[0]
	exitCode = p.returncode


	usage_end = resource.getrusage(resource.RUSAGE_CHILDREN)
	cpu_time = usage_end.ru_utime - usage_start.ru_utime	



	rssArray = np.array(rssList,"d")
	virtualArray = np.array(virtual,"d")
	xAxis = []
	for i in range(0,len(rssArray)):
		xAxis.append(i*(cpu_time/len(rssArray)))
		
	xAxisArray = np.array(xAxis,"d")	
	graphRSS = TGraph(len(rssArray),xAxisArray,rssArray)
	graphVirtual = TGraph(len(virtualArray),xAxisArray,virtualArray)
	
	graphRSS.SetMarkerColor(kBlue)
	graphRSS.SetMarkerStyle(21)
	
	c1 = TCanvas("c1","c1",800,800)
	
		
	legend = TLegend(0.65, 0.65, 0.98, 0.90)
	legend.SetFillStyle(0)
	legend.SetBorderSize(0)
		
	legend.AddEntry(graphRSS,"resident memory consumption","p")
	legend.AddEntry(graphVirtual,"virtual memory consumption","p")

	c1.DrawFrame(0,0,cpu_time+0.15*cpu_time,2000,";run time [s]; memory consumption [MB]")

	
	graphRSS.Draw("samep")
	graphVirtual.Draw("samep")
	legend.Draw("same")
	
	
	c1.Print("memory.pdf")
	
	rssMax = 0
	for i in rssList:
		if i > rssMax:
			rssMax = i 
	virtualMax = 0
	for i in virtual:
		if i > virtualMax
	
	return exitCode, rssMax, virtualMax, cpu_time
	


def submitCrabTask(pset,env,config):
	
	crabCfg = createCRABcfg(config,pset)
	env = sourceCrab(env)
	p = subprocess.Popen("crab submit -c %s"%crabCfg,shell=True,stdout=subprocess.PIPE,env=env)
	output = p.communicate()[0]	
	
	
	
def main():
	
	from sys import argv
	config  = __import__(argv[1], fromlist=[''])
	
	test = config.trainconfig.runConfig.test
	submitToGrid = config.trainconfig.runConfig.submitToGrid
	env = setupCMSSW(config.trainconfig.runConfig.scramArchitcture,config.trainconfig.runConfig.releasePath)
		
	i = 0
	for wagon in dir(config.trainconfig.wagons):		
		if (i > 1):
			pset = runConfigBuild(config,getattr(config.trainconfig.wagons, wagon), env)
			if test:
				runTest(pset,env)
			elif submitToGrid:
				submitCrabTask(pset,env,config)
				
		i = i +1
	

main()	
