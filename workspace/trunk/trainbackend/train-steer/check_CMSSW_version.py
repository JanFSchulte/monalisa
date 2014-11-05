"""
tool to check available CMSSW releases for given list of SCRAM architectures
list of releases will be written to the database

author: Jan-Frederik Schulte (jschulte@cern.ch) 01.11.2014
"""

import subprocess, os

supportedArchitectures = ["slc5_amd64_gcc434","slc5_amd64_gcc461","slc5_amd64_gcc462","slc5_amd64_gcc470","slc5_amd64_gcc472","slc6_amd64_gcc480","slc5_amd64_gcc481","slc6_mic_gcc481","slc6_amd64_gcc490"]

def shell_source(script):
    """Sometime you want to emulate the action of "source" in bash,
    settings some environment variables. Here is a way to do it."""
    
    pipe = subprocess.Popen(". %s; env" % script, stdout=subprocess.PIPE, shell=True)
    output = pipe.communicate()[0]
    env = dict((line.split("=", 1) for line in output.splitlines()))
    return env


def updateDB(results):
	
	import psycopg2
	import sys


	con = None

	try:
		 
		conn_string = "dbname='mon_data' user='mon_user'"
		conn = psycopg2.connect(conn_string)
		cursor = conn.cursor()
		cursor.execute("SELECT * FROM cmssw_releases")
		for record in cursor:
			release = record[0]
			arch = record[1]
			for entry in results:
				if entry[0] == release and entry[1] == arch:
					results.remove(entry)          
		for entry in results:
			cursor.execute("INSERT INTO cmssw_releases (release,architecture,path) VALUES ('%s','%s','%s')"%(entry[0],entry[1],entry[2]))		
		conn.commit()

	except psycopg2.DatabaseError, e:
		print 'Error %s' % e    
		sys.exit(1)
		
		
	finally:
		
		if con:
			con.close()		
	

def main():
	result = []
	for arc in supportedArchitectures:
		
		
		env = shell_source("/cvmfs/cms.cern.ch/cmsset_default.sh")
		env["SCRAM_ARCH"] = arc
		
		pipe = subprocess.Popen(["scram list CMSSW"],stdout=subprocess.PIPE,env=env,shell=True)
		releases = []
		while True:
			line = pipe.stdout.readline()
			if line != '':
				for element in line.split(" "):
					if "CMSSW_" in element:
							releases.append(element)
						 
			else:
				break
		i = 0		
		while i < len(releases)-1:
			result.append([releases[i],arc,releases[i+1].split("\n")[0]])
			i = i+2
			
	updateDB(result)
	
	
main()



