locals {
  quoted_namespaces = [for item in var.exclude_namespaces: replace(jsonencode(item), "\"", "'")]
  exclude_namespaces = join(",", local.quoted_namespaces)

  quoted_cluster_names = [for item in var.cluster_names: replace(jsonencode(item), "\"", "'")]
  cluster_names = join(",", local.quoted_cluster_names)
}

resource "newrelic_alert_policy" "kubernetes_alert_policy" {
  name = var.alert_policy_name
}

## Node

resource "newrelic_nrql_alert_condition" "node_not_ready" {
  policy_id                    = newrelic_alert_policy.kubernetes_alert_policy.id
  type                         = "static"
  name                         = "Node is not ready"
  description                  = "Node is not ready after 5 minutes"
  runbook_url                  = ""
  enabled                      = var.conditions_enabled
  violation_time_limit_seconds = 21600
  fill_option                    = null
  fill_value                     = null
  aggregation_window             = 60
  aggregation_method             = "event_flow"
  aggregation_delay              = 60
  evaluation_delay               = 300
  expiration_duration            = 300
  open_violation_on_expiration   = false
  close_violations_on_expiration = true
  slide_by                       = null


  nrql {
    query             = "from K8sNodeSample select latest(condition.Ready) where clusterName in (${local.cluster_names}) facet nodeName, clusterName"
  }

  critical {
    operator              = "below"
    threshold             = 1
    threshold_duration    = 300
    threshold_occurrences = "ALL"
  }
}

resource "newrelic_nrql_alert_condition" "node_pod_count_capacity" {
  policy_id                    = newrelic_alert_policy.kubernetes_alert_policy.id
  type                         = "static"
  name                         = "Node pod count near capacity"
  description                  = "Running pod count on a node is > 90% of the node's pod capacity for more than 5 minutes"
  runbook_url                  = ""
  enabled                      = var.conditions_enabled
  violation_time_limit_seconds = 21600
  fill_option                    = null
  fill_value                     = null
  aggregation_window             = 60
  aggregation_method             = "event_flow"
  aggregation_delay              = 60
  evaluation_delay               = 60
  expiration_duration            = 300
  open_violation_on_expiration   = false
  close_violations_on_expiration = true
  slide_by                       = null


  nrql {
    query             = "FROM K8sPodSample, K8sNodeSample select ceil(filter(uniqueCount(podName), where status = 'Running') / latest(capacityPods) * 100) as 'Pod Capacity %' where nodeName != '' and nodeName is not null and clusterName in (${local.cluster_names}) facet nodeName, clusterName"
  }

  critical {
    operator              = "above"
    threshold             = 90
    threshold_duration    = 300
    threshold_occurrences = "ALL"
  }
}

resource "newrelic_nrql_alert_condition" "node_allocatable_cpu_util_high" {
  policy_id                    = newrelic_alert_policy.kubernetes_alert_policy.id
  type                         = "static"
  name                         = "Node allocatable cpu utilization is high"
  description                  = "Average node allocatable CPU utilization is > 90% for more than 5 minutes"
  runbook_url                  = ""
  enabled                      = var.conditions_enabled
  violation_time_limit_seconds = 21600
  fill_option                    = null
  fill_value                     = null
  aggregation_window             = 300
  aggregation_method             = "event_flow"
  aggregation_delay              = 60
  evaluation_delay               = 60
  expiration_duration            = 300
  open_violation_on_expiration   = false
  close_violations_on_expiration = true
  slide_by                       = 60


  nrql {
    query             = "from K8sNodeSample select average(allocatableCpuCoresUtilization) where clusterName in (${local.cluster_names}) facet nodeName, clusterName"
  }

  critical {
    operator              = "above"
    threshold             = 90
    threshold_duration    = 300
    threshold_occurrences = "ALL"
  }
}

resource "newrelic_nrql_alert_condition" "node_allocatable_mem_util_high" {
  policy_id                    = newrelic_alert_policy.kubernetes_alert_policy.id
  type                         = "static"
  name                         = "Node allocatable memory utilization is high"
  description                  = "Average node allocatable memory utilization is > 90% for more than 5 minutes"
  runbook_url                  = ""
  enabled                      = var.conditions_enabled
  violation_time_limit_seconds = 21600
  fill_option                    = null
  fill_value                     = null
  aggregation_window             = 300
  aggregation_method             = "event_flow"
  aggregation_delay              = 60
  evaluation_delay               = 60
  expiration_duration            = 300
  open_violation_on_expiration   = false
  close_violations_on_expiration = true
  slide_by                       = 60


  nrql {
    query             = "from K8sNodeSample select average(allocatableMemoryUtilization) where clusterName in (${local.cluster_names}) facet nodeName, clusterName"
  }

  critical {
    operator              = "above"
    threshold             = 90
    threshold_duration    = 300
    threshold_occurrences = "ALL"
  }
}

resource "newrelic_nrql_alert_condition" "node_unschedulable" {
  policy_id                    = newrelic_alert_policy.kubernetes_alert_policy.id
  type                         = "static"
  name                         = "Node is unschedulable"
  description                  = "Node has been marked as unschedulable"
  runbook_url                  = ""
  enabled                      = var.conditions_enabled
  violation_time_limit_seconds = 21600
  fill_option                    = null
  fill_value                     = null
  aggregation_window             = 60
  aggregation_method             = "event_flow"
  aggregation_delay              = 60
  evaluation_delay               = 60
  expiration_duration            = 300
  open_violation_on_expiration   = false
  close_violations_on_expiration = true
  slide_by                       = null


  nrql {
    query             = "from K8sNodeSample select latest(unschedulable) where clusterName in (${local.cluster_names}) facet nodeName, clusterName"
  }

  critical {
    operator              = "above"
    threshold             = 0
    threshold_duration    = 300
    threshold_occurrences = "ALL"
  }
}

resource "newrelic_nrql_alert_condition" "node_root_fs_capacity_high" {
  policy_id                    = newrelic_alert_policy.kubernetes_alert_policy.id
  type                         = "static"
  name                         = "Node root file system capacity utilization is high"
  description                  = "Average node root file system capacity utilization is > 90% for more than 5 minutes"
  runbook_url                  = ""
  enabled                      = var.conditions_enabled
  violation_time_limit_seconds = 21600
  fill_option                    = null
  fill_value                     = null
  aggregation_window             = 300
  aggregation_method             = "event_flow"
  aggregation_delay              = 60
  evaluation_delay               = 60
  expiration_duration            = 300
  open_violation_on_expiration   = false
  close_violations_on_expiration = true
  slide_by                       = 60


  nrql {
    query             = "from K8sNodeSample select average(fsCapacityUtilization) where clusterName in (${local.cluster_names}) facet nodeName, clusterName"
  }

  critical {
    operator              = "above"
    threshold             = 90
    threshold_duration    = 300
    threshold_occurrences = "ALL"
  }
}

## Pod

resource "newrelic_nrql_alert_condition" "pods_failing_in_namespace" {
  policy_id                    = newrelic_alert_policy.kubernetes_alert_policy.id
  type                         = "static"
  name                         = "More than 5 pods are failing in a namespace"
  description                  = "Alert when more than 5 pods are failing in a namespace"
  runbook_url                  = ""
  enabled                      = var.conditions_enabled
  violation_time_limit_seconds = 21600
  fill_option                    = null
  fill_value                     = null
  aggregation_window             = 60
  aggregation_method             = "event_flow"
  aggregation_delay              = 60
  evaluation_delay               = 300
  expiration_duration            = 300
  open_violation_on_expiration   = false
  close_violations_on_expiration = true
  slide_by                       = null


  nrql {
    query             = "from K8sPodSample select uniqueCount(podName) where clusterName in (${local.cluster_names}) and namespaceName not in (${local.exclude_namespaces}) and status = 'Failed' facet namespaceName, clusterName"
  }

  critical {
    operator              = "above"
    threshold             = 5
    threshold_duration    = 300
    threshold_occurrences = "ALL"
  }
}

resource "newrelic_nrql_alert_condition" "pod_not_ready" {
  policy_id                    = newrelic_alert_policy.kubernetes_alert_policy.id
  type                         = "static"
  name                         = "Pod is not ready"
  description                  = "Pod is not ready for more than 5 minutes"
  runbook_url                  = ""
  enabled                      = var.conditions_enabled
  violation_time_limit_seconds = 21600
  fill_option                    = null
  fill_value                     = null
  aggregation_window             = 60
  aggregation_method             = "event_flow"
  aggregation_delay              = 60
  evaluation_delay               = 60
  expiration_duration            = 300
  open_violation_on_expiration   = false
  close_violations_on_expiration = true
  slide_by                       = null


  nrql {
    query             = "FROM K8sPodSample select latest(isReady) where status not in ('Failed', 'Succeeded') and clusterName in (${local.cluster_names}) and namespaceName not in (${local.exclude_namespaces}) facet podName, namespaceName, clusterName"
  }

  critical {
    operator              = "below"
    threshold             = 1
    threshold_duration    = 300
    threshold_occurrences = "ALL"
  }
}

resource "newrelic_nrql_alert_condition" "pod_unschedulable" {
  policy_id                    = newrelic_alert_policy.kubernetes_alert_policy.id
  type                         = "static"
  name                         = "Pod cannot be scheduled"
  description                  = "Pod cannot be scheduled for more than 5 minutes"
  runbook_url                  = ""
  enabled                      = var.conditions_enabled
  violation_time_limit_seconds = 21600
  fill_option                    = null
  fill_value                     = null
  aggregation_window             = 60
  aggregation_method             = "event_flow"
  aggregation_delay              = 60
  evaluation_delay               = 60
  expiration_duration            = 300
  open_violation_on_expiration   = false
  close_violations_on_expiration = true
  slide_by                       = null


  nrql {
    query             = "FROM K8sPodSample select latest(isScheduled) where clusterName in (${local.cluster_names}) and namespaceName not in (${local.exclude_namespaces}) facet podName, namespaceName, clusterName"
  }

  critical {
    operator              = "below"
    threshold             = 1
    threshold_duration    = 300
    threshold_occurrences = "ALL"
  }
}

## Container

resource "newrelic_nrql_alert_condition" "container_is_restarting" {
  policy_id                    = newrelic_alert_policy.kubernetes_alert_policy.id
  type                         = "static"
  name                         = "Container is Restarting"
  description                  = "Container restart count is greater than 0 in a sliding 5 minute window"
  runbook_url                  = ""
  enabled                      = var.conditions_enabled
  violation_time_limit_seconds = 21600
  fill_option                    = null
  fill_value                     = null
  aggregation_window             = 300
  aggregation_method             = "event_flow"
  aggregation_delay              = 60
  evaluation_delay               = 60
  expiration_duration            = 300
  open_violation_on_expiration   = false
  close_violations_on_expiration = true
  slide_by                       = 60

  nrql {
    query             = "from K8sContainerSample select sum(restartCountDelta) where clusterName in (${local.cluster_names}) and namespaceName not in (${local.exclude_namespaces}) FACET containerName, podName, namespaceName, clusterName"
  }

  critical {
    operator              = "above"
    threshold             = 0
    threshold_duration    = 300
    threshold_occurrences = "ALL"
  }
}

resource "newrelic_nrql_alert_condition" "container_is_waiting" {
  policy_id                    = newrelic_alert_policy.kubernetes_alert_policy.id
  type                         = "static"
  name                         = "Container is Waiting"
  description                  = "Container is waiting for more than 5 minutes"
  runbook_url                  = ""
  enabled                      = var.conditions_enabled
  violation_time_limit_seconds = 21600
  fill_option                    = null
  fill_value                     = null
  aggregation_window             = 60
  aggregation_method             = "event_flow"
  aggregation_delay              = 60
  evaluation_delay               = 60
  expiration_duration            = 300
  open_violation_on_expiration   = false
  close_violations_on_expiration = true
  slide_by                       = null


  nrql {
    query             = "from K8sContainerSample select uniqueCount(podName) WHERE status = 'Waiting' and clusterName in (${local.cluster_names}) and namespaceName not in (${local.exclude_namespaces}) FACET containerName, podName, namespaceName, clusterName"
  }

  critical {
    operator              = "above"
    threshold             = 0
    threshold_duration    = 300
    threshold_occurrences = "ALL"
  }
}

resource "newrelic_nrql_alert_condition" "container_high_cpu_util" {
  policy_id                    = newrelic_alert_policy.kubernetes_alert_policy.id
  type                         = "static"
  name                         = "Container high cpu utilization"
  description                  = "Average container CPU utilization (vs. limit) is > 90% for more than 5 minutes"
  runbook_url                  = ""
  enabled                      = var.conditions_enabled
  violation_time_limit_seconds = 21600
  fill_option                    = null
  fill_value                     = null
  aggregation_window             = 300
  aggregation_method             = "event_flow"
  aggregation_delay              = 60
  evaluation_delay               = 60
  expiration_duration            = 300
  open_violation_on_expiration   = false
  close_violations_on_expiration = true
  slide_by                       = 60


  nrql {
    query             = "from K8sContainerSample select average(cpuCoresUtilization) where clusterName in (${local.cluster_names}) and namespaceName not in (${local.exclude_namespaces}) facet containerName, podName, namespaceName, clusterName"
  }

  critical {
    operator              = "above"
    threshold             = 90
    threshold_duration    = 300
    threshold_occurrences = "ALL"
  }
}

resource "newrelic_nrql_alert_condition" "container_high_mem_util" {
  policy_id                    = newrelic_alert_policy.kubernetes_alert_policy.id
  type                         = "static"
  name                         = "Container high memory utilization"
  description                  = "Average container memory utilization (vs. limit) is > 90% for more than 5 minutes"
  runbook_url                  = ""
  enabled                      = var.conditions_enabled
  violation_time_limit_seconds = 21600
  fill_option                    = null
  fill_value                     = null
  aggregation_window             = 300
  aggregation_method             = "event_flow"
  aggregation_delay              = 60
  evaluation_delay               = 60
  expiration_duration            = 300
  open_violation_on_expiration   = false
  close_violations_on_expiration = true
  slide_by                       = 60


  nrql {
    query             = "from K8sContainerSample select average(memoryWorkingSetUtilization) where clusterName in (${local.cluster_names}) and namespaceName not in (${local.exclude_namespaces}) facet containerName, podName, namespaceName, clusterName"
  }

  critical {
    operator              = "above"
    threshold             = 90
    threshold_duration    = 300
    threshold_occurrences = "ALL"
  }
}

resource "newrelic_nrql_alert_condition" "container_high_cpu_throttling" {
  policy_id                    = newrelic_alert_policy.kubernetes_alert_policy.id
  type                         = "static"
  name                         = "Container cpu throttling is high"
  description                  = "Alert when container is being throttled > 25% of the time for more than 5 minutes"
  runbook_url                  = ""
  enabled                      = var.conditions_enabled
  violation_time_limit_seconds = 21600
  fill_option                    = null
  fill_value                     = null
  aggregation_window             = 300
  aggregation_method             = "event_flow"
  aggregation_delay              = 60
  evaluation_delay               = 60
  expiration_duration            = 300
  open_violation_on_expiration   = false
  close_violations_on_expiration = true
  slide_by                       = 60


  nrql {
    query             = "from K8sContainerSample select sum(containerCpuCfsThrottledPeriodsDelta) / sum(containerCpuCfsPeriodsDelta) * 100 where clusterName in (${local.cluster_names}) and namespaceName not in (${local.exclude_namespaces}) facet containerName, podName, namespaceName, clusterName"
  }

  critical {
    operator              = "above"
    threshold             = 90
    threshold_duration    = 300
    threshold_occurrences = "ALL"
  }
}

## Daemonset

resource "newrelic_nrql_alert_condition" "daemonset_missing_pods" {
  policy_id                    = newrelic_alert_policy.kubernetes_alert_policy.id
  type                         = "static"
  name                         = "Daemonset is missing pods"
  description                  = "Daemonset is missing pods for > 5 minutes"
  runbook_url                  = ""
  enabled                      = var.conditions_enabled
  violation_time_limit_seconds = 21600
  fill_option                    = null
  fill_value                     = null
  aggregation_window             = 60
  aggregation_method             = "event_flow"
  aggregation_delay              = 60
  evaluation_delay               = 60
  expiration_duration            = 300
  open_violation_on_expiration   = false
  close_violations_on_expiration = true
  slide_by                       = null


  nrql {
    query             = "from K8sDaemonsetSample select latest(podsMissing) where clusterName in (${local.cluster_names}) and namespaceName not in (${local.exclude_namespaces}) facet daemonsetName, namespaceName, clusterName"
  }

  critical {
    operator              = "above"
    threshold             = 0
    threshold_duration    = 300
    threshold_occurrences = "ALL"
  }
}

## Deployment

resource "newrelic_nrql_alert_condition" "deployment_missing_pods" {
  policy_id                    = newrelic_alert_policy.kubernetes_alert_policy.id
  type                         = "static"
  name                         = "Deployment is missing pods"
  description                  = "Deployment is missing pods for > 5 minutes"
  runbook_url                  = ""
  enabled                      = var.conditions_enabled
  violation_time_limit_seconds = 21600
  fill_option                    = null
  fill_value                     = null
  aggregation_window             = 60
  aggregation_method             = "event_flow"
  aggregation_delay              = 60
  evaluation_delay               = 60
  expiration_duration            = 300
  open_violation_on_expiration   = false
  close_violations_on_expiration = true
  slide_by                       = null


  nrql {
    query             = "from K8sDeploymentSample select latest(podsMissing) where clusterName in (${local.cluster_names}) and namespaceName not in (${local.exclude_namespaces}) facet deploymentName, namespaceName, clusterName"
  }

  critical {
    operator              = "above"
    threshold             = 0
    threshold_duration    = 300
    threshold_occurrences = "ALL"
  }
}

## Statefulset

resource "newrelic_nrql_alert_condition" "statefulset_missing_pods" {
  policy_id                    = newrelic_alert_policy.kubernetes_alert_policy.id
  type                         = "static"
  name                         = "Statefulset is missing pods"
  description                  = "Statefulset is missing pods for > 5 minutes"
  runbook_url                  = ""
  enabled                      = var.conditions_enabled
  violation_time_limit_seconds = 21600
  fill_option                    = null
  fill_value                     = null
  aggregation_window             = 60
  aggregation_method             = "event_flow"
  aggregation_delay              = 60
  evaluation_delay               = 60
  expiration_duration            = 300
  open_violation_on_expiration   = false
  close_violations_on_expiration = true
  slide_by                       = null


  nrql {
    query             = "from K8sStatefulsetSample select latest(podsMissing) where clusterName in (${local.cluster_names}) and namespaceName not in (${local.exclude_namespaces}) facet statefulsetName, namespaceName, clusterName"
  }

  critical {
    operator              = "above"
    threshold             = 0
    threshold_duration    = 300
    threshold_occurrences = "ALL"
  }
}

## Horizontal Pod Autoscaler

resource "newrelic_nrql_alert_condition" "hpa_max_replicas" {
  policy_id                    = newrelic_alert_policy.kubernetes_alert_policy.id
  type                         = "static"
  name                         = "HPA has reached maximum replicas"
  description                  = "HPA replicas have maxed out for 5 minutes"
  runbook_url                  = ""
  enabled                      = var.conditions_enabled
  violation_time_limit_seconds = 21600
  fill_option                    = null
  fill_value                     = null
  aggregation_window             = 60
  aggregation_method             = "event_flow"
  aggregation_delay              = 60
  evaluation_delay               = 60
  expiration_duration            = 300
  open_violation_on_expiration   = false
  close_violations_on_expiration = true
  slide_by                       = null


  nrql {
    query             = "FROM K8sHpaSample select latest(maxReplicas - currentReplicas) where clusterName in (${local.cluster_names}) and namespaceName not in (${local.exclude_namespaces}) facet displayName, namespaceName, clusterName"
  }

  critical {
    operator              = "equals"
    threshold             = 0
    threshold_duration    = 300
    threshold_occurrences = "ALL"
  }
}


resource "newrelic_nrql_alert_condition" "hpa_current_vs_desired_replicas" {
  policy_id                    = newrelic_alert_policy.kubernetes_alert_policy.id
  type                         = "static"
  name                         = "HPA current replicas < desired replicas"
  description                  = "HPA current replicas < desired replicas for 5 minutes"
  runbook_url                  = ""
  enabled                      = var.conditions_enabled
  violation_time_limit_seconds = 21600
  fill_option                    = null
  fill_value                     = null
  aggregation_window             = 60
  aggregation_method             = "event_flow"
  aggregation_delay              = 60
  evaluation_delay               = 60
  expiration_duration            = 300
  open_violation_on_expiration   = false
  close_violations_on_expiration = true
  slide_by                       = null


  nrql {
    query             = "FROM K8sHpaSample select latest(desiredReplicas - currentReplicas) where clusterName in (${local.cluster_names}) and namespaceName not in (${local.exclude_namespaces}) facet displayName, namespaceName, clusterName"
  }

  critical {
    operator              = "equals"
    threshold             = 0
    threshold_duration    = 300
    threshold_occurrences = "ALL"
  }
}

## Job

resource "newrelic_nrql_alert_condition" "job_failed" {
  policy_id                    = newrelic_alert_policy.kubernetes_alert_policy.id
  type                         = "static"
  name                         = "Job failed"
  description                  = "Job reports a failed status"
  runbook_url                  = ""
  enabled                      = var.conditions_enabled
  violation_time_limit_seconds = 21600
  fill_option                    = null
  fill_value                     = null
  aggregation_window             = 60
  aggregation_method             = "event_flow"
  aggregation_delay              = 60
  evaluation_delay               = 60
  expiration_duration            = 300
  open_violation_on_expiration   = false
  close_violations_on_expiration = true
  slide_by                       = null


  nrql {
    query             = "from K8sJobSample select uniqueCount(jobName) where failed = 'true' and clusterName in (${local.cluster_names}) and namespaceName not in (${local.exclude_namespaces}) facet jobName, namespaceName, clusterName, failedPodsReason"
  }

  critical {
    operator              = "above"
    threshold             = 0
    threshold_duration    = 60
    threshold_occurrences = "AT_LEAST_ONCE"
  }
}

## Persistent Volume

resource "newrelic_nrql_alert_condition" "persistent_volume_errors" {
  policy_id                    = newrelic_alert_policy.kubernetes_alert_policy.id
  type                         = "static"
  name                         = "Persistent volume has errors"
  description                  = "Persistent volume is in a failed or pending state for more than 5 minutes"
  runbook_url                  = ""
  enabled                      = var.conditions_enabled
  violation_time_limit_seconds = 21600
  fill_option                    = null
  fill_value                     = null
  aggregation_window             = 60
  aggregation_method             = "event_flow"
  aggregation_delay              = 60
  evaluation_delay               = 60
  expiration_duration            = 300
  open_violation_on_expiration   = false
  close_violations_on_expiration = true
  slide_by                       = null


  nrql {
    query             = "from K8sPersistentVolumeSample select uniqueCount(volumeName) where statusPhase in ('Failed','Pending') and clusterName in (${local.cluster_names}) facet volumeName, clusterName"
  }

  critical {
    operator              = "above"
    threshold             = 0
    threshold_duration    = 300
    threshold_occurrences = "ALL"
  }
}

## Control Plane

resource "newrelic_nrql_alert_condition" "etcd_has_no_leader" {
  policy_id                    = newrelic_alert_policy.kubernetes_alert_policy.id
  type                         = "static"
  name                         = "Etcd has no leader"
  description                  = "Etcd has no leader for more than 1 minute"
  runbook_url                  = ""
  enabled                      = var.conditions_enabled
  violation_time_limit_seconds = 21600
  fill_option                    = null
  fill_value                     = null
  aggregation_window             = 60
  aggregation_method             = "event_flow"
  aggregation_delay              = 60
  evaluation_delay               = 60
  expiration_duration            = 300
  open_violation_on_expiration   = false
  close_violations_on_expiration = true
  slide_by                       = null


  nrql {
    query             = "from K8sEtcdSample select min(etcdServerHasLeader) where clusterName in (${local.cluster_names}) facet displayName, clusterName"
  }

  critical {
    operator              = "below"
    threshold             = 1
    threshold_duration    = 60
    threshold_occurrences = "ALL"
  }
}

resource "newrelic_nrql_alert_condition" "etcd_file_descriptor_util" {
  policy_id                    = newrelic_alert_policy.kubernetes_alert_policy.id
  type                         = "static"
  name                         = "Etcd file descriptor utilization is high"
  description                  = "Etcd file descriptor utilization is > 90% for more than 1 minute"
  runbook_url                  = ""
  enabled                      = var.conditions_enabled
  violation_time_limit_seconds = 21600
  fill_option                    = null
  fill_value                     = null
  aggregation_window             = 60
  aggregation_method             = "event_flow"
  aggregation_delay              = 60
  evaluation_delay               = 60
  expiration_duration            = 300
  open_violation_on_expiration   = false
  close_violations_on_expiration = true
  slide_by                       = null


  nrql {
    query             = "from K8sEtcdSample select max(processFdsUtilization) where clusterName in (${local.cluster_names}) facet displayName, clusterName"
  }

  critical {
    operator              = "above"
    threshold             = 90
    threshold_duration    = 60
    threshold_occurrences = "ALL"
  }
}

