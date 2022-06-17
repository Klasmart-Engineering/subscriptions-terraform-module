# database outputs
output "db_output_secret" {
  description = "The Kubernetes secret containing all terraform output"
  value       = "tf-outputs"
}
