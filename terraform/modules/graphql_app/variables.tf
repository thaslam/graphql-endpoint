variable "app_name" {
  description = "Name of GraphQL application"
  type        = string
  default     = "jokesapi"
}

variable "model_path" {
  description = "Path to GraphQL schema file"
  type        = string
  default     = "../../../api/jokesmodel/schema.graphql"
}