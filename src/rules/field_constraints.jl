# Auto-generated file - Field constraint validation rules
# Generated from GTFS specification parsing

# Compact rule set distilled from parsed field constraint information
const FIELD_CONSTRAINTS = Dict(
    :agency => [
        (
            field = :agency_id,
            constraint = "Unique",
        ),
    ],
    :stops => [
        (
            field = :stop_id,
            constraint = "Unique",
        ),
    ],
    :routes => [
        (
            field = :route_id,
            constraint = "Unique",
        ),
        (
            field = :route_sort_order,
            constraint = "Non-negative",
        ),
    ],
    :trips => [
        (
            field = :trip_id,
            constraint = "Unique",
        ),
    ],
    :stop_times => [
        (
            field = :stop_sequence,
            constraint = "Non-negative",
        ),
        (
            field = :shape_dist_traveled,
            constraint = "Non-negative",
        ),
    ],
    :calendar => [
        (
            field = :service_id,
            constraint = "Unique",
        ),
    ],
    :fare_attributes => [
        (
            field = :fare_id,
            constraint = "Unique",
        ),
        (
            field = :price,
            constraint = "Non-negative",
        ),
        (
            field = :transfer_duration,
            constraint = "Non-negative",
        ),
    ],
    :rider_categories => [
        (
            field = :rider_category_id,
            constraint = "Unique",
        ),
    ],
    :fare_media => [
        (
            field = :fare_media_id,
            constraint = "Unique",
        ),
    ],
    :fare_leg_rules => [
        (
            field = :rule_priority,
            constraint = "Non-negative",
        ),
    ],
    :fare_transfer_rules => [
        (
            field = :transfer_count,
            constraint = "Non-zero",
        ),
        (
            field = :duration_limit,
            constraint = "Positive",
        ),
    ],
    :areas => [
        (
            field = :area_id,
            constraint = "Unique",
        ),
    ],
    :networks => [
        (
            field = :network_id,
            constraint = "Unique",
        ),
    ],
    :shapes => [
        (
            field = :shape_pt_sequence,
            constraint = "Non-negative",
        ),
        (
            field = :shape_dist_traveled,
            constraint = "Non-negative",
        ),
    ],
    :frequencies => [
        (
            field = :headway_secs,
            constraint = "Positive",
        ),
    ],
    :transfers => [
        (
            field = :min_transfer_time,
            constraint = "Non-negative",
        ),
    ],
    :pathways => [
        (
            field = :pathway_id,
            constraint = "Unique",
        ),
        (
            field = :length,
            constraint = "Non-negative",
        ),
        (
            field = :traversal_time,
            constraint = "Positive",
        ),
        (
            field = :min_width,
            constraint = "Positive",
        ),
    ],
    :levels => [
        (
            field = :level_id,
            constraint = "Unique",
        ),
    ],
    :location_groups => [
        (
            field = :location_group_id,
            constraint = "Unique",
        ),
    ],
    :booking_rules => [
        (
            field = :booking_rule_id,
            constraint = "Unique",
        ),
    ],
    :attributions => [
        (
            field = :attribution_id,
            constraint = "Unique",
        ),
    ],
)
