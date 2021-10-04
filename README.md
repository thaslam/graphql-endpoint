# graphql-endpoint
Sample AWS GraphQL endpoint service that returns jokes

**1. Build Service Logic**


cd service/
npm install
npm run build

**2. Provision and Deploy Infrastructure**


cd terraform/modules/graphql_app
terraform init
terraform plan
terraform apply

**3. Invoke Service Test**


curl -XPOST -H "Content-Type:application/graphql" -H "x-api-key:<<get from infraoutput>>" -d '{"query": "{ jokes {id frame punchline type} }"}' https://3rt33ojyvbduphjoy3p2frcmci.appsync-api.us-east-1.amazonaws.com/graphql