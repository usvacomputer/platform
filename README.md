# usva

In conventional Kubernetes setups, a cluster is initiated by starting a control plane, which then awaits connections from worker nodes. This process requires upfront dedicated hardware, a networking setup, and planning for cluster state persistence, not to mention the transfer of join tokens to the actual worker nodes.

Usva reverses this process - the control plane is initiated on-demand, triggered by the connection of worker nodes. As an open-source project, Usva builds on top of k0smotron (k0smotron.io), which deploys the k0s distribution (k0sproject.io) control planes. The Usva-enhanced k0smotron works in both on-prem and cloud environments, thanks to the newly introduced support for Cluster API.

Usva is a great fit for ephemeral clusters, such as those used for batch processing and handling spike workloads. This talk aims to clarifythe components, deployment, and use cases for Usva, accompanied by a live demo of mixed-environment workers forming a Kubernetes cluster in seconds.

## Setup

Clone and `bin/usva start`, then `bin/usva dev` followed by `bin/usva worker`
