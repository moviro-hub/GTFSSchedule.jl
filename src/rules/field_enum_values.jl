# Auto-generated file - Generic enum validation rules
# Generated from GTFS specification parsing

# Compact rule set distilled from parsed enum field definitions
const ENUM_RULES = Dict(
    :agency => [
        (
            field = :cemv_support,
            enum_values = [
                (value = 0, description = "No cEMV information for trips associated with this agency"),
                (value = 1, description = "Riders may use cEMVs as fare media for trips associated with this agency"),
                (value = 2, description = "cEMVs are not supported as fare media for trips associated with this agency"),
            ],
            allow_empty = true,
            empty_maps_to = 0,
        ),
    ],
    :stops => [
        (
            field = :location_type,
            enum_values = [
                (value = 0, description = "**Stop** (or **Platform**). A location where passengers board or disembark from a transit vehicle. Is called a platform when defined within a `parent_station`"),
                (value = 1, description = "**Station**. A physical structure or area that contains one or more platform"),
                (value = 2, description = "**Entrance/Exit**. A location where passengers can enter or exit a station from the street. If an entrance/exit belongs to multiple stations, it may be linked by pathways to both, but the data provider must pick one of them as parent"),
                (value = 3, description = "**Generic Node**. A location within a station, not matching any other `location_type`, that may be used to link together pathways define in [pathways.txt](#pathwaystxt)"),
                (value = 4, description = "**Boarding Area**. A specific location on a platform, where passengers can board and/or alight vehicles"),
            ],
            allow_empty = true,
            empty_maps_to = 0,
        ),
        (
            field = :wheelchair_boarding,
            enum_values = [
                (value = 0, description = "No accessibility information for the stop"),
                (value = 1, description = "Some vehicles at this stop can be boarded by a rider in a wheelchair"),
                (value = 2, description = "Wheelchair boarding is not possible at this stop"),
                (value = 0, description = "Stop will inherit its `wheelchair_boarding` behavior from the parent station, if specified in the parent"),
                (value = 1, description = "There exists some accessible path from outside the station to the specific stop/platform"),
                (value = 2, description = "There exists no accessible path from outside the station to the specific stop/platform"),
                (value = 0, description = "Station entrance will inherit its `wheelchair_boarding` behavior from the parent station, if specified for the parent"),
                (value = 1, description = "Station entrance is wheelchair accessible"),
                (value = 2, description = "No accessible path from station entrance to stops/platforms"),
            ],
            allow_empty = true,
            empty_maps_to = 0,
        ),
        (
            field = :stop_access,
            enum_values = [
                (value = 0, description = "The stop/platform cannot be directly accessed from the street network. It must be accessed from a station entrance if there is one defined for the station, otherwise the station itself. If there are pathways defined for the station, they must be used to access the stop/platform"),
                (value = 1, description = "Consuming applications should generate directions for access directly to the stop, independent of any entrances or pathways of the parent station"),
            ],
            allow_empty = true,
            empty_maps_to = nothing,
        ),
    ],
    :routes => [
        (
            field = :route_type,
            enum_values = [
                (value = 0, description = "Tram, Streetcar, Light rail. Any light rail or street level system within a metropolitan area"),
                (value = 1, description = "Subway, Metro. Any underground rail system within a metropolitan area"),
                (value = 2, description = "Rail. Used for intercity or long-distance travel"),
                (value = 3, description = "Bus. Used for short- and long-distance bus routes"),
                (value = 4, description = "Ferry. Used for short- and long-distance boat service"),
                (value = 5, description = "Cable tram. Used for street-level rail cars where the cable runs beneath the vehicle (e.g., cable car in San Francisco)"),
                (value = 6, description = "Aerial lift, suspended cable car (e.g., gondola lift, aerial tramway). Cable transport where cabins, cars, gondolas or open chairs are suspended by means of one or more cables"),
                (value = 7, description = "Funicular. Any rail system designed for steep inclines"),
                (value = 11, description = "Trolleybus. Electric buses that draw power from overhead wires using poles"),
                (value = 12, description = "Monorail. Railway in which the track consists of a single rail or a beam"),
            ],
            allow_empty = false,
            empty_maps_to = nothing,
        ),
        (
            field = :continuous_pickup,
            enum_values = [
                (value = 0, description = "Continuous stopping pickup"),
                (value = 1, description = "No continuous stopping pickup"),
                (value = 2, description = "Must phone agency to arrange continuous stopping pickup"),
                (value = 3, description = "Must coordinate with driver to arrange continuous stopping pickup"),
            ],
            allow_empty = true,
            empty_maps_to = 1,
        ),
        (
            field = :continuous_drop_off,
            enum_values = [
                (value = 0, description = "Continuous stopping drop off"),
                (value = 1, description = "No continuous stopping drop off"),
                (value = 2, description = "Must phone agency to arrange continuous stopping drop off"),
                (value = 3, description = "Must coordinate with driver to arrange continuous stopping drop off"),
            ],
            allow_empty = true,
            empty_maps_to = 1,
        ),
        (
            field = :cemv_support,
            enum_values = [
                (value = 0, description = "No cEMV information for trips associated with this route"),
                (value = 1, description = "Riders may use cEMVs as fare media for trips associated with this route"),
                (value = 2, description = "cEMVs are not supported as fare media for trips associated with this route"),
            ],
            allow_empty = true,
            empty_maps_to = 0,
        ),
    ],
    :trips => [
        (
            field = :direction_id,
            enum_values = [
                (value = 0, description = "Travel in one direction (e.g. outbound travel)"),
                (value = 1, description = "Travel in the opposite direction (e.g. inbound travel).<hr>*Example: The `trip_headsign` and `direction_id` fields may be used together to assign a name to travel in each direction for a set of trips. A [trips.txt](#tripstxt) file could contain these records for use in time tables:*"),
            ],
            allow_empty = true,
            empty_maps_to = nothing,
        ),
        (
            field = :wheelchair_accessible,
            enum_values = [
                (value = 0, description = "No accessibility information for the trip"),
                (value = 1, description = "Vehicle being used on this particular trip can accommodate at least one rider in a wheelchair"),
                (value = 2, description = "No riders in wheelchairs can be accommodated on this trip"),
            ],
            allow_empty = true,
            empty_maps_to = 0,
        ),
        (
            field = :bikes_allowed,
            enum_values = [
                (value = 0, description = "No bike information for the trip"),
                (value = 1, description = "Vehicle being used on this particular trip can accommodate at least one bicycle"),
                (value = 2, description = "No bicycles are allowed on this trip"),
            ],
            allow_empty = true,
            empty_maps_to = 0,
        ),
        (
            field = :cars_allowed,
            enum_values = [
                (value = 0, description = "No car information for the trip"),
                (value = 1, description = "Vehicle being used on this particular trip can accommodate at least one car"),
                (value = 2, description = "No cars are allowed on this trip"),
            ],
            allow_empty = true,
            empty_maps_to = 0,
        ),
    ],
    :stop_times => [
        (
            field = :pickup_type,
            enum_values = [
                (value = 0, description = "Regularly scheduled pickup"),
                (value = 1, description = "No pickup available"),
                (value = 2, description = "Must phone agency to arrange pickup"),
                (value = 3, description = "Must coordinate with driver to arrange pickup"),
            ],
            allow_empty = true,
            empty_maps_to = 0,
        ),
        (
            field = :drop_off_type,
            enum_values = [
                (value = 0, description = "Regularly scheduled drop off"),
                (value = 1, description = "No drop off available"),
                (value = 2, description = "Must phone agency to arrange drop off"),
                (value = 3, description = "Must coordinate with driver to arrange drop off"),
            ],
            allow_empty = true,
            empty_maps_to = 0,
        ),
        (
            field = :continuous_pickup,
            enum_values = [
                (value = 0, description = "Continuous stopping pickup"),
                (value = 1, description = "No continuous stopping pickup"),
                (value = 2, description = "Must phone agency to arrange continuous stopping pickup"),
                (value = 3, description = "Must coordinate with driver to arrange continuous stopping pickup"),
            ],
            allow_empty = true,
            empty_maps_to = 1,
        ),
        (
            field = :continuous_drop_off,
            enum_values = [
                (value = 0, description = "Continuous stopping drop off"),
                (value = 1, description = "No continuous stopping drop off"),
                (value = 2, description = "Must phone agency to arrange continuous stopping drop off"),
                (value = 3, description = "Must coordinate with driver to arrange continuous stopping drop off"),
            ],
            allow_empty = true,
            empty_maps_to = 1,
        ),
        (
            field = :timepoint,
            enum_values = [
                (value = 0, description = "Times are considered approximate"),
                (value = 1, description = "Times are considered exact"),
            ],
            allow_empty = true,
            empty_maps_to = nothing,
        ),
    ],
    :calendar => [
        (
            field = :monday,
            enum_values = [
                (value = 1, description = "Service is available for all Mondays in the date range"),
                (value = 0, description = "Service is not available for Mondays in the date range"),
            ],
            allow_empty = false,
            empty_maps_to = nothing,
        ),
    ],
    :calendar_dates => [
        (
            field = :exception_type,
            enum_values = [
                (value = 1, description = "Service has been added for the specified date"),
                (value = 2, description = "Service has been removed for the specified date.<hr>*Example: Suppose a route has one set of trips available on holidays and another set of trips available on all other days. One `service_id` could correspond to the regular service schedule and another `service_id` could correspond to the holiday schedule. For a particular holiday, the [calendar_dates.txt](#calendar_datestxt) file could be used to add the holiday to the holiday `service_id` and to remove the holiday from the regular `service_id` schedule.*"),
            ],
            allow_empty = false,
            empty_maps_to = nothing,
        ),
    ],
    :fare_attributes => [
        (
            field = :payment_method,
            enum_values = [
                (value = 0, description = "Fare is paid on board"),
                (value = 1, description = "Fare must be paid before boarding"),
            ],
            allow_empty = false,
            empty_maps_to = nothing,
        ),
        (
            field = :transfers,
            enum_values = [
                (value = 0, description = "No transfers permitted on this fare"),
                (value = 1, description = "Riders may transfer once"),
                (value = 2, description = "Riders may transfer twice"),
            ],
            allow_empty = true,
            empty_maps_to = nothing,
        ),
    ],
    :rider_categories => [
        (
            field = :is_default_fare_category,
            enum_values = [
                (value = 0, description = "Category is not considered the default"),
                (value = 1, description = "Category is considered the default one"),
            ],
            allow_empty = true,
            empty_maps_to = 0,
        ),
    ],
    :fare_media => [
        (
            field = :fare_media_type,
            enum_values = [
                (value = 0, description = "None.  Used when there is no fare media involved in purchasing or validating a fare product, such as paying cash to a driver or conductor with no physical ticket provided"),
                (value = 1, description = "Physical paper ticket that allows a passenger to take either a certain number of pre-purchased trips or unlimited trips within a fixed period of time"),
                (value = 2, description = "Physical transit card that has stored tickets, passes or monetary value"),
                (value = 3, description = "cEMV (contactless Europay, Mastercard and Visa) as an open-loop token container for account-based ticketing"),
                (value = 4, description = "Mobile app that have stored virtual transit cards, tickets, passes, or monetary value"),
            ],
            allow_empty = false,
            empty_maps_to = nothing,
        ),
    ],
    :fare_transfer_rules => [
        (
            field = :duration_limit_type,
            enum_values = [
                (value = 0, description = "Between the departure fare validation of the first leg in transfer sub-journey and the arrival fare validation of the last leg in transfer sub-journey"),
                (value = 1, description = "Between the departure fare validation of the first leg in transfer sub-journey and the departure fare validation of the last leg in transfer sub-journey"),
                (value = 2, description = "Between the arrival fare validation of the first leg in transfer sub-journey and the departure fare validation of the last leg in transfer sub-journey"),
                (value = 3, description = "Between the arrival fare validation of the first leg in transfer sub-journey and the arrival fare validation of the last leg in transfer sub-journey"),
            ],
            allow_empty = true,
            empty_maps_to = nothing,
        ),
        (
            field = :fare_transfer_type,
            enum_values = [
                (value = 0, description = "From-leg `fare_leg_rules.fare_product_id` plus `fare_transfer_rules.fare_product_id`; A + AB"),
                (value = 1, description = "From-leg `fare_leg_rules.fare_product_id` plus `fare_transfer_rules.fare_product_id` plus to-leg `fare_leg_rules.fare_product_id`; A + AB + B"),
                (value = 2, description = "`fare_transfer_rules.fare_product_id`; AB"),
            ],
            allow_empty = false,
            empty_maps_to = nothing,
        ),
    ],
    :frequencies => [
        (
            field = :exact_times,
            enum_values = [
                (value = 0, description = "Frequency-based trips"),
                (value = 1, description = "Schedule-based trips with the exact same headway throughout the day. In this case the `end_time` value must be greater than the last desired trip `start_time` but less than the last desired trip start_time + `headway_secs`"),
            ],
            allow_empty = true,
            empty_maps_to = 0,
        ),
    ],
    :transfers => [
        (
            field = :transfer_type,
            enum_values = [
                (value = 0, description = "Recommended transfer point between routes"),
                (value = 1, description = "Timed transfer point between two routes. The departing vehicle is expected to wait for the arriving one and leave sufficient time for a rider to transfer between routes"),
                (value = 2, description = "Transfer requires a minimum amount of time between arrival and departure to ensure a connection. The time required to transfer is specified by `min_transfer_time`"),
                (value = 3, description = "Transfers are not possible between routes at the location"),
                (value = 4, description = "Passengers can transfer from one trip to another by staying onboard the same vehicle (an \"in-seat transfer\"). More details about this type of transfer [below](#linked-trips)"),
                (value = 5, description = "In-seat transfers are not allowed between sequential trips. The passenger must alight from the vehicle and re-board. More details about this type of transfer [below](#linked-trips)"),
            ],
            allow_empty = true,
            empty_maps_to = 0,
        ),
    ],
    :pathways => [
        (
            field = :pathway_mode,
            enum_values = [
                (value = 1, description = "Walkway"),
                (value = 2, description = "Stairs"),
                (value = 3, description = "Moving sidewalk/travelator"),
                (value = 4, description = "Escalator"),
                (value = 5, description = "Elevator"),
                (value = 6, description = "Fare gate (or payment gate): A pathway that crosses into an area of the station where proof of payment is required to cross. Fare gates may separate paid areas of the station from unpaid ones, or separate different payment areas within the same station from each other. This information can be used to avoid routing passengers through stations using shortcuts that would require passengers to make unnecessary payments, like directing a passenger to walk through a subway platform to reach a busway"),
                (value = 7, description = "Exit gate: A pathway exiting a paid area into an unpaid area where proof of payment is not required to cross"),
            ],
            allow_empty = false,
            empty_maps_to = nothing,
        ),
    ],
    :booking_rules => [
        (
            field = :booking_type,
            enum_values = [
                (value = 0, description = "Real time booking"),
                (value = 1, description = "Up to same-day booking with advance notice"),
                (value = 2, description = "Up to prior day(s) booking"),
            ],
            allow_empty = false,
            empty_maps_to = nothing,
        ),
    ],
    :attributions => [
        (
            field = :is_producer,
            enum_values = [
                (value = 0, description = "Organization doesn’t have this role"),
                (value = 1, description = "Organization does have this role"),
            ],
            allow_empty = true,
            empty_maps_to = 0,
        ),
    ],
)
