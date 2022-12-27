provider "google" {
  project = var.project
  region  = var.region
}

data "google_billing_account" "account" {
  display_name = var.billing_account
}

resource "google_project" "project" {
  name            = "Serverless Demo"
  project_id      = var.project
  billing_account = data.google_billing_account.account.id
}

resource "google_project_iam_member" "owner" {
  role   = "roles/owner"
  member = "user:${var.user}"
  project = var.project
  depends_on = [google_project.project]
}

resource "google_project_service" "compute" {
  service    = "compute.googleapis.com"
  depends_on = [google_project.project]
}

resource "google_project_service" "container_registry" {
  service    = "containerregistry.googleapis.com"
  depends_on = [google_project.project]

  disable_dependent_services = true
}

resource "google_project_service" "cloud_run" {
  service    = "run.googleapis.com"
  depends_on = [google_project.project]
}

resource "google_project_service" "cloud_build" {
  service    = "cloudbuild.googleapis.com"
  depends_on = [google_project.project]
}

resource "google_project_service" "firebase" {
  service    = "firebase.googleapis.com"
  depends_on = [google_project.project]

  disable_dependent_services = true
}

resource "google_project_service" "firestore" {
  service    = "firestore.googleapis.com"
  depends_on = [google_project.project]
}

resource "google_project_service" "source_repo" {
  service    = "sourcerepo.googleapis.com"
  depends_on = [google_project.project]
}

module "org_policy_allow_ingress_settings" {
source = "terraform-google-modules/org-policy/google"
policy_for = "project"
project_id = var.project
constraint = "constraints/cloudfunctions.allowedIngressSettings"
policy_type = "list"
enforce = false
allow= ["IngressSettings.ALLOW_ALL"]
}

module "org_policy_allow_domain_membership" {
source = "terraform-google-modules/org-policy/google"
policy_for = "project"
project_id = var.project
constraint = "constraints/iam.allowedPolicyMemberDomains"
policy_type = "list"
enforce = false

}
