# From https://github.com/SD2E/plan-requests

from agavepy.agave import Agave
import json
import time
import os
import xplan_api.lab.transcriptic as transcriptic_config
import xplan_api.s_expr.problem as prob
from pyDOE import *

ag = Agave.restore()
print('%r' % (ag))

# Create an XPlan Request
## Plan Metadata ##

experimentId = "1"
experimentLab=transcriptic_config.experimentLab
experimentSet="rule-30_q0"
planId="b7cf7a75-9769-4d54-a807-ac81b92fb0af"
planName="Rule30 Q0 Plan"

## Experiment Resources ##

plasmid1={ "name" : "http://sd2e.org#pAN3928", "type" : "plasmid"}
plasmid2={ "name" : "http://sd2e.org#pAN4036", "type" : "plasmid"}
plasmid3={ "name" : "http://sd2e.org#pAN1201", "type" : "plasmid"}
plasmid4={ "name" : "http://sd2e.org#pAN1717", "type" : "plasmid"}
host={ "name" : "http://sd2e.org#NEB_10-beta", "type" : "host" }
beadcontrol="http://sd2e.org#beadcontrol"

strains=[{ "host" : host, "plasmids" : [plasmid3], "control" : "negative" },   #01-03
        { "host" : host, "plasmids" : [plasmid1, plasmid2], "control" : ""  }, #04-06
        { "host" : host, "plasmids" : [plasmid4], "control" : "positive" }]    #07-09

# Give the strains IDs
for strain, strain_id in zip(strains, range(1, len(strains) + 1)):
    strain["strain_id"] = strain_id

inducer1={ "name" : "http://sd2e.org#Larabinose_measure", "values" : ["0", "5"], "type" : "inducer"}
inducer2={ "name" : "http://sd2e.org#IPTG_measure",      "values" : ["0", "1"], "type" : "inducer"}
inducer3={ "name" : "http://sd2e.org#aTc_measure",       "values" : ["0", "0.002"], "type" : "inducer"}

#inducer1={ "name" : "http://sd2e.org#Larabinose", "values" : ["0mM", "5mM"], "type" : "inducer"}
#inducer2={ "name" : "http://sd2e.org#IPTG",      "values" : ["0mM", "1mM"], "type" : "inducer"}
#inducer3={ "name" : "http://sd2e.org#aTc",       "values" : ["0mM", "2ng/ml"], "type" : "inducer"}


## DOE Setup ##

replicates=range(1,4)

# Experimental Factors (Variables)
factors=[
    { "name" : "Biological Replicate", "values" : replicates },
    { "name" : "strain",                "values" : strains },
    { "name" : inducer2["name"],        "values" : inducer2["values"] },
    { "name" : inducer3["name"],        "values" : inducer3["values"] },
    { "name" : inducer1["name"],        "values" : inducer1["values"] }
    ]

# Experimental Levels (value size)
levels=[len(factor["values"]) for factor in factors]

# Construct the test matrix
doe=fullfact(levels)

data_point_descriptions = []
for row in doe:
    data_point_description = []
    for factor in range(len(factors)):
        data_point_description.append({
            "name" : factors[factor]["name"],
            "value" : factors[factor]["values"][int(row[factor])]})
    data_point_descriptions.append(data_point_description)

## Determine sample ids for canned Rule30 data ##

sample_ids=[]
samples_to_files=[]
alpha_prefixes=["A", "B", "C", "D", "E", "F", "G", "H"]
alpha_index=-1
for row_idx in range(len(doe)):
    index=(row_idx%9)+1
    if index == 1:
        alpha_index += 1
    sample_id = \
        "agave://data-sd2e-community/transcriptic/rule-30_q0/1/09242017/" + \
        alpha_prefixes[alpha_index] + "0" + str(index)
    sample_ids.append(sample_id)
    file_id = "agave://data-sd2e-community/transcriptic/rule-30_q0/1/instrument_output/SD30_09242017_SD30_09242017_Rule30Plate_" + alpha_prefixes[alpha_index]  + str(index)  + ".fcs"
    samples_to_files.append({ "source" : sample_id, "file" : file_id } )


extra_sample_conditions=[
    {
        "sample_id": 'agave://data-sd2e-community/transcriptic/rule-30_q0/1/09242017/beadcontrol',
        "name" : "bead_model",
        "value" : "SpheroTech URCP-38-2K"
    },
    {
        "sample_id": 'agave://data-sd2e-community/transcriptic/rule-30_q0/1/09242017/beadcontrol',
        "name" : "bead_batch",
        "value" : "Lot AJ02"
    },
    {
        "sample_id" : 'agave://data-sd2e-community/transcriptic/rule-30_q0/1/09242017/A04',
        "name" : "Is_Blank",
        "value" : True
     }
]

sample_ids.append('agave://data-sd2e-community/transcriptic/rule-30_q0/1/09242017/beadcontrol')

samples_to_files.append(
    {
        "source" : 'agave://data-sd2e-community/transcriptic/rule-30_q0/1/09242017/beadcontrol',
        "file" : "agave://data-sd2e-community/transcriptic/rule-30_q0/1/09242017/instrument_output/SD30_09242017_SD30_09242017_Rule30Plate_A12.fcs"
    })


# Plan:
# Build
# 1) Prepare Plasmids
# Transform
# 2) Transform Plasmids
# Culture
# 3) Pick -> 96 well V
# 4) Incubate
# 5) Dilute
# 6) Incubate
# 7) Dilute
# 8) Transfer (induce)
# Measure
# 9) flow (use sample ids)
# ---
# 10) dilute
# 11) incubate
# 12) rnaSeq


## Replicatessources available for plan ##
plasmids=[plasmid1, plasmid2, plasmid3, plasmid4]
hosts=[host]
inducers=[inducer1, inducer2, inducer3]
resources={"plasmids" : plasmids,
           "hosts" : hosts,
           "inducers" : inducers}

## Goals for the Plan ##
goal_data=doe.tolist()
goal_data.append(["beadcontrol"])
goals=[{"measure" : "flowCytometry", "sample" : data_point} for data_point in goal_data]

methods=''

for dp_desc, sample_id in zip(data_point_descriptions, sample_ids):
    for dp in dp_desc:
        dp['sample_id'] = sample_id

for goal, sample_id in zip(goals, sample_ids):
    goal['sample_id'] = sample_id

## Problem Description ##
problem=prob.Problem(experiment_id=experimentId,
               experiment_lab=experimentLab,
               experiment_set=experimentSet,
               plan_id=planId,
               plan_name=planName,
               resources=resources,
               strains=strains,
               goals=goals,
               methods=methods,
               data_points=data_point_descriptions,
               extra_sample_conditions=extra_sample_conditions,
               samples_to_files=samples_to_files,
               cost_table='',
               libraries=[])

print str(problem)

plan_request_file = "/tmp/xplan_problem_" + time.strftime("%Y%m%d-%H%M%S") + ".lisp"
f = open(plan_request_file, 'w+')
f.write(str(problem))
f.close()

# Copy to public plan directory

import_status = ag.files.importData(systemId='data-sd2e-community',
                                    filePath='plan',
                                    fileToUpload=open(plan_request_file))

# Wait for file upload to complete
def ag_list_files(ag, sysId, path=''):
    return [f['name'] for f in ag.files.list(systemId=sysId,
                                            filePath=path)]

plan_request = os.path.basename(plan_request_file)
while plan_request not in ag_list_files(ag,
                                             'data-sd2e-community',
                                             'plan'):
    print "Waiting for %s" % (plan_request)
    time.sleep(3)

print "Plan request %s has uploaded" % (plan_request)


# Setup Job for XPlan
job  = {
    "name": "xplan-test",
    "appId": "xplan-dbryce-0.1.0",
    "archive": True,
    "archivePath":"/plan/",
    "archiveSystem" : "data-sd2e-community",
    "parameters": {
	"problem": "agave://data-sd2e-community/plan/" + plan_request
    }
}

print job

# Submit the job to run
my_job = ag.jobs.submit(body=job)
my_job

while ag.jobs.getStatus(jobId=my_job['id'])['status'] != 'FINISHED':
    time.sleep(1)

print 'Done!'

job_status = ag.jobs.getStatus(jobId=my_job['id'])
print job_status

exit(0)
