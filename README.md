<!-- README.md is generated from README.Rmd. Please edit that file -->
[![Build Status](https://travis-ci.org/mpadge/bikedata.svg)](https://travis-ci.org/mpadge/bikedata) [![Build status](https://ci.appveyor.com/api/projects/status/github/mpadge/bikedata?svg=true)](https://ci.appveyor.com/project/mpadge/bikedata) [![codecov](https://codecov.io/gh/mpadge/bikedata/branch/master/graph/badge.svg)](https://codecov.io/gh/mpadge/bikedata) [![Project Status: Active](http://www.repostatus.org/badges/latest/active.svg)](http://www.repostatus.org/#active) [![CRAN\_Status\_Badge](http://www.r-pkg.org/badges/version/bikedata)](http://cran.r-project.org/web/packages/bikedata)

bikedata
========

The `bikedata` package aims to enable ready importing of historical trip data from all public bicycle hire systems which provide data, and will be expanded on an ongoing basis as more systems publish open data. Cities and names of associated public bicycle systems currently included, along with numbers of bikes and of docking stations, are:

| City                     | Hire Bicycle System                                                   | Number of Bicycles | Number of Docking Stations |
|--------------------------|-----------------------------------------------------------------------|--------------------|----------------------------|
| London, U.K.             | [Santander Cycles](https://tfl.gov.uk/modes/cycling/santander-cycles) | 13,600             | 839                        |
| New York City NY, U.S.A. | [citibike](https://www.citibikenyc.com/)                              |  7,000             | 458                        |
| Chicago IL, U.S.A.       | [Divvy](https://www.divvybikes.com/)                                  |  5,837             | 576                        |
| Washingon DC, U.S.A.     | [Capital BikeShare](https://www.capitalbikeshare.com/)                |  4,457             | 406                        |
| Boston MA, U.S.A.        | [Hubway](https://www.thehubway.com/)                                  |  1,461             | 158                        |
| Los Angeles CA, U.S.A.   | [Metro](https://bikeshare.metro.net/)                                 |  1,000             |  65                        |
| Philadelphia PA, U.S.A.  | [Indego](https://www.rideindego.com)                                  |    600             |  60                        |

These data include the places and times at which all trips start and end. Some systems provide additional demographic data including years of birth and genders of cyclists.

The following provides a brief overview of package functionality. For more detail, see the [vignette](https://mpadge.github.io/bikedata/articles/bikedata.html).

-   [1 Installation](#installation)
-   [2 Usage](#usage)
    -   [2.1 Filtering trips by dates, times, and weekdays](#dates-times)
    -   [2.2 Filtering trips by demographic characteristics](#demography)

------------------------------------------------------------------------

<a name="installation"></a>1 Installation
--------------

Currently a development version only which can be installed with the following command.

``` r
devtools::install_github("mpadge/bikedata")
```

and then loaded the usual way

``` r
library (bikedata)
```

<a name="usage"></a>2 Usage
-------

Data may downloaded for a particular city and stored in an `SQLite3` database with the simple command,

``` r
store_bikedata (city = 'nyc', bikedb = 'bikedb', dates = 201601:201603)
# [1] 2019513
```

where the `bikedb` parameter provides the name for the database, and the optional argument `dates` can be used to specify a particular range of dates (Jan-March 2016 in this example). The `store_bikedata` function returns the total number of trips added to the specified database. The primary objects returned by the `bikedata` packages are 'trip matrices' which contain aggregate numbers of trips between each pair of stations. These are extracted from the database with:

``` r
tm <- bike_tripmat (bikedb = 'bikedb')
dim (tm); format (sum (tm), big.mark = ',')
```

    #> [1] 518 518
    #> [1] "2,019,513"

During the specified time period there were just over 2 million trips between 518 bicycle docking stations. Note that the associated databases can be very large, particularly in the absence of `dates` restrictions, and extracting these data can take quite some time.

Data can also be aggregated as daily time series with

``` r
bike_daily_trips (bikedb = 'bikedb')
```

    #> # A tibble: 87 x 2
    #>          date numtrips
    #>         <chr>    <dbl>
    #>  1 2016-01-01    11172
    #>  2 2016-01-02    14794
    #>  3 2016-01-03    15775
    #>  4 2016-01-04    19879
    #>  5 2016-01-05    18326
    #>  6 2016-01-06    24922
    #>  7 2016-01-07    28215
    #>  8 2016-01-08    29131
    #>  9 2016-01-08    21140
    #> 10 2016-01-10    14481
    #> # ... with 77 more rows

A summary of all data contained in a given database can be produced as

``` r
bike_summary_stats (bikedb = 'bikedb')
#>    num_trips num_stations          first_trip       last_trip latest_files
#> ny  2019513          518 2016-01-01 00:00    2016-03-31 23:59        FALSE
```

The final field, `latest_files`, indicates whether the files in the database are up to date with the latest published files.

<a name="dates-times"></a>2.1 Filtering trips by dates, times, and weekdays
-------

Trip matrices can be constructed for trips filtered by dates, days of the week, times of day, or any combination of these. The temporal extent of a `bikedata` database is given in the above `bike_summary_stats()` function, or can be directly viewed with

``` r
bike_datelimits (bikedb = 'bikedb')
```

    #>              first               last 
    #> "2016-01-01 00:00" "2016-03-31 23:59"

Additional temporal arguments which may be passed to the `bike_tripmat` function include `start_date`, `end_date`, `start_time`, `end_time`, and `weekday`. Dates and times may be specified in almost any format, but larger units must always precede smaller units (so years before months before days; hours before minutes before seconds). The following examples illustrate the variety of acceptable formats for these arguments.

``` r
tm <- bike_tripmat ('bikedb', start_date = "20160102")
tm <- bike_tripmat ('bikedb', start_date = 20160102, end_date = "16/02/28")
tm <- bike_tripmat ('bikedb', start_time = 0, end_time = 1) # 00:00 - 01:00
tm <- bike_tripmat ('bikedb', start_date = 20160101, end_date = "16,02,28",
                 start_time = 6, end_time = 24) # 06:00 - 23:59
tm <- bike_tripmat ('bikedb', weekday = 1) # 1 = Sunday
tm <- bike_tripmat ('bikedb', weekday = c('m', 'Th'))
tm <- bike_tripmat ('bikedb', weekday = 2:6,
                    start_time = "6:30", end_time = "10:15:25")
```

<a name="demography"></a>2.2 Filtering trips by demographic characteristics
-------

Trip matrices can also be filtered by demographic characteristics through specifying the three additional arguments of `member`, `gender`, and `birth_year`. `member = 0` is equivalent to `member = FALSE`, and `1` equivalent to `TRUE`. `gender` is specified numerically such that values of `2`, `1`, and `0` respectively translate to female, male, and unspecified. The following lines demonstrate this functionality

``` r
sum (bike_tripmat ('bikedb', member = 0))
sum (bike_tripmat ('bikedb', gender = 'female'))
sum (bike_tripmat ('bikedb', weekday = 'sat', birth_year = 1980:1990,
                   gender = 'unspecified'))
```
