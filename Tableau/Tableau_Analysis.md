# Tableau Data Analysis — Little Lemon

This document describes the worksheets and dashboard built in Tableau for the
Little Lemon sales analysis, using the course-provided data file.

## Data Preparation

1. Connect Tableau to the Little Lemon data file (Excel/CSV).
2. Split the `Customer Name` field into **First Name** and **Last Name**.
3. Filter out records where `Postcode` is unknown.
4. Create a calculated field for profit:
   `Profit = Sales - Cost`

## Worksheet 1 — Customers Sales

- Bar chart with **Customer (Full Name)** on Rows and **SUM(Sales)** on Columns.
- Filter applied: at-least sales of **$70**.
- Sorted descending to show the highest-spending customers first.

## Worksheet 2 — Profit Chart

- Line chart with **YEAR(Order Date)** on Columns and **SUM(Profit)** on Rows.
- Shows the sales profit trend per year.

## Worksheet 3 — Sales Bubble Chart

- Bubble chart with **Customer Name** on Detail, **SUM(Sales)** on Size,
  and Customer Name on Color/Label.
- Hovering a bubble shows the customer's name and total sales.

## Worksheet 4 — Cuisine Sales and Profits

- Bar chart of the **three most popular cuisines** (Greek, Italian, Turkish).
- **Cuisine Name** on Columns; **SUM(Sales)** and **SUM(Profit)** on Rows.
- Bars sorted in descending order of sales.

## Dashboard — Customers Sales Analysis

- Combines the **Customers Sales bar chart** and the **Sales Bubble Chart**.
- Interactive: hovering over a customer bar or bubble highlights the
  corresponding data and shows the sales amount in the tooltip.
