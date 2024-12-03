String fetchStoresQuery() {
  return '''
    query {
      getStores(configId: "2EF21B71E41C4730B6046409F979CC17") {
        name
        promotionBanner
        announcement
        darkTheme
        storeConfig {
          name
          shortDescription
          storeImage
          storeId
          csBunit {
            csBunitId
            value
            name
          }
          storeTimings {
            startTime
            endTime
            isMonday
            isTuesday
            isWednesday
            isThursday
            isFriday
            isSaturday
            isSunday
          }
          storeHolidays {
            name
            holidayDate
          }
        }
      }
    }
  ''';
}
