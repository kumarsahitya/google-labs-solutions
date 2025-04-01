# 👨‍💻 Lab Link: [Get Started with Looker: Challenge Lab](https://www.cloudskillsboost.google/course_templates/647/labs/461643)


## Task 1. Create a new report in Looker Studio

1. Create a new [Looker Studio](http://lookerstudio.google.com/) report named **Online Sales**, and connect to **Public datasets** > **<mark>\<filled in at lab start></mark>** > **thelook_ecommerce** > **orders**.

2. Add a time series chart using any theme and title of your choice.

## Task 2. Create a new view in Looker

1. Create a new view named **users_region** with the following specifications:

2. Copy and Paste below code in **editor** and click **save change**.

```
view: users_region {
  sql_table_name: cloud-training-demos.looker_ecomm.users ;;
  
  dimension: id {
    type: number
    sql: ${TABLE}.id ;;
    primary_key: yes
  }
  
  dimension: state {
    type: string
    sql: ${TABLE}.state ;;
  }
  
  dimension: country {
    type: string
    sql: ${TABLE}.country ;;
  }
  
  measure: count {
    type: count
    drill_fields: [id, state, country]
  }
}
```

3. In the file browser, under the models folder, navigate to the ```training_ecommerce.model``` file.

4. Clear existing code from **editor**.

5. Copy and Paste below code in **editor** and click **save change**.

```
connection: "bigquery_public_data_looker"

# include all the views
include: "/views/*.view"
include: "/z_tests/*.lkml"
include: "/**/*.dashboard"

datagroup: training_ecommerce_default_datagroup {
  # sql_trigger: SELECT MAX(id) FROM etl_log;;
  max_cache_age: "1 hour"
}

persist_with: training_ecommerce_default_datagroup

label: "E-Commerce Training"

explore: order_items {
  join: users {
    type: left_outer
    sql_on: ${order_items.user_id} = ${users.id} ;;
    relationship: many_to_one
  }

  join: inventory_items {
    type: left_outer
    sql_on: ${order_items.inventory_item_id} = ${inventory_items.id} ;;
    relationship: many_to_one
  }

  join: products {
    type: left_outer
    sql_on: ${inventory_items.product_id} = ${products.id} ;;
    relationship: many_to_one
  }

  join: distribution_centers {
    type: left_outer
    sql_on: ${products.distribution_center_id} = ${distribution_centers.id} ;;
    relationship: many_to_one
  }
}

explore: events {
  join: event_session_facts {
    type: left_outer
    sql_on: ${events.session_id} = ${event_session_facts.session_id} ;;
    relationship: many_to_one
  }
  join: event_session_funnel {
    type: left_outer
    sql_on: ${events.session_id} = ${event_session_funnel.session_id} ;;
    relationship: many_to_one
  }
  join: users {
    type: left_outer
    sql_on: ${events.user_id} = ${users.id} ;;
    relationship: many_to_one
  }
  join: users_region {
    type: left_outer
    sql_on: ${events.user_id} = ${users_region.id};;
    relationship: many_to_one
  }
}
```

### Commit Changes and Deploy to Production

1. Click **Validate LookML** and then click **Commit Changes & Push**.
2. Add a commit message and click **Commit**.
3. Lastly, click **Deploy to Production**.

<<<<<<< HEAD
## Task 3. Create a new dashboard in Looker
=======
### Task 3. Create a new dashboard in Looker
>>>>>>> 3ef699b64f45ed0890cb9f7bde300b52966f2123

1. Use your new view named **users_region** to create a bar chart of the **top 3 event types based on the highest number of users**.

2. Customize your bar chart using any colors and labels of your choice.

3. Save your bar chart to a new dashboard named **User Events**.

## Now check the score.

---

## ⚖️ NOTE: Copyright by Google Cloud
* This script is not originally from this page. It has been edited and shared for educational purposes. Message me if you want credit or removal (no copyright intended). All rights and credits for the original content go to Google Cloud. 📜✍️💡
* Credit goes to the respective owner [Google Cloud Skill Boost website](https://www.cloudskillsboost.google/). 🙏👑

---
