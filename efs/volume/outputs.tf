output "volume" {
  value = aws_efs_file_system.this
}

output "mount_targets" {
  value = aws_efs_mount_target.this
}
