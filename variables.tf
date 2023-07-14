variable "cluster_names" {
    description = "The name of a Kubernetes cluster."
    type = list(string)
    default = ["my-awesome-cluster"]
}

variable "namespaces" {
    description = "Namespaces to monitor."
    type = list(string)
    default = ["newrelic"]
}

variable "conditions_enabled" {
    description = "Toggle to set all alert conditions as either enabled or disabled at deployment time."
    type = bool
    default = true
}

variable "alert_policy_name" {
    description = "Name of the Kubernetes alert policy in New Relic"
    type = string
    default = "Kubernetes Alert Policy"
}