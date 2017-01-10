# SQL Migration Scripts

Plpgsql scripts useful at the moment to migrate between versions, because these reduce considerably the time of the migration. 

- create_quant_from_sql_method.sql

    This file contains a try of copy of the methods involved in the quant creation process but in plpgsql.

    This methods were tested in a database from V7 of Odoo with more than 600 thousands stock moves and the result in speed and accuracy of the quantity on hand were the expected(even with the negative quants).

    This [line](https://github.com/Vauxoo/sql_migration/blob/master/create_quant_from_sql_methods.sql#L448) starts the process, you can modified and customize this [line](https://github.com/Vauxoo/sql_migration/blob/master/create_quant_from_sql_methods.sql#L436)   to specify the moves that you want use to create the quants(even for a specific product or location) the only require thing is order the moves by date.

    Known Details
    --------------
    In the instance where this scripts was used had a lot of inconsistences with the use of the lot and package, for this reason were ignored at the momento to select the quant to use or create in each move.

    To use the cases ignored you need to modified the following lines.

    This [line](https://github.com/Vauxoo/sql_migration/blob/master/create_quant_from_sql_methods.sql#L120) can be mofied to add the following files ignored in the process to search quants with these values 

    This [line](https://github.com/Vauxoo/sql_migration/blob/master/create_quant_from_sql_methods.sql#L180) can be modified to add the lot and the package used by the move that is generating the quant.


- get_qty_available_by_location.sql

    This file is used to know the quantity on hand of a product computed using the stock moves and the unit of measure used  in the each move. This is useful to verify that the result shown after of execute of create_quant_from_sql_methods.sql is the expected. 

    This script was used in V7, V8 and V9 of odoo and the result shown is the real quantity on hand for the products.
    
    You can modified this [section](https://github.com/Vauxoo/sql_migration/blob/master/get_qty_available_by_location.sql#L50-L57) to be specific with the result to be shown in this litte report 

    Requirements.
    -------------
    To execute this script is needed create the methods used in the create_quant_from_sql_methods.sql script
