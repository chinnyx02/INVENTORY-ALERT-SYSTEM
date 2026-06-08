Project Overview

This project provides a complete inventory analytics solution for a retail/wholesale business with 8 SKUs across Electronics and Accessories categories. It includes SQL scripts, Excel templates, and Power BI dashboards to monitor stock levels, identify stockout risks, and generate purchase recommendations.

Key Deliverables:

    ✅ SQL database schema with analytical views

    ✅ Excel dashboard with auto-calculating KPIs

    ✅ Executive summary with actionable insights


Key Insights

# Phone X and Monitor 24 will stockout in less than 3 days


    Phone X: 12 units left → 2 days remaining

    Monitor 24: 8 units left → 2.4 days remaining

    Action: Emergency reorder within 24 hours


# USB Cable has a hidden supply chain failure

    500 units on hand appears safe, but:

        14-day lead time + 1,200 monthly demand = negative buffer of −60 units

    Action: Increase safety stock to 100 or find faster supplier

Technologies Used

SQL Server	Data storage, calculations, views
Excel	Quick analysis, templates, conditional formatting
Power BI,Interactive dashboard.
   
     Recommended Actions

Priority	Action	Timeline	Responsible
P0	Reorder Phone X (27 units)	< 24 hours	Procurement
P0	Reorder Monitor 24 (31 units)	< 24 hours	Procurement
P1	Reorder Keyboard (25 units)	< 48 hours	Procurement
P1	Increase USB Cable safety stock to 100	< 1 week	Inventory Manager
P2	Reduce Desk Mat stock to 100 units	< 2 weeks	Warehouse Manager
P3	Set automated reorder alerts at ReorderLevel	Immediate	IT / Ops
