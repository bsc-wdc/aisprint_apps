#!/usr/bin/python
#
#  Copyright 2002-2023 Barcelona Supercomputing Center (www.bsc.es)
#
#  Licensed under the Apache License, Version 2.0 (the "License");
#  you may not use this file except in compliance with the License.
#  You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
#  Unless required by applicable law or agreed to in writing, software
#  distributed under the License is distributed on an "AS IS" BASIS,
#  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#  See the License for the specific language governing permissions and
#  limitations under the License.
#

# -*- coding: utf-8 -*-

from pycompss.api.parameter import *
from pycompss.api.task import task
from pycompss.api.api import compss_wait_on
from pycompss.api.constraint import constraint
from dislib.trees import RandomForestClassifier
import dislib as ds
import numpy as np

class Report():

    def __init__(self):
        import socket
        hostname = socket.gethostname()
        self.accuracy = None
        self.node = hostname

    def __str__(self):
        return "Accuracy of model: " + str(self.accuracy)

    def set_accuracy(self, accuracy):
        self.accuracy = accuracy

    def get_accuracy(self):
        return self.accuracy

def pairwise(iterable):
    "s -> (s0, s1), (s2, s3), (s4, s5), ..."
    a = iter(iterable)
    return zip(a, a)

@task(files=IN, evaluate_files=IN)
def main_program(files, evaluate_files):
    print(">>>>>>>>>>>>>>>>>>>>>> Calling taining for file "+files, flush=True)
    files = files.split(",")
    evaluate_files = evaluate_files.split(",")
    test_file, test_file_y = evaluate_files
    models = []
    reports = []

    for file, file_y in pairwise(files):
        print(">>>>>>>>>>>>>>>>>>>>>> Calling training for file "+file, flush=True)
        model = RandomForestClassifier(n_estimators=40, distr_depth=2, random_state=0)
        train_model(model, file, file_y)
        models.append(model)

    for model in models:
        report = evaluate(model, test_file, test_file_y)
        reports.append(report)

    global_model = merge_models(models)
    global_report = evaluate(global_model, test_file, test_file_y)

    for report in reports:
        report = compss_wait_on(report);
        print("Partial Results for model "+report.node, flush=True)
        print(report, flush=True)

    print("Final Results for global model ", flush=True)
    global_report = compss_wait_on(global_report);
    print(global_report, flush=True)

@constraint(computing_units="48")
@task(model=INOUT, file = IN, file_y = IN)
def train_model(model, file, file_y):
    print("Creating model from dataset "+file)
    x = np.load(str(file))
    y = np.load(str(file_y))
    x = ds.array(x, block_size=(500, 500))
    y = ds.array(y, block_size=(500, 1))
    model.fit(x, y)
    model.rf.classes = compss_wait_on(model.rf.classes)
    n_classes = compss_wait_on(model.rf.trees[0].n_classes)
    for idx in range(len(model.rf.trees)):
        model.rf.trees[idx].subtrees = compss_wait_on(model.rf.trees[idx].subtrees)
        model.rf.trees[idx].nodes_info = compss_wait_on(model.rf.trees[idx].nodes_info)
        model.rf.trees[idx].n_classes = n_classes



@task(file=IN, file_y=IN)
def evaluate(model, file, file_y):
    report = Report()
    x = np.load(str(file))
    y = np.load(str(file_y))
    x = ds.array(x, block_size=(400, 400))
    y = ds.array(y, block_size=(400, 1))
    score = model.score(x, y, collect=True)
    report.set_accuracy(score)
    return report


@constraint(is_local=True)
@task(models=COLLECTION_IN)
def merge_models(models):
    print("Merging models ", flush=True)
    merged_forest = RandomForestClassifier()
    merged_forest.rf = ds.trees.mmap.RandomForestClassifier()
    merged_forest.rf.trees = []
    for model in models:
        merged_forest.rf.trees.extend(model.rf.trees)
    for idx in range(len(merged_forest.rf.trees)):
        merged_forest.rf.trees[idx].n_classes = models[0].rf.trees[0].n_classes
    merged_forest.rf.classes = models[0].rf.classes
    return merged_forest
    
