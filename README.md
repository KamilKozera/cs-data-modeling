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

## 3. Transforming the relation into First Normal Form (1NF)

To normalize the relation to 1NF, the relation must satisfy following conditions:
- Each row is unique. (**Satisfied**)
- There are no repeating groups of columns (**Satisfied**)
- All attribute values are atomic (indivisible) - (**Not satisfied**)

Columns <code>actors_list</code> and <code>special_features</code> contain data that fails to meet one of the conditions - indivisibility.

actors_list |  special_features
:-:|:-:
![](https://github.com/KamilKozera/cs-data-modeling/blob/main/png-files/file_5.png)  | ![](https://github.com/KamilKozera/cs-data-modeling/blob/main/png-files/file_6.png)

To achieve First Normal Form, the non-atomic columns were resolved by creating two new tables: <code>film_actors</code> and <code>film_features</code>. In the <code>film_actors</code> table, a composite primary key of (<code>film_id</code>, <code>actor_name</code> was established to ensure each row is unique. Similarly, the <code>film_features</code> table uses a composite primary key of (<code>film_id</code>, <code>special_feature</code>) to guarantee uniqueness for each film-feature combination.

![](https://github.com/KamilKozera/cs-data-modeling/blob/main/png-files/file_4.png)

At this point, all three of my tables are in 1NF. Notice that I have not yet added any foreign keys. My only goal was to fix the atomicity problem. The tables are now structurally sound, but the database doesn't yet enforce the relationships between them. We will address that in the next step.

## 4. Transforming the relations into Second Normal Form (2NF)

To normalize the relation to 2NF, the relation must satisfy following conditions:
- The relation must already be in First Normal Form (1NF). (**Satisfied**)
- The relation must have no partial dependencies. This means every non-key attribute must be fully functionally dependent on the *entire* primary key. (**Not Satisfied**)

### Identifying the Partial Dependencies

A partial dependency exists because our table uses a composite primary key: (<code>inventory_id</code>, <code>customer_id</code>, <code>rental_date</code>). We have two groups of attributes that violate the 2NF rule:
1. **Customer-related attributes**: Columns like <code>customer_first_name</code>, <code>customer_last_name</code>, <code>customer_email</code>, <code>customer_address</code>, <code>customer_city</code> and <code>customer_country</code> are dependent only on <code>customer_id</code>, which is just one part of the primary key.
2. **Film-related attributes**: Columns like <code>film_title</code>, <code>film_category</code> and <code>film_rating</code> are dependent only on <code>inventory_id</code>, another part of the primary key.

### Creating new tables

To normalize all the relations to **Second Normal Form**, three additional tables were created <code>inventory</code>, <code>customers</code> and <code>films</code>. On top of that, the table <code>normalized_to_1NF</code> was renamed to <code>rentals</code>. The <code>inventory</code> table was created to link renatals table with the tables that have <code>film_id</code> as a primary key. This was done because <code>inventory_id</code> in <code>rentals</code> table describes copies that are rented out. There can be multiple copies of the same film. On top of that, new primary surrogate key <code>rental_id</code> was added to <code>rentals</code> table.

Achieving Second Normal Form delivers immediate and substantial benefits by eliminating the data redundancy caused by partial dependencies. This directly resolves the risk of update and deletion anomalies that were present in the 1NF model. For example, changing a film's title previously required finding and modifying every single rental record associated with that film - a process prone to error. Now, it is a single, safe update in one location within the films table. This principle extends to all customer and film information, making the entire data model significantly more efficient, reliable, and easier to maintain.

### Foreign key constraints



![](https://github.com/KamilKozera/cs-data-modeling/blob/main/png-files/file_7.png)

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
