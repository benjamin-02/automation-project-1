output "jenkins_public_ip" {
  description = "Public IP of Jenkins Instance"
  value       = aws_instance.jenkins.public_ip
}