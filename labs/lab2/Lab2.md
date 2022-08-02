Show sensitive values
https://devcoops.com/show-sensitive-output-values-terraform/
terraform plan -out=tfplan
terraform show -json tfplan

### Task
Produce some records into orders topic:
confluent kafka topic produce orders --environment env-j5wn88 --cluster lkc-81d277  --api-key <key> --api-secret <secret>

{"number":1,"date":18500,"shipping_address":"899 W Evelyn Ave, Mountain View, CA 94041, USA","cost":15.00}
{"number":2,"date":18501,"shipping_address":"1 Bedford St, London WC2E 9HG, United Kingdom","cost":5.00}
{"number":3,"date":18502,"shipping_address":"3307 Northland Dr Suite 400, Austin, TX 78731, USA","cost":10.00}

Try to consume from orders topic: 

confluent kafka topic consume orders --from-beginning --environment env-j5wn88 --cluster lkc-81d277 --api-key <key> --api-secret <secret>
### Solution

1. Check service accounts created
confluent iam service-account list
2. Check role-bindings created for consumer service account
confluent iam rbac role-binding list --principal User:sa-2r8opm 

confluent iam service-account list

     ID     |     Name     |          Description            
------------+--------------+---------------------------------
  sa-r5z3qp | app-manager  | Service account to manage       
            |              | 'inventory' Kafka cluster       
  sa-2r8opm | app-consumer | Service account to consume      
            |              | from 'orders' topic of          
            |              | 'inventory' Kafka cluster       
  sa-0981qq | app-producer | Service account to produce to   
            |              | 'orders' topic of 'inventory'   
            |              | Kafka cluster          

confluent iam rbac role-binding list --principal User:sa-2r8opm

    Principal    | Email |     Role      | Environment | Cloud Cluster | Cluster Type | Logical Cluster | Resource Type |  Name  | Pattern Type  
-----------------+-------+---------------+-------------+---------------+--------------+-----------------+---------------+--------+---------------
  User:sa-2r8opm |       | DeveloperRead | env-j5wn88  | lkc-81d277    | Kafka        | lkc-81d277      | Topic         | orders | LITERAL       

3. Solution: assign role DeveloperRead to consumer

confluent iam rbac role-binding create --principal User:sa-2r8opm --role DeveloperRead \
  --environment env-j5wn88 --cloud-cluster lkc-81d277 --kafka-cluster-id lkc-81d277 \
  --resource Group:dummy
+--------------+----------------+
| Principal    | User:sa-2r8opm |
| Role         | DeveloperRead  |
| ResourceType | Group          |
| Name         | dummy          |
| PatternType  | LITERAL        |
+--------------+----------------+

confluent kafka topic consume orders --from-beginning --environment env-j5wn88 --cluster lkc-81d277 --api-key <key> --api-secret <secret> --group dummy
Starting Kafka Consumer. Use Ctrl-C to exit.
{"number":2,"date":18501,"shipping_address":"1 Bedford St, London WC2E 9HG, United Kingdom","cost":5.00}
{"number":3,"date":18502,"shipping_address":"3307 Northland Dr Suite 400, Austin, TX 78731, USA","cost":10.00}
{"number":1,"date":18500,"shipping_address":"899 W Evelyn Ave, Mountain View, CA 94041, USA","cost":15.00}

confluent iam rbac role-binding list --principal User:sa-2r8opm
    Principal    | Email |     Role      | Environment | Cloud Cluster | Cluster Type | Logical Cluster | Resource Type |  Name  | Pattern Type  
-----------------+-------+---------------+-------------+---------------+--------------+-----------------+---------------+--------+---------------
  User:sa-2r8opm |       | DeveloperRead | env-j5wn88  | lkc-81d277    | Kafka        | lkc-81d277      | Group         | dummy  | LITERAL       
  User:sa-2r8opm |       | DeveloperRead | env-j5wn88  | lkc-81d277    | Kafka        | lkc-81d277      | Topic         | orders | LITERAL 

Source:
https://docs.confluent.io/cloud/current/access-management/access-control/cloud-rbac.html

Explanation:

Read-only access to the resource
When granted read-only access on a topic, read permission is also required on on a consumer group in order to subscribe to the topic. This is not necessary if the consumer does manual partition assignment. See also: Consumer groups.
When consuming from a topic using the Confluent CLI, the CLI will choose a consumer group name starting with confluent_cli_consumer_ by default, so the principal requires a DeveloperRead role binding on that prefix. Alternately, you can specify a consumer group with the --group flag and give a DeveloperRead role binding on your chosen group name. See confluent kafka topic consume.