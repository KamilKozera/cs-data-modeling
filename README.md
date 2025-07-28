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

## 2. Creating denormalized data model.

<table border="1">
  <thead>
    <tr>
      <th>Denormalized Table</th>
      <th>Description</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td rowspan="4">
        <img src="https://github.com/KamilKozera/cs-data-modeling/blob/main/png-files/file_3.png" alt="Denormalized Table Image" width="300">
      </td>
      <td>
        Using the SQL script found 
        <a href="https://github.com/KamilKozera/cs-data-modeling/blob/main/sql-scripts/denormalize-scripts/denormalize.sql">here</a>,
        a single, denormalized table named <code>denormalized_table</code> was constructed. To accelerate the creation of this complex, intentionally flawed starting point, a Generative AI was leveraged to produce the baseline script. Specifically, it contains the following known issues that we will resolve:
      </td>
    </tr>
    <tr>
      <td><strong>1NF Violation:</strong> The <code>actors_list</code> and <code>special_features</code> columns contain non-atomic, multi-valued data.</td>
    </tr>
    <tr>
      <td><strong>2NF Violation:</strong> With a composite primary key of (<code>inventory_id</code>, <code>customer_id</code>, <code>rental_date</code>), columns like <code>film_title</code> (dependent only on <code>inventory_id</code>) and <code>customer_first_name</code> (dependent only on <code>customer_id</code>) represent partial dependencies.</td>
    </tr>
    <tr>
      <td><strong>3NF Violation:</strong> The table contains transitive dependencies, such as <code>customer_country</code> being dependent on the non-key attribute <code>customer_city</code>.</td>
    </tr>
  </tbody>
</table>


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
