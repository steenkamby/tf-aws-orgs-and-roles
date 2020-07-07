# tf-aws-orgs-and-roles

Setup orgs, sub accounts and roles via tf.

## Assignment

### Description

Let's say we have two groups of users. The first group - "​​Developers​​", with users: Eugene, Milo, Abigail, Aidan. The second group - "​​Ops​​", with users: Santiago, Felix, Morgan.
Your cloud provider is AWS, but this is only a hint of which resources you should use. For the purpose of the task, it does not have to run against a real AWS environment.

### Task

1. Which resources will you use, and how will they interact?
2. Write Terraform code which will:
    1. Create users and groups
    2. Assign users to the groups
    3. Create roles for each group (users should be able to assume them); you do not have to assign any policies to the roles.

## Task Breakdown

To figure out what's needed, assumptions can be made about the company and organization in question, since it's important for the resulting organization layout.

1. The company is a bank with compliance obligations. We will call it ACME-Bank.
2. Since it's a bank, segregation of duties demand that developers do not have access to the running production environment.

The recommended approach to handling several environments is to use a multi-account setup in AWS. One of the strengths of using the multi-account approach lies in architecting it into the platforms microservice structure, and in defining a good domain driven organization to enable independent (blackboxed) feature development - this makes it easy to later scale development. Another strength with the multi-account strategy is a completely isolated security and resource environment, which limits the blast radius if the app is compromised.
One might imagine a company, where the app contains both a thin frontend, which is injected into store pages, and underlying heavy business logic. Dividing those domains into several domains might be a good idea.
Lastly the division makes it easy to trace cost across the platform in detail.

3. Developers and Ops belong to the legal department.
4. The data domain is legal documents stored in s3 (simplest task)

For this assignment, it will be assumed that users are working on assignments in the legal department, where they are responsible for preparing pdfs to be served on S3. (They could be working in other data doamins also, but this assignment only deals with setting up boundaries and access for legal document storage.) The company setup uses a standardized non-prod / prod model. Meaning the devs will map which legal documents/version that go into the non-prod and prod S3 buckets. Only Ops is actually allowed to run the pipeline to apply the mapping to the prod bucket.

5. The company adopts a whitelisting strategy towards policies and access rights. (Everything is blocked/denied by default. All access has to be explicitely defined.)

### Links

<https://aws.amazon.com/organizations/getting-started/best-practices/>
<https://docs.aws.amazon.com/organizations/latest/userguide/organizations-userguide.pdf#orgs_getting-started_concepts/>

## AWS Organization

When working with Terraform and AWS services, it's a very good idea to sketch out, what's about to be built.

### Diagram

It should now be possible to do an easy draft of a barebone account / organizational unit structure (x - scope for this task).

```bash
x aws-account Master
├── aws-account Logging
├── aws-account Billing
├── aws-account Security
├── aws-account Custodian
├── aws-account Audit
└── x aws-organization ACME-Bank
    ├── aws-ou Infrastructure
    │   ├── aws-account MessageQueues
    │   ├── aws-account TaskRunners
    │   └── aws-account Analytics
    └── x aws-ou BusinessDomains
        ├── aws-ou EmbeddedFrontend
        ├── aws-ou Frontend
        ├── aws-ou CreditDecisions
        ├── aws-ou BusinessIntelligence
        └── x aws-ou Legal
            ├── aws-ou SignedDocuments
            ├── aws-ou DynamicDocuments
            └── x aws-ou StaticDocuments
                ├── x aws-account StaticDocsArchive
                ├── x aws-account StaticDocsNonProd
                └── x aws-account StaticDocsProd
```

### Admin Account Purposes

| Account               | Description                                                                                         |
|-----------------------|-----------------------------------------------------------------------------------------------------|
| aws-account Master    | The root account from where OU's and sub-accounts are controlled, should be locked down.            |
| aws-account Logging   | All Cloudtrail logs are dumped here for centralized management and supervision.                     |
| aws-account Billing   | Account for consolidated billing. Services can be set up to automatically audit expenses.           |
| aws-account Security  | Security management, consume logs from Logging account to generate notifications, incidents etc.    |
| aws-account Custodian | For automated enforcing of policies on all sub-accounts.                                            |
| aws-account Audit     | Provides auditors an entry(glasspane) to switchroles into read-only audit roles in the subaccounts. |

### IT DDD OUs and accounts

| Account / OU                  | Purpose                                                                                   |
|-------------------------------|-------------------------------------------------------------------------------------------|
| aws-organization ACME-Bank    | The main organization, scp's can be attached here to affect all nested ou's and accounts. |
| aws-ou Infrastructure         | OU for shared IT resources across the organization.                                       |
| aws-account MessageQueues     | Kafka, RabitMQ, etc.                                                                      |
| aws-account TaskRunners       | Jenkins, droneci, etc.                                                                    |
| aws-account Analytics         | Infrastructure for org-wide collection of analytics for use by BA's og BI's.              |
| aws-ou BusinessDomains        | Collection of domains, that represent the organization, application and DDD units.        |
| aws-ou EmbeddedFrontend       | Development and production of the embedded webshop frontend.                              |
| aws-ou Frontend               | Homepage                                                                                  |
| aws-ou CreditDecisions        | Numbercrunching                                                                           |
| aws-ou BusinessIntelligence   | Smart stuff                                                                               |
| aws-ou Legal                  | OU for customer documentation                                                             |
| aws-ou SignedDocuments        | OU for storage of customer signed documents.                                              |
| aws-ou DynamicDocuments       | OU for services handling generation of legal documents for customer signing.              |
| aws-ou StaticDocuments        | OU for static documents such as TOS.                                                      |
| aws-account StaticDocsArchive | Versioned docs, from which the current non-prod and prod variants are pulled.             |
| aws-account StaticDocsNonProd | Internally accesible non-prod version of the legal documents.                             |
| aws-account StaticDocsProd    | Current legally binding version of documents.                                             |

### Users

From the subset of OUs and accounts to be generated, it can now be ascertained which roles the users should be assigned.

* Developers - The non-prod feature development environment account(s).
* Operations - The prod feature developemnt account(s).

If the org was fully implemented, Developers would also have domain non-prod scoped access to the logging account, the message queue and the task runner accounts. Operations would have domain scoped prod access to these.

Also, it's clear that there are some roles, which are out of scope for this exercise, which are nessecary to run the (minimalistic) organisation compliantly.

* Root Login on Master account - Locked in a safe somewhere and never touched.
* CTO / COO - Able to assign SecOps and Audit roles.
* SecOps - Who run the security account, and are able to assign dev and ops roles. (But dont have access into prod accounts)
* Audit - Able to use the glass-pane read only access to make sure company policies are being upheld.

### SCP's

Service Control Policies are the key to successfully using the AWS Organization.
For this task three basic SCP's will be implemeted.

1. A logging SCP that prevents any sub-account from disabling CloudTrails logging. All actions taken should be auditable always.
2. A deny all org wide SCP to lock down all features in all sub accounts.
3. A SCP to allow the use of S3 in the legal docs OU.
4. A SCP blocking the tf-created root users of the new accounts from taking actions

In other words, we start by locking down logging for audit, then blacklist everything, then whitelist the feature we actually need.

### Scope for this task

For this task the following needs to be implemented via Terraform.

1. Org structure that are needed for user roles.
2. SCP's
3. Users, groups and roles, with example policies to set them aside.
4. Assign roles to groups
5. S3 Bucket(s)

#### Links

<https://chaosgears.com/dont-panic-organize-part-1-of-2/>

## Running the Terraform

* Create a root aws account, create a user with terminal access
* brew install tf gpg awscli
* Configure aws locally for the root account. edit provider.tf with the profile name of the root user.
* Replace the exampleuser.asc with a locally created key, edit company_users.tf if you change the filename.
* Replace the emails in company_org.tf with one under your control. Note: if you wish to use email aliases, you must choose a provider who supports it, like gmail.
* terraform init
* terraform plan
* terraform apply
* To decrypt the secrets pr user, output them to files like secret_key.tmp and secret_pw.tmp and use: 
    * base64 --decode secret_key.tmp | gpg --decrypt
    * base64 --decode secret_pw.tmp | gpg --decrypt
    * This example only outputs the test_admins fake credentials, in a real use case, you would collect valid public keys from all the develops and ops, and input those, then map the credential outputs for all users and send them the resulting JSON files.
