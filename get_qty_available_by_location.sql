/* RAISE NOTICE USING MESSAGE = 'move product: ' || move.product_id; */
DROP FUNCTION IF EXISTS get_qty_available_by_location(product integer, location integer);
CREATE OR REPLACE FUNCTION get_qty_available_by_location(product integer, location integer)
RETURNS float AS $$
    DECLARE
        total float;
        total_in float;
        total_out float;
        compute_qty float;
        template integer;
        move stock_move%rowtype;
        from_uom product_uom%rowtype;
        to_uom product_uom%rowtype;
    BEGIN
        total_in := 0;
        total_out := 0;
        total := 0;
        FOR move IN SELECT * FROM stock_move
                             WHERE product_id = product
                                   AND location_dest_id = location
                                   AND location_id != location
                                   AND state = 'done'
                                   AND product_uom_qty > 0
                             LOOP
            template := (SELECT product_tmpl_id FROM product_product WHERE id=move.product_id);
            SELECT * INTO from_uom FROM product_uom WHERE id=move.product_uom;
            SELECT * INTO to_uom FROM product_uom WHERE id IN (SELECT uom_id FROM product_template WHERE id = template);
            SELECT compute_qty_obj(from_uom, move.product_uom_qty, to_uom, 'HALF-UP') INTO compute_qty;
            total_in := total_in + compute_qty;
        END LOOP;
        FOR move IN SELECT * FROM stock_move
                             WHERE product_id = product
                                   AND location_id = location
                                   AND location_dest_id != location
                                   AND state = 'done'
                                   AND product_uom_qty > 0
                             LOOP
            template := (SELECT product_tmpl_id FROM product_product WHERE id=move.product_id);
            SELECT * INTO from_uom FROM product_uom WHERE id=move.product_uom;
            SELECT * INTO to_uom FROM product_uom WHERE id IN (SELECT uom_id FROM product_template WHERE id = template);
            SELECT compute_qty_obj(from_uom, move.product_uom_qty, to_uom, 'HALF-UP') INTO compute_qty;
            total_out := total_out + compute_qty;
        END LOOP;
        total := total_in - total_out;

        RETURN total; END;
    $$ LANGUAGE plpgsql;

WITH move AS (
    SELECT
        product_id,
        location_dest_id
    FROM
        stock_move WHERE state ='done'
    GROUP BY
        product_id,
        location_dest_id)
SELECT
    loc.complete_name AS location_name,
    prod.name_template AS product_name,
    prod.id AS product_id,
    move.location_dest_id AS location_id,
    loc.usage AS loc_type,
    get_qty_available_by_location(move.product_id, move.location_dest_id) AS total
FROM
    move
INNER JOIN
    product_product AS prod ON prod.id = move.product_id
INNER JOIN
    stock_location AS loc ON loc.id = move.location_dest_id
WHERE
    loc.usage='internal'
    /* AND move.product_id=14608 */
ORDER BY
    loc.complete_name,
    move.product_id;
