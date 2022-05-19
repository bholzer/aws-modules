output "table" {
  value = aws_dynamodb_table.this
}

output "read_policy" {
  value = aws_iam_policy.table_read
}

output "write_policy" {
  value = aws_iam_policy.table_write
}
