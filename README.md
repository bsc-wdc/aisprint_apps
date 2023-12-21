# AI-Sprint Applications
This repository gathers a collection of applications developed within the context of the "Artificial Intelligence in Secure PRIvacy-preserving computing coNTinuum (AI-Sprint)" project. All these applications apply different techniques with the same purpose training an AI model to detect Atrial Fibrillation patterns in ECGs.

## Applications
Each of the folders within this repository contains the application code and some instructions describing how to launch it for training the model using a specific technique and running corresponding inference.

### Federated Learning
The application contained in this folder creates an AI model using Federeated Learning. Unlike other applications, which have a centralized training dataset, this version pursues training the model using multiple datasets hosted in different institutions without need of transferring them and, hence, faouring the privacy of the data collected by each institution. In this case, each institution trains a RandomForest model from the dataset available in it. The model trained by each institution is transferred to a central institution which merges all the models to create a single model.


## Funding
The AI-Sprint project has received funding from the European Union Horizon 2020 research and innovation programme under Grant Agreement No. 101016577
