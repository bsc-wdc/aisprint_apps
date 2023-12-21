# Federated Learning
The application contained in this folder creates an AI model using Federeated Learning. Unlike other applications, which have a centralized training dataset, this version pursues training the model using multiple datasets hosted in different institutions without need of transferring them and, hence, faouring the privacy of the data collected by each institution. In this case, each institution trains a RandomForest model from the dataset available in it. The model trained by each institution is transferred to a central institution which merges all the models to create a single model.

## Application description
### Arguments
The application requires two arguments:

1. List of references to the training datasets to train the partial models.  
Each dataset is passed in as a pair of references to files where the first component corresponds to the collection of samples of ECGs features in a host institution and the second corresponds to the class assigned to each sample. Both, the elements in each pair and the list of pairs are separated by ",".  
**Example:**
```
"file://institution1@dataset.npy,file://institution1@dataset_classes.npy,file://institution2@dataset.npy,file://institution2@dataset_classes.npy,file://institution3@dataset.npy,file://institution3@dataset_classes.npy"
```

2. Evaluation dataset that will be used for evaluating each partial model and the global.  
This test dataset is composed of a pair of files, separated by ",",  where the first is component of the pair contains the multiple samples of ECG features and the second component indicates the corresponding class for each sample.  
**Example:**
```
"file://testset.npy,file://institution1@testset_classes.npy"
```

### Application behaviour
This application starts invoking the `main_program` method of the `learning.py` python module in the main institution. At this point, the agent running in this main institution parses the inputs and creates 2 depending tasks for each input dataset pair that are submitted to the corresponding institution. The first task trains the model using the corresponding dataset, and the second one evaluates it using the test dataset. In the current of implementation, this training corresponds to a RandomForest model; which runs in parallel using all desired amount of resources available in that institution. Once an institution finishes computing its model, the decision trees composing the model are shipped back to the central institution that aggregates them into a larger RandomForest model. While the central institution runs this merging, the institution owning the data run in parallel an evaluation of its model. Finally, when all the decision trees are merged into the model, the central institution runs the evaluation of the global model.

## Launching the application
The repository also contains the code necessary to run the application both, locally and on marenostrum.
### Local execution
The local execution script `execution_scripts/launch.sh` deploys 4 independent agents on the local host: COMPSsWorker01 acts as the central institution while COMPSsWorker02, COMPSsWorker03 and COMPSsWorker04 become the entry point for each institution hosting the data.

### Marenostrum execution
The script `execution_scripts/enqueue.sh` enqueues a new SLURM job in Marenostrum that will spawn an execution with 4 independent agents  in 4 different nodes: the node with lowest id acts as the central institution while the rest of the nodes will become the entry point for each institution hosting the data. In this case, the datasets are in the shared file system.

## Obtianed results
The following results have been obtained using the Physionet dataset modified to obtain ECGs of up to 30 seconds and splitting it into 4 different parts (1 for each institution and 1 for testing purposes) using different policies.

### Unbalanced class partitioning
Partial Results for model from Institution 1 (40 estimators)  
Accuracy of model: 0.5329646958740961  
Partial Results for model from Institution 2 (40 estimators)  
Accuracy of model: 0.8634623564440663  
Partial Results for model from Institution 3 (40 estimators)  
Accuracy of model: 0.8498511271799234  

Final Results for global model (120 estimators)  
Accuracy of model: 0.8728200765631646   

### Random Partitioning
Partial Results for model from Institution 1 (40 estimators)  
Accuracy of model: 0.8728200765631646  
Partial Results for model from Institution 2 (40 estimators)  
Accuracy of model: 0.8719693747341557    
Partial Results for model from Institution 3 (40 estimators)  
Accuracy of model: 0.8817524457677584  

Final Results for global model (120 estimators)  
Accuracy of model: 0.8838792003402808 