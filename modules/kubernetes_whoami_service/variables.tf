variable "whoami_namespace" {
  type = string
  description = "the name of the whoami namespace such as whoami"
}

variable "whoami_documents" {
  type = list(string)
  description = "the yaml documents to apply to the whoami namespace"
}
