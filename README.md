# OCI Terraform

### getting start with terraform and oci
https://learn.hashicorp.com/collections/terraform/oci-get-started

### oci availability domain
https://docs.oracle.com/pt-br/iaas/Content/General/Concepts/regions.htm
![Availability Domain](/availability_domain.png?raw=true "Availability Domain")

### oci images
https://docs.oracle.com/en-us/iaas/images/image/1eabae6e-af35-4986-aaf7-820459113753/

### oci session
```
oci session authenticate
```

### init
```
terraform init
```

### Generating ssh-key files
You can generate the ssh files by running
```bash
ssh-keygen -t rsa -b 2048 -f ssh.key
```

### Connecting into instance
After running terraform apply you will see the publi ip
```
ssh -i ssh.key opc@<instance_ip>
```

### cloud-init Log
You can visualize the cloud-init-output.log
```bash
sudo tail  -f /var/log/cloud-init-output.log
```