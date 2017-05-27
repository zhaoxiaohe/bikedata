context ("database stats")

require (testthat)

bikedb <- system.file ('db', 'testdb.sqlite', package = 'bikedata')

test_that ('can not read all data', {
               expect_error (trips <- bike_tripmat (bikedb),
                             'Calls to tripmat must specify city')
               expect_error (trips <- bike_tripmat (bikedb, city = 'aa'),
                             'city aa not represented in database')
})

test_that ('dplyr read db', {
               db <- dplyr::src_sqlite (bikedb, create = F)
               trips <- dplyr::collect (dplyr::tbl (db, 'trips'))
               expect_equal (dim (trips), c (1198, 11))
               nms <- c ("id", "city", "trip_duration", "start_time",
                         "stop_time", "start_station_id", "end_station_id",
                         "bike_id", "user_type", "birth_year", "gender")
               expect_equal (names (trips), nms)
})

test_that ('latest files', {
               x <- bike_latest_files (bikedb)
               expect_true (all (!x))
               expect_equal (length (x), 6)
})

test_that ('date limits', {
               x <- bike_datelimits (bikedb)
               expect_is (x, 'character')
               expect_length (x, 2)
})

test_that ('db stats', {
               db_stats <- bike_summary_stats (bikedb)
               expect_is (db_stats, 'data.frame')
               expect_equal (names (db_stats), c ('num_trips', 'num_stations',
                                                  'first_trip', 'last_trip',
                                                  'latest_files'))
               expect_equal (dim (db_stats), c (7, 5))
               expect_equal (rownames (db_stats), c ('all', 'bo', 'ch', 'dc',
                                                     'la', 'lo', 'ny'))
               expect_true (sum (db_stats$num_trips) == 2396)
               expect_true (sum (db_stats$num_stations) == (2 * 2186))
})