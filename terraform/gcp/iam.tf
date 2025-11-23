resource "google_service_account" "dataproc_sa" {
  account_id   = "flink-dataproc-sa"
  display_name = "Dataproc Flink Service Account"
}

resource "google_project_iam_member" "dataproc_role" {
  project = var.gcp_project
  role    = "roles/dataproc.admin"
  member  = "serviceAccount:${google_service_account.dataproc_sa.email}"
}

resource "google_project_iam_member" "storage_role" {
  project = var.gcp_project
  role    = "roles/storage.objectAdmin"
  member  = "serviceAccount:${google_service_account.dataproc_sa.email}"
}

resource "google_project_iam_member" "logging_role" {
  project = var.gcp_project
  role    = "roles/logging.logWriter"
  member  = "serviceAccount:${google_service_account.dataproc_sa.email}"
}
