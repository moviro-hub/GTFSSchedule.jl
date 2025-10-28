# Auto-generated file - Generic file presence validator
# Generated from GTFS specification parsing

# Compact rule set distilled from parsed file-level conditions
const FILE_RULES = Dict(
    :agency => (
        presence = "Required",
        relations = [
        ],
    ),
    :stops => (
        presence = "Conditionally Required",
        relations = [
            (
                required = true, forbidden = false, when_all = [
                    (type = :file, file = :locations, must_exist = false),
                ],
            ),
            (
                required = false, forbidden = false, when_all = [
                    (type = :file, file = :locations, must_exist = true),
                ],
            ),
        ],
    ),
    :routes => (
        presence = "Required",
        relations = [
        ],
    ),
    :trips => (
        presence = "Required",
        relations = [
        ],
    ),
    :stop_times => (
        presence = "Required",
        relations = [
        ],
    ),
    :calendar => (
        presence = "Conditionally Required",
        relations = [
            (
                required = true, forbidden = false, when_all = [
                    (type = :file, file = :calendar_dates, must_exist = false),
                ],
            ),
            (
                required = false, forbidden = false, when_all = [
                    (type = :file, file = :calendar_dates, must_exist = true),
                ],
            ),
        ],
    ),
    :calendar_dates => (
        presence = "Conditionally Required",
        relations = [
            (
                required = true, forbidden = false, when_all = [
                    (type = :file, file = :calendar, must_exist = true),
                    (type = :file, file = :calendar_dates, must_exist = true),
                ],
            ),
            (
                required = false, forbidden = false, when_all = [
                    (type = :file, file = :calendar, must_exist = false),
                    (type = :file, file = :calendar_dates, must_exist = false),
                ],
            ),
        ],
    ),
    :fare_attributes => (
        presence = "Optional",
        relations = [
        ],
    ),
    :fare_rules => (
        presence = "Optional",
        relations = [
        ],
    ),
    :timeframes => (
        presence = "Optional",
        relations = [
        ],
    ),
    :rider_categories => (
        presence = "Optional",
        relations = [
        ],
    ),
    :fare_media => (
        presence = "Optional",
        relations = [
        ],
    ),
    :fare_products => (
        presence = "Optional",
        relations = [
        ],
    ),
    :fare_leg_rules => (
        presence = "Optional",
        relations = [
        ],
    ),
    :fare_leg_join_rules => (
        presence = "Optional",
        relations = [
        ],
    ),
    :fare_transfer_rules => (
        presence = "Optional",
        relations = [
        ],
    ),
    :areas => (
        presence = "Optional",
        relations = [
        ],
    ),
    :stop_areas => (
        presence = "Optional",
        relations = [
        ],
    ),
    :networks => (
        presence = "Conditionally Forbidden",
        relations = [
            (
                required = false, forbidden = true, when_all = [
                    (type = :file, file = :routes, must_exist = true),
                    (type = :field, file = :routes, field = :network_id, value = "defined"),
                ],
            ),
        ],
    ),
    :route_networks => (
        presence = "Conditionally Forbidden",
        relations = [
            (
                required = false, forbidden = true, when_all = [
                    (type = :file, file = :routes, must_exist = true),
                    (type = :field, file = :routes, field = :network_id, value = "defined"),
                ],
            ),
        ],
    ),
    :shapes => (
        presence = "Optional",
        relations = [
        ],
    ),
    :frequencies => (
        presence = "Optional",
        relations = [
        ],
    ),
    :transfers => (
        presence = "Optional",
        relations = [
        ],
    ),
    :pathways => (
        presence = "Optional",
        relations = [
        ],
    ),
    :levels => (
        presence = "Conditionally Required",
        relations = [
            (
                required = true, forbidden = false, when_all = [
                    (type = :field, file = :pathways, field = :pathway_mode, value = "5"),
                ],
            ),
        ],
    ),
    :location_groups => (
        presence = "Optional",
        relations = [
        ],
    ),
    :location_group_stops => (
        presence = "Optional",
        relations = [
        ],
    ),
    :locations => (
        presence = "Optional",
        relations = [
        ],
    ),
    :booking_rules => (
        presence = "Optional",
        relations = [
        ],
    ),
    :translations => (
        presence = "Optional",
        relations = [
        ],
    ),
    :feed_info => (
        presence = "Conditionally Required",
        relations = [
            (
                required = true, forbidden = false, when_all = [
                    (type = :file, file = :translations, must_exist = true),
                ],
            ),
        ],
    ),
    :attributions => (
        presence = "Optional",
        relations = [
        ],
    ),
)
