output "graphql_endpoint" {
  description = "The endpoint for GraphQL API"
  value       = aws_appsync_graphql_api.appsync_endpoint.uris["GRAPHQL"]
}

output "apikey_fortesting" {
  description = "API Key for testing"
  sensitive   = true
  value       = aws_appsync_api_key.temp_api_key.key
}