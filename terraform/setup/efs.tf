resource "aws_efs_file_system" "efs-storage" {
  creation_token = "efs-storage"
  availability_zone_name = var.aws_availability_zone

  tags = {
    Name = "efs-storage",
    Project = var.project
  }
}

resource "aws_efs_access_point" "efs-storage" {
  file_system_id = aws_efs_file_system.efs-storage.id
  tags = { Project = var.project }
}

resource "aws_efs_mount_target" "efs-storage" {
  file_system_id = aws_efs_file_system.efs-storage.id
  subnet_id = aws_subnet.subnet.id
  security_groups = [aws_security_group.security.id]
}

resource "aws_vpc" "efs-storage" {
  cidr_block = "10.0.0.0/16"
  tags = { Project = var.project }
}

output "mount_target_id" {
  description = "The id of the mount target for the efs drive"
  value       = aws_efs_mount_target.efs-storage.id
}

output "mount_target_dns_name" {
  description = "The dns_name of the mount targert for the efs drive"
  value       = aws_efs_mount_target.efs-storage.dns_name
}

output "file_system_id" {
  description = "The id of the shared efs drive"
  value       = aws_efs_file_system.efs-storage.id
}

resource "aws_datasync_location_efs" "efs-storage" {
  # The below example uses aws_efs_mount_target as a reference to ensure a mount target already exists when resource creation occurs.
  # You can accomplish the same behavior with depends_on or an aws_efs_mount_target data source reference.
  efs_file_system_arn = aws_efs_mount_target.efs-storage.file_system_arn
  ec2_config {
    security_group_arns = [aws_security_group.security.arn]
    subnet_arn          = aws_subnet.subnet.arn
  }
}
