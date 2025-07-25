# Case Study: Remodeling Data Using PostgreSQL Hosted on Amazon RDS

In this case study, I will remodel data from the popular **Sakila** dataset. The dataset will first be **denormalized** to simulate a real-world messy data scenario, and then **normalized** again to demonstrate data modeling techniques.

I'm using the **AWS Free Tier** of Amazon RDS with **PostgreSQL**, without Multi-AZ deployment. The database is managed and accessed using **pgAdmin 4**, installed locally on my private workstation.

To ensure secure access, I have configured **inbound rules** in the associated **Security Group** to only allow traffic from my **office IP address**. This minimizes the exposure of the database to unauthorized access.

![Inbound rule configuration for PostgreSQL access](https://github.com/KamilKozera/cs-data-modeling/blob/main/png-files/file_1.png)

> *Inbound rule setup in AWS allowing access to port 5432 (PostgreSQL) only from a specific IP address.*


## 1. Populating the Database with Data

To populate the database, I use the Sakila dataset available on GitHub:  
🔗 [jOOQ/sakila](https://github.com/jOOQ/sakila)

![SQL scripts in GitHub repo](https://github.com/KamilKozera/cs-data-modeling/blob/main/png-files/file_2.png)


Since **Amazon RDS** does not grant superuser privileges, certain SQL commands like:

```sql
ALTER TABLE language DISABLE TRIGGER ALL;
ALTER TABLE language ENABLE TRIGGER ALL;
```

must be removed. This means all data inserts must be performed with full integrity checks enabled.



---
This case study includes SQL scripts derived from the [jOOQ Object Oriented Querying](https://github.com/jOOQ/sakila) project, which is licensed under the **BSD 2-Clause License**.

---

**Copyright (c) 2021, jOOQ Object Oriented Querying**  
All rights reserved.

Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

1. Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.

2. Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.

> **DISCLAIMER:**  
> THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED.  
> IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
