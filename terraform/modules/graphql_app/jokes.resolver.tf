# TODO: move this to a standalone resolver mapping terraform directory
# Reference: https://elopmental.dev/easy-appsync-with-terraform/

# get jokes lambdafunction
data "aws_lambda_function" "getJokes_function" {
  function_name = "getJokes_function"
}

# create data source in appsync from lambda function
resource "aws_appsync_datasource" "getJokes_function_datasource" {
  name             = "getJokes_function_datasource"
  api_id           = aws_appsync_graphql_api.appsync_endpoint.id
  service_role_arn = aws_iam_role.iam_appsync_role.arn
  type             = "AWS_LAMBDA"
  lambda_config {
    function_arn = data.aws_lambda_function.getJokes_function.arn
  }
}

# map jokes field to lambda jokes function
resource "aws_appsync_resolver" "getJokes_function" {
  type              = "Query"
  api_id            = aws_appsync_graphql_api.appsync_endpoint.id
  field             = "jokes"

  request_template  = <<EOF
{
  "version": "2018-05-29",
  "operation": "Invoke",
  "payload": {
    "arguments": $utils.toJson($context.arguments)
  }
}
EOF
  response_template = "$util.toJson($context.result)"
  data_source       = aws_appsync_datasource.getJokes_function_datasource.name
}