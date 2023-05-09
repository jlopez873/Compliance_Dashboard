# Compliance Dashboard - README

This project provides a dashboard that informs stakeholders of hospital metrics, patient demographics, and health trends. It aims to help decision-makers identify opportunities for improving patient outcomes and reducing readmission rates, among other metrics.

The project includes two main components: data preprocessing using pgAdmin 4 and data visualization using Tableau Public. The data comes from two datasets: medical data and CMS data from the Hospital Readmissions Reduction Program.

## Installation

To install and use the Compliance Dashboard, follow these instructions:

1. Make sure you are running Mac OS and have a fully functioning installation of pgAdmin 4 and Tableau Public on your machine. If you do not have pgAdmin 4 installed, download and install it from [here](https://www.pgadmin.org/download/). If you do not have Tableau Public installed, download and install it from [here](https://public.tableau.com/en-us/s/download).
2. Open PostgreSQL on your desktop.
3. Expand Servers in the Object Explorer.
4. Right-click Databases > Create > Database on the Object Explorer container.
5. Type `medical` into the Database field and click Save.
6. Select the medical database and select Query Tool.
7. Click the Open File folder button, select `CreateTables.sql`, and click Open.
8. Click the Execute/Refresh play button.
9. Expand Schemas.
10. Expand Tables. Note: If no tables populate, right-click Tables > Refresh.
11. Right-click on the medical table and select Import/Export Data.
12. Select the `medical_clean.csv` file and click OK.
13. Right-click on the readmissions table and select Import/Export Data.
14. Select the `FY_2023_HRRP.csv` file and click OK.
15. Click the Open File folder button, select `CleanData.sql`, and click Open.
16. Click the Execute/Refresh play button.
17. Click the Save results to file download button.
18. Name the file `readmissions.csv` and click Save.
19. Open Tableau Public.
20. Click File > Open on the Menubar.
21. Select the `ComplianceDashboard.twbx` file and click Open.
22. Click the COMPLIANCE DASHBOARD tab, or click [here](https://public.tableau.com/views/ComplianceDashboard_16205563409360/COMPLIANCEDASHBOARD?:language=en-US&:display_count=n&:origin=viz_share_link) to view the dashboard.

## Reporting

To learn more about the project, read the `Compliance Dashboard Analysis` report. It includes information about the dashboard's purpose, justification, data preparation, dashboard creation, results, executive decision-making, and limitations.

## Sources

The data used in this project comes from the Hospital Readmissions Reduction Program of the Center for Medicare & Medicaid Services. For more information, visit [their website](https://data.cms.gov/provider-data/dataset/9n3s-kdb3).
