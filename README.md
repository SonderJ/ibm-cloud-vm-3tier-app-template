# ibm-cloud-vm-3tier-app-template
Terraform template for a typical 3-tier app stack containing Apache Tomcat, MySQL and IBM Load Balancer

## Variables

|Variable Name|Description|Default Value|
|-------------|-----------|-------------|
|appname|Application name for the stack to be deployed.|pocapp|
|webinstances|Number of web application instances to be deployed|2|
|webapp_port|Web application port|8080|
|cores|The number of CPU cores to allocate.|1|
|datacenter|Which data center the VM is to be provisioned in.|fra02|
|disk_size|Numeric disk sizes in GBs.|25|
|domain|Domain for the computing instance.|domain.dev|
|hostname|Hostname for the computing instance.|hostname|
|memory|The amount of memory to allocate, expressed in megabytes.|1026|
|network_speed|The connection speed (in Mbps) for the instance’s network components.|100|
|os_reference_code|An operating system reference code that is used to provision the computing instance.|CENTOS_7|
|private_network_only|When set to `true`, a compute instance only has access to the private network.|false|
|softlayer_api_key|Your IBM Cloud Infrastructure (SoftLayer) API key.| |
|softlayer_username|Your IBM Cloud Infrastructure (SoftLayer) user name.||
|ssh_key|Your public SSH key to use for access to virtual machine.||
|ssh_label|An identifying label to assign to the SSH key.|Admin Key|
|ssh_notes|Notes to store with the SSH key.|SSH Key for the Administrator|
|ssh_user|The provisioning user name.|root|
|tags|Set tags on the VM instance.|dbsystel|
