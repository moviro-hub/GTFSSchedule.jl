# Auto-generated file - Field type validation rules
# Generated from GTFS specification parsing

# Compact rule set distilled from parsed field type information
const FIELD_TYPES = Dict(
    :agency => [
        (
            field = :agency_id,
            gtfs_type = :ID,
            alternative_types = [],
        ),
        (
            field = :agency_name,
            gtfs_type = :Text,
            alternative_types = [],
        ),
        (
            field = :agency_url,
            gtfs_type = :URL,
            alternative_types = [],
        ),
        (
            field = :agency_timezone,
            gtfs_type = :Timezone,
            alternative_types = [],
        ),
        (
            field = :agency_lang,
            gtfs_type = :LanguageCode,
            alternative_types = [],
        ),
        (
            field = :agency_phone,
            gtfs_type = :PhoneNumber,
            alternative_types = [],
        ),
        (
            field = :agency_fare_url,
            gtfs_type = :URL,
            alternative_types = [],
        ),
        (
            field = :agency_email,
            gtfs_type = :Email,
            alternative_types = [],
        ),
        (
            field = :cemv_support,
            gtfs_type = :Enum,
            alternative_types = [],
        ),
    ],
    :stops => [
        (
            field = :stop_id,
            gtfs_type = :ID,
            alternative_types = [],
        ),
        (
            field = :stop_code,
            gtfs_type = :Text,
            alternative_types = [],
        ),
        (
            field = :stop_name,
            gtfs_type = :Text,
            alternative_types = [],
        ),
        (
            field = :tts_stop_name,
            gtfs_type = :Text,
            alternative_types = [],
        ),
        (
            field = :stop_desc,
            gtfs_type = :Text,
            alternative_types = [],
        ),
        (
            field = :stop_lat,
            gtfs_type = :Latitude,
            alternative_types = [],
        ),
        (
            field = :stop_lon,
            gtfs_type = :Longitude,
            alternative_types = [],
        ),
        (
            field = :zone_id,
            gtfs_type = :ID,
            alternative_types = [],
        ),
        (
            field = :stop_url,
            gtfs_type = :URL,
            alternative_types = [],
        ),
        (
            field = :location_type,
            gtfs_type = :Enum,
            alternative_types = [],
        ),
        (
            field = :parent_station,
            gtfs_type = :ID,
            alternative_types = [],
        ),
        (
            field = :stop_timezone,
            gtfs_type = :Timezone,
            alternative_types = [],
        ),
        (
            field = :wheelchair_boarding,
            gtfs_type = :Enum,
            alternative_types = [],
        ),
        (
            field = :level_id,
            gtfs_type = :ID,
            alternative_types = [],
        ),
        (
            field = :platform_code,
            gtfs_type = :Text,
            alternative_types = [],
        ),
        (
            field = :stop_access,
            gtfs_type = :Enum,
            alternative_types = [],
        ),
    ],
    :routes => [
        (
            field = :route_id,
            gtfs_type = :ID,
            alternative_types = [],
        ),
        (
            field = :agency_id,
            gtfs_type = :ID,
            alternative_types = [],
        ),
        (
            field = :route_short_name,
            gtfs_type = :Text,
            alternative_types = [],
        ),
        (
            field = :route_long_name,
            gtfs_type = :Text,
            alternative_types = [],
        ),
        (
            field = :route_desc,
            gtfs_type = :Text,
            alternative_types = [],
        ),
        (
            field = :route_type,
            gtfs_type = :Enum,
            alternative_types = [],
        ),
        (
            field = :route_url,
            gtfs_type = :URL,
            alternative_types = [],
        ),
        (
            field = :route_color,
            gtfs_type = :Color,
            alternative_types = [],
        ),
        (
            field = :route_text_color,
            gtfs_type = :Color,
            alternative_types = [],
        ),
        (
            field = :route_sort_order,
            gtfs_type = :Integer,
            alternative_types = [],
        ),
        (
            field = :continuous_pickup,
            gtfs_type = :Enum,
            alternative_types = [],
        ),
        (
            field = :continuous_drop_off,
            gtfs_type = :Enum,
            alternative_types = [],
        ),
        (
            field = :network_id,
            gtfs_type = :ID,
            alternative_types = [],
        ),
        (
            field = :cemv_support,
            gtfs_type = :Enum,
            alternative_types = [],
        ),
    ],
    :trips => [
        (
            field = :route_id,
            gtfs_type = :ID,
            alternative_types = [],
        ),
        (
            field = :service_id,
            gtfs_type = :ID,
            alternative_types = [],
        ),
        (
            field = :trip_id,
            gtfs_type = :ID,
            alternative_types = [],
        ),
        (
            field = :trip_headsign,
            gtfs_type = :Text,
            alternative_types = [],
        ),
        (
            field = :trip_short_name,
            gtfs_type = :Text,
            alternative_types = [],
        ),
        (
            field = :direction_id,
            gtfs_type = :Enum,
            alternative_types = [],
        ),
        (
            field = :block_id,
            gtfs_type = :ID,
            alternative_types = [],
        ),
        (
            field = :shape_id,
            gtfs_type = :ID,
            alternative_types = [],
        ),
        (
            field = :wheelchair_accessible,
            gtfs_type = :Enum,
            alternative_types = [],
        ),
        (
            field = :bikes_allowed,
            gtfs_type = :Enum,
            alternative_types = [],
        ),
        (
            field = :cars_allowed,
            gtfs_type = :Enum,
            alternative_types = [],
        ),
    ],
    :stop_times => [
        (
            field = :trip_id,
            gtfs_type = :ID,
            alternative_types = [],
        ),
        (
            field = :arrival_time,
            gtfs_type = :Time,
            alternative_types = [],
        ),
        (
            field = :departure_time,
            gtfs_type = :Time,
            alternative_types = [],
        ),
        (
            field = :stop_id,
            gtfs_type = :ID,
            alternative_types = [],
        ),
        (
            field = :location_group_id,
            gtfs_type = :ID,
            alternative_types = [],
        ),
        (
            field = :location_id,
            gtfs_type = :ID,
            alternative_types = [],
        ),
        (
            field = :stop_sequence,
            gtfs_type = :Integer,
            alternative_types = [],
        ),
        (
            field = :stop_headsign,
            gtfs_type = :Text,
            alternative_types = [],
        ),
        (
            field = :start_pickup_drop_off_window,
            gtfs_type = :Time,
            alternative_types = [],
        ),
        (
            field = :end_pickup_drop_off_window,
            gtfs_type = :Time,
            alternative_types = [],
        ),
        (
            field = :pickup_type,
            gtfs_type = :Enum,
            alternative_types = [],
        ),
        (
            field = :drop_off_type,
            gtfs_type = :Enum,
            alternative_types = [],
        ),
        (
            field = :continuous_pickup,
            gtfs_type = :Enum,
            alternative_types = [],
        ),
        (
            field = :continuous_drop_off,
            gtfs_type = :Enum,
            alternative_types = [],
        ),
        (
            field = :shape_dist_traveled,
            gtfs_type = :Float,
            alternative_types = [],
        ),
        (
            field = :timepoint,
            gtfs_type = :Enum,
            alternative_types = [],
        ),
        (
            field = :pickup_booking_rule_id,
            gtfs_type = :ID,
            alternative_types = [],
        ),
        (
            field = :drop_off_booking_rule_id,
            gtfs_type = :ID,
            alternative_types = [],
        ),
    ],
    :calendar => [
        (
            field = :service_id,
            gtfs_type = :ID,
            alternative_types = [],
        ),
        (
            field = :monday,
            gtfs_type = :Enum,
            alternative_types = [],
        ),
        (
            field = :tuesday,
            gtfs_type = :Enum,
            alternative_types = [],
        ),
        (
            field = :wednesday,
            gtfs_type = :Enum,
            alternative_types = [],
        ),
        (
            field = :thursday,
            gtfs_type = :Enum,
            alternative_types = [],
        ),
        (
            field = :friday,
            gtfs_type = :Enum,
            alternative_types = [],
        ),
        (
            field = :saturday,
            gtfs_type = :Enum,
            alternative_types = [],
        ),
        (
            field = :sunday,
            gtfs_type = :Enum,
            alternative_types = [],
        ),
        (
            field = :start_date,
            gtfs_type = :Date,
            alternative_types = [],
        ),
        (
            field = :end_date,
            gtfs_type = :Date,
            alternative_types = [],
        ),
    ],
    :calendar_dates => [
        (
            field = :service_id,
            gtfs_type = :ID,
            alternative_types = [],
        ),
        (
            field = :date,
            gtfs_type = :Date,
            alternative_types = [],
        ),
        (
            field = :exception_type,
            gtfs_type = :Enum,
            alternative_types = [],
        ),
    ],
    :fare_attributes => [
        (
            field = :fare_id,
            gtfs_type = :ID,
            alternative_types = [],
        ),
        (
            field = :price,
            gtfs_type = :Float,
            alternative_types = [],
        ),
        (
            field = :currency_type,
            gtfs_type = :CurrencyCode,
            alternative_types = [],
        ),
        (
            field = :payment_method,
            gtfs_type = :Enum,
            alternative_types = [],
        ),
        (
            field = :transfers,
            gtfs_type = :Enum,
            alternative_types = [],
        ),
        (
            field = :agency_id,
            gtfs_type = :ID,
            alternative_types = [],
        ),
        (
            field = :transfer_duration,
            gtfs_type = :Integer,
            alternative_types = [],
        ),
    ],
    :fare_rules => [
        (
            field = :fare_id,
            gtfs_type = :ID,
            alternative_types = [],
        ),
        (
            field = :route_id,
            gtfs_type = :ID,
            alternative_types = [],
        ),
        (
            field = :origin_id,
            gtfs_type = :ID,
            alternative_types = [],
        ),
        (
            field = :destination_id,
            gtfs_type = :ID,
            alternative_types = [],
        ),
        (
            field = :contains_id,
            gtfs_type = :ID,
            alternative_types = [],
        ),
    ],
    :timeframes => [
        (
            field = :timeframe_group_id,
            gtfs_type = :ID,
            alternative_types = [],
        ),
        (
            field = :start_time,
            gtfs_type = :LocalTime,
            alternative_types = [],
        ),
        (
            field = :end_time,
            gtfs_type = :LocalTime,
            alternative_types = [],
        ),
        (
            field = :service_id,
            gtfs_type = :ID,
            alternative_types = [],
        ),
    ],
    :rider_categories => [
        (
            field = :rider_category_id,
            gtfs_type = :ID,
            alternative_types = [],
        ),
        (
            field = :rider_category_name,
            gtfs_type = :Text,
            alternative_types = [],
        ),
        (
            field = :is_default_fare_category,
            gtfs_type = :Enum,
            alternative_types = [],
        ),
        (
            field = :eligibility_url,
            gtfs_type = :URL,
            alternative_types = [],
        ),
    ],
    :fare_media => [
        (
            field = :fare_media_id,
            gtfs_type = :ID,
            alternative_types = [],
        ),
        (
            field = :fare_media_name,
            gtfs_type = :Text,
            alternative_types = [],
        ),
        (
            field = :fare_media_type,
            gtfs_type = :Enum,
            alternative_types = [],
        ),
    ],
    :fare_products => [
        (
            field = :fare_product_id,
            gtfs_type = :ID,
            alternative_types = [],
        ),
        (
            field = :fare_product_name,
            gtfs_type = :Text,
            alternative_types = [],
        ),
        (
            field = :rider_category_id,
            gtfs_type = :ID,
            alternative_types = [],
        ),
        (
            field = :fare_media_id,
            gtfs_type = :ID,
            alternative_types = [],
        ),
        (
            field = :amount,
            gtfs_type = :CurrencyAmount,
            alternative_types = [],
        ),
        (
            field = :currency,
            gtfs_type = :CurrencyCode,
            alternative_types = [],
        ),
    ],
    :fare_leg_rules => [
        (
            field = :leg_group_id,
            gtfs_type = :ID,
            alternative_types = [],
        ),
        (
            field = :network_id,
            gtfs_type = :ID,
            alternative_types = [],
        ),
        (
            field = :from_area_id,
            gtfs_type = :ID,
            alternative_types = [],
        ),
        (
            field = :to_area_id,
            gtfs_type = :ID,
            alternative_types = [],
        ),
        (
            field = :from_timeframe_group_id,
            gtfs_type = :ID,
            alternative_types = [],
        ),
        (
            field = :to_timeframe_group_id,
            gtfs_type = :ID,
            alternative_types = [],
        ),
        (
            field = :fare_product_id,
            gtfs_type = :ID,
            alternative_types = [],
        ),
        (
            field = :rule_priority,
            gtfs_type = :Integer,
            alternative_types = [],
        ),
    ],
    :fare_leg_join_rules => [
        (
            field = :from_network_id,
            gtfs_type = :ID,
            alternative_types = [],
        ),
        (
            field = :to_network_id,
            gtfs_type = :ID,
            alternative_types = [],
        ),
        (
            field = :from_stop_id,
            gtfs_type = :ID,
            alternative_types = [],
        ),
        (
            field = :to_stop_id,
            gtfs_type = :ID,
            alternative_types = [],
        ),
    ],
    :fare_transfer_rules => [
        (
            field = :from_leg_group_id,
            gtfs_type = :ID,
            alternative_types = [],
        ),
        (
            field = :to_leg_group_id,
            gtfs_type = :ID,
            alternative_types = [],
        ),
        (
            field = :transfer_count,
            gtfs_type = :Integer,
            alternative_types = [],
        ),
        (
            field = :duration_limit,
            gtfs_type = :Integer,
            alternative_types = [],
        ),
        (
            field = :duration_limit_type,
            gtfs_type = :Enum,
            alternative_types = [],
        ),
        (
            field = :fare_transfer_type,
            gtfs_type = :Enum,
            alternative_types = [],
        ),
        (
            field = :fare_product_id,
            gtfs_type = :ID,
            alternative_types = [],
        ),
    ],
    :areas => [
        (
            field = :area_id,
            gtfs_type = :ID,
            alternative_types = [],
        ),
        (
            field = :area_name,
            gtfs_type = :Text,
            alternative_types = [],
        ),
    ],
    :stop_areas => [
        (
            field = :area_id,
            gtfs_type = :ID,
            alternative_types = [],
        ),
        (
            field = :stop_id,
            gtfs_type = :ID,
            alternative_types = [],
        ),
    ],
    :networks => [
        (
            field = :network_id,
            gtfs_type = :ID,
            alternative_types = [],
        ),
        (
            field = :network_name,
            gtfs_type = :Text,
            alternative_types = [],
        ),
    ],
    :route_networks => [
        (
            field = :network_id,
            gtfs_type = :ID,
            alternative_types = [],
        ),
        (
            field = :route_id,
            gtfs_type = :ID,
            alternative_types = [],
        ),
    ],
    :shapes => [
        (
            field = :shape_id,
            gtfs_type = :ID,
            alternative_types = [],
        ),
        (
            field = :shape_pt_lat,
            gtfs_type = :Latitude,
            alternative_types = [],
        ),
        (
            field = :shape_pt_lon,
            gtfs_type = :Longitude,
            alternative_types = [],
        ),
        (
            field = :shape_pt_sequence,
            gtfs_type = :Integer,
            alternative_types = [],
        ),
        (
            field = :shape_dist_traveled,
            gtfs_type = :Float,
            alternative_types = [],
        ),
    ],
    :frequencies => [
        (
            field = :trip_id,
            gtfs_type = :ID,
            alternative_types = [],
        ),
        (
            field = :start_time,
            gtfs_type = :Time,
            alternative_types = [],
        ),
        (
            field = :end_time,
            gtfs_type = :Time,
            alternative_types = [],
        ),
        (
            field = :headway_secs,
            gtfs_type = :Integer,
            alternative_types = [],
        ),
        (
            field = :exact_times,
            gtfs_type = :Enum,
            alternative_types = [],
        ),
    ],
    :transfers => [
        (
            field = :from_stop_id,
            gtfs_type = :ID,
            alternative_types = [],
        ),
        (
            field = :to_stop_id,
            gtfs_type = :ID,
            alternative_types = [],
        ),
        (
            field = :from_route_id,
            gtfs_type = :ID,
            alternative_types = [],
        ),
        (
            field = :to_route_id,
            gtfs_type = :ID,
            alternative_types = [],
        ),
        (
            field = :from_trip_id,
            gtfs_type = :ID,
            alternative_types = [],
        ),
        (
            field = :to_trip_id,
            gtfs_type = :ID,
            alternative_types = [],
        ),
        (
            field = :transfer_type,
            gtfs_type = :Enum,
            alternative_types = [],
        ),
        (
            field = :min_transfer_time,
            gtfs_type = :Integer,
            alternative_types = [],
        ),
    ],
    :pathways => [
        (
            field = :pathway_id,
            gtfs_type = :ID,
            alternative_types = [],
        ),
        (
            field = :from_stop_id,
            gtfs_type = :ID,
            alternative_types = [],
        ),
        (
            field = :to_stop_id,
            gtfs_type = :ID,
            alternative_types = [],
        ),
        (
            field = :pathway_mode,
            gtfs_type = :Enum,
            alternative_types = [],
        ),
        (
            field = :is_bidirectional,
            gtfs_type = :Enum,
            alternative_types = [],
        ),
        (
            field = :length,
            gtfs_type = :Float,
            alternative_types = [],
        ),
        (
            field = :traversal_time,
            gtfs_type = :Integer,
            alternative_types = [],
        ),
        (
            field = :stair_count,
            gtfs_type = :Integer,
            alternative_types = [],
        ),
        (
            field = :max_slope,
            gtfs_type = :Float,
            alternative_types = [],
        ),
        (
            field = :min_width,
            gtfs_type = :Float,
            alternative_types = [],
        ),
        (
            field = :signposted_as,
            gtfs_type = :Text,
            alternative_types = [],
        ),
        (
            field = :reversed_signposted_as,
            gtfs_type = :Text,
            alternative_types = [],
        ),
    ],
    :levels => [
        (
            field = :level_id,
            gtfs_type = :ID,
            alternative_types = [],
        ),
        (
            field = :level_index,
            gtfs_type = :Float,
            alternative_types = [],
        ),
        (
            field = :level_name,
            gtfs_type = :Text,
            alternative_types = [],
        ),
    ],
    :location_groups => [
        (
            field = :location_group_id,
            gtfs_type = :ID,
            alternative_types = [],
        ),
        (
            field = :location_group_name,
            gtfs_type = :Text,
            alternative_types = [],
        ),
    ],
    :location_group_stops => [
        (
            field = :location_group_id,
            gtfs_type = :ID,
            alternative_types = [],
        ),
        (
            field = :stop_id,
            gtfs_type = :ID,
            alternative_types = [],
        ),
    ],
    :locations => [
        (
            field = :type,
            gtfs_type = :String,
            alternative_types = [],
        ),
        (
            field = :features,
            gtfs_type = :Array,
            alternative_types = [],
        ),
        (
            field = :type,
            gtfs_type = :String,
            alternative_types = [],
        ),
        (
            field = :id,
            gtfs_type = :String,
            alternative_types = [],
        ),
        (
            field = :properties,
            gtfs_type = :Object,
            alternative_types = [],
        ),
        (
            field = :stop_name,
            gtfs_type = :String,
            alternative_types = [],
        ),
        (
            field = :stop_desc,
            gtfs_type = :String,
            alternative_types = [],
        ),
        (
            field = :geometry,
            gtfs_type = :Object,
            alternative_types = [],
        ),
        (
            field = :type,
            gtfs_type = :String,
            alternative_types = [],
        ),
        (
            field = :coordinates,
            gtfs_type = :Array,
            alternative_types = [],
        ),
    ],
    :booking_rules => [
        (
            field = :booking_rule_id,
            gtfs_type = :ID,
            alternative_types = [],
        ),
        (
            field = :booking_type,
            gtfs_type = :Enum,
            alternative_types = [],
        ),
        (
            field = :prior_notice_duration_min,
            gtfs_type = :Integer,
            alternative_types = [],
        ),
        (
            field = :prior_notice_duration_max,
            gtfs_type = :Integer,
            alternative_types = [],
        ),
        (
            field = :prior_notice_last_day,
            gtfs_type = :Integer,
            alternative_types = [],
        ),
        (
            field = :prior_notice_last_time,
            gtfs_type = :Time,
            alternative_types = [],
        ),
        (
            field = :prior_notice_start_day,
            gtfs_type = :Integer,
            alternative_types = [],
        ),
        (
            field = :prior_notice_start_time,
            gtfs_type = :Time,
            alternative_types = [],
        ),
        (
            field = :prior_notice_service_id,
            gtfs_type = :ID,
            alternative_types = [],
        ),
        (
            field = :message,
            gtfs_type = :Text,
            alternative_types = [],
        ),
        (
            field = :pickup_message,
            gtfs_type = :Text,
            alternative_types = [],
        ),
        (
            field = :drop_off_message,
            gtfs_type = :Text,
            alternative_types = [],
        ),
        (
            field = :phone_number,
            gtfs_type = :PhoneNumber,
            alternative_types = [],
        ),
        (
            field = :info_url,
            gtfs_type = :URL,
            alternative_types = [],
        ),
        (
            field = :booking_url,
            gtfs_type = :URL,
            alternative_types = [],
        ),
    ],
    :translations => [
        (
            field = :table_name,
            gtfs_type = :Enum,
            alternative_types = [],
        ),
        (
            field = :field_name,
            gtfs_type = :Text,
            alternative_types = [],
        ),
        (
            field = :language,
            gtfs_type = :LanguageCode,
            alternative_types = [],
        ),
        (
            field = :translation,
            gtfs_type = :Text,
            alternative_types = [
                :URL,
                :Email,
                :PhoneNumber,
            ],
        ),
        (
            field = :record_id,
            gtfs_type = :ID,
            alternative_types = [],
        ),
        (
            field = :record_sub_id,
            gtfs_type = :ID,
            alternative_types = [],
        ),
        (
            field = :field_value,
            gtfs_type = :Text,
            alternative_types = [
                :URL,
                :Email,
                :PhoneNumber,
            ],
        ),
    ],
    :feed_info => [
        (
            field = :feed_publisher_name,
            gtfs_type = :Text,
            alternative_types = [],
        ),
        (
            field = :feed_publisher_url,
            gtfs_type = :URL,
            alternative_types = [],
        ),
        (
            field = :feed_lang,
            gtfs_type = :LanguageCode,
            alternative_types = [],
        ),
        (
            field = :default_lang,
            gtfs_type = :LanguageCode,
            alternative_types = [],
        ),
        (
            field = :feed_start_date,
            gtfs_type = :Date,
            alternative_types = [],
        ),
        (
            field = :feed_end_date,
            gtfs_type = :Date,
            alternative_types = [],
        ),
        (
            field = :feed_version,
            gtfs_type = :Text,
            alternative_types = [],
        ),
        (
            field = :feed_contact_email,
            gtfs_type = :Email,
            alternative_types = [],
        ),
        (
            field = :feed_contact_url,
            gtfs_type = :URL,
            alternative_types = [],
        ),
    ],
    :attributions => [
        (
            field = :attribution_id,
            gtfs_type = :ID,
            alternative_types = [],
        ),
        (
            field = :agency_id,
            gtfs_type = :ID,
            alternative_types = [],
        ),
        (
            field = :route_id,
            gtfs_type = :ID,
            alternative_types = [],
        ),
        (
            field = :trip_id,
            gtfs_type = :ID,
            alternative_types = [],
        ),
        (
            field = :organization_name,
            gtfs_type = :Text,
            alternative_types = [],
        ),
        (
            field = :is_producer,
            gtfs_type = :Enum,
            alternative_types = [],
        ),
        (
            field = :is_operator,
            gtfs_type = :Enum,
            alternative_types = [],
        ),
        (
            field = :is_authority,
            gtfs_type = :Enum,
            alternative_types = [],
        ),
        (
            field = :attribution_url,
            gtfs_type = :URL,
            alternative_types = [],
        ),
        (
            field = :attribution_email,
            gtfs_type = :Email,
            alternative_types = [],
        ),
        (
            field = :attribution_phone,
            gtfs_type = :PhoneNumber,
            alternative_types = [],
        ),
    ],
)
