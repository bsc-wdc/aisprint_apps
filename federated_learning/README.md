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

### Marenostrum execution