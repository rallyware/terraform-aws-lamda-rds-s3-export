# terraform-aws-lambda-rds-s3-export 

This module deploys an AWS Lambda function that automates RDS snapshot export to S3.

<!-- BEGIN_TF_DOCS -->
## Usage
```hcl
 resource "aws_s3_bucket" "export" {
  bucket = "bucket-for-rds-snapshots-export"
}

resource "aws_s3_bucket_acl" "export" {
  bucket = aws_s3_bucket.export.id
  acl    = "private"
}

resource "aws_kms_key" "export" {}

resource "aws_kms_alias" "export" {
  name          = "alias/rds-snapshot-export-key"
  target_key_id = aws_kms_key.export.key_id
}

data "aws_iam_policy_document" "export_assume" {
  version = "2012-10-17"

  statement {
    sid = "ExportAssumeRole"
    actions = [
      "sts:AssumeRole"
    ]
    principals {
      type = "Service"
      identifiers = [
        "export.rds.amazonaws.com"
      ]
    }
    effect = "Allow"
  }
}

data "aws_iam_policy_document" "export" {
  version = "2012-10-17"

  statement {
    sid = "AllowS3"
    actions = [
      "s3:PutObject*",
      "s3:ListBucket",
      "s3:GetObject*",
      "s3:DeleteObject*",
      "s3:GetBucketLocation"
    ]
    resources = [
      "arn:aws:s3:::${aws_s3_bucket.export.id}",
      "arn:aws:s3:::${aws_s3_bucket.export.id}/*"
    ]
    effect = "Allow"
  }
}

resource "aws_iam_policy" "export" {
  name   = "export-task-policy"
  policy = data.aws_iam_policy_document.export.json
}

resource "aws_iam_role" "export" {
  name               = "export-task-role"
  assume_role_policy = data.aws_iam_policy_document.export_assume.json
}

resource "aws_iam_role_policy_attachment" "export" {
  role       = aws_iam_role.export.name
  policy_arn = aws_iam_policy.export.arn
}

data "aws_iam_policy_document" "lambda" {
  version = "2012-10-17"

  statement {
    sid = "AllowExportDescribeSnapshot"
    actions = [
      "rds:StartExportTask",
      "rds:DescribeDBSnapshots"
    ]
    resources = [
      "*"
    ]
    effect = "Allow"
  }

  statement {
    sid = "AllowGetPassRole"
    actions = [
      "iam:GetRole",
      "iam:PassRole"
    ]
    resources = [
      aws_iam_role.export.arn
    ]
    effect = "Allow"
  }

  statement {
    sid = "AllowExportKeyKMS"
    actions = [
      "kms:Encrypt",
      "kms:Decrypt",
      "kms:GenerateDataKey",
      "kms:GenerateDataKeyWithoutPlaintext",
      "kms:ReEncryptFrom",
      "kms:ReEncryptTo",
      "kms:CreateGrant",
      "kms:DescribeKey",
      "kms:RetireGrant",
    ]
    resources = [
      aws_kms_key.export.arn
    ]
    effect = "Allow"
  }
}

resource "aws_iam_policy" "lambda" {
  name   = "export-lambda-policy"
  policy = data.aws_iam_policy_document.lambda.json
}

module "lambda" {
  source = "../../"

  s3_bucket_id         = aws_s3_bucket.export.id
  kms_key_id           = aws_kms_key.export.key_id
  export_task_role_arn = aws_iam_role.export.arn
  lambda_policy_arn    = aws_iam_policy.lambda.arn
}

module "bucket" {
  source                       = "../../"
  acl                          = "private"
  user_enabled                 = true
  force_destroy                = true
  versioning_enabled           = false
  allow_encrypted_uploads_only = true
  sse_algorithm                = "aws:kms"
  name                         = "bucket-for-rds-snapshots-export"
  lifecycle_rules              = var.lifecycle_rules
  kms_master_key_arn           = module.kms_key.key_arn
  allowed_bucket_actions       = var.allowed_bucket_actions
  object_lock_configuration    = var.object_lock_configuration
  context                      = module.this.context

  lifecycle_configuration_rules = var.lifecycle_configuration_rules
}

module "kms_key" {
  source                  = "cloudposse/kms-key/aws"
  version                 = "0.12.1"
  name                    = "key-key-lambda-rds-s3"
  description             = "KMS key for lambda-rds-s3"
  deletion_window_in_days = 7
  enable_key_rotation     = false
  context                 = module.this.context
}

module "role" {
  source       = "cloudposse/iam-role/aws"
  version      = "0.18.0"
  name         = "export-task-role"
  principals   = [
    {
      type        = "Service"
      identifiers = ["export.rds.amazonaws.com"]
    }
  ]
  use_fullname = true

  policy_documents = [
    data.aws_iam_policy_document.export_assume.json,
    data.aws_iam_policy_document.export.json,
    data.aws_iam_policy_document.lambda.json
  ]
  policy_document_count = 3
  policy_description    = "IAM policy for s3 bucket"
  role_description      = "IAM role for s3 bucket"

  context = module.this.context
}
```
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.3 |
| <a name="requirement_archive"></a> [archive](#requirement\_archive) | >= 2 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 4 |
| <a name="requirement_random"></a> [random](#requirement\_random) | >= 3 |
## Providers

| Name | Version |
|------|---------|
| <a name="provider_archive"></a> [archive](#provider\_archive) | >= 2 |
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 4 |
| <a name="provider_random"></a> [random](#provider\_random) | >= 3 |
## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_bucket"></a> [bucket](#module\_bucket) | cloudposse/s3-bucket/aws | 3.1.1 |
| <a name="module_kms_key"></a> [kms\_key](#module\_kms\_key) | cloudposse/kms-key/aws | 0.12.1 |
| <a name="module_lambda"></a> [lambda](#module\_lambda) | rallyware/lambda-function/aws | 0.1.0 |
| <a name="module_role"></a> [role](#module\_role) | cloudposse/iam-role/aws | 0.18.0 |
| <a name="module_this"></a> [this](#module\_this) | cloudposse/label/null | 0.25.0 |
## Resources

| Name | Type |
|------|------|
| [random_id.build](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/id) | resource |
| [archive_file.build](https://registry.terraform.io/providers/hashicorp/archive/latest/docs/data-sources/file) | data source |
| [aws_iam_policy_document.base](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.resource_full_access](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_lambda_policy_arn"></a> [lambda\_policy\_arn](#input\_lambda\_policy\_arn) | The ARN of custom IAM policy for lambda function that starts snapshot export task | `string` | n/a | yes |
| <a name="input_names"></a> [names](#input\_names) | Bucket and IAM name | `string` | n/a | yes |
| <a name="input_additional_tag_map"></a> [additional\_tag\_map](#input\_additional\_tag\_map) | Additional key-value pairs to add to each map in `tags_as_list_of_maps`. Not added to `tags` or `id`.<br>This is for some rare cases where resources want additional configuration of tags<br>and therefore take a list of maps with tag key, value, and additional configuration. | `map(string)` | `{}` | no |
| <a name="input_allowed_bucket_actions"></a> [allowed\_bucket\_actions](#input\_allowed\_bucket\_actions) | List of actions the user is permitted to perform on the S3 bucket | `list(string)` | <pre>[<br>  "s3:PutObject",<br>  "s3:PutObjectAcl",<br>  "s3:GetObject",<br>  "s3:DeleteObject",<br>  "s3:ListBucket",<br>  "s3:ListBucketMultipartUploads",<br>  "s3:GetBucketLocation",<br>  "s3:AbortMultipartUpload"<br>]</pre> | no |
| <a name="input_attributes"></a> [attributes](#input\_attributes) | ID element. Additional attributes (e.g. `workers` or `cluster`) to add to `id`,<br>in the order they appear in the list. New attributes are appended to the<br>end of the list. The elements of the list are joined by the `delimiter`<br>and treated as a single ID element. | `list(string)` | `[]` | no |
| <a name="input_context"></a> [context](#input\_context) | Single object for setting entire context at once.<br>See description of individual variables for details.<br>Leave string and numeric variables as `null` to use default value.<br>Individual variable settings (non-null) override settings in context object,<br>except for attributes, tags, and additional\_tag\_map, which are merged. | `any` | <pre>{<br>  "additional_tag_map": {},<br>  "attributes": [],<br>  "delimiter": null,<br>  "descriptor_formats": {},<br>  "enabled": true,<br>  "environment": null,<br>  "id_length_limit": null,<br>  "label_key_case": null,<br>  "label_order": [],<br>  "label_value_case": null,<br>  "labels_as_tags": [<br>    "unset"<br>  ],<br>  "name": null,<br>  "namespace": null,<br>  "regex_replace_chars": null,<br>  "stage": null,<br>  "tags": {},<br>  "tenant": null<br>}</pre> | no |
| <a name="input_delimiter"></a> [delimiter](#input\_delimiter) | Delimiter to be used between ID elements.<br>Defaults to `-` (hyphen). Set to `""` to use no delimiter at all. | `string` | `null` | no |
| <a name="input_descriptor_formats"></a> [descriptor\_formats](#input\_descriptor\_formats) | Describe additional descriptors to be output in the `descriptors` output map.<br>Map of maps. Keys are names of descriptors. Values are maps of the form<br>`{<br>   format = string<br>   labels = list(string)<br>}`<br>(Type is `any` so the map values can later be enhanced to provide additional options.)<br>`format` is a Terraform format string to be passed to the `format()` function.<br>`labels` is a list of labels, in order, to pass to `format()` function.<br>Label values will be normalized before being passed to `format()` so they will be<br>identical to how they appear in `id`.<br>Default is `{}` (`descriptors` output will be empty). | `any` | `{}` | no |
| <a name="input_enabled"></a> [enabled](#input\_enabled) | Set to false to prevent the module from creating any resources | `bool` | `null` | no |
| <a name="input_environment"></a> [environment](#input\_environment) | ID element. Usually used for region e.g. 'uw2', 'us-west-2', OR role 'prod', 'staging', 'dev', 'UAT' | `string` | `null` | no |
| <a name="input_id_length_limit"></a> [id\_length\_limit](#input\_id\_length\_limit) | Limit `id` to this many characters (minimum 6).<br>Set to `0` for unlimited length.<br>Set to `null` for keep the existing setting, which defaults to `0`.<br>Does not affect `id_full`. | `number` | `null` | no |
| <a name="input_label_key_case"></a> [label\_key\_case](#input\_label\_key\_case) | Controls the letter case of the `tags` keys (label names) for tags generated by this module.<br>Does not affect keys of tags passed in via the `tags` input.<br>Possible values: `lower`, `title`, `upper`.<br>Default value: `title`. | `string` | `null` | no |
| <a name="input_label_order"></a> [label\_order](#input\_label\_order) | The order in which the labels (ID elements) appear in the `id`.<br>Defaults to ["namespace", "environment", "stage", "name", "attributes"].<br>You can omit any of the 6 labels ("tenant" is the 6th), but at least one must be present. | `list(string)` | `null` | no |
| <a name="input_label_value_case"></a> [label\_value\_case](#input\_label\_value\_case) | Controls the letter case of ID elements (labels) as included in `id`,<br>set as tag values, and output by this module individually.<br>Does not affect values of tags passed in via the `tags` input.<br>Possible values: `lower`, `title`, `upper` and `none` (no transformation).<br>Set this to `title` and set `delimiter` to `""` to yield Pascal Case IDs.<br>Default value: `lower`. | `string` | `null` | no |
| <a name="input_labels_as_tags"></a> [labels\_as\_tags](#input\_labels\_as\_tags) | Set of labels (ID elements) to include as tags in the `tags` output.<br>Default is to include all labels.<br>Tags with empty values will not be included in the `tags` output.<br>Set to `[]` to suppress all generated tags.<br>**Notes:**<br>  The value of the `name` tag, if included, will be the `id`, not the `name`.<br>  Unlike other `null-label` inputs, the initial setting of `labels_as_tags` cannot be<br>  changed in later chained modules. Attempts to change it will be silently ignored. | `set(string)` | <pre>[<br>  "default"<br>]</pre> | no |
| <a name="input_lambda_architectures"></a> [lambda\_architectures](#input\_lambda\_architectures) | Instruction set architecture for AWS Lambda function. | `list(string)` | <pre>[<br>  "arm64"<br>]</pre> | no |
| <a name="input_lambda_description"></a> [lambda\_description](#input\_lambda\_description) | Description of what the Lambda Function does. | `string` | `"This Lambda function automates RDS snapshot export to S3"` | no |
| <a name="input_lambda_log_retention"></a> [lambda\_log\_retention](#input\_lambda\_log\_retention) | Specifies the number of days you want to retain log events in the specified log group. | `number` | `30` | no |
| <a name="input_lambda_memory"></a> [lambda\_memory](#input\_lambda\_memory) | Amount of memory in MB the Lambda Function can use at runtime. | `number` | `128` | no |
| <a name="input_lambda_runtime"></a> [lambda\_runtime](#input\_lambda\_runtime) | The runtime environment for the Lambda function you are uploading. | `string` | `"python3.9"` | no |
| <a name="input_lambda_timeout"></a> [lambda\_timeout](#input\_lambda\_timeout) | The amount of time the Lambda Function has to run in seconds. | `number` | `5` | no |
| <a name="input_lifecycle_configuration_rules"></a> [lifecycle\_configuration\_rules](#input\_lifecycle\_configuration\_rules) | A list of lifecycle V2 rules | <pre>list(object({<br>    enabled = bool<br>    id      = string<br><br>    abort_incomplete_multipart_upload_days = number<br><br>    filter_and = any<br>    expiration = any<br>    transition = list(any)<br><br>    noncurrent_version_expiration = any<br>    noncurrent_version_transition = list(any)<br>  }))</pre> | `[]` | no |
| <a name="input_lifecycle_rules"></a> [lifecycle\_rules](#input\_lifecycle\_rules) | A list of lifecycle rules. | <pre>list(object({<br>    prefix  = string<br>    enabled = bool<br>    tags    = map(string)<br><br>    enable_glacier_transition            = bool<br>    enable_deeparchive_transition        = bool<br>    enable_standard_ia_transition        = bool<br>    enable_current_object_expiration     = bool<br>    enable_noncurrent_version_expiration = bool<br><br>    abort_incomplete_multipart_upload_days         = number<br>    noncurrent_version_glacier_transition_days     = number<br>    noncurrent_version_deeparchive_transition_days = number<br>    noncurrent_version_expiration_days             = number<br><br>    standard_transition_days    = number<br>    glacier_transition_days     = number<br>    deeparchive_transition_days = number<br>    expiration_days             = number<br>  }))</pre> | <pre>[<br>  {<br>    "abort_incomplete_multipart_upload_days": 90,<br>    "deeparchive_transition_days": 90,<br>    "enable_current_object_expiration": true,<br>    "enable_deeparchive_transition": false,<br>    "enable_glacier_transition": true,<br>    "enable_noncurrent_version_expiration": true,<br>    "enable_standard_ia_transition": false,<br>    "enabled": false,<br>    "expiration_days": 90,<br>    "glacier_transition_days": 60,<br>    "noncurrent_version_deeparchive_transition_days": 60,<br>    "noncurrent_version_expiration_days": 90,<br>    "noncurrent_version_glacier_transition_days": 30,<br>    "prefix": "",<br>    "standard_transition_days": 30,<br>    "tags": {}<br>  }<br>]</pre> | no |
| <a name="input_name"></a> [name](#input\_name) | ID element. Usually the component or solution name, e.g. 'app' or 'jenkins'.<br>This is the only ID element not also included as a `tag`.<br>The "name" tag is set to the full `id` string. There is no tag with the value of the `name` input. | `string` | `null` | no |
| <a name="input_namespace"></a> [namespace](#input\_namespace) | ID element. Usually an abbreviation of your organization name, e.g. 'eg' or 'cp', to help ensure generated IDs are globally unique | `string` | `null` | no |
| <a name="input_object_lock_configuration"></a> [object\_lock\_configuration](#input\_object\_lock\_configuration) | A configuration for S3 object locking. With S3 Object Lock, you can store objects using a `write once, read many` (WORM) model. Object Lock can help prevent objects from being deleted or overwritten for a fixed amount of time or indefinitely. | <pre>object({<br>    mode  = string # Valid values are GOVERNANCE and COMPLIANCE.<br>    days  = number<br>    years = number<br>  })</pre> | `null` | no |
| <a name="input_principals"></a> [principals](#input\_principals) | Map of service name as key and a list of ARNs to allow assuming the role as value (e.g. map(`AWS`, list(`arn:aws:iam:::role/admin`))) | `map(list(string))` | <pre>{<br>  "AWS": [<br>    "*"<br>  ]<br>}</pre> | no |
| <a name="input_regex_replace_chars"></a> [regex\_replace\_chars](#input\_regex\_replace\_chars) | Terraform regular expression (regex) string.<br>Characters matching the regex will be removed from the ID elements.<br>If not set, `"/[^a-zA-Z0-9-]/"` is used to remove all characters other than hyphens, letters and digits. | `string` | `null` | no |
| <a name="input_s3_prefix"></a> [s3\_prefix](#input\_s3\_prefix) | The Amazon S3 bucket prefix to use as the file name and path of the exported data | `string` | `"RDS"` | no |
| <a name="input_stage"></a> [stage](#input\_stage) | ID element. Usually used to indicate role, e.g. 'prod', 'staging', 'source', 'build', 'test', 'deploy', 'release' | `string` | `null` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Additional tags (e.g. `{'BusinessUnit': 'XYZ'}`).<br>Neither the tag keys nor the tag values will be modified by this module. | `map(string)` | `{}` | no |
| <a name="input_tenant"></a> [tenant](#input\_tenant) | ID element \_(Rarely used, not included by default)\_. A customer identifier, indicating who this instance of a resource is for | `string` | `null` | no |
## Outputs

| Name | Description |
|------|-------------|
| <a name="output_alias_arn"></a> [alias\_arn](#output\_alias\_arn) | Alias ARN |
| <a name="output_bucket_arn"></a> [bucket\_arn](#output\_bucket\_arn) | Bucket ARN |
| <a name="output_bucket_domain_name"></a> [bucket\_domain\_name](#output\_bucket\_domain\_name) | FQDN of bucket |
| <a name="output_key_alias_name"></a> [key\_alias\_name](#output\_key\_alias\_name) | KMS key alias name |
| <a name="output_key_arn"></a> [key\_arn](#output\_key\_arn) | Key ARN |
| <a name="output_key_id"></a> [key\_id](#output\_key\_id) | Key ID |
| <a name="output_lambda_arn"></a> [lambda\_arn](#output\_lambda\_arn) | The AWS Lambda function ARN |
| <a name="output_role_arn"></a> [role\_arn](#output\_role\_arn) | Role ARN |
| <a name="output_role_id"></a> [role\_id](#output\_role\_id) | The stable and unique string identifying the role |
| <a name="output_role_name"></a> [role\_name](#output\_role\_name) | The name of the created role |
| <a name="output_s3_export_path"></a> [s3\_export\_path](#output\_s3\_export\_path) | A path to exported data in an AWS S3 bucket |
<!-- END_TF_DOCS -->

## License
The Apache-2.0 license