# Steps prior to the workshop (ideally 1 day before the workshop)

1. Create a dedicated Environment 'RTL' in Confluent Cloud within Thinkport Organization.
2. Send e-mail invitation to participants to confluent cloud. (Organization Thinkport GmbH)
Participants should get the RBAC role EnvironmentAdmin assigned. This way they only see their dedicated environment.
3. Spin up an arbitrary number of EC2 instances in AWS. (bastion hosts)
Hand over the bastion host .pem file and three public ip addresses to the participants via Zoho Vault.
Ask them to fill out a Miro Board checklist whether their log in was successful.
Optional: After feedback has been provided shut down the ec2 instances until the day of the workshop.
Once participants log into Confluent Cloud they should create their own access keys + secrets and save them somewhere safe.
They will need it for the labs.
4. Create a second environment called Demo environment. This will be used for the demos mainly. (used for Datadog and BYOK show casing)
The idea behind this is to separate the demos from the labs and do not grant participants access do standard or dedicated clusters as this
might result in very high costs.

# Steps on day 1 of the workshop

## Demo 1. (this should be also a general introduction to confluent cloud, with its hierarchies etc.)
Introduce the Confluent Cloud Console and the RTL environment.
Briefly introduce the confluent CLI.
Briefly introduce the confluent cloud terraform provider. Create a terraform service account and assign it the necessary role to be able to start.
This should be a detailed walk through.

Spin up 3 identical clusters in the RTL environment. For the first demo and lab 3 basic clusters are okay.

TODO: remove the environment resource in the terraform scripts, make sure that only clusters are created

After the 3 clusters exist show them around and issue a couple of cli commands: show environment etc.

## Lab 1. is based on the previously created 3 basic clusters.

TODO: for this pre-provision the confluent cli tools on the bastion hosts.

Ask participants to log in with their previously created cloud api keys and secrets.
Present them with the task. Create a pdf with the steps to be executed. This should be placed in a labs folder on the hosts.
Optimize a producer for throughput.

## Demo 2.This should be a complete walk through. For this spin up a dedicated cluster in the Demo environment.
Create keys on AWS KMS. And also revoke the keys to showcase how this would break things.


## Lab 2. As lab 2 heavily relies on the concepts of RBAC and ACLs make sure to spin up at least one standard cluster.
Create a topic and dump some arbitrary data into the topic. This could be the inventory use case from the example terraform provider project.
Dump some records into the orders topic. Create three consumers and ask participants in the labs to consume data from the orders topic.
This won't work so ask them to find out the root cause and fix it.
(a combination of rbac and acls)


## Demo 3. This should be again a complete walk through. Create service account for data dog with the MetricsReporter role assigned.
Log in to data dog and include the confluent cloud integration. Assign the clusters and connectors to be monitored to data dog.
Generate some load on the cluster and go through the metrics.

## Lab 3. This should be in the basic cluster. Sping up a Datagen connector and ask the participants to figure out why it cannot connect.
To make the task more difficult ask them to not replace the service account for the connector when fixing the issue.




