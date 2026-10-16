# Troubleshooting and results

These issues and fixes are documented in Week 10, Assignment 4.

| Issue observed | Reported cause | Resolution described |
|---|---|---|
| Node.js/Sequelize `ECONNREFUSED 127.0.0.1:3306` | Application still targeted local MySQL rather than RDS | Correct database host/environment settings and restart the application. |
| Nginx default welcome page instead of EpicBook | Default site was enabled or custom site was not linked/reloaded | Enable the EpicBook Nginx site, disable the default site, validate Nginx config and restart. |
| RDS database provisioning failed | Only one database subnet was specified | Add subnets in different Availability Zones to the RDS subnet group. |
| Terraform EC2 key pair error | Required public key path/key reference was missing | Provide a valid key-pair resource/public key path without storing private key material in Git. |
| Bookstore showed empty content | No sample books existed in the database | Insert test `Author` / `Book` records; reload and verify. |
| MySQL authentication attempts initially failed | Database login settings were not accepted | Correct the database access configuration; later MySQL terminal evidence shows a successful connection. |

## Recorded verification

- Terraform output reported an EC2 public address.
- EpicBook storefront displayed in a browser.
- MySQL terminal listed the expected application tables.
- The written report describes sample book loading, cart operations and checkout records.

**Limitations:** screenshots show point-in-time deployment evidence. They do not establish automated health monitoring, load balancing, application auto-recovery, HTTPS, backups or long-term high availability.
