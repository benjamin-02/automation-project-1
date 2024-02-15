#!/bin/bash

# Update the repos
sudo dnf update -y
# Install openjdk/aws corretto
sudo dnf install java-17-amazon-corretto -y
# Install other dependencies
sudo dnf install fontconfig wget -y

# Install Jenkins
sudo wget -O /etc/yum.repos.d/jenkins.repo https://pkg.jenkins.io/redhat-stable/jenkins.repo
sudo rpm --import https://pkg.jenkins.io/redhat-stable/jenkins.io-2023.key
sudo dnf upgrade -y
sudo dnf install jenkins -y
sudo systemctl daemon-reload
sudo systemctl jenkins enable --now