variable "cluster_names" {
    description = "The name of a Kubernetes cluster."
    type = list(string)
    default = ["your-cluster-name"]
}

variable "exclude_namespaces" {
    description = "Namespaces to exclude from alerting."
    type = list(string)
    default = ["some-namespace"]
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