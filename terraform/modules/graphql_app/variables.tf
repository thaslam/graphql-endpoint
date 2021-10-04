# TODO create app creation tf that specifies project specific variable values
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

variable "resolver_functions_path" {
  type        = string
  default     = "../../../service/built/"
}

variable "resolver_functions" {
  type    = set(string)
  default = ["getJokes_function"]
}