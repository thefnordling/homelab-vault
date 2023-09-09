# homelab-vault
This is the HashiCorp Vault setup I use in my home lab environment.  I use the PKI plugin to create a Root Certificate for the home lab (home.arpa), as well as a leaf/intermediate certificate (generated/signed by the root CA) which will be used to create the hosting certificates that the various services I run in my home lab will use for TLS.

Secrets that applications and services will use will be stored in the Key-Value secret plugin (v2).

I use the approle plugin to limit access to PKI and KV secrets via policy based access control.

Unlock-Keys, root tokens and other such secrets will be saved outside of vault in a password manager.

For now I am running this in docker swarm, but will be setting up a k8s-vault in the near future.

Note - once set up Vault has no open ports on docker so it cannot be accessed directly from the network (that is why I have TLS disabled in my configurations).  Any usage of Vault occurs through an Nginx ingres service that provides TLS termination/upgrades.

Persistent Storage:

I will be running Vault as a stateless docker service.  We will be storing all vault data on an NFS share so all of our approles, secrets and PKI data will be not be lost after a service restart or if a host crashes or undergoes maintenance.  All of our docker hosts will have the same NFS volume mounted at the same location (via /etc/fstab on host) to store the encrypted Vault Data.

We will be taking a daily backup of vault, and configuring a retention period for the backups.  Backups will be stored on a separate NFS share, which is set up similarly on each host.  At some point in the near future I will be switching to S3 (minio) to store the backups (so if my nas dies I can recover from a separate store).  I will likely write a simple [C# Consoel App](https://github.com/thefnordling/dotnet-s3-example) for that when i have some time.

Setup:

After provisioning storage, setting up NFS mounts and installing docker, I add a new docker config with the value of the contents of the [initial config](./docker/initial/config.hcl).

 I [initialize the stack](./docker/initialize-vault-only/docker-compose.yml).  Once the vault service starts up - i attach to the container and initialize the vault by running the command `vault operator init -key-shares=1 -key-threshold=1`.  If you have more time and enjoy a more complex/secure setup - you should generate more keys and have a higher number of keys required to unseal (but for a home lab POC this was fine for me).  This command will produce the unseal keys as well as a root token - save those someplace safe and secure you will need them for future maintenance, and add the vault unseal key as a docker secret.  We will need this for the next step.

 Now that vault has been initialized - if it were to restart it would not function since the unseal keys are not available to vault itself.  We have a solution for that with a simple script that will [unseal](https://github.com/thefnordling/homelab-vault-unseal) the vault automatically.   Since you have now saved the unseal keys as a docker secret, you can then run the [vault with an unseal service](./docker/vault-with-unseal/docker-compose.yml)