module "lambda" {
  source = "../../"

  s3_bucket_id         = module.bucket.bucket_id
  kms_key_id           = module.kms_key.key_id
  export_task_role_arn = aws_iam_role.export.arn
  lambda_policy_arn    = aws_iam_policy.lambda.arn
}
