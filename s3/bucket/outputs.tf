output "bucket" {
  value = aws_s3_bucket.this
}

output "read_policy" {
  value = aws_iam_policy.read
}

output "write_policy" {
  value = aws_iam_policy.write
}
